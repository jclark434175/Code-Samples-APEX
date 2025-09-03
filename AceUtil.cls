/*
 * Name:        AceUtil
 *
 * Description: Utility methods, etc., in support of ACE web services.
 *               
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM.
 */

public class AceUtil {

    private static String REGULAR_GRP_TYPE = 'Regular';
    private static String ROLE_GRP_TYPE = 'Role';
    
    public static Integer MAX_COLLECTION_SIZE = 1000; 
    
    public static String TASK_COMPLETED_STATUS = 'Completed';

//  ============================================================================
//  Method: concatList
//
//  Desc:   Utility to concatenate the message strings contained within the
//          specified list of Database.Errors into a single string, separated
//          by the specified delimiter.
//     
//  Return: The concatenated string.
//  ============================================================================                    
    public static String concatList ( List<Database.Error> errList , String delim ) {
        
        String concatStr = '';
        for ( Integer i = 0 ; i < errList.size () ; i++ ) {
            concatStr += ( i == 0 ? '' : delim ) + errList[ i ].getMessage ();
        }
        return concatStr;
    }
    
//  ============================================================================
//  Method: concatList
//
//  Desc:   Utility to concatenate the specified list of strings into a single
//			string, separated by the specified delimiter and with each component
//			surrounded by single quotes, if desired.
//     
//  Return: The concatenated string.
//  ============================================================================                    
	public static String concatList ( String[] strList , String delim , Boolean bUseQuotes ) {
		if ( strList.isEmpty () ) {
			return '';
		}
		if ( bUseQuotes ) {
			return '\'' + concatList ( strList , '\'' + delim + '\'' ) + '\'';
		}
		else {
			return concatList ( strList , delim );
		}
	}
	
	public static String concatList ( String[] strList , String delim ) {
		String concatStr = '';
		for ( Integer i = 0 ; i < strList.size () ; i++ ) {
			concatStr += ( i == 0 ? '' : delim ) + strList[ i ];
		}
		return concatStr;
	}

//  ============================================================================
//  Method: mkPageQryClause
//
//  Desc:   Utility to create the SOQL query clause to support retrieving a
//			page of records from the database.
//     
//  Return: The query clause.
//  ============================================================================                    
	public static String mkPageQryClause ( Boolean bAndClause , String key , String value ) {
		String qryClause = '';
		if ( value != Null ) {
			qryClause = ( bAndClause ? 'and ' : 'where ' );
			qryClause += key + ' >= \'' + value + '\' ';
		}
		
		return qryClause;
	}

//  ============================================================================
//  Method: getParentIdTree
//
//  Desc:   Utility to traverse the specified Id-to-ParentIdSet map, starting
//		  with the specified Id and recursively working upward to generate a
//		  set of the Id's parent/grandparent/... Ids.
//	   
//  Return: The set of parent/... Ids - INCLUDING THE ORIGINAL SPECIFIED ID.
//  ============================================================================					
	private static Set<Id> getParentIdTree ( Map<Id , Set<Id>> parentIdsById , Id myId ) {
		Set<Id> treeIdSet = new Set<Id> { myId };
		Set<Id> parentIdSet = parentIdsById.get ( myId );
		if ( parentIdSet != Null ) {
			treeIdSet.addAll ( parentIdSet );
			for ( Id pid : parentIdSet ) {
				treeIdSet.addAll ( getParentIdTree ( parentIdsById , pid ) );
			}
		} 

		return treeIdSet;
	}

//  ============================================================================
//  Method: getUserGroups
//
//  Desc:   Function to determine the group membership of the specified userId.
//		  Traverses the group hierarchy to include 'parent' groups, not only
//		  of the userId's group membership but also of the specified roleId's
//		  pseudo-group.
//	   
//  Return: Set of group Ids representing the membership as described above.
//  ============================================================================					
	public static Set<Id> getUserGroups ( Id userId , Id roleId ) {
		
		Set<Id> userGrpIdSet = new Set<Id> {};

//	  Grab the Groups we're interested in:
//	  * The specified Role's pseudo-Group.
//	  * All "Regular" Groups.
//	  ------------------------------------
		Map<Id , Group> allGrpById = new Map<Id , Group> {};
		Id roleGrpId;
		for ( Group grp : [select Id , RelatedId , Type , Name from Group
							where Type = :REGULAR_GRP_TYPE
							or ( Type = :ROLE_GRP_TYPE and RelatedId = :roleId )] 
					) {
			if ( grp.Type == ROLE_GRP_TYPE ) {
				roleGrpId = grp.Id;
			}
			allGrpById.put ( grp.Id , grp );
		}
	
//	  Grab the GroupMembers we're interested in:
//	  * GroupMembers which are the specified userId.
//	  * GroupMembers which are Regular Groups themselves.
//	  ---------------------------------------------------
		Map<Id , Set<Id>> parentGIdsByGId = new Map<Id , Set<Id>> {};
		for ( GroupMember gm : [select Id , GroupId , UserOrGroupId from GroupMember
								where UserOrGroupId = :userId
								or UserOrGroupId in :allGrpById.keySet ()]
						) {
			if ( gm.UserOrGroupId != userId 
					&& allGrpById.get ( gm.UserOrGroupId ).Type == REGULAR_GRP_TYPE ) {
						
//			  This is a group belonging to a group.
//			  -------------------------------------
				if ( !parentGIdsByGId.containsKey ( gm.UserOrGroupId ) ) {
					parentGIdsByGId.put ( gm.UserOrGroupId , new Set<Id> {} );
				}
				parentGIdsByGId.get ( gm.UserOrGroupId ).add ( gm.GroupId );
			}
			else if ( allGrpById.containsKey ( gm.GroupId ) ) {
				
//			  This is a group that our user belongs to.
//			  -----------------------------------------			   
				userGrpIdSet.add ( gm.GroupId );
			}
		}

//	  Now go thru and grab the groups we're interested in.
//	  ----------------------------------------------------
		Set<Id> startingGrpSet = new Set<Id> ( userGrpIdSet );
		startingGrpSet.add ( roleGrpId );
		for ( Id gid : startingGrpSet ) {
			userGrpIdSet.addAll ( getParentIdTree ( parentGIdsByGId , gid ) );
		}

//	  Finally, strip out the user's Role pseudo-group.
//	  ------------------------------------------------
		userGrpIdSet.remove ( roleGrpId );
		
		return userGrpIdSet;
	}

//  ============================================================================
//  Method: setListAdd
//
//  Desc:   Utility function to add the specified element (Id) to the specified
//          list of sets of elements (Ids again).  Calls the 'set' version of 
//          this function, which does all the work.
//       
//  Return: 1 if the Id was added ; 0 otherwise.
//          The list of sets of elements is modified in situ.
//  ============================================================================                    
    public static Integer setListAdd ( List<Set<Id>> idSetList , Id myId , Boolean bUniq ) {
        return setListAdd ( idSetList , new Set<Id> { myId } , bUniq );
    }

//  ============================================================================
//  Method: setListAdd
//
//  Desc:   Utility function to add the specified set of elements (Ids) to the
//          specified list of sets of elements (Ids again).
//       
//  Return: The number of elements added.
//          The list of sets of elements is modified in situ.
//  ============================================================================                    
    public static integer setListAdd ( List<Set<Id>> idSetList , Set<Id> myIdSet , Boolean bUniq ) {

        Integer myIdSetSize = myIdSet.size ();
        if ( myIdSetSize == 0 ) {
            return 0;
        }

//      If we're checking for uniqueness, go through the list of sets, finding
//      any elements that exist in both these sets and the input set and 
//      removing them from the input set.
//      Clone the input set first to avoid nasty surprises in the caller!
//      ----------------------------------------------------------------------
        if ( bUniq ) {
            myIdSet = myIdSet.clone ();
            for ( Set<Id> listSet : idSetList ) {
                myIdSet.removeAll ( listSet );
            }
            myIdSetSize = myIdSet.size ();
            if ( myIdSetSize == 0 ) {
                return 0;
            }
        }
        
//      Go through the list of sets, finding the first set that has room for
//      our ID set.
//      --------------------------------------------------------------------
        Set<Id> idSet = Null;
        for ( Set<Id> listSet : idSetList ) {
            if ( listSet.size () <= MAX_COLLECTION_SIZE - myIdSetSize ) {
                idSet = listSet;
                break;
            }
        }
                 
        if ( idSet == Null ) {
            idSet = new Set<Id> {};
            idSetList.add ( idSet );
        }
        
        idSet.addAll ( myIdSet );
        return myIdSetSize;
    }

//  ============================================================================
//  Method: setListFind
//
//  Desc:   Utility function to locate the specified Id in the specified
//          list of sets of Ids.
//       
//  Return: True if the Id is found; False otherwise.
//  ============================================================================                    
    public static Boolean setListFind ( List<Set<Id>> idSetList , Id findId ) {
    
        for ( Set<Id> idSet : idSetList ) {
            if ( idSet.contains ( findId ) ) {
                return True;
            }
        }
        return False;
    }


//  ============================================================================
//  Method:	getSObjFld
//
//  Desc:	Grabs the value of the field with the specified name from the
//			specified SObject.  If the field is a relationship field (e.g.
//			'Contact.Phone', this method recurses into the relationship object
//			to get the field value.
//
//	Args:	sobj	- the SObject
//			fldName	- the field name
//
//	Return: The field value (blank string if not found).
//  ============================================================================                        
	public static Object getSObjFld ( SObject sobj , String fldName ) {
		if ( !fldName.contains ( '.' ) ) {
			return sobj.get ( fldName );
		}
		else {
			Pattern fldPtrn = Pattern.compile ( '^([^.]+)\\.(.*)$' );
			Matcher fldMatcher = fldPtrn.matcher ( fldName );
			if ( !fldMatcher.matches () ) {
				return Null;
			}
			else {
				SObject refSobj = sobj.getSObject ( fldMatcher.group ( 1 ) );
				String refFldName = fldMatcher.group ( 2 );
				return ( refSObj == Null ? Null : getSObjFld ( refSobj , refFldName ) );
			}
		}
	}
   
//  ============================================================================
//  Method:	upsertRecord
//
//  Desc:	Updates or inserts the given SObject.
//            
//  Args:	SObject
//
//  Return:	AceWSResult containing results of upsert for the obj.
//  ============================================================================
	public static AceWSResult upsertRecord ( SObject obj ) {
		
		AceWSResult result = new AceWSResult();

//      Upsert the record, remembering failure.
//      ---------------------------------------
        Database.upsertResult uResult;
        try {
            uResult = Database.upsert ( obj , False );
        }
        catch ( Exception e ) {
            result.setResult ( False ,
                                    'Error upserting SObject: [' 
                                    + e.getMessage () + ']' );
            return result;
        }
        
//      Populate the return object with ID of the successfully upserted SObject.
//      ------------------------------------------------------------------------
		Boolean bStatus = True; 
		String msg;          
		if ( !uResult.isSuccess () ) {
			bStatus = False;
			msg = concatList ( uResult.getErrors () , ' ; ' );
		}
		else {
			msg = obj.Id;
		}
		result.setResult ( bStatus , msg );
        
        return result;
    }
        
//	============================================================================
//	Method:	upsertRecords
//
//  Desc:   Updates or inserts the given array of SObject.
//             
//  Args:   Array of SObjects
//			bBatch - flag to indicate whether to do the upsert in one
//			         single batch or individually by record.
//			         If bBatch is True, falls thru to single-arg
//			         variant of this method.
//
//  Return:	AceWSResultList containing results of upsert for each obj.
//  ============================================================================
	public static AceWSResultList upsertRecords ( SObject[] sObjects , Boolean bBatch ) {
		if ( bBatch == True ) {
			return upsertRecords ( sObjects );
		}
		else {
			AceWSResultList resultList = new AceWSResultList ( sObjects.size () , False );
			for ( Integer idx = 0 ; idx < sObjects.size () ; idx++ ) {
				SObject obj = sObjects[ idx ];
				AceWSResult result = upsertRecord ( obj );
				resultList.setResult ( idx , result.bSuccess , result.statusMsg );
			}
			return resultList;
		}
	}
	
    public static AceWSResultList upsertRecords(SObject[] sObjects ) {

        AceWSResultList resultList = new AceWSResultList ( sObjects.size () , False );

//      Upsert the records, remembering failures.
//      -----------------------------------------
        Database.upsertResult[] uResultList;
        try {
            uResultList = Database.upsert ( sObjects , False );
        }
        catch ( ListException e ) {
            resultList.setResult ( False , 
                                    'Duplicate SObject Ids in input list - aborting entire job.' );
            return resultList;
        }
        catch ( Exception e ) {
            resultList.setResult ( False ,
                                    'Error upserting SObject list: [' 
                                    + e.getMessage () + '] - aborting entire job.' );
            return resultList;
        }

        
//      Populate the return list with IDs of successfully upserted SObjects.
//      --------------------------------------------------------------------        
        for ( Integer i = 0 ; i < sObjects.Size () ; i++ ) {
            
            Database.upsertResult uResult = uResultList[ i ];
            Boolean bStatus = True;
            String msg = '';
            
            if ( !uResult.isSuccess () ) {
                bStatus = False;
                msg = concatList ( uResult.getErrors () , ' ; ' );
            }
            else {
                msg = sObjects[ i ].Id;
            }
            resultList.setResult ( i , bStatus , msg );     
        }
        
        return resultList;
    }
    
//  ============================================================================
//  Method:	updateRecords
//
//  Desc:	Updates the given array of objects    
//      
//  Args:	Array of sObjects
//
//  Return:	AceWSResultList containing result of update.                        
//  ============================================================================    
    public static AceWSResultList updateRecords(SObject[] sObjects) {
        return upsertRecords ( sObjects );
    }
    
//  ============================================================================
//  Method:	deleteRecords
//
//  Desc:	Deletes the given array of objects   
//       
//  Args:	Array of sObjects
//
//  Return:	AceWSResultList containing result of deletion.                    
//  ============================================================================    
    public static AceWSResultList deleteRecords(Id[] sObjIds) {

        AceWSResultList resultList = new AceWSResultList ( sObjIds.size () , False );

//      Delete the records, remembering failures.
//      -----------------------------------------
        Database.deleteResult[] dResultList;
        try {
            dResultList = Database.delete ( sObjIds , False );
        }
        catch ( ListException e ) {
            resultList.setResult ( False , 
                                    'Duplicate SObject Ids in input list - aborting entire job.' );
            return resultList;
        }
        catch ( Exception e ) {
            resultList.setResult ( False ,
                                    'Error deleting SObject list: [' 
                                    + e.getMessage () + '] - aborting entire job.' );
            return resultList;
        }
        
//      Populate the return list with IDs of successfully deleted SObjects.
//      ------------------------------------------------------------------- 
        for ( Integer i = 0 ; i < sObjIds.Size () ; i++ ) {
            Database.deleteResult dResult = dResultList[ i ];
            Boolean bStatus = True;
            String msg = '';
            
            if ( !dResult.isSuccess () ) {
                bStatus = False;
                msg = concatList ( dResult.getErrors () , ' ; ' );
            }   
            else {
                msg = sObjIds[ i ];
            }
            resultList.setResult ( i , bStatus , msg );
        }
        
        return resultList;
    }

//  ============================================================================
//  Method:	getBoolValue
//
//  Desc:	Gets the boolean value of the string value passed in   
//	   
//  Args:	String value - Value of the string
//
//  Return:	Boolean representing the value of the string					
//  ============================================================================
	public static Boolean getBoolValue ( String value ) {		
		return ( value == 'True' );
	} 
	
//  ============================================================================
//  Method:	getMaxCollectionSize
//
//  Desc:	Gets the list size limit based on the number of records passed in.   
//	   
//  Args:	processedRecordCount - Size of the records being processed
//
//  Return:	Integer containing the limit size of how big a list can be					
//  ============================================================================
	public static Integer getMaxCollectionSize ( Integer processedRecordCount ) {
		
		return  ( ( ( Math.min ( processedRecordCount , 200 ) - 1 ) / 40 ) + 1 ) 
					* MAX_COLLECTION_SIZE;
	}

}