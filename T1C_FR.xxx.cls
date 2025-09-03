public class xxx {

	public static final String WILDCARD_STRING = '*';
	public static final String FEATURE_NAME_STRING = 'FeatureName';

	public static final String USER_STRING = 'USER';
	public static final String GROUP_STRING = 'GROUP';
	public static final String ROLE_STRING = 'ROLE';
	public static final String PROFILE_STRING = 'PROFILE';

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
	public static Feature yyy ( Id userId , String featureName , String attribName ,
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
				return Null;
			}
			profileId = uList[ 0 ].ProfileId;
			roleId = uLIst[ 0 ].UserRoleId;
		}
		
		System.debug ( 'USER [' + userId + '] PROFILE [' + profileId + '] ROLE [' + roleId + ']' );
		
//		Grab the relevant Feature Cache records.
//		----------------------------------------
		Feature_Cache__c[] fcList = new Feature_Cache__c[] {};
		
		System.debug ( '[' + featureName + '] [' + attribName + '] [' + bGetTree + ']' );
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
		for ( Feature_Cache__c fc : fcList ) {
			System.debug ( 'FC [' + fc + ']' );
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
	
//		Finally, sort the output and make a Feature tree, rooted at a single root Feature.
//		-----------------------------------------------------------------------------------
		Feature rootFeat;
		List<String> featNameList = new List<String> ( featByName.keySet () );
		featNameList.sort ();
		
		for ( String featName : featNameList ) {
			Feature feat = featByName.get ( featName );
			
			String parentFeatName = featureCacheUtil.getFeatureParentName ( featName );
			if ( parentFeatName == Null || !featByName.containsKey ( parentFeatName ) ) {
				
//				Root of the tree!
//				-----------------
				rootFeat = feat;
			}
			else {
				Feature parentFeat = featByName.get ( parentFeatName );
				parentFeat.SubFeatures.add ( feat );
			}
		}
		
		return rootFeat;		  
	}
	
/*	
	public static Feature[] getFeatureTree ( String rootFeatName ) {

		Map<String , Map<String , Map<String , FeatureCache>>> fcMap
				= new Map<String , Map<String , Map<String , FeatureCache>>> {};
				
		Map<Id , Feature__c> featById = new Map<Id , Feature__c> {
								 [ select 
										Name__c ,
										Permission_Required__c ,
										UGPR_Override__c ,
										Core_Feature__c ,
										(
											select
												Name ,
												Value__c
											from
												Attributes__r
										)
									from
										Feature__c
									where
										Name__c = :rootFeatName or
										Name__c like :rootFeatName + '%'
								] };
		
		Map<String , Id> coreFeatByFName = new Map<String , Id> {};
		for ( Feature__c feat : featById.values () ) {
			if ( feat.Core_Feature__c == Null ) {
				coreFeatByFName.put ( feat.Name__c , feat.Id );

				fcMap.put ( feat.Name__c , new Map<String , Map<String , FeatureCache>> {} );
				
				if ( !feat.Permission_Required__c ) {
					for ( Attribute__c attr : feat.Attributes__r ) {
						FeatureCache fc = new FeatureCache ( featureCacheUtil.WILDCARD_STRING ,
																featureCacheUtil.WILDCARD_STRING ,
																featureCacheUtil.WILDCARD_STRING ,
																False ,
																feat.Name__c ,
																attr.Name , attr.Value__c
															);
						fcMap.get ( feat.Name__c ).put ( attr.Name , new Map<String , FeatureCache> {
																			featureCacheUtil.WILDCARD_STRING => fc
																		}
																	);
					}
				}																
			}
		}
		
		Map<String , Map<Id , Map<String , Feature_UGPR__c>>> featUGPRMap
				= featureCacheUtil.getUGPRInfoByFeature ( featList , coreFeatByFName );
		
		Map<Id , Map<String , Feature_UGPR__c>> permFeatUGPRMap 
								= featUGPRMap.get ( featureCacheUtil.PERMISSIONED_UGPR_STRING );
		for ( Id featId : permFeatUGPRMap.keySet () ) {
			Feature__c permFeat = featById.get ( featId );
			Id coreFeatId = coreFeatByFName.get ( permFeat.Name__c ).Id;
			if ( coreFeatId == Null ) {
				System.debug ( 'ERROR : no core feature for perm feat [' + permFeat.Id + ']' );
				continue;
			}
			Feature__c coreFeat = featById.get ( coreFeatId );
			
			for ( String UGPRId : permFeatUGPRMap.get ( featId ).keySet () ) {
				Feature_UGPR__c UGPR = permFeatUGPRMap.get ( featId ).get ( UGPRId );
				 
				for ( Attribute__c attr : coreFeat.Attributes__r ) {
					FeatureCache fc = new FeatureCache ( UGPR.UGPR_Id__c , UGPR.UGPR_Name__c ,
															UGPR.UGPR_Type__c ,
															UGPR.Roll_Up_Role_Hierarchy__c,
															coreFeat.Name__c , 
															attr
															attr.Name , attr.Value__c
														);
					fcMap.get ( feat.Name__c ).put ( attr.Name , new Map<String , FeatureCache> {
																		featureCacheUtil.WILDCARD_STRING => fc
																	}
																);
				}
						
			
					
		for ( String linkType : featUGPRMap.keySet () ) {
			for ( Id featId : featUGPRMap.get ( featName ) ) 
		
		) {
			String featType = ( feat.Core_Feature__c == Null ?
									( feat.Permission_Required__c ? 'PERM REQD' : 'PUBLIC' ) :
									( feat.UGPR_Override__c ? 'UGPR OVERRIDE' : 'PERMISSIONED' ) );
			System.debug ( 'FEAT [' + feat.Name__c + '] TYPE [' + featType + ']' );
			for ( Attribute__c attr : feat.Attributes__r ) {
				System.debug ( '...ATTR [' + attr.Name + '] = [' + attr.Value__c + ']' );
			}
			
			if ( 
		}
		return new Feature[] {};
	}
*/
}