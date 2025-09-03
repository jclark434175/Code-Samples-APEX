

public class featureCacheUtil {

//	Constants.
//	----------
	public static final String ERR_NONCORE_FEATURE_NO_UGPR_LINK_REF = 'Non-core Feature has no User/Group/Profile/Role Link reference.';
	public static final String ERR_NONCORE_FEATURE_BAD_CORE_REF = 'Non-core Feature has invalid Core Feature reference.';
	public static final String ERR_NONCORE_FEATURE_NONCORE_CORE_REF = 'Non-core Feature has Core Feature reference to non-core Feature.';
	public static final String ERR_NONCORE_FEATURE_BADNAME_CORE_REF = 'Non-core Feature has Core Feature reference to Feature with different name.';
	public static final String ERR_ENTITLED_FEATURE_PUBLIC_CORE_REF = 'Entitled Feature has Core Feature reference to public Feature.';
	public static final String ERR_CORE_FEATURE_UGPR_LINK_REF = 'Core Feature has User/Group/Profile/Role Link reference.';
	
	public static final String ERR_SUB_FEATURE_NAME_NOT_DELIMITED = 'Sub-Feature name not delimited by ".".';
	public static final String ERR_SUB_FEATURE_BAD_PARENT_REF = 'Sub-Feature has invalid Parent Feature reference.';
	public static final String ERR_SUB_FEATURE_BADTYPE_PARENT_REF = 'Sub-Feature has Parent Feature reference to Feature of different type.';
	public static final String ERR_SUB_FEATURE_BADNAME_PARENT_REF = 'Sub-Feature has Parent Feature reference to Feature with different name.';
	public static final String ERR_FEATURE_NAME_DELIMITED = 'Main Feature name contains delimiter ".".';
	
	public static final String ERR_DL_NONCORE_FEATURE_NO_CORE_FEATURE = 'Non-core Feature has no corresponding Core Feature.';
	public static final String ERR_DL_SUB_FEATURE_NO_PARENT_FEATURE = 'Sub-Feature has no corresponding Parent Feature.';
	
	public static final String ERR_UGPR_INVALID_USER_ROLE_GRP_PROFILE = 'Feature User/Group/Profile/Role must be linked to only one of: User, Group, Role or Profile.';
	public static final String ERR_UGPR_INVALID_UGPR_TYPE = 'Invalid Feature User/Group/Profile/Role Type.';
	public static final String ERR_UGPR_INVALID_GROUP = 'Invalid Group Id.';
	public static final String ERR_UGPR_NOT_REGULAR_GROUP = 'Feature User/Group/Profile/Role can be linked only to Regular Group.';
	public static final String ERR_UGPR_INVALID_ROLE = 'Invalid Role Id.';
	public static final String ERR_UGPR_INVALID_PROFILE = 'Invalid Profile Id.';		
	public static final String ERR_UGPR_INVALID_USER = 'Invalid User Id.';		
	
	public static final String WILDCARD_STRING = '*';
	public static final String FEATURE_NAME_STRING = 'FeatureName';
	
	public static final String UGPR_NAME_STRING = 'UGPRName';
	public static final String UGPR_TYPE_STRING = 'UGPRType';
	public static final String UGPR_ROLL_UP_ROLE_STRING = 'UGPRRollUpRoleHierarchy';
	
	public static final String UGPR_OVERRIDE_STRING = 'OverrideUGPR';
	public static final String PERMISSIONED_UGPR_STRING = 'PermissionedUGPR';
	
	public static final String USER_STRING = 'USER';
	public static final String GROUP_STRING = 'GROUP';
	public static final String ROLE_STRING = 'ROLE';
	public static final String PROFILE_STRING = 'PROFILE';

	public static final String REGULAR_GROUP_TYPE = 'Regular';
	public static final String ROLE_GROUP_TYPE = 'Role';

//	============================================================================
//	Method:	showQueryStats
//
//	Desc:	Utility to display current SOQL query/query row counts + limits.
//
//	Return:	Nothing.
//	============================================================================	
	public static void showQueryStats ( String tag ) {
		System.debug ( tag + ' :\n'
						+ ' QUERIES [' + Limits.getQueries () + ']'
						+ '  OF MAX [' + Limits.getLimitQueries() + ']'
						+ '  ; ROWS [' + Limits.getQueryRows () + ']'
						+ '  OF MAX [' + Limits.getLimitQueryRows () + ']'
					); 
	}

//	============================================================================
//	Method:	idTo18Char
//
//	Desc:	Utility to extend the specified Id from 15 chars to 18.
//
//	Return:	The converted Id.
//	============================================================================	
	public static string idTo18Char ( String myId ) {

//		Convert the Id only if it is exactly 15 chars long.
//		---------------------------------------------------
		if ( myId.length() != 15 ) {
			return myId;
		}
		
		String[] capLetterList = new String[] { 'A' , 'B' , 'C' , 'D' , 'E' , 'F' , 'G' , 'H' , 'I' , 'J' , 
												'K' , 'L' , 'M' , 'N' , 'O' , 'P' , 'Q' , 'R' , 'S' , 'T' , 
												'U' , 'V' , 'W' , 'X' , 'Y' , 'Z' };
		Set<String> capLetterSet = new Set<String> ( capLetterList );
		
//		Go thru the Id, computing the extra 3 chars.
//		--------------------------------------------
		for ( Integer i = 0 ; i < 3 ; i++ ) {
			Integer charOffset = 0;
			for ( Integer j = 0 ; j < 5 ; j++ ) {
				String s = myId.substring ( (i * 5) + j , (i * 5) + j + 1 );
//				System.debug ( 'i [' + i + '] j [' + j + '] s [' + s + ']' ); 
				if ( capLetterSet.contains ( s ) ) {
					charOffset += Math.pow ( 2 , j ).intValue ();
				}
			}
			if ( charOffset < 26 ) {
				myId += capLetterList[ charOffset ];
			}
			else {
				myId += charOffset - 26;
			}
		}
		return myId;
		
	}
				
//	============================================================================
//	Method:	mkFeatureExternalId
//
//	Desc:	Utility to build a Feature External Id string from the specified
//			components - Feature Name, UGPRLink Id and UserOverride flag.
//
//	Return:	The External Id.
//	============================================================================	
	public static String mkFeatureExternalId ( String featureName , Id UGPRLinkId , Boolean bOverride ) {
		
		String externalId = featureName;
		
		if ( bOverride == True ) {
			externalId += ':OVERRIDE:' + UGPRLinkId;
		}
		else if ( UGPRLinkId != Null ) {
			externalId += ':PERMISSIONED:' + UGPRLinkId;
		}
		else {
			externalId += ':CORE';
		}
		
		return ( externalId );
	}

//	============================================================================
//	Method:	mkFeatureExternalId
//
//	Desc:	Utility to build a Feature External Id string from the specified
//			components - Feature Name, Feature Type and Feature External Ref 
//			(the latter could be an UGPRLink Id).
//
//	Return:	The External Id.
//	============================================================================	
	public static String mkFeatureExternalId ( String featureName , String featureType , String featureExtRef ) {
			
		String externalId = featureName + ':' + featureType;
		if ( featureExtRef != '' ) {
			externalId += ':' + featureExtRef;
		}
	
		return ( externalId );
	}

//	============================================================================
//	Method:	parseFeatureExternalId
//
//	Desc:	Utility to parse the specified Feature External Id into its 
//			components - Feature Name, Feature Type and External Reference Id.
//
//	Return:	A list containing the parsed-out components.
//	============================================================================	
	public static String[] parseFeatureExternalId ( String externalId ) {
	
		String[] resultList = new String[] {};
		
//		Short-circuit if externalId happens to be blank.
//		------------------------------------------------		
		if ( externalId == Null ) {
			return ( resultList );
		}
		
		if ( externalId.endsWith ( ':CORE' ) ) {
			externalId += ':';
		}
		
		Pattern ptrn = Pattern.compile ( '([^:]+):([^:]+):(.*)' );
		Matcher match = ptrn.matcher ( externalId );
		if ( match.matches () ) {
			resultList.add ( match.group ( 1 ) ) ;
			resultList.add ( match.group ( 2 ) ) ;
			resultList.add ( match.group ( 3 ) ) ;
		}
		
		return ( resultList );
	}

//	============================================================================
//	Method:	pruneChildFeatures
//
//	Desc:	Utility to prune out all members of the specified Feature Name set,
//			whose Parent Feature Names also appear in the set.
//
//	Return:	Nothing.  Input Feature Name set is modified in situ.
//	============================================================================	
	public static void pruneChildFeatures ( Set<String> fNameSet ) {
		
		String[] fNameList = new String[] {};
		for ( String fName : fNameSet ) {
			fNameList.add ( fName );
		}
		fNameList.sort ();
		
		String prevFName = '';
		Set<String> pruneFNameSet = new Set<String> {};
		for ( String fName : fNameList ) {
			if ( prevFName != '' && fName.startsWith ( prevFName + '.' ) ) {
				pruneFNameSet.add ( fName );
			}
			else {
				prevFName = fName;
			}
		}
		fNameSet.removeAll ( pruneFNameSet );
	}
	 
//	============================================================================
//	Method:	getFeatureNameAncestry
//
//	Desc:	Utility to take the specified Feature Name and return a list 
//			consisting of this Name and all its Parent Names (e.g. Name 'a.b.c'
//			returns <'a.b.c' , 'a.b' , 'a'>
//
//	Return:	The list of Feature Names, as described above.
//	============================================================================	
	public static String[] getFeatureNameAncestry ( String featureName ) {
		String[] featureNameList = new String[] {};

		Pattern ptrn = Pattern.compile ( '(.*)\\.[^.]+$' );
		while ( True ) {
			Matcher match = ptrn.matcher ( featureName );
			if ( match.matches () ) {
				featureName = match.group ( 1 );
				featureNameList.add ( featureName );
			}
			else {
				break;
			}
		}
		
		return featureNameList;
	}			
		
//	============================================================================
//	Method:	getFeatureParentName
//
//	Desc:	Utility to return the specified Feature Name's Parent Name, by
//			stripping off the rightmost component of the dot-separated Feature
//			Name.
//
//	Return:	The Parent Name, or blank if the Feature Name has no Parent Name.
//	============================================================================	
	public static String getFeatureParentName ( String featureName ) {
		
		String parentName = '';
		
//		Pick off the rightmost name fragment from the feature name.
//		-----------------------------------------------------------
		Pattern ptrn = Pattern.compile ( '(.*)\\.[^.]+$' );
		Matcher match = ptrn.matcher ( featureName );
		if ( match.matches () ) {
			parentName = match.group ( 1 );
		}
		
		return parentName;			
	}

//	============================================================================
//	Method:	getFeatureRootName
//
//	Desc:	Utility to return the specified Feature Name's Root Name, by
//			stripping off all but the leftmost component of the dot-separated
//			Feature Name.  If the Feature Name is already a Root Name, returns
//			the Name as is.
//
//	Return:	The Root Name.
//	============================================================================	
	public static String getFeatureRootName ( String featureName ) {
		
//		Grab the leftmost name fragment from the feature name.
//		------------------------------------------------------
		Pattern ptrn = Pattern.compile ( '^([^\\.]+)\\..*$' );
		Matcher match = ptrn.matcher ( featureName );
		if ( match.matches () ) {
			return match.group ( 1 );
		}
		else {
			return featureName;
		}
	}

//	============================================================================
//	Method:	getFeatureLeafName
//
//	Desc:	Utility to return the specified Feature Name's Leaf Name, by
//			stripping off all but the rightmost component of the dot-separated
//			Feature Name.  If the Feature Name is a Root Name, returns the Name
//			as is.
//
//	Return:	The Leaf Name.
//	============================================================================	
	public static String getFeatureLeafName ( String featureName ) {
		
//		Grab the rightmost name fragment from the feature name.
//		------------------------------------------------------
		Pattern ptrn = Pattern.compile ( '^.*\\.([^\\.]+)$' );
		Matcher match = ptrn.matcher ( featureName );
		if ( match.matches () ) {
			return match.group ( 1 );
		}
		else {
			return featureName;
		}
	}

//	============================================================================
//	Method:	joinList
//
//	Desc:	Utility to concatenate the specified list of strings into a single
//			string, using the specified delimiter.
//
//	Return:	The concatenated string.
//	============================================================================	
	public static String joinList ( String[] elemList , String delim ) {
		Boolean bStart = True;
		String joinStr = '';
		
		for ( String elem : elemList ) {
			joinStr += ( bStart ? '' : delim ) + elem;
			bStart = False;
		}
		return ( joinStr );
	}	

//	============================================================================
//	Method:	mkObjName
//
//	Desc:	Utility to create a reasonable looking name from the specified 
//			input string, replacing excess with '...' if necessary. 
//		 
//	Return:	The name.
//	============================================================================					
	public static String mkObjName ( String inputName ) {
		if ( inputName.length () > 80 ) {
			inputName = inputName.substring ( 0 , 77 ) + '...';
		}
		return ( inputName );
	}

//	============================================================================
//	Method:	dumpFeature
//
//	Desc:	Utility to System.debug() out the specified Feature record
//			in a readable way. 
//
//	Return:	Nothing.
//	============================================================================	
	public static void dumpFeature ( Feature__c feature ) {
		if ( feature == Null ) {
			System.debug ( 'NULL FEATURE' );
			return;
		}
		System.debug ( 'FEATURE :\n' 
						+ 'Id           : ' + feature.Id + '\n'
						+ 'Name         : ' + feature.Name__c + '\n'
						+ 'Perm Reqd    : ' + feature.Permission_Required__c + '\n'
						+ 'ParentFeature: ' + feature.Parent_Feature__c + '\n'
						+ 'CoreFeature  : ' + feature.Core_Feature__c + '\n'
						+ 'UGPRLink     : ' + feature.Feature_UGPR_Link__c + '\n'
						+ 'UGPROverride : ' + feature.UGPR_Override__c + '\n'
						+ 'ExternalId   : ' + feature.External_Id__c + '\n'					
					);
	}

//	============================================================================
//	Method:	dumpFeature
//
//	Desc:	Utility to System.debug() out the specified LIST OF Feature
//			records in a readable way. 
//
//	Return:	Nothing.
//	============================================================================	
	public static void dumpFeature ( Feature__c[] featureList ) {
		if ( featureList == Null ) {
			System.debug ( 'NULL FEATURE LIST' );
			return;
		}
		for ( Feature__c feature : featureList ) {
			dumpFeature ( feature );
		}
	}
	
//	============================================================================
//	Method:	dumpFeatureCache
//
//	Desc:	Utility to System.debug() out the specified Feature Cache record
//			in a readable way. 
//
//	Return:	Nothing.
//	============================================================================	
	public static void dumpFeatureCache ( Feature_Cache__c fc ) {
		if ( fc == Null ) {
			System.debug ( 'NULL FEATURE CACHE' );
			return;
		}
		System.debug ( 'FEATURE CACHE :\n' 
						+ 'Id      : ' + fc.Id + '\n'
						+ 'UGPRName: ' + fc.UGPR_Name__c + '\n'
						+ 'UGPRType: ' + fc.UGPR_Type__c + '\n'
						+ 'Feature : ' + fc.Feature_Name__c + '\n'
						+ 'AttrName: ' + fc.Attribute_Name__c + '\n'
						+ 'AttrVal : ' + fc.Attribute_Value__c + '\n'
					);
	}

//	============================================================================
//	Method:	dumpFeatureCache
//
//	Desc:	Utility to System.debug() out the specified LIST OF Feature Cache
//			records in a readable way. 
//
//	Return:	Nothing.
//	============================================================================	
	public static void dumpFeatureCache ( Feature_Cache__c[] fcl ) {
		if ( fcl == Null ) {
			System.debug ( 'NULL FEATURE CACHE LIST' );
			return;
		}
		for ( Feature_Cache__c fc : fcl ) {
			dumpFeatureCache ( fc );
		}
	}

//	============================================================================
//	Method:	getFeatureFamilies
//
//	Desc:	Function to get the Features corresponding to the specified Feature
//			Names.  Each name comes with a pair of directives, indicating 
//			whether to get ancestor Features and/or child Features.
//			If the input name/directive map is Null, we get all Features.  
//
//	Return:	A <featureId , Feature> map.
//	============================================================================	
	public static Map<Id , Feature__c> getFeatureFamilies ( Map<String , Boolean[]> featureNameMap ) {
		
		Set<String> ancestorFNameSet = new Set<String> {};
		Set<String> subFNameSet = new Set<String> {};
		String fNameRegexp , latestSubFName;

//		Assemble a list of Feature Names to search for.
//		-----------------------------------------------		
		if ( featureNameMap != Null ) {
			for ( String fName : featureNameMap.keySet () ) {
				Boolean bGetAncestors = featureNameMap.get ( fName )[ 0 ];
				Boolean bGetSubFeatures = featureNameMap.get ( fName )[ 1 ];
				
				ancestorFNameSet.add ( fName );
				if ( bGetAncestors ) {
					
//					Add this Feature's ancestor names to the Ancestor search list.
//					-------------------------------------------------------------- 					
					String[] ancestorFNameList = getFeatureNameAncestry ( fName );
					ancestorFNameSet.addAll ( ancestorFNameList );
				}
				
				if ( bGetSubFeatures ) {
					
//					Add this Feature name to the Sub-feature search list.
//					-----------------------------------------------------			
					subFNameSet.add ( fName );
					latestSubFName = fName;
									
					if ( fNameRegexp != '' ) {
						fNameRegexp += '|';
					}
					fNameRegexp += fName;
				}
			}
		}
		
//		Remove entries in the Sub-Feature Name search list whose parents also 
//		appear in the list - the parent entries suffice.
//		---------------------------------------------------------------------
		pruneChildFeatures ( subFNameSet );
		
		Map<Id , Feature__c> hFeatureById = new Map<Id , Feature__c> {};
		
		if ( subFNameSet.size () > 1 || featureNameMap == Null ) {
			
//			No input Features, or we're getting more than one set of sub-Features.
//			----------------------------------------------------------------------
			hFeatureById = new Map<Id , Feature__c> (
							 [select Id , Name__c , Feature_UGPR_Link__c ,
							 	Core_Feature__c , External_Id__c ,
								Parent_Feature__c , Permission_Required__c ,
								UGPR_Override__c
								from Feature__c]
							);
		}
		else if ( subFNameSet.size () == 1 ) {
			
//			We are getting one single set of sub-Features.
//			----------------------------------------------			
			hFeatureById = new Map<Id, Feature__c> (
							 [select Id , Name__c , Feature_UGPR_Link__c ,
							 	Core_Feature__c , External_Id__c ,
								Parent_Feature__c , Permission_Required__c ,
								UGPR_Override__c
								from Feature__c
								where Name__c like :latestSubFName + '.%' 
								or Name__c in :ancestorFNameSet]
							);
		}
		else {
			
//			We are getting no sub-Features.
//			-------------------------------			
			hFeatureById = new Map<Id, Feature__c> (
							 [select Id , Name__c , Feature_UGPR_Link__c ,
							 	Core_Feature__c , External_Id__c ,
								Parent_Feature__c , Permission_Required__c ,
								UGPR_Override__c
								from Feature__c
								where Name__c in :ancestorFNameSet]
							);
		}
		
//		Now prune the retrieved Features that we're not interested in.
//		--------------------------------------------------------------		
		if ( subFNameSet.size () > 1 ) {

			fNameRegexp = '^(' + fNameRegexp + ')(\\..*)?$';
			Pattern fNamePtrn = Pattern.compile ( fNameRegexp );
	
			for ( Feature__c feature : hFeatureById.values () ) {
				if ( ancestorFNameSet.contains ( feature.Name__c ) ) {
					continue;
				}
				if ( fNamePtrn.matcher ( feature.Name__c ).matches () ) {
					continue;
				}
				
				hFeatureById.Remove ( feature.Id );
			}
		}
				
		return ( hFeaturebyId );
	}

//	============================================================================
//	Method:	deleteFeatureCache
//
//	Desc:	Function to delete all Feature Cache records corresponding to 
//			the specified set of UserIds and/or the specified list of
//			Feature names.
//
//			Works in 100-record chunks to avoid blowing a Governor limit 
//			(at the possible peril of another Governer limit).
//
//	Return:	The number of records deleted.
//	============================================================================	
	public static Integer deleteFeatureCache ( Set<Id> userSet , Set<String> featureNameSet ) {
		
		System.debug ( 'DELETE FEATURE CACHE' );
		System.debug ( '...USER SET : [' + userSet + ']' );
		System.debug ( '...FEATURE SET : [' + featureNameSet + ']' );
				
		Integer iNumToDelete;
		Integer iTotDeleted = 0;
		Feature_Cache__c[] fcList;
		
		while ( True ) {
			if ( userSet != Null ) {
				if ( featureNameSet != Null ) {
					fcList = [select Id , UGPR_Id__c , UGPR_Name__c , UGPR_Type__c ,
									Feature_Name__c , Attribute_Name__c , Attribute_Value__c 
							from Feature_Cache__c 
							where UGPR_Id__c in :userSet
							and Feature_Name__c in :featureNameSet 
							limit 100];
				}
				else {
					fcList = [select Id , UGPR_Id__c , UGPR_Name__c , UGPR_Type__c ,
									 Feature_Name__c , Attribute_Name__c , Attribute_Value__c 
							from Feature_Cache__c 
							where UGPR_Id__c in :userSet
							limit 100];
				}
			}
			else {
				if ( featureNameSet != Null ) {
					fcList = [select Id , UGPR_Id__c , UGPR_Name__c , UGPR_Type__c ,
									Feature_Name__c , Attribute_Name__c , Attribute_Value__c 
							from Feature_Cache__c 
							where Feature_Name__c in :featureNameSet 
							limit 100];
				}
				else {
					fcList = [select Id , UGPR_Id__c , UGPR_Name__c ,UGPR_Type__c ,
									Feature_Name__c , Attribute_Name__c , Attribute_Value__c 
							from Feature_Cache__c 
							limit 100];
				}
			}
			
			iNumToDelete = fcList.size ();
			iTotDeleted += iNumToDelete;
			if ( iNumToDelete > 0 ) {
				System.debug ( 'ABOUT TO DELETE [' + iNumToDelete + '] FEATURE CACHE RECS :' );
				dumpFeatureCache ( fcList );
				delete fcList;
			}

			if ( iNumToDelete < 100 ) {
				break;
			}
		}
		
		return ( iTotDeleted );
	}

//	============================================================================
//	Method:	rebuildFeatureCache
//
//	Desc:	Big function to rebuild all Feature Cache records corresponding to
//			the specified Feature directives in the input arguments.
//
//			In a nutshell:
//			* Traverses the Feature/Attribute object records, building a list
//			  of Feature Cache records and overlaying where necessary (e.g. an
//			  Attribute hooked to a Feature which has a UGPRLink reference).
//			* Deletes all Feature Cache records associated with the specified 
//			  User Ids/Feature Names.
//			* Inserts the Feature Cache record list we just built.
//
//			This is the function that does all the heavy lifting when a Feature
//			or Attribute is added/changed/deleted in the system. 
//		 
//	Return:	Nothing.
//	============================================================================					
	public static void rebuildFeatureCache ( Map<String , Boolean[]> familyByFName ) { 

		System.debug ( 'RFC : familyByFName [' + familyByFName + ']' );
		
//		Build an <Id , Feature> map of Features involved in this rebuild.
//		-----------------------------------------------------------------
		Map<Id , Feature__c> featureById = getFeatureFamilies ( familyByFName );

//		Get the set of Feature names from our Features, and initialize Attribute lists
//		for each Feature.
//		------------------------------------------------------------------------------
		Set<String> featureNameFamilySet = new Set<String> {};
		Map<Id , Map<String , String>> attrMapByFeat = new Map<Id , Map<String , String>> {};
		
		for ( Feature__c feature : featureById.values () ) {
			featureNameFamilySet.add ( feature.Name__c );
			attrMapByFeat.put ( feature.Id , new Map<String , String> {} );
		}
		System.debug ( 'FEATURE NAME FAMILY SET : [' + featureNameFamilySet + ']' );

//		Organize the family Feature names by root name, and determine each
//		Feature name's parent name.
//		Also, for input Feature names specified with the 'doChildren' flag set,
//		the sub-Feature names will appear in the family name set; pull them out
//		and add them to our input name set.
//		-----------------------------------------------------------------------
		Map<String , String> parentFNameByName = new Map<String , String> {};
		Map<String , String[]> featureNamesByRootName = new Map<String , String[]> {};
		
		Boolean bAllFamilies = False;
		if ( familyByFName == Null ) {
			familyByFName = new Map <String , Boolean[]> {};
			bAllFamilies = True;
		}
		
		Map<String , Set<String>> extraFNamesByBaseFName = new Map<String , Set<String>> {};
		
		for ( String fName : featureNameFamilySet ) {
			parentFNameByName.put ( fName , getFeatureParentName ( fName ) );
			String rootName = getFeatureRootName ( fName );
			if ( !featureNamesByRootName.containsKey ( rootName ) ) {
				featureNamesByRootName.put ( rootName , new String[] {} );
			}
			featureNamesByRootName.get ( rootName ).add ( fName );
			System.debug ( 'ROOT NAME [' + rootName + '] CHILDREN [' + featureNamesByRootName.get ( rootName ) + ']' );
			
			if ( !familyByFName.containsKey ( fName ) ) {
				if ( bAllFamilies == True ) {
					familyByFName.put ( fName , new Boolean[]{ True , True } );
				}
				else {
					for ( String inputFName : familyByFName.keySet () ) {
						if ( fName.startsWith ( inputFName + '.' ) ) {
							
//							Child of one of our input Feature Names.  Grab it for later addition
//							to our map.
//							--------------------------------------------------------------------							
							if ( !extraFNamesByBaseFName.containsKey ( inputFName ) ) {
								extraFNamesByBaseFName.put ( inputFName , new Set<String> {} );
							}
							extraFNamesByBaseFName.get ( inputFName ).add ( fName );
							break;
						}
					}
				}
			}
		}
					
//		Add all the child Feature Names we just found to our original maps.
//		-------------------------------------------------------------------
		for ( String inputFName : extraFNamesByBaseFName.keySet () ) {
			for ( String extraFName : extraFNamesByBaseFName.get ( inputFName ) ) {
				familyByFName.put ( extraFName , familyByFName.get ( inputFName ).clone () );
			}
		}
		
		System.debug ( 'FAMILY BY FNAME : [' + familyByFName + ']' );
		showQueryStats ( 'AFTER FAMILY BY FNAME' );

//		Grab the attributes corresponding to our Feature name set.
//		----------------------------------------------------------
		for ( Attribute__c attr : [select Id , Feature__c , Feature__r.Name__c ,
						 			Name , Value__c
									from Attribute__c
									where Feature__r.Name__c in :familyByFName.keySet ()]
						) {
			attrMapByFeat.get ( attr.Feature__c ).put ( attr.Name , attr.Value__c );
		}
		showQueryStats ( 'AFTER ATTR BY FEATURE NAME MAP BUILD' );

//		Go thru the Features and make some lookup maps for future reference:
//		- overFeaturesByFName : Map<featureName , overrideFeature[]>
//		- permFeaturesByFName : Map<featureName , entitledFeature[]>
//		- coreFeatureByFName  : Map<featureName , coreFeature>
//		--------------------------------------------------------------------
		Map<String , Set<String>> permUGPRIdsByFName = new Map<String , Set<String>> {};
		Map<String , Feature__c[]> overFeaturesByFName = new Map<String , Feature__c[]> {};
		Map<String , Feature__c[]> permFeaturesByFName = new Map<String , Feature__c[]> {};
		Map<String , Feature__c> coreFeatureByFName = new Map<String , Feature__c> {};

		for ( Feature__c feature : featureById.values () ) {

			if ( !overFeaturesByFName.containsKey ( feature.Name__c ) ) {
				overFeaturesByFName.put ( feature.Name__c , new Feature__c[] {} );
			}

			if ( feature.Feature_UGPR_Link__c != Null ) {
				if ( feature.UGPR_Override__c == True ) {
					
//					Override Feature.
//					-----------------
					overFeaturesByFName.get ( feature.Name__c ).add ( feature );
				}
				else {
				
//					Entitled Feature.
//					-----------------				
					if ( !permFeaturesbyFName.containsKey ( feature.Name__c ) ) {
						permFeaturesByFName.put ( feature.Name__c , new Feature__c[] {} );
					} 				
					permFeaturesByFName.get ( feature.Name__c ).add ( feature );				
				}
			}
			
			else {
				
//				Core Feature.
//				-------------
				coreFeatureByFName.put ( feature.Name__c , feature );
				
				if ( feature.Permission_Required__c ) {
					
//					Permissionable feature.  Initialize its Entitled Feature set,
//					if necessary.
//					-------------------------------------------------------------
					if ( !permFeaturesByFName.containsKey ( feature.Name__c ) ) {
						permFeaturesByFName.put ( feature.Name__c , new Feature__c[] {} );
					} 											
					permUGPRIdsByFName.put ( feature.Name__c , new Set<String> {} );
				}
			}			
		}
		System.debug ( 'PERM FEATURES BY FNAME : [' + permFeaturesByFName + ']' );
		System.debug ( 'OVER FEATURES BY FNAME : [' + overFeaturesByFName + ']' );

//		Get the UGPR info corresponding to those Linked Features.
//		---------------------------------------------------------
		showQueryStats ( 'BEFORE GET UGPR INFO BY FEATURE' );
		
		Map<String , Map<Id , Map<String , Feature_UGPR__c>>> UGPRInfoByFeat
										= getUGPRInfoByFeature ( featureById.values () , coreFeatureByFName );
			
		showQueryStats ( 'AFTER GET UGPR INFO BY FEATURE' );

//		Re-jig this UGPR Info so it is by Feature Name, not Feature Id.
//		---------------------------------------------------------------
		Map<String , Map<String , Map<String , Feature_UGPR__c>>> UGPRInfoByFName
					= new Map<String , Map<String , Map<String , Feature_UGPR__c>>> {
								UGPR_OVERRIDE_STRING => new Map<String , Map<String , Feature_UGPR__c>> {} ,
								PERMISSIONED_UGPR_STRING => new Map<String , Map<String , Feature_UGPR__c>> {}
							};
							
		for ( String linkType : UGPRInfoByFeat.keySet () ) {
			for ( Id featId : UGPRInfoByFeat.get ( linkType ).keySet () ) {
				String fName = featureById.get ( featId ).Name__c;
				if ( !UGPRInfoByFName.get ( linkType ).containsKey ( fName ) ) {
					UGPRInfoByFName.get ( linkType ).
										put ( fName , new Map<String , Feature_UGPR__c> {} );
				}
				UGPRInfoByFName.get ( linkType ).get ( fName )
									.putAll ( UGPRInfoByFeat.get ( linkType ).get ( featId ) );  
			}
		}
		
		String str = 'UGPRS BY FEATURE NAME BEFORE PRUNING:';
		for ( String linkType : UGPRInfoByFName.keySet () ) {
			str += '\n' + linkType + ':';
			for ( String featName : UGPRInfoByFName.get ( linkType ).keySet () ) {
				str += '\n...FEATURE NAME [' + featName + ']:';
				for ( String UGPRId : UGPRInfoByFName.get ( linkType ).get ( featName ).keySet () ) {
					Feature_UGPR__c UGPR = UGPRInfoByFName.get ( linkType ).get ( featName ).get ( UGPRId );
					str += '\n......UGPR [' + UGPR.Id
								+ '] TYPE [' + UGPR.UGPR_Type__c 
								+ '] NAME [' + UGPR.UGPR_Name__c 
								+ '] ROLL UP ROLES [' + UGPR.Roll_Up_Role_Hierarchy__c
								+ ']';
				}
			}
		}
		System.debug ( str );
		
//		Get a sorted list of Feature Names - so Parent Features appear in the list
//		before their children.
//		--------------------------------------------------------------------------		
		String[] sortedFNameList = new List<String> ( coreFeatureByFName.keySet () );
		sortedFNameList.sort ();

//		Prune permissioned and override UGPR lists, by ANDing them with their parents'
//		permissioned UGPR lists (which themselves may have been pruned already).
//		------------------------------------------------------------------------------
		Map<Id , Map<String , Feature_UGPR__c>> permUGPRInfoByFeat 
											= UGPRInfoByFeat.get ( PERMISSIONED_UGPR_STRING );	
		Map<String , Map<String , Feature_UGPR__c>> permUGPRInfoByFName 
											= UGPRInfoByFName.get ( PERMISSIONED_UGPR_STRING );
			
		for ( String fName : sortedFNameList ) {

			Map<String , Feature_UGPR__c> permUGPRMap = permUGPRInfoByFName.get ( fName );
			if ( permUGPRMap == Null ) {

				if ( permFeaturesByFName.containsKey ( fName ) ) {
					
//					Permission Req'd Feature without Permissioned UGPRLinks.  Stick an empty
//					map in, to allow inheritance from parent Feature.
//					------------------------------------------------------------------------
					permUGPRMap = new Map<String , Feature_UGPR__c> {};
					permUGPRInfoByFName.put ( fName , permUGPRMap );
				}
				else {
					
//					No Permissioned UGPRLinks - not a Permission Req'd Feature.  Nothing to do!
//					---------------------------------------------------------------------------
					continue;
				}
			}
			Set<String> permUGPRIdSet = permUGPRMap.keySet ();
				
			String parentFName = getFeatureParentName ( fName );
			if ( parentFName == '' ) {
				
//				No parent.  Nothing to do!
//				--------------------------	
				continue;
			}
			
			Map<String , Feature_UGPR__c> parentPermUGPRMap = permUGPRInfoByFName.get ( parentFName );
			if ( parentPermUGPRMap == Null ) {

//				Parent has no Permissioned UGPRLinks (prob. because it is Public).
//				Nothing to do!
//				------------------------------------------------------------------				
				continue;
			}
			Set<String> parentPermUGPRIdSet = parentPermUGPRMap.keySet ().clone ();
			
			System.debug ( 'FNAME [' + fName + '] PERM UGPRS [' + permUGPRIdSet
							+ '] PARENT PERM UGPRS [' + parentPermUGPRIdSet + ']' );
							
			if ( permUGPRIdSet.IsEmpty () ) {
				
//				Permissioned UGPR list is empty - use its Parent's UGPR list.
//				-------------------------------------------------------------
				System.debug ( 'PERM FEAT [' + fName + '] w/NO UGPRIds - ' 
								+ 'INHERITING PARENT PERM UGPRIDs [' + parentPermUGPRIdSet + ']' ); 
				permUGPRInfoByFName.put ( fName , parentPermUGPRMap.clone () );
			}				
			else {

//				AND the Permissioned UGPR list with that of its Parent;
//				do the same for each UGPR list of the individual Permissioned Features.
//				-----------------------------------------------------------------------			
				System.debug ( 'PERM FEAT NAME [' + fName + '] w/UGPRIds [' + permUGPRIdSet 
								+ '] AND-ING WITH PARENT PERM UGPRIDs [' + parentPermUGPRIdSet + ']' );
				
				parentPermUGPRIdSet.removeAll ( permUGPRIdSet );
				for ( String UGPRId : permUGPRIdSet ) {
					if ( parentPermUGPRIdSet.contains ( UGPRId ) ) {
						permUGPRInfoByFName.get ( fName ).remove ( UGPRId );
						  
						for ( Feature__c permFeat : permFeaturesByFName.get ( fName ) ) {
							System.debug ( '...PERM FEAT [' + permFeat.Id + '] UGPRIds [' 
											+ permUGPRInfoByFeat.get ( permFeat.Id ).keySet()
											+ '] REMOVING ID [' + UGPRId + ']' ); 
							permUGPRInfoByFeat.get ( permFeat.Id ).remove ( UGPRId );
						}
					}
				}
			}		
		}

		str = 'UGPRS BY FEATURE NAME AFTER PRUNING:';
		for ( String linkType : UGPRInfoByFName.keySet () ) {
			str += '\n' + linkType + ':';
			for ( String featName : UGPRInfoByFName.get ( linkType ).keySet () ) {
				str += '\n...FEATURE NAME [' + featName + ']:';
				for ( String UGPRId : UGPRInfoByFName.get ( linkType ).get ( featName ).keySet () ) {
					Feature_UGPR__c UGPR = UGPRInfoByFName.get ( linkType ).get ( featName ).get ( UGPRId );
					str += '\n......UGPR [' + UGPR.Id
								+ '] TYPE [' + UGPR.UGPR_Type__c 
								+ '] NAME [' + UGPR.UGPR_Name__c 
								+ '] ROLL UP ROLES [' + UGPR.Roll_Up_Role_Hierarchy__c
								+ ']';
				}
			}
		}
		System.debug ( str );
		
		
//		Prune override UGPR lists, by ANDing them with their corresponding 
//		permissioned UGPR lists (in cases where both lists exist).
//		------------------------------------------------------------------
		Map<Id , Map<String , Feature_UGPR__c>> overUGPRInfoByFeat 
											= UGPRInfoByFeat.get ( UGPR_OVERRIDE_STRING );	

		for ( Id overFeatId : overUGPRInfoByFeat.keySet () ) {
			String fName = featureById.get ( overFeatId ).Name__c;
			
			Map<String , Feature_UGPR__c> permUGPRMap = permUGPRInfoByFName.get ( fName );
			if ( permUGPRMap == Null ) {
				
//				Feature is not Permissionable, so there's no pruning to do.
//				-----------------------------------------------------------
				continue;
			}
			
			System.debug ( 'OVER FEAT [' + overFeatId + '] [' + fName + '] PERM UGPRIDS [' 
							+ permUGPRMap.keySet () + ']' );
			
			Map<String , Feature_UGPR__c> overUGPRMap = overUGPRInfoByFeat.get ( overFeatId );
			Set<String> overUGPRIdSet = overUGPRMap.keySet ();
			
			for ( String UGPRId : overUGPRIdSet ) {
				if ( !permUGPRMap.containsKey ( UGPRId ) ) {
					overUGPRMap.remove ( UGPRId );
				}
			}
		}

//		Go through the features, accumulating a FName -> AttrName -> UGPRId -> FeatureCache map
//		(the Master Map).
//		---------------------------------------------------------------------------------------		
		Map<String , Map<String , Map<String , FeatureCache>>> featAttrUGPRMap
							= new Map<String , Map<String , Map<String , FeatureCache>>> {};

		for ( String fName : familyByFName.keySet () ) {
			Set<String> permUGPRIdSet = permUGPRIdsByFName.get ( fName );
			Feature__c coreFeat = coreFeatureByFName.get ( fName );
			
			featAttrUGPRMap.put ( fName , new Map<String , Map<String , FeatureCache>> {} );
			
//			If no core Feature, then don't bother with the Attributes - this is a Feature
//			we just deleted, or whose Name just changed.
//			-----------------------------------------------------------------------------
			if ( coreFeat == Null ) {
				continue;
			}
						
			Map<String , Map<String , FeatureCache>> attrUGPRMap = featAttrUGPRMap.get ( fName );
			Map<String , Feature_UGPR__c> featNameUGPRMap
										= UGPRInfoByFName.get ( PERMISSIONED_UGPR_STRING )
															.get ( fName );
			if ( featNameUGPRMap == Null ) {
				featNameUGPRMap = new map<String , Feature_UGPR__c> {};
			}

//			A Feature Name's default Attribute set is that of its Core Feature, plus
//			a placeholder 'FeatureName' attribute.
//			------------------------------------------------------------------------
			Map<String , String> attrMap = attrMapByFeat.get ( coreFeat.Id ).clone ();
			attrMap.put ( FEATURE_NAME_STRING , fName );
			System.debug ( 'CORE ATTR MAP : [' + attrMap + ']' );
			
			if ( coreFeat.Permission_Required__c ) {
				
//				Permissionable feature.  Seed the Master Map with the default Attribute set
//				for each permissioned UGPR.
//				---------------------------------------------------------------------------
				for ( String attrName : attrMap.keySet () ) {
					attrUGPRMap.put ( attrName , new Map<String , FeatureCache> {} );
					String attrVal = attrMap.get ( attrName );
					for ( Feature_UGPR__c UGPR : featNameUGPRMap.values () ) {  
						FeatureCache fc = new FeatureCache ( UGPR , fName , attrName , attrVal );
						attrUGPRMap.get ( attrName ).put ( UGPR.UGPR_Id__c , fc );
						System.debug ( 'ADDING PERM FCE [' + fName + '] [' + attrName 
										+ '] [' + UGPR.UGPR_Id__c + '] [' + attrVal + ']' );
					}
				}
				
//				Overlay the Master Map with any Attributes attached to Features linked to 
//				permissioned Users.
//				-------------------------------------------------------------------------				
				for ( Feature__c permFeat : permFeaturesByFName.get ( fName ) ) {
					Map<String , String> permAttrMap = attrMapByFeat.get ( permFeat.Id );
					for ( String attrName : permAttrMap.keySet () ) {
						String attrVal = permAttrMap.get ( attrName );
						if ( !attrUGPRMap.containsKey ( attrName ) ) {
							attrUGPRMap.put ( attrName , new Map<String , FeatureCache> {} );
						}

						for ( Feature_UGPR__c UGPR : UGPRInfoByFeat.get ( PERMISSIONED_UGPR_STRING )
																	.get ( permFeat.Id ).values () ) { 
							FeatureCache fc = new FeatureCache ( UGPR , fName , attrName , attrVal );
							attrUGPRMap.get ( attrName ).put ( UGPR.UGPR_Id__c , fc );
							System.debug ( 'ADDING PERM OVERLAY FCE [' + fName + '] [' + attrName 
											+ '] [' + UGPR.UGPR_Id__c + '] [' + attrVal + ']' );
						}
					}
				}
			}
			else {
				
//				Public feature.  Seed the Master Map with the default Attribute set, for
//				the 'wildcard' User.
//				------------------------------------------------------------------------				
				for ( String attrName : attrMap.keySet () ) {
					FeatureCache fc = new FeatureCache ( WILDCARD_STRING , WILDCARD_STRING , 
															WILDCARD_STRING , False ,
															fName , attrName , attrMap.get ( attrName ) );
					attrUGPRMap.put ( attrName , new Map<String , FeatureCache> { WILDCARD_STRING => fc } );
					System.debug ( 'ADDING PUBLIC FCE [' + fName + '] [' + attrName 
									+ '] [' + WILDCARD_STRING + '] [' + attrMap.get ( attrName ) + ']' );
				}
			}
			
//			Either way (Public or not): Overlay the Master map with any Attributes attached
//			to Features linked to 'override' Users.
//			-------------------------------------------------------------------------------			
			for ( Feature__c overFeat : overFeaturesByFName.get ( fName ) ) {
				Map<String , String> overAttrMap = attrMapByFeat.get ( overFeat.Id );
				for ( String attrName : overAttrMap.keySet () ) {
					String attrVal = overAttrMap.get ( attrName );
					if ( !attrUGPRMap.containsKey ( attrName ) ) {
						attrUGPRMap.put ( attrName , new Map<String , FeatureCache> {} );
					}
					
					for ( Feature_UGPR__c UGPR : UGPRInfoByFeat.get ( UGPR_OVERRIDE_STRING )
																.get ( overFeat.Id ).values () ) { 
						FeatureCache fc = new FeatureCache ( UGPR , fName , attrName , attrVal );
						attrUGPRMap.get ( attrName ).put ( UGPR.UGPR_Id__c , fc );
						System.debug ( 'ADDING OVERRIDE FCE [' + fName + '] [' + attrName 
										+ '] [' + UGPR.UGPR_Id__c + '] [' + attrVal + ']' );
					}
				}
			}
		}

		str = 'MASTER FC MAP:\n';
		for ( String fName : featAttrUGPRMap.keySet () ) {
			str += '\nFEAT [' + fName + ']:';
			for ( String aName : featAttrUGPRMap.get ( fName ).keySet () ) {
				str += '\n...ATTR [' + aName + ']:';
				for ( String UGPRId : featAttrUGPRMap.get ( fName ).get ( aName ).keySet () ) {
					str += '\n......UGPR [' + UGPRId + '] : ['
								+ featAttrUGPRMap.get ( fName ).get ( aName ).get ( UGPRId ) 
								+ ']';
				}
			}
		}
		System.debug ( str );
				
//		Finally, refresh the Feature Cache with the Feature Cache record list.
//		----------------------------------------------------------------------
		refreshFeatureCache ( featAttrUGPRMap );		
	}	

//	============================================================================
//	Method:	refreshFeatureCache
//
//	Desc:	Function to refresh the Feature Cache with the specified collection
//			of Feature Cache records, deleting/updating/inserting records as
//			necessary.
//
//	Return:	Nothing.
//	============================================================================					
	private static void refreshFeatureCache ( 
						Map<String , Map<String , Map<String , FeatureCache>>> featAttrUGPRMap ) {
		
		String str = 'REFRESH FC WITH:';
		for ( String fName : featAttrUGPRMap.keySet () ) {
			str += '\nFEAT [' + fName + ']:';
			for ( String aName : featAttrUGPRMap.get ( fName ).keySet () ) {
				str += '\n...ATTR [' + aName + ']:';
				for ( String UGPRId : featAttrUGPRMap.get ( fName ).get ( aName ).keySet () ) {
					str += '\n......UGPR [' + UGPRId + '] : ['
								+ featAttrUGPRMap.get ( fName ).get ( aName ).get ( UGPRId ).AttributeName 
								+ ']';
				}
			}
		}
		System.debug ( str );

//		Flatten out the map, for ease of comparison.
//		--------------------------------------------
		Map<String , FeatureCache> newFCMap = new Map<String , FeatureCache> {};
		for ( String fName : featAttrUGPRMap.keySet () ) {
			for ( String aName : featAttrUGPRMap.get ( fName ).keySet () ) {
				for ( String UGPRId : featAttrUGPRMap.get ( fName ).get ( aName ).keySet () ) {
					FeatureCache fc = featAttrUGPRMap.get ( fName ).get ( aName ).get ( UGPRId );
					newFCMap.put ( fName + ':' + aName + ':' + UGPRId , fc );
				}
			}
		}

				
//		Grab the existing Features from the DB.
//		---------------------------------------
		Map<String , Feature_Cache__c> dbFCMap = new Map<String , Feature_Cache__c> {};
		for ( Feature_Cache__c dbFC : [ select 
											UGPR_Id__c , 
											UGPR_Name__c , 
											UGPR_Type__c ,
											Roll_Up_Role_Hierarchy__c ,
											Feature_Name__c ,
											Attribute_Name__c ,
											Attribute_Value__c
										from 
											Feature_Cache__c
										where 
											Feature_Name__c in :featAttrUGPRMap.keySet ()
										]
		) {
			String fcKey = dbFC.Feature_Name__c + ':' + dbFC.Attribute_Name__c + ':' + dbFC.UGPR_Id__c;
			dbFCMap.put ( fcKey , dbFC );	
		}
		System.debug ( 'ALREADY IN DB : [' + dbFCMap + ']' );
		
//		Now compare the Feature maps, looking for additions/deletions/updates.
//		----------------------------------------------------------------------
		Set<String> commonKeySet = new Set<String> {};
		Feature_Cache__c[] dbUpdateFCList = new Feature_Cache__c[] {};
		
		for ( String fcKey : newFCMap.keySet () ) {
			Feature_Cache__c dbFC = dbFCMap.get ( fcKey );
			FeatureCache newFC = newFCMap.get ( fcKey );

			if ( dbFC != Null ) {
				commonKeySet.add ( fcKey );
				dbFCMap.remove ( fcKey );
				
				if ( !newFC.matches ( dbFC ) ) {
					System.debug ( 'CHANGED : [' + fcKey + '] : [' + dbFC + '] -> [' + newFC + ']' );
					newFC.setDBFC ( dbFC );
					dbUpdateFCList.add ( dbFC ); 
				}
				else {
					System.debug ( 'UNCHANGED : [' + fcKey + '] : [' + newFC + ']' );
				} 
			}
			else {
				System.debug ( 'BRAND NEW : [' + fcKey + '] : [' + newFC + ']' );
			}
		}
		
		for ( String fcKey : dbFCMap.keySet () ) {
			System.debug ( 'DEFUNCT : [' + fcKey + '] : [' + dbFCMap.get ( fcKey ) + ']' );
		}
		
		for ( String fcKey : commonKeySet ) {
			newFCMap.remove ( fcKey );
		}

//		What's left in newFCMap is brand new FC entries, to be inserted.
//		What's left in dbFCMap is defunct FC entries, to be removed.
//		What's in dbUpdateFCList is modified FC entries, to be updated.
//		----------------------------------------------------------------		
		Feature_Cache__c[] dbInsertFCList = new Feature_Cache__c[] {};
		for ( String fcKey : newFCMap.keySet () ) {
			FeatureCache fc = newFCMap.get ( fcKey );
			Feature_Cache__c dbFC = new Feature_Cache__c ();
			fc.setDBFC ( dbFC );
			System.debug ( 'INSERTING dbFC:\n' + dbFC );
			dbInsertFCList.add ( dbFC );
		}

		Delete dbFCMap.values ();
		Update dbUpdateFCList;
		Insert dbInsertFCList;
	}

//	============================================================================
//	Method:	getFeatureAttributes
//
//	Desc:	Function to retrieve the specified records from the Feature Cache, 
//			for the specified User Id:
//			- a specific Feature/Attribute combination
//			- all Attributes for a specific Feature
//			- all Attributes for a specific Feature and all its child Features
//
//			Accounts for both specific-user and wildcard-user Feature Cache
//			records, including the case where the former overrides the latter.
//		 
//	Return:	A list of <Feature> lists.
//	============================================================================	
	public static Feature[] getFeatureAttributes ( Id userId , String featureName , String attribName ,
													Boolean bGetTree ) {
		
		Id profileId , roleId;	
				
		if ( userId == null ) {
			userId = UserInfo.getUserId ();
			profileId = UserInfo.getProfileId ();
			roleId = UserInfo.getUserRoleId ();
		}
		else {
			User[] uList = [ select Id , ProfileId , UserRoleId from User
							where Id = :userId ];
			if ( uList.isEmpty () ) {
				System.debug ( 'Invalid user Id [' + userId + ']' );
				return ( new Feature[] {} );
			}
			userId = uList[ 0 ].Id;
			profileId = uList[ 0 ].ProfileId;
			roleId = uLIst[ 0 ].UserRoleId;
		}
		
		System.debug ( 'USER [' + userId + '] PROFILE [' + profileId + '] ROLE [' + roleId + ']' );
		
//		Grab the relevant Feature Cache records.
//		----------------------------------------
		Feature_Cache__c[] fcList = new Feature_Cache__c[] {};
		
		if ( attribName == Null ) {
			if ( bGetTree ) {
				fcList = [ select
								UGPR_Id__c , UGPR_Type__c , Roll_Up_Role_Hierarchy__c , 
								Feature_Name__c , Attribute_Name__c , Attribute_Value__c
							from
								Feature_Cache__c
							where ( 
								Feature_Name__c = :featureName
								or Feature_Name__c like :featureName + '.%'
							)
							and (
								( UGPR_Type__c = :USER_STRING and UGPR_Id__c = :userId ) or
								( UGPR_Type__c = :PROFILE_STRING and UGPR_Id__c = :profileId ) or
								( UGPR_Type__c in ( :WILDCARD_STRING , :GROUP_STRING , :ROLE_STRING ) )
							) 
						];
			}
			else {
				fcList = [ select
								UGPR_Id__c , UGPR_Type__c , Roll_Up_Role_Hierarchy__c , 
								Feature_Name__c , Attribute_Name__c , Attribute_Value__c
							from
								Feature_Cache__c
							where 
								Feature_Name__c = :featureName 
							and (
								( UGPR_Type__c = :USER_STRING and UGPR_Id__c = :userId ) or
								( UGPR_Type__c = :PROFILE_STRING and UGPR_Id__c = :profileId ) or
								( UGPR_Type__c in ( :WILDCARD_STRING , :GROUP_STRING , :ROLE_STRING ) )
							) 
						];

			}
		}
		else {
			fcList = [ select
							UGPR_Id__c , UGPR_Type__c , Roll_Up_Role_Hierarchy__c , 
							Feature_Name__c , Attribute_Name__c , Attribute_Value__c
						from
							Feature_Cache__c
						where 
							Feature_Name__c = :featureName  and
							Attribute_Name__c = :attribName
						and (
							( UGPR_Type__c = :USER_STRING and UGPR_Id__c = :userId ) or
							( UGPR_Type__c = :PROFILE_STRING and UGPR_Id__c = :profileId ) or
							( UGPR_Type__c in ( :WILDCARD_STRING , :GROUP_STRING , :ROLE_STRING ) )
						) 
					];
		}
		
//		Organize the Feature Cache list by Feature Name, Attribute Name and UPGRId.
//		While we're at it, determine whether we need to get Group and/or Role info.
//		---------------------------------------------------------------------------
		Map<String , Map<String , Map<String , Feature_Cache__c>>> fcMap 
					= new Map<String , Map<String , Map<String , Feature_Cache__c>>> {};
		Set<String> grpIdSet = new Set<String> {};
		Set<String> roleIdSet = new Set<String> {};
		Boolean bNeedRoles = False;
		Boolean bNeedGroups = False;
					
		for ( Feature_Cache__c fc : fcList ) {
			if ( !fcMap.containsKey ( fc.Feature_Name__c ) ) {
				fcMap.put ( fc.Feature_Name__c , new Map<String , Map<String , Feature_Cache__c>> {} );
			}
			if ( !fcMap.get ( fc.Feature_Name__c ).containsKey ( fc.Attribute_Name__c ) ) {
				fcMap.get ( fc.Feature_Name__c )
						.put ( fc.Attribute_Name__c , new Map<String , Feature_Cache__c> {} );
			}
			fcMap.get ( fc.Feature_Name__c ).get ( fc.Attribute_Name__c )
											.put ( fc.UGPR_Id__c , fc );

			if ( fc.UGPR_Type__c == ROLE_STRING && fc.Roll_Up_Role_Hierarchy__c == True ) {
				bNeedRoles = True;
			}
			else if ( fc.UGPR_Type__c == GROUP_STRING ) {
				bNeedGroups = True;
			}
		}

		String str = 'CHECKING FEATURE CACHE ENTRIES:';
		for ( String fName : fcMap.keySet () ) {
			for ( String aName : fcMap.get ( fName ).keySet () ) {
				for ( String UGPRId : fcMap.get ( fName ).get ( aName ).keySet () ) {
					str += '\n' + fName + ':' + aName + ':' + UGPRId + ': ['
							+ fcMap.get ( fName ).get ( aName ).get ( UGPRId );
				}
			}
		}
		System.debug ( str );
		 
//		Get the Group and/or Role information, if required.
//		---------------------------------------------------
		if ( bNeedGroups || bNeedRoles ) {
			Map<String , Set<Id>> grpRoleMap = grpRoleProfileUtil.getUserGrpsAndRoles (
																userId ,
																( bNeedRoles ? roleId : Null ) );
			for ( Id myId : grpRoleMap.get ( GROUP_STRING ) ) {
				grpIdSet.add ( myId );
			}
			for ( Id myId : grpRoleMap.get ( ROLE_STRING ) ) {
				if ( roleId != myId ) {
					roleIdSet.add ( myId );
				}
			}
		}

//		Organize our User, Group, Profile and Role information into an ordered
//		list of ID sets, in DECREASING order of priority (i.e User-type FC
//		records trump Group-type, which trump Role-type, which trump
//		Subordinate-Role-type, which trump Profile-type, which trump the
//		lowly Wildcard(Public)-type.
//		----------------------------------------------------------------------
		List<Set<String>> UGPRIdSetList = new List<Set<String>> {
												new Set<String> { userId } ,
												grpIdSet ,
												new Set<String> { roleId } ,
												roleIdSet ,
												new Set<String> { profileId } ,
												new Set<String> { WILDCARD_STRING }
											};
		
		System.debug ( '...CHECKING AGAINST ID SET LIST:\n' + UGPRIdSetList );
		
//		Now go thru the Feature Cache map, using the above ordered Id set list
//		for each FC set belonging to a particular FeatureName/AttribName pair
//		to determine which FC record, if any, 'wins'.
//		----------------------------------------------------------------------
		Map<String , Feature> featByName = new Map<String , Feature> {};
		
		for ( String fName : fcMap.keySet () ) {
			for ( String aName : fcMap.get ( fName ).keySet () ) {
				Set<String> fcUGPRIdSet = fcMap.get ( fName ).get ( aName ).keySet ();
				for ( Set<String> UGPRIdSet : UGPRIdSetList ) {
					Set<String> matchIdSet = UGPRIdSet.clone ();
					matchIdSet.retainAll ( fcUGPRIdSet );
					if ( !matchIdSet.isEmpty () ) {
						
//						Some jiggery-pokery to do with Subordinate Role Ids.  If we 
//						found a match between this Feature Cache set and our set of
//						subordinate RoleIds, then this match is valid ONLY if it
//						points at a Feature Cache record whose Roll Up Role flag is
//						set to True.
//						-----------------------------------------------------------
						Feature_Cache__c matchFC;

						for ( String UGPRId : matchIdSet ) {
							matchFC = fcMap.get ( fName ).get ( aName ).get ( UGPRId );
							if ( roleIdSet.contains ( UGPRId ) && !matchFC.Roll_Up_Role_Hierarchy__c ) {
								matchFC = Null;
								continue;
							}
							else {
								break;
							}
						}
		
						if ( matchFC != Null ) {

//							Found a matching FC record.  Grab its Feature and Attribute info.
//							-----------------------------------------------------------------	
							System.debug ( 'MATCHING FC:\n' + matchFC );
										
							Feature feat = featByName.get ( matchFC.Feature_Name__c );
							if ( feat == Null ) {
								feat = new Feature ( matchFC.Feature_Name__c );
								featByName.put ( matchFC.Feature_Name__c , feat );
							}
							
							if ( !featByName.containsKey ( matchFC.Feature_Name__c ) ) {
								featByName.put ( matchFC.Feature_Name__c ,
												new Feature ( matchFC.Feature_Name__c ) ); 
							}
							if ( matchFC.Attribute_Name__c != FEATURE_NAME_STRING ) {
								feat.Attributes.add ( new Attribute ( matchFC.Attribute_Name__c, 
																		matchFC.Attribute_Value__c ,
																		Null ) );
							}	
							
							break;		 
						}
					}
				}
			}
		}
	
//		Finally, sort the output.
//		-------------------------
		Feature[] featList = new Feature[] {};
		List<String> featNameList = new List<String> ( featByName.keySet () );
		featNameList.sort ();
		for ( String featName : featNameList ) {
			featList.add ( featByName.get ( featName ) );
		}
		
		return featList;		  
	}
				
//	============================================================================
//	Method:	isFeatureAdministrator
//
//	Desc:	Function to determine whether the current user is an administrator
//			of the specified feature.
//
//	Return:	Boolean.
//	============================================================================	
	public static boolean isFeatureAdministrator ( String featureName ) {
		
		return isFeatureAdministrator ( new String[] { featureName } )[ 0 ];		
	}
	
//	============================================================================
//	Method:	isFeatureAdministrator
//
//	Desc:	Function to determine whether the current user is an administrator
//			of the specified list of features.
//
//	Return:	Array of Booleans, one per Feature name.				
//	============================================================================		
	public static Boolean[] isFeatureAdministrator ( String[] featureNames ) {
				
		String userId = UserInfo.getUserId();
		Boolean[] isAdminList = new Boolean[ featureNames.Size () ];
		for ( Integer i = 0 ; i < featureNames.Size () ; i++ ) {
			isAdminList[ i ] = False;
		}
		
		String featAdmin = [Select Feature_Administrator__c From User Where Id = :userId]
									.Feature_Administrator__c;

		if ( featAdmin == Null ) {
			return isAdminList;		// doesn't administer ANY features!
		}
		
		for ( Integer i = 0 ; i < featureNames.Size() ; i++ ) {
			String featPtrn = '(^|;)' + getFeatureRootName(featureNames[ i ]) + '(;|$)';
			if ( featAdmin.replaceAll ( featPtrn , '' ) != featAdmin ) {
				
//				The root name of our Feature appears somewhere in this user's Admin list.
//				-------------------------------------------------------------------------				
				isAdminList[ i ] = True;
			} 
		}
		
		return isAdminList;
	}

//	============================================================================
//	Method:	getUGPRInfoByFeature
//
//	Desc:	Function to retrieve a big map of UGPR-type information for the
//			specified list of Features:
//			Perm/Override -> FeatureId -> UGPRId -> UGPR Record
//
//	Return:	The big map.
//	============================================================================		
	public static Map<String , Map<Id , Map<String , Feature_UGPR__c>>>
														getUGPRInfoByFeature (
																Feature__c[] featList ,
																Map<String , Feature__c> coreFeatByFName
														) {
		
		List<Map<Id , Set<String>>> UGPRIdsByFeatList = new List<Map<Id , Set<String>>> {};
		Map<Id , Set<String>> UGPRIdsByPermFeat = new Map<Id , Set<String>> {};
		Map<Id , Set<String>> UGPRIdsByOverFeat = new Map<Id , Set<String>> {};
		UGPRIdsByFeatList.add ( UGPRIdsByPermFeat );
		UGPRIdsByFeatList.add ( UGPRIdsByOverFeat );

//		Perm/Override -> FeatId -> UGPRId -> UGPRRec
//		--------------------------------------------
		Map<String , Map<Id , Map<String , Feature_UGPR__c>>> UGPRInfoByFeat
				= new Map<String , Map<Id , Map<String , Feature_UGPR__c>>> {
							UGPR_OVERRIDE_STRING => new Map<Id , Map<String , Feature_UGPR__c>> {} ,
							PERMISSIONED_UGPR_STRING => new Map<Id , Map<String , Feature_UGPR__c>> {}
						};
		
//		Get the UGPRLink reference set from the Feature list.
//		-----------------------------------------------------
		Map<Id , Feature__c> featureById = new Map<Id , Feature__c> {};
		Set<Id> UGPRLinkIdSet = new Set<Id> {};		
		Map<Id , Set<Id>> featIdsByUGPRLink = new Map<Id , Set<Id>> {};
		
		for ( Feature__c feat : featList ) {
			featureById.put ( feat.Id , feat );
			
			if ( feat.Feature_UGPR_Link__c != Null ) {
				String linkType = ( feat.UGPR_Override__c ? UGPR_OVERRIDE_STRING :
															PERMISSIONED_UGPR_STRING );
															
//				Skip PERMISSIONED features whose Core features are Public.
//				----------------------------------------------------------
				if ( linkType == PERMISSIONED_UGPR_STRING ) {
					Feature__c coreFeat = coreFeatByFName.get ( feat.Name__c );
					if ( coreFeat == Null || coreFeat.Permission_Required__c == False ) {
						continue;
					}
				}
																			
				UGPRInfoByFeat.get ( linkType ).put ( feat.Id , new Map<String , Feature_UGPR__c> {} );

				UGPRLinkIdSet.add ( feat.Feature_UGPR_Link__c );

				if ( !featIdsByUGPRLink.containsKey  ( feat.Feature_UGPR_Link__c ) ) {
					featIdsByUGPRLink.put ( feat.Feature_UGPR_Link__c , new Set<Id> {} );
				}
				featIdsByUGPRLink.get ( feat.Feature_UGPR_Link__c ).add ( feat.Id );		
			}
			else if ( feat.Permission_Required__c ) {
				
//				Core Permission Reqd Feature.  Put a placeholder in there, in case (later)
//				it has to inherit its Parent Feature's permissions.
//				--------------------------------------------------------------------------
//				UGPRInfoByFeat.get ( PERMISSIONED_UGPR_STRING ).
//								put ( feat.Id , new Map<String , Feature_UGPR__c> {} );
			}
		}
		if ( UGPRLinkIdSet.isEmpty () ) {

//			No UGPRLinks associated with the specified Features.  Just return
//			the empty map.
//			-----------------------------------------------------------------
			System.debug ( 'No UGPRLinks attached to specified Feature list' );		
			return UGPRInfoByFeat;
		}

//		We now have:
//		UGPRLinkIdSet - set of all UGPRLink Ids hooked to our list of Features
//		featIdsByUGPRLink - set of Feature Ids for each UGPRLink we're hooked to
//		------------------------------------------------------------------------

//		Initialize the UGPRLinkId -> UGPRIdSet map, where we'll accumulate the results of
//		the SOQL query (and split out into Perm and Override at the end).
//		---------------------------------------------------------------------------------		
		Map<Id , Set<Id>> UGPRIdsByUGPRLink = new Map<Id , Set<Id>> {};
		for ( Id UGPRLinkId : UGPRLinkIdSet ) {
			UGPRIdsByUGPRLink.put ( UGPRLinkId , new Set<Id> {} );
		}

		showQueryStats ( 'GET UGPRS BY FEATURE - BEFORE UGPR LOOKUP' );
		for ( Feature_UGPR__c UGPR : [ select 
											Id , 
											UGPR_Id__c , 
											UGPR_Name__c , 
											UGPR_Type__c ,
											Roll_Up_Role_Hierarchy__c ,
											Feature_UGPR_Link__c
										from 
											Feature_UGPR__c
										where 
											Feature_UGPR_Link__c in :UGPRLinkIdSet
										] 
		) {			
			for ( Id featId : featIdsByUGPRLink.get ( UGPR.Feature_UGPR_Link__c ) ) {
				Feature__c feat = featureById.get ( featId );
				String linkType = ( feat.UGPR_Override__c == True ? UGPR_OVERRIDE_STRING :
																	PERMISSIONED_UGPR_STRING );
				
				UGPRInfoByFeat.get ( linkType ).get ( featId ).put ( UGPR.UGPR_Id__c , UGPR );
			}
		}
		showQueryStats ( 'GET USERS BY FEATURE - AFTER UGPR LOOKUP' );
		
		String str = 'UGPRS BY FEATURE:';
		for ( String linkType : UGPRInfoByFeat.keySet () ) {
			str += '\n' + linkType + ':';
			for ( Id featId : UGPRInfoByFeat.get ( linkType ).keySet () ) {
				str += '\n...FEATURE [' + featId + '] [' + featureById.get ( featId ).External_Id__c + ']:';
				for ( String UGPRId : UGPRInfoByFeat.get ( linkType ).get ( featId ).keySet () ) {
					Feature_UGPR__c UGPR = UGPRInfoByFeat.get ( linkType ).get ( featId ).get ( UGPRId );
					str += '\n......UGPR [' + UGPR.Id
								+ '] TYPE [' + UGPR.UGPR_Type__c 
								+ '] NAME [' + UGPR.UGPR_Name__c 
								+ '] ROLL UP ROLES [' + UGPR.Roll_Up_Role_Hierarchy__c
								+ ']';
				}
			}
		}
		
		System.debug ( str );
		
		return UGPRInfoByFeat;
	}
}