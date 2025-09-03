/* 
 * Name: AceCoverageUtil 
 * Description: Utilities to retrieve coverage information on behalf
 *				of a user.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
public class AceCoverageUtil {

	public enum CoverageMode { DIRECT_ACCOUNT_COVERAGE , 
								INDIRECT_ACCOUNT_COVERAGE , 
								DIRECT_CONTACT_COVERAGE ,
								INDIRECT_CONTACT_COVERAGE }
								
//  ============================================================================
//  Method:	getCoverage
//
//  Desc:	Retrieves the Ids corresponding to the Accounts or Contacts covered
//			the specified User's Employee, depending on the mode specified:
//			* DIRECT ACCOUNT COVERAGE - all Account Ids directly covered by
//			  Employee, via Account Coverage records
//			* INDIRECT ACCOUNT COVERAGE - all the above Account Ids, plus those
//			  with one or more Contacts covered by Employee via Contact Coverage
//			  records
//			* DIRECT CONTACT COVERAGE - all Contact Ids covered by Employee via
//			  Contact Coverage records
//			* INDIRECT CONTACT COVERAGE - all Contact Ids belonging to Accounts
//			  covered by Employee via Account Coverage records
//			Records can also be filtered by Role (comma-separated string) and by 
//			Active status.
//
//	Args:	userId 			- the UserId (Null to use current context user).
//			mode			- the Coverage Mode (per above).
//			coverageRole	- Comma-separated string denoting role(s) to filter
//							  on (Null for no coverage filter).
//			bActiveOnly		- True to retrieve Active Coverage records only, False
//							  to return all Coverage records (default : True).
//
//	Return:	List of lists of covered Ids. 
//  ============================================================================                        
	public static List<Id[]> getCoverage ( Id userId , CoverageMode mode ,
											String coverageRole ) {
		return getCoverage ( userId , '' + mode , coverageRole , True );
	}
	
	public static List<Id[]> getCoverage ( Id userId , CoverageMode mode ,
											String coverageRole ,
											Boolean bActiveOnly ) {
		return getCoverage ( userId , '' + mode , coverageRole , bActiveOnly );
	}
	
	public static List<Id[]> getCoverage ( Id userId , String mode ,
											String coverageRole ) {
		return getCoverage ( userId , mode , coverageRole , True );							
	}

	public static List<Id[]> getCoverage ( Id userId , String mode ,
											String coverageRole ,
											Boolean bActiveOnly ) {

		if ( userId == Null ) {
			userId = UserInfo.getUserId ();
		}

//		Build the common query clause.
//		------------------------------		
		String whereClause = 'Employee__r.User__c = \'' + userId + '\'';
		if ( coverageRole != Null ) {
			whereClause += ' and Role__c in ( ' 
									+ AceUtil.concatList ( coverageRole.split ( ',' ) , ' , ' , True )
									+ ' )';
		}
		if ( bActiveOnly ) {
			whereClause += ' and Inactive__c = \'false\'';
		}
		String ccWhereClause = whereClause + ' and Contact__c != Null and Contact__r.ST_Inactive__c = False';
		String acWhereClause = whereClause + ' and Account__c != Null and Account__r.ST_Inactive__c = False';

		List<Set<Id>> covIdSetList = new List<Set<Id>> {};
		
		String startName;
		
		if ( mode == '' + CoverageMode.DIRECT_ACCOUNT_COVERAGE 
				|| mode == '' + CoverageMode.INDIRECT_ACCOUNT_COVERAGE
				|| mode == '' + CoverageMode.INDIRECT_CONTACT_COVERAGE ) {
					
//			Grab all Account coverages.
//			---------------------------
			startName = Null;
			for ( ; ; ) {
				SObjectPage sobjPage = AceSObject.getSObjectPage ( 'Account_Coverage__c' , 
																	acWhereClause ,
																	'Account__r.Name' , startName , 
																	AceUtil.MAX_COLLECTION_SIZE ,
																	new String[] { 'Account__c' }
																);
				if ( sobjPage.SObjectList.isEmpty () ) {
					break;
				}
				for ( SObject sobj : sobjPage.SObjectList ) {
					Id acctId = String.valueOf ( AceUtil.getSObjFld ( sobj , 'Account__c' ) );
					AceUtil.setListAdd ( covIdSetList , acctId , True );
				}

				startName = sobjPage.NextKey;
				if ( startName == Null ) {
					break;
				}
			}
		}
		
		if ( mode == '' + CoverageMode.INDIRECT_ACCOUNT_COVERAGE 
				|| mode == '' + CoverageMode.DIRECT_CONTACT_COVERAGE ) {

//			Constrain the Contact Coverage query if we are looking for Indirect Account
//			coverage (Accounts related to covered Contacts).
//			----------------------------------------------------------------------------
			if ( mode == '' + CoverageMode.INDIRECT_ACCOUNT_COVERAGE ) { 
				String extraWhereClause = mkInQueryClause ( 'Contact__r.AccountId' , covIdSetList , False ); 
				ccWhereClause += ' and ' + extraWhereClause;
			}
			if ( mode == '' + CoverageMode.INDIRECT_CONTACT_COVERAGE ) {
				covIdSetList = new List<Set<Id>> {};
			}

//			Grab the (possibly constrained) Contact coverages.
//			--------------------------------------------------	
			startName = Null;
			for ( ; ; ) {
				SObjectPage sobjPage = AceSObject.getSObjectPage ( 'Contact_Coverage__c' , 
																	ccWhereClause ,
																	'Contact__r.Name' , startName , 
																	AceUtil.MAX_COLLECTION_SIZE ,
																	new String[] { 'Contact__c , Contact__r.AccountId' }
																);
				if ( sobjPage.SObjectList.isEmpty () ) {
					break;
				}
				for ( SObject sobj : sobjPage.SObjectList ) {
					
					if ( mode == '' + CoverageMode.INDIRECT_ACCOUNT_COVERAGE ) {
						Id acctId = String.valueOf ( AceUtil.getSObjFld ( sobj , 'Contact__r.AccountId' ) );
						AceUtil.setListAdd ( covIdSetList , acctId , True );
					}
					else {
						Id contId = String.valueOf ( AceUtil.getSObjFld ( sobj , 'Contact__c' ) );
						AceUtil.setListAdd ( covIdSetList , contId , True );
					}
				}
				
				startName = sobjPage.NextKey;
				if ( startName == Null ) {
					break;
				}
			}
		}

		else if ( mode == '' + CoverageMode.INDIRECT_CONTACT_COVERAGE ) {
			
//			Indirect Contact coverage - grab all Contacts associated with the covered Accounts.
//			-----------------------------------------------------------------------------------
			String contWhereClause = mkInQueryClause ( 'AccountId' , covIdSetList , True ); 
			covIdSetList = new List<Set<Id>> {};
			
//			Grab the (possibly constrained) Contact coverages.
//			--------------------------------------------------	
			startName = Null;
			for ( ; ; ) {
				SObjectPage sobjPage = AceSObject.getSObjectPage ( 'Contact' , 
																	contWhereClause ,
																	'Name' , startName , 
																	AceUtil.MAX_COLLECTION_SIZE ,
																	new String[] { 'Id' }
																);
				if ( sobjPage.SObjectList.isEmpty () ) {
					break;
				}
				for ( SObject sobj : sobjPage.SObjectList ) {
					Id contId = String.valueOf ( AceUtil.getSObjFld ( sobj , 'Id' ) );
					AceUtil.setListAdd ( covIdSetList , contId , True );
				}
				
				startName = sobjPage.NextKey;
				if ( startName == Null ) {
					break;
				}
			}
		}
		
//		Now assemble the Id set list into a list of lists.
//		--------------------------------------------------
		List<Id[]> coveredIdListList = new List<Id[]> {};
		for ( Set<Id> idSet : covIdSetList ) {
			Id[] idList = new List<Id> ( idSet ); 
			coveredIdListList.add ( idList );
		}
		
		return coveredIdListList;
	}
	
//  ============================================================================
//  Method:	mkInQueryClause
//
//  Desc:	Creates a query clause from the specified SObject field name and
//			list of lists of Ids, of one of the following form:
//			(
//				sobjFld in ( 'Id' , 'Id' , ... ) or 
//				sobjFld in ( 'Id' , 'Id' , ... ) or
//				...
//			)
//			...or...
//			(
//				sobjFld not in ( 'Id' , 'Id' , ... ) and
//				sobjFld not in ( 'Id' , 'Id' , ... ) and
//				...
//			)
//
//	Args:	sobjFld		- the SObject field name.
//			idListList	- the list of lists of Ids.
//			bIn			- True to use 'in'; False to use 'not in'.
//
//	Return:	The resulting query clause, suitable for inclusion in a dynamic
//			SOQL query. 
//
//	Vars:	mkInQueryClause ( sobjFld , strListList )
//			- Calls mkInQueryClause ( sobjFld , strListList , True )
//			mkInQueryClause ( sobjFld , strSetList , bIn )
//			- Converts strSetList to strListList
//			- Calls mkInQueryClause ( sobjFld , strListList , bIn )
//  ============================================================================
	public static String mkInQueryClause ( String sobjFld , List<Id[]> idListList ) {
		return mkInQueryClause ( sobjFld , idListList , True );
	}
	
	public static String mkInQueryClause ( String sobjFld , List<Set<Id>> idSetList , Boolean bIn ) {

		List<Id[]> idListList = new List<Id[]> {};
		for ( Set<Id> idSet : idSetList ) {
			idListList.add ( new List<Id> ( idSet ) );
		}
		return mkInQueryClause ( sobjFld , idListList , bIn );
	}
	                     
	public static String mkInQueryClause ( String sobjFld , List<Id[]> idListList , Boolean bIn ) {
		
		if ( idListList == Null || idListList.isEmpty () ) {
			return '';
		}

		String[] qryClauseList = new String[] {};
		for ( Id[] idList : idListList ) {
			if ( !idList.isEmpty () ) {
				qryClauseList.add ( sobjFld 
									+ ( bIn ? ' in ( ' : ' not in ( ' )
									+ AceUtil.concatList ( idList , ' , ' , True ) 
									+ ' )'
								);
			}
		}
		return '( ' + AceUtil.concatList ( qryClauseList , ( bIn ? ' or ' : ' and ' ) ) + ' )';
	}
}