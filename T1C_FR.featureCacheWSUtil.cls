/*
 * Name:        featureCacheWSUtil
 *
 * Description: Functions to support the Feature/Entitlements WebServices methods.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM.
 */ 

public class featureCacheWSUtil {

	static final String INSUFFICIENT_PERM_ERROR_STR
							= 'ERROR : Insufficient permission to perform this action.';

	static final String USER_STRING = 'USER';
	static final String GROUP_STRING = 'GROUP';
	static final String ROLE_STRING = 'ROLE';
	static final String PROFILE_STRING = 'PROFILE';

	public class FCException extends Exception {}

//	============================================================================
//	Method:	concatList
//
//	Desc:	Utility to concatenate the message strings contained within the
//			specified list of Database.Errors into a single string, separated
//			by the specified delimiter.
//		 
//	Return:	The concatenated string.
//	============================================================================					
	private static String concatList ( Database.Error[] errList , String delim ) {
		
		String concatStr = '';
		for ( Integer i = 0 ; i < errList.size () ; i++ ) {
			concatStr += ( i == 0 ? '' : delim ) + errList[ i ].getMessage ();
		}
		return concatStr;
	}
	
//	============================================================================
//	Method:			upsertRecords
//	Description: 	Updates or inserts the given array of objects 			
//	Args:			Array of sObjects
//	Return:			AceWSResultList record containing upsert results.					
//	============================================================================	
	private static AceWSResultList upsertRecords ( SObject[] sObjects ) {

		AceWSResultList arl = new AceWSResultList ( sObjects.size () , False );

//		Upsert the records, remembering failures.
//		-----------------------------------------
		Database.upsertResult[] uResultList;
		try {
			uResultList = Database.upsert ( sObjects , False );
		}
		catch ( ListException e ) {
			arl.setResult ( False , 'Duplicate SObject Ids in input list - aborting entire job.' );
			return arl;
		}
		catch ( Exception e ) {
			arl.setResult ( False ,	'Error upserting SObject list: [' 
									+ e.getMessage () + '] - aborting entire job.' );
			return arl;
		}
		
//		Populate the return list with IDs of successfully upserted SObjects.
//		--------------------------------------------------------------------		
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
			arl.setResult ( i , bStatus , msg );		
		}
		
		return arl;
	}
	
//	============================================================================
//	Method:			updateRecords
//	Description: 	Updates the given array of objects 			
//	Args:			Array of sObjects
//	Return:			AceWSResultList record containing update results. 						
//	============================================================================	
	public static AceWSResultList updateRecords ( SObject[] sObjects ) {
		return upsertRecords ( sObjects );
	}
	
//	============================================================================
//	Method:			insertRecords
//	Description: 	Inserts the given array of objects 			
//	Args:			Array of sObjects
//	Return:			AceWSResultList record containing insert results. 						
//	============================================================================	
	public static AceWSResultList insertRecords ( SObject[] sObjects ) {
		return upsertRecords ( sObjects );
	}
	
//	============================================================================
//	Method:			deleteRecords
//	Description: 	Deletes the given array of objects 			
//	Args:			Array of sObjects
//	Return:			AceWSResultList record containing delete results.					
//	============================================================================	
	public static AceWSResultList deleteRecords(Id[] sObjIds) {

		AceWSResultList arl = new AceWSResultList ( sObjIds.size () , False );

//		Delete the records, remembering failures.
//		-----------------------------------------
		Database.deleteResult[] dResultList;
		try {
			dResultList = Database.delete ( sObjIds , False );
		}
		catch ( ListException e ) {
			arl.setResult ( False , 
									'Duplicate SObject Ids in input list - aborting entire job.' );
			return arl;
		}
		catch ( Exception e ) {
			arl.setResult ( False ,
									'Error deleting SObject list: [' 
									+ e.getMessage () + '] - aborting entire job.' );
			return arl;
		}
		
//		Populate the return list with IDs of successfully deleted SObjects.
//		-------------------------------------------------------------------	
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
			arl.setResult ( i , bStatus , msg );
		}
		
		return arl;
	}

//	============================================================================
//	Method:	createFeatures
//
//	Desc:	Function to insert core Features with the specified names and
//			permissionability flag.
//		 
//	Return:	AceWSResultList record containing create results.
//	============================================================================						
	public static AceWSResultList createFeatures ( String[] featNameList , Boolean bPermReqd ) {
			
		AceWSResultList arl = new AceWSResultList ( featNameList.size () , True );

//		Validate the user permissions on the Feature list.
//		-------------------------------------------------				
		Boolean[] isAdminList = featureCacheUtil.isFeatureAdministrator ( featNameList );
		
		Feature__c[] featList = new Feature__c[] {};
		map<Integer , Integer> featIdxMap = new Map<Integer , Integer> {};
		Integer featIdx = 0;
		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			String featName = featNameList[ i ];

//			Validate the user permission on this Feature.
//			---------------------------------------------
			if ( !isAdminList[ i ] ) {								
				arl.setResult ( i , False , INSUFFICIENT_PERM_ERROR_STR );
				continue;
			}
			
			String objName = featName.replaceAll ( '^.*\\.' , '' );
			Feature__c feature = new Feature__c ( Name = objName ,
													Name__c = featName ,
													Permission_Required__c = bPermReqd
												); 
			featList.add ( feature );
			featIdxMap.put ( featIdx++ , i );
		}
		
//		Insert the new Features, and stick the results in the proper array slots.
//		-------------------------------------------------------------------------
		AceWSResultList dbArl = insertRecords ( featList );
		for ( featIdx = 0 ; featIdx < featList.size () ; featIdx++ ) {
			Integer i = featIdxMap.get ( featIdx );
			AceWSResult dbAr = dbArl.getResult ( featIdx );
			String msg = dbAr.statusMsg;
			if ( msg.contains ( 'DUPLICATE_VALUE' ) ) {
				msg = 'ERROR : Feature with this name already exists.';
			}
			
			arl.setResult ( i , dbAr.bSuccess , msg );
		}
		
		return arl;
	}

//	============================================================================
//	Method:	permissionFeatures
//
//	Desc:	Function to permission the specified User/Group/Role/Profile
//			for the specified list of Features.  The 'whoType' argument
//			determines what type the whoId refers to.
//		 
//	Return:	AceWSResultList record containing permissioning results.
//	============================================================================					
	public static AceWSResultList permissionFeatures ( String[] featNameList , 
															Id whoId , String whoType ,
															Boolean bRollUpRoleHierarchy ) {	

		AceWSResultList arl = new AceWSResultList ( featNameList.size () , False );

		if ( whoId == Null ) {
			whoId = UserInfo.getUserId ();
		}
		else {
			whoId = featureCacheUtil.idTo18Char ( whoId );
		}
		
//		Validate the user permissions on the Feature list.
//		-------------------------------------------------				
		Boolean[] isAdminList = featureCacheUtil.isFeatureAdministrator ( featNameList );

		Map<Integer , Integer> featIdxMap = new Map<Integer , Integer> {};
		String[] linkFeatNameList = new String[] {};
		Integer featIdx = 0;
		
		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			String featName = featNameList[ i ];

			if ( !isAdminList[ i ] ) {								
				arl.setResult ( i , False , INSUFFICIENT_PERM_ERROR_STR );
				continue;
			}
			
			linkFeatNameList.add ( featName );
			featIdxMap.put ( featIdx++ , i );
		}
		
//		Link the Feature Names to the whoId.
//		------------------------------------		
		Map<String , Feature__c[]> linkFeatByName = linkUGPRToFeatures (		
													linkFeatNameList , whoId , whoType , 
													False , bRollUpRoleHierarchy );
	
		for ( featIdx = 0 ; featIdx < linkFeatNameList.size () ; featIdx++ ) {
			Integer i = featIdxMap.get ( featIdx );
			if ( linkFeatByName.containsKey ( linkFeatNameList[ featIdx ] ) ) {
				arl.setResult ( i , True , '' );
			}
			else {
				arl.setResult ( i , False , 'Could not link [' + whoType + '] [' + whoId 
								+ '] to Feature "' + linkFeatNameList[ featIdx ] + '"' );
			}
		}
		
		return arl;
	}

//	============================================================================
//	Method:	unPermissionFeatures
//
//	Desc:	Function to un-permission the specified User/Group/Role/Profile
//			for the specified list of Features.  The 'whoType' argument
//			determines what the whoId refers to.
//		 
//	Return:	AceWSResultList record containing unpermissioning results.
//	============================================================================					
	public static AceWSResultList unPermissionFeatures ( String[] featNameList , 
															Id whoId , String whoType ) {

		AceWSResultList arl = new AceWSResultList ( featNameList.size () , True );

		if ( whoId == Null ) {
			whoId = UserInfo.getUserId ();
		}
		else {
			whoId = featureCacheUtil.idTo18Char ( whoId );
		}
		
		Set<String> featNameToUnlinkSet = new Set<String> ( featNameList );
		
//		Prune the Features we're not permitted to un-permission.
//		--------------------------------------------------------		
		Boolean[] isAdminList = featureCacheUtil.isFeatureAdministrator ( featNameList );

		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			String featName = featNameList[ i ];

			if ( !isAdminList[ i ] ) {								
				arl.setResult ( i , False , INSUFFICIENT_PERM_ERROR_STR );
				featNameToUnlinkSet.remove ( featName );
			}
		}
		
		Set<Id> linkIdSet = new Set<Id> {};
		Map<Id , Feature__c[]> featListByLinkId = new Map<Id , Feature__c[]> {};
		Set<String> linkedFeatNameSet = new Set<String> {};
		
//		Get list of Entitled Features matching the input list.
//		------------------------------------------------------
		for ( Feature__c feature : [select Name__c , Permission_Required__c , 
									Core_Feature__c , Feature_UGPR_Link__c
									from Feature__c
									where Name__c in :featNameToUnlinkSet
									and Feature_UGPR_Link__c != Null]
								) {
			linkIdSet.add ( feature.Feature_UGPR_Link__c );
			if ( !featListByLinkId.containsKey ( feature.Feature_UGPR_Link__c ) ) {
				featListByLinkId.put ( feature.Feature_UGPR_Link__c , new Feature__c[] {} );
			}
			featListByLinkId.get ( feature.Feature_UGPR_Link__c ).add ( feature );
			linkedFeatNameSet.add ( feature.Name__c );
		}
		System.debug ( 'FEAT LIST BY LINK ID:\n' + featListByLinkId );
		
//		Prune Feature Names that have no Entitlements at all.
//		-----------------------------------------------------
		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			String featName = featNameList[ i ];
			if ( !featNameToUnlinkSet.contains ( featName ) ) {
				continue;
			}
			if ( !linkedFeatNameSet.contains ( featName ) ) {
				featNameToUnlinkSet.remove ( featName );
				arl.setResult ( i , False , 'Feature "' + featName + '" not permissioned for ['
								+ whoType + '] [' + whoId + ']' );
			}
		} 
		
//		Get list of UGPRs matching the input whoId and the above
//		Entitled Features.
//		-----------------------------------------------------------------
		Feature_UGPR__c[] UGPRToDelList = [ select 
												Feature_UGPR_Link__c , 
												UGPR_Id__c
											from
												Feature_UGPR__c
											where
												Feature_UGPR_Link__c in :linkIdSet and 
												UGPR_Id__c = :whoId
											];

//		Extract the set of UGPRLinks to be deleted, and identify the 
//		corresponding Entitled Features to be deleted.
//		------------------------------------------------------------  
		Id[] linkIdToDelList = new Id[] {};
		Id[] featIdToDelList = new Id[] {};
		Map<String , Integer> featToDelIdxByName = new Map<String , Integer> {};
		
		Integer idx = 0;
		for ( Feature_UGPR__c UGPR : UGPRToDelList ) {
			linkIdToDelList.add ( UGPR.Feature_UGPR_Link__c );
			for ( Feature__c f : featListByLinkId.get ( UGPR.Feature_UGPR_Link__c ) ) {
				featIdToDelList.add ( f.Id );
				featToDelIdxByName.put ( f.Name__c , idx++ );
			} 
		}
		System.debug ( 'UGPR TO DEL LIST:\n' + UGPRToDelList );
		System.debug ( 'FEATURE TO DEL LIST:\n' + featIdToDelList );
		System.debug ( 'FEATURE TO DEL IDX BY NAME:\n' + featToDelIdxByName );

//		Tear down the resulting lists of objects, folding the Feature delete results
//		into our result list.  (Note - removing an UGPRLink record also tears down
//		the Detail-side UGPR records.)
//		-----------------------------------------------------------------------------
		deleteRecords ( linkIdToDelList );
		AceWSResultList dbArl = deleteRecords ( featIdToDelList );
		
		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			String featName = featNameList[ i ];
			Integer featToDelIdx = featToDelIdxByName.get ( featName );
			if ( featToDelIdx == Null ) {
				continue;
			}
			
			AceWSResult dbAr = dbArl.getResult ( featToDelIdx );		
			arl.setResult ( i , dbAr.bSuccess , dbAr.statusMsg );
		}
			
		return arl;
	}

//	============================================================================
//	Method:	deleteFeatures
//
//	Desc:	Function to delete Features with the specified names.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================						
	public static AceWSResultList deleteFeatures ( String[] featNameList ) {
		
		AceWSResultList arl = new AceWSResultList ( featNameList.size () , True );
		
//		Validate the user permissions on the Feature list.
//		-------------------------------------------------
		Map<String , Integer[]> featIdxListByName = new Map<String , Integer[]> {};	 				
		Boolean[] isAdminList = featureCacheUtil.isFeatureAdministrator ( featNameList );	
		
		for ( Integer i = 0 ; i < featNameList.size () ; i++ ) {
			if ( !isAdminList[ i ] ) {
				arl.setResult ( i , False , INSUFFICIENT_PERM_ERROR_STR );
			}
			else {
				String featName = featNameList[ i ];
				if ( !featIdxListByName.containsKey ( featName ) ) {
					featIdxListByName.put ( featName , new Integer[] {} );
				}
				featIdxListByName.get ( featName ).add ( i );
			}
		}
		if ( featIdxListByName.isEmpty () ) {
			return arl;
		}
		 
//		Grab the remaining Features from the db.
//		----------------------------------------
		Feature__c[] featList = [ select Id , Name__c from Feature__c
										where Name__c in :featIdxListByName.keySet() ];
		Id[] idList = new Id[] {};
		Set<String> dbFeatNameSet = new Set<String> {};
		for ( Feature__c feat : featList ) {
			idList.add ( feat.Id );
			dbFeatNameSet.add ( feat.Name__c );
		}

//		Identify and flag any input Feature Names not corresponding to
//		actual Features.
//		--------------------------------------------------------------
		for ( Integer i = 0 ; i < featNameList.Size () ; i++ ) {
			if ( !dbFeatNameSet.contains ( featNameList[ i ] ) ) {
				arl.setResult ( False , 'No such feature "' + featNameList[ i ] + '"' );
			}
		}

//		Delete the Features and slot the results back into our result list.
//		Note that the Feature trigger will take care of tearing down any
//		Attributes that might be attached to these Features.
//		-------------------------------------------------------------------
		AceWSResultList dbArl = deleteRecords ( idList );
		
		for ( Integer featIdx = 0 ; featIdx < featList.size () ; featIdx++ ) {		
			String featName = featList[ featIdx ].Name__c;
			Boolean bSuccess = dbArl.getResult( featIdx ).bSuccess;
			String msg = dbArl.getResult( featIdx ).statusMsg;
						
			for ( Integer i : featIdxListByName.get ( featName ) ) {
				if ( arl.getResult( i ).bSuccess != False ) {
					arl.getResult( i ).bSuccess = bSuccess;
					arl.getResult( i ).statusMsg = msg;
				}
			}
		}

		return arl;
	}

//	============================================================================
//	Method:	setAttributes
//
//	Desc:	Function to insert/update the Attributes corresponding to the
//			specified list of Attribute names and values.  Attaches the
//			Attributes to the CORE Feature.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================
	public static AceWSResultList setAttributes ( String featName ,
													Attribute[] attrList ) {
		
		Map<String , AceWSResultList> arlByFeatName 
				= setAttributes ( new Map<String , Attribute[]> { featName => attrList } );
		
		return arlByFeatName.get ( featName );
	}
		

	public static Map<String , AceWSResultList> setAttributes (
												Map<String , Attribute[]> attrsByFeatName ) {
		
//		Initialize Attribute and result set maps.
//		-----------------------------------------
		Map<String , Map<String , Attribute>> attrMapByFeatName 
											= new Map<String , Map<String , Attribute>> {};
		Map<String , AceWSResultList> arlByFeatName = new Map<String , AceWSResultList> {};

		Set<String> noPermFeatNameSet = new Set<String> {};
							
		for ( String featName : attrsByFeatName.keySet () ) {

			Attribute[] attrList = attrsByFeatName.get ( featName );
			
			AceWSResultList arl = new AceWSResultList ( attrList.Size () , True );
			arlByFeatName.put ( featName , arl );
			
//			Validate the user permission for this feature.
//			----------------------------------------------
			if ( !featureCacheUtil.isFeatureAdministrator ( featName ) ) {
				arl.setResult ( False , INSUFFICIENT_PERM_ERROR_STR );
				noPermFeatNameSet.add ( featName );
				continue;
			}

			Map<String , Attribute> attrByName = new Map<String , Attribute> {};
			for ( Attribute attrEntry : attrList ) {
				attrByName.put ( attrEntry.Name , attrEntry );
			}
			attrMapByFeatName.put ( featName , attrByName );						
		}
		
//		Get Core Features matching the input feature names.
//		---------------------------------------------------
		Map<String , Feature__c> featByName = new Map<String , Feature__c> {};
		Map<Id , Feature__c> featById = new Map<Id , Feature__c> {};
		Map<String , Map<String , Attribute__c>> dbAttrByFeatAndName 
										= new Map<String , Map<String , Attribute__c>> {};
										
		for ( Feature__c feat : [ select Id , Name__c
									from Feature__c
									where Name__c in :attrMapByFeatName.keySet ()
									and Core_Feature__c = Null
								]
		) {
			featByName.put ( feat.Name__c , feat );
			featById.put ( feat.Id , feat );
			dbAttrByFeatAndName.put ( feat.Name__c , new Map<String , Attribute__c> {} );
		}
		
//		Grab the Attributes already hooked to these Core Features.
//		----------------------------------------------------------
		for ( Attribute__c attr : [ select Id , Name , Value__c , 
										Feature__r.Name__c , 
										User_Overridable__c
										from Attribute__c
										where Feature__c in :featById.keySet () ]
		) {
			dbAttrByFeatAndName.get ( attr.Feature__r.Name__c ).put ( attr.Name , attr );
		}
 
//		Now go through the Features and create their Attributes.
//		--------------------------------------------------------
		Attribute__c[] upsertAttrList = new Attribute__c[] {};
		
		for ( String featName : attrsByFeatName.keySet () ) {
			AceWSResultList arl = arlByFeatName.get ( featName );
			
			Feature__c feat = featByName.get ( featName );
			if ( feat == Null ) {		
				arl.setResult ( False , 'No such Feature "' + featName + '"' );
				continue;
			}
										
//			...create the Attributes...
//			---------------------------				
			for ( Attribute attr : attrsByFeatName.get ( featName ) ) {
				Map<String , Attribute__c> dbAttrByName = dbAttrByFeatAndName.get ( featName );
				Attribute__c newDbAttr;
				
				if ( dbAttrByName.containsKey ( attr.Name ) ) {
					newDbAttr = dbAttrByName.get ( attr.Name );
					newDbAttr.Value__c = attr.Value;
					newDbAttr.User_Overridable__c = attr.bUserOverridable;
				}
				else {
					newDbAttr = new Attribute__c ( Name = attr.Name , Value__c = attr.Value ,
													Feature__c = feat.Id ,
													User_Overridable__c = attr.bUserOverridable );
				}
			
				upsertAttrList.add ( newDBAttr );
			}
		}
		
//		Now insert/upsert the new Attributes.
//		-------------------------------------
		Integer upsertSize = upsertAttrList.size ();
		if ( upsertSize > 0 ) {
			AceWSResultList uarl = upsertRecords ( upsertAttrList );
			
//			Distribute the result list into the output result structure.
//			------------------------------------------------------------
			for ( Integer i = 0 ; i < upsertSize ; i++ ) {
				Attribute__c attr = upsertAttrList[ i ];
				Id featId = attr.Feature__c;
				String featName = featById.get ( featId ).Name__c;
				AceWSResultList arl = arlByFeatName.get ( featName );
				arl.resultList.add ( uarl.getResult ( i ) );
			}	
		}	
		
		return arlbyFeatName;
	}
	
//	============================================================================
//	Method:	overrideAttributes
//
//	Desc:	Function to override the specified Attributes for the specified
//			User/Group/Role/Profile.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================					
	public static AceWSResultList overrideAttributes ( Id whoId , String whoType ,
															String featName ,
															Attribute[] attrList ) {

		AceWSResultList arl = new AceWSResultList ( attrList.size () , True );
		
		if ( whoId == Null ) {
			whoId = UserInfo.getUserId ();
		}
		else {
			whoId = featureCacheUtil.idTo18Char ( whoId );
		}
		
//		Grab existing Features + Attributes per specified args.
//		-------------------------------------------------------
		Map<String , String> attrValByName = new Map<String , String> {};
		for ( Attribute attr : attrList ) {
			attrValByName.put ( attr.Name , attr.Value );
		}

		Feature__c coreFeat;
		Map<Id , Feature__c> overFeatById = new Map<Id , Feature__c> {};
		Map<Id , Map<String , Attribute__c>> attrMapByFeat 
											= new Map<Id , Map<String , Attribute__c>> {};
		
		Boolean bCheckFeatAdmin = ( whoType != featureCacheUtil.USER_STRING );
		
		for ( Feature__c feat : [select Id , Core_Feature__c ,
									( select Name , Value__c , User_Overridable__c
										from Attributes__r
										where Name in :attrValByName.keySet ()
									)
								from Feature__c
								where Name__c = :featName
								and ( 
									Core_Feature__c = Null
									or UGPR_Override__c = True
								) ]
						) {

//			Remember which of these features is the Core feature.
//			-----------------------------------------------------			
			if ( feat.Core_Feature__c == Null ) {
				coreFeat = feat;
			}
		
//			Accumulate a FeatureId -> { AttribName , AttribVal } map.
//			Also - check if any Core Attribute is flagged as Non-User-Overridable.
//			----------------------------------------------------------------------		
			attrMapByFeat.put ( feat.Id , new Map<String , Attribute__c> {} );	
			for ( Attribute__c attr : feat.Attributes__r ) {
				attrMapByFeat.get ( feat.Id ).put ( attr.Name , attr );
				
				if ( feat.Core_Feature__c == Null && attr.User_Overridable__c == False ) {
					bCheckFeatAdmin = True;
				}
			}
		}
				
//		Bail if we found no matching Feature.
//		-------------------------------------
		if ( coreFeat == Null ) {
			arl.setResult ( False , 'No such Feature "' + featName + '"' );
			return arl;
		}
		
//		Check for Feature administrator privilege, if necessary.
//		--------------------------------------------------------
		if ( bCheckFeatAdmin == True ) {
			
//			At least one attribute is not user-overridable - meaning, the context user
//			must be a feature administrator.
//			--------------------------------------------------------------------------
			if ( ! featureCacheUtil.isFeatureAdministrator ( featName ) ) {
				arl.setResult ( False , INSUFFICIENT_PERM_ERROR_STR );
				return arl;
			}
		}

//		Link the whoId to the appropriate feature.  (It might already be linked.)
//		-------------------------------------------------------------------------		
		Feature__c[] linkFeatList = linkUGPRToFeature ( featName , whoId , whoType , True , False );
		if ( linkFeatList == Null || linkFeatList.isEmpty () ) {
			arl.setResult ( False , 'Could not link [' + whoType + '] [' + whoId + '] to [' + featName + ']' );
			return arl;
		}

//		Create and insert/update the Attributes.
//		----------------------------------------
		Attribute__c[] attrsToUpsert = new Attribute__c[] {};
		
		for ( String attrName : attrValByName.keySet () ) {
			String attrVal = attrValByName.get ( attrName );
			Attribute__c attr = Null;
			
			for ( Feature__c linkFeat : linkFeatList ) {
				Map<String , Attribute__c> existingAttrMap = attrMapByFeat.get ( linkFeat.Id );
				if ( existingAttrMap != Null && existingAttrMap.containsKey ( attrName ) ) {
					attr = existingAttrMap.get ( attrName );
					attr.Value__c = attrVal;
					attrsToUpsert.add ( attr );
					break;
				}
			}
			if ( attr == Null ) {
				attr = new Attribute__c ( Name = attrName , Value__c = attrVal ,
														Feature__c = linkFeatList[ 0 ].Id );
				attrsToUpsert.add ( attr );
			}
		}
		
		arl = upsertRecords ( attrsToUpsert );
		return arl;
	}

//	============================================================================
//	Method:	unOverrideAttributes
//
//	Desc:	Function to remove the Override Attributes corresponding to the
//			specified list of Attribute names, and the specified User/Group/
//			Profile/Role Id.
//		 
//	Return:	AceWSResultList record containing unoverride results.
//	============================================================================					
	public static AceWSResultList unOverrideAttributes ( Id whoId , String whoType ,
													String featName , 
													String[] attrNameList ) {

		AceWSResultList arl = new AceWSResultList ( attrNameList.size () , True );
		
		if ( whoId == Null ) {
			whoId = UserInfo.getUserId ();
		}
		else {
			whoId = featureCacheUtil.idTo18Char ( whoId );
		}
		
//		First get the Override Features matching the featureName + attrib list.
//		-----------------------------------------------------------------------
		Map<String , Feature__c[]> featListByAttrName 
												= new Map<String , Feature__c[]> {};
		Map<Id , Map<String , Attribute__c>> attrByFeatIdAndAttrName
												= new Map<Id , Map<String , Attribute__c>> {};
		Map<Id , Id> UGPRLinkByFeat = new Map<Id , Id> {};
		
		for ( Feature__c feat : [select Name__c , Feature_UGPR_Link__c ,
									( select Id , Name , Value__c from Attributes__r
										where Name in :attrNameList
									)
								from Feature__c
								where Name__c = :featName
								and UGPR_Override__c = True ]
						) {
			for ( Attribute__c attr : feat.Attributes__r ) {
				if ( !featListByAttrName.containsKey ( attr.Name ) ) {
					featListByAttrName.put ( attr.Name , new Feature__c[] {} );
				}
				featListByAttrName.get ( attr.Name ).add ( feat );
				
				if ( !attrByFeatIdAndAttrName.containsKey ( feat.Id ) ) {
					attrByFeatIdAndAttrName.put ( feat.Id , new Map<String , Attribute__c> {} );
				}
				attrByFeatIdAndAttrName.get ( feat.Id ).put ( attr.Name , attr );
			}
			UGPRLinkByFeat.put ( feat.Id , feat.Feature_UGPR_Link__c );
		}
		
		System.debug ( UGPRLinkByFeat );
		
//		Get the UGPRs matching the specified UGPRLinks these Features
//		are linked to.
//		-------------------------------------------------------------
		Map<Id , Feature_UGPR__c[]> UGPRListByLink = new Map<Id , Feature_UGPR__c[]> {};
		
		for ( Feature_UGPR__c UGPR : [select Id , Feature_UGPR_Link__c
										from Feature_UGPR__c
										where Feature_UGPR_Link__c in :UGPRLinkByFeat.Values ()
										and UGPR_Id__c = :whoId
									]
								) {
			if ( !UGPRListByLink.containsKey ( UGPR.Feature_UGPR_Link__c ) ) {
				UGPRListByLink.put ( UGPR.Feature_UGPR_Link__c , new Feature_UGPR__c[] {} );
			}
			UGPRListByLink.get ( UGPR.Feature_UGPR_Link__c ).add ( UGPR );
		}
	
		System.debug ( UGPRListByLink );

//		Go through the Attribute Names, and find the Attribute record attached to
//		the Feature record linked to our specified User.
//		-------------------------------------------------------------------------
		Id[] idList = new Id[] {};
		Map<String , Integer> delAttrIdxbyName = new Map<String , Integer> {};
		Integer attrIdx = 0;
		for ( String attrName : featListByAttrName.keySet () ) {
			for ( Feature__c feat : featListByAttrName.get ( attrName ) ) {
				Id UGPRLinkId = UGPRLinkByFeat.get ( feat.Id );
				if ( UGPRListByLink.containsKey ( UGPRLinkId ) ) {
					Attribute__c attr = attrByFeatIdAndAttrName.get ( feat.Id ).get ( attrName );
					idList.add ( attr.Id );
					delAttrIdxByName.put ( attrName , attrIdx++ );
				}
			}
		}

//		Un-override these attributes by simply deleting them.
//		-----------------------------------------------------
		AceWSResultList dbArl = deleteRecords ( idList );
		
		for ( Integer i = 0 ; i < attrNameList.Size () ; i++ ) {
			String attrName = attrNameList[ i ];
			if ( delAttrIdxByName.containsKey ( attrName ) ) {
				attrIdx = delAttrIdxByName.get ( attrName );
				AceWSResult dbAr = dbArl.getResult ( attrIdx );
				arl.setResult ( i , dbAr.bSuccess , dbAr.statusMsg );
			}
			else {
				arl.setResult ( i , False , 'No such override Attribute "' + attrName + '"' );
			}
		}
		
		return arl;
	}

//	============================================================================
//	Method:	deleteAttributes
//
//	Desc:	Function to remove the Attributes corresponding to the
//			specified list of Attribute names, from the specified Core
//			Feature.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================					
	public static AceWSResultList deleteAttributes ( String featName , String[] attrNameList ) {

		AceWSResultList arl = new AceWSResultList ( attrNameList.size () , True );
		
//		Validate the user permission.
//		-----------------------------												
		if ( ! featureCacheUtil.isFeatureAdministrator ( featName ) ) {
			arl.setResult ( False , INSUFFICIENT_PERM_ERROR_STR );
			return arl;
		}

//		Keep track of what Attribute name is where in the input list.
//		-------------------------------------------------------------
		Map<String , Integer[]> attrIdxListByName = new Map<String , Integer[]> {};	 						
		for ( Integer i = 0 ; i < attrNameList.size () ; i++ ) {
			String attrName = attrNameList[ i ];
			if ( !attrIdxListByName.containsKey ( attrName ) ) {
				attrIdxListByName.put ( attrName , new Integer[] {} );
			}
			attrIdxListByName.get ( attrName ).add ( i );
		}

//		Get Core Feature by featureName.
//		--------------------------------
		Feature__c feat;
		Feature__c[] featList = [select Id
									from Feature__c
									where Name__c = :featName
									and Core_Feature__c = Null
									limit 1];
		if ( featList.size() == 0 ) {
			arl.setResult ( False , 'No such Feature "' + featName + '"' );
			return arl;
		}
		feat = featList[ 0 ];
		
//		Grab the Attributes from the db.
//		--------------------------------
		Attribute__c[] attrList = [ select Id , Name , Value__c from Attribute__c
										where Feature__c = :feat.Id 
										and Name in :attrNameList ];
		Id[] idList = new Id[] {};
		Set<String> dbAttrNameSet = new Set<String> {};
		for ( Attribute__c attr : attrList ) {
			idList.add ( attr.Id );
			dbAttrNameSet.add ( attr.Name );
		}

//		Identify and flag any input Attribute Names not corresponding to
//		actual Attributes.
//		----------------------------------------------------------------
		for ( Integer i = 0 ; i < attrNameList.Size () ; i++ ) {
			if ( !dbAttrNameSet.contains ( attrNameList[ i ] ) ) {
				arl.setResult ( False , 'No such attribute "' + attrNameList[ i ] + '"' );
			}
		}

//		Delete the Attributes and slot the results back into our result list.
//		---------------------------------------------------------------------
		AceWSResultList dbArl = deleteRecords ( idList );
		
		for ( Integer attrIdx = 0 ; attrIdx < attrList.size () ; attrIdx++ ) {		
			String attrName = attrList[ attrIdx ].Name;
			Boolean bSuccess = dbArl.getResult( attrIdx ).bSuccess;
			String msg = dbArl.getResult( attrIdx ).statusMsg;
						
			for ( Integer i : attrIdxListByName.get ( attrName ) ) {
				if ( arl.getResult( i ).bSuccess != False ) {
					arl.getResult( i ).bSuccess = bSuccess;
					arl.getResult( i ).statusMsg = msg;
				}
			}
		}

		return arl;
	}

//	============================================================================
//	Method:	linkUGPRToFeature
//
//	Desc:	Function to link the User/Group/Role/Profile whoId to the specified 
//			Feature Name.  Uses linkUGPRToFeatures to do all the heavy lifting.
//		 
//	Return:	The Feature__c record linking the whoId with the Feature Name.
//	============================================================================					
	static Feature__c[] linkUGPRToFeature ( String featName , Id whoId , String whoType ,
											Boolean bUserOverride ,
											Boolean bRollUpRoleHierarchy ) {
												
		Map<String , Feature__c[]> linkedFeatByName
								= linkUGPRToFeatures ( new String[] { featName } ,
														whoId , whoType , 
														bUserOverride ,
														bRollUpRoleHierarchy );
		return linkedFeatByName.get ( featName );	
	}
	
//	============================================================================
//	Method:	linkUGPRToFeatures
//
//	Desc:	Function to link the specified User/Group/Role/Profile whoId
//			to the specified list of Feature Names, via Feature_UGPR_Link__c linkage
//			records, Feature_UGPR__c records and Feature__c records.
//			The 'whoType' argument determines what the whoId refers to.
//		 
//	Return:	A FName -> linkedFeature map, showing what linked Feature__c record
//	links the whoId with each Feature Name.
//	============================================================================					
	static Map<String , Feature__c[]> linkUGPRToFeatures (
												String[] featNames ,
												Id whoId , String whoType ,
												Boolean bUserOverride ,
												Boolean bRollUpRoleHierarchy ) {
												
		Map<String , Feature__c> coreFeatByFName = new Map<String , Feature__c> {};
		Map<Id , Feature__c> linkedFeatByUGPRLink = new Map<Id , Feature__c> {};
		
		Set<Id> linkIdSet = new Set<Id> {};
											
//		Get list of core + linked Features matching the input list.
//		-----------------------------------------------------------
		for ( Feature__c feat : [select Name__c , Permission_Required__c , 
									Core_Feature__c , Feature_UGPR_Link__c ,
									UGPR_Override__c
									from Feature__c
									where Name__c in :featNames]
								) {
			if ( feat.Feature_UGPR_Link__c != Null && feat.UGPR_Override__c == bUserOverride ) {
				linkIdSet.add ( feat.Feature_UGPR_Link__c );
				linkedFeatByUGPRLink.put ( feat.Feature_UGPR_Link__c , feat );
			}
			else if ( feat.Core_Feature__c == Null ) {
				coreFeatByFName.put ( feat.Name__c , feat );
			}
		}
		
//		Get lists of users/grps/roles/profiles already associated with the
//		already-linked Features.
//		------------------------------------------------------------------
		Map<String , Feature__c[]> linkedFeatByName = new Map<String , Feature__c[]> {};
		Set<String> unlinkedFNameSet = new Set<String> {};
		
		for ( Feature_UGPR__c UGPR : [ select
											Feature_UGPR_Link__c , 
											UGPR_Id__c
										from
											Feature_UGPR__c
										where
											Feature_UGPR_Link__c in :linkIdSet and 
											UGPR_Id__c = :whoId
										]
		) {
			System.debug ( 'UGPR : [' + UGPR + ']' );

			Feature__c linkedFeat = linkedFeatByUGPRLink.get ( UGPR.Feature_UGPR_Link__c );
			if ( !linkedFeatByName.containsKey ( linkedFeat.Name__c ) ) {
				linkedFeatByName.put ( linkedFeat.Name__c , new Feature__c[] {} );
			}
			linkedFeatByName.get ( linkedFeat.Name__c ).add ( linkedFeat );
		}
		
		for ( String fName : featNames ) {
			
//			Skip invalid Feature names.
//			---------------------------		
			if ( !coreFeatByFName.containsKey ( fName ) ) {
				System.debug ( 'ERROR : linkUGPRsToFeatures : invalid Feature name "' + fName + '"' );
			}
			
//			Get a set of Ids to be linked, skipping those already linked.
//			-------------------------------------------------------------
			else if ( linkedFeatByName.containsKey ( fName ) ) {				
					System.debug ( 'INFO : feature [' + fName + '] already linked to ' 
									+ whoType + ' Id [' + whoId + '].' );
			}
			else {
				unlinkedFNameSet.add ( fName );
			}
		}
		
//		If every Feature is already linked, just bail now.
//		--------------------------------------------------
		if ( unlinkedFNameSet.isEmpty () ) {
			System.debug ( 'INFO : nothing to do!' );
			return linkedFeatByName;
		}
		
//		Make UGPRLink and UGPR records to hook everything together.
//		-----------------------------------------------------------
		Feature_UGPR_Link__c link = new Feature_UGPR_Link__c ();
		Insert link;

		Feature_UGPR__c UGPR = new Feature_UGPR__c (
								UGPR_Id__c = whoId ,
								UGPR_Type__c = whoType ,
								Roll_Up_Role_Hierarchy__c = bRollUpRoleHierarchy ,
								Feature_UGPR_Link__c = link.Id
							);
		insert UGPR;

//		Make Linked Feature records to hook to the UGPRLink record.
//		Skip any invalid Feature names.
//		--------------------------------------------------------------
		Feature__c[] newLinkedFeatList = new Feature__c[] {};
		
		for ( String fName : unlinkedFNameSet ) {
			Feature__c coreFeat = coreFeatByFName.get ( fName );
			if ( coreFeat == Null ) {
				continue;
			}
		
			Feature__c linkedFeat = new Feature__c ( 
										Name = featureCacheUtil.mkObjName ( fName ) ,
										Name__c = fName ,
										Core_Feature__c = coreFeat.Id ,
										Feature_UGPR_Link__c = link.Id ,
										UGPR_Override__c = bUserOverride
									);
			newLinkedFeatList.add ( linkedFeat );
			linkedFeatByName.put ( fName , new Feature__c[] { linkedFeat } );
		}
		Insert newLinkedFeatList;
				
		return linkedFeatByName;	
	}
	
//	============================================================================
//	Method:	mvFeatureTree
//
//	Desc:	Method to move the Feature Tree with the specified root name to
//			the specified target root name.
//
//			Will probably have to be revamped, to allow iterative execution.
//		 
//	Return:	AceWSResult record containing move results.
//	============================================================================					
	public static AceWSResult mvFeatureTree ( String rootName , String tgtName ) {

		String thisMethod = 'mvFeatureTree';
		
//		Basic sanity checks.
//		--------------------
		if ( rootName == Null || rootName == '' || rootName.endsWith ( '.' ) ) {
			return new AceWSResult ( False , 'Invalid root name [' + rootName + ']' , thisMethod );
		}
		if ( tgtName == Null || tgtName == '' || tgtName == '.' ) {
			return new AceWSResult ( False , 'Invalid target name [' + tgtName + ']' , thisMethod );
		}
		 
//		Massage target tree if necessary.
//		---------------------------------
		if ( tgtName.endsWith ( '.' ) ) {
			tgtName += featureCacheUtil.getFeatureLeafName ( rootName );
		}
		
//		Don't allow the tree to be moved onto, or into, itself.
//		-------------------------------------------------------
		if ( rootName == tgtName ) {
			return new AceWSResult ( True , 'Root name [' + rootName + '] same as target name - nothing to do!' ,
										thisMethod );
		}
		if ( tgtName.startsWith ( rootName ) ) {
			return new AceWSResult ( False , 
										'Cannot move feature tree [' + rootName 
										+ '] into a descendant of itself [' + tgtName + ']'  ,
									thisMethod );
		}
		 
//		Check for existence of Feature at rootName.
//		-------------------------------------------
		Feature__c[] rootFeats = [ select
										Name__c ,
										Core_Feature__c ,
										Parent_Feature__c
									from
										Feature__c
									where
										Name__c = :rootName 
								];
		if ( rootFeats.isEmpty () ) {
			return new AceWSResult ( False , 'No such feature tree : [' + rootName + ']' , thisMethod );
		}
		
//		Create the Target ancestors as necessary.
//		-----------------------------------------
		String parentName = tgtName;
		Set<String> tgtAncestorNameSet = new Set<String> { parentName };
		while ( True ) {
			parentName = featureCacheUtil.getFeatureParentName ( parentName );
			if ( parentName == '' ) {
				break;
			}
			tgtAncestorNameSet.add ( parentName ); 
		}
		
		Map<String , Feature__c> existingTgtAncestorByName = new Map<String , Feature__c> {};
		for ( Feature__c feat : [ select
										Id ,
								 		Name__c
									from
										Feature__c
									where
										Name__c in :tgtAncestorNameSet and
										Core_Feature__c = Null
								]
		) {
			existingTgtAncestorByName.put ( feat.Name__c , feat );
		}
		
//		Make sure the Target name itself doesn't already exist.
//		-------------------------------------------------------
		if ( existingTgtAncestorByName.containsKey ( tgtName ) ) {
			return new AceWSResult ( False , 'Target name [' + tgtName + '] already exists in feature tree.' ,
										thisMethod );
		}
		
		tgtAncestorNameSet.removeAll ( existingTgtAncestorByName.keySet() );
		tgtAncestorNameSet.remove ( tgtName );
		
//		Now do the ancestor creation if necessary.
//		------------------------------------------
		if ( !tgtAncestorNameSet.isEmpty () ) {
			String[] tgtAncestorNameList = new String[] {};
			for ( String featName : tgtAncestorNameSet ) {
				tgtAncestorNameList.add ( featName );
			}
			System.debug ( 'CREATING TGT ANCESTOR FEATURES [' + tgtAncestorNameList + ']' );
			AceWSResultList awrl = createFeatures (	tgtAncestorNameList , False );
			for ( AceWSResult awr : awrl.getResultList () ) {
				if ( !awr.bSuccess ) {
					return new AceWSResult ( False , 
												'Could not create target ancestor tree : ' + awr ,
											thisMethod );
				}
			}
		}
		
//		Get the immediate target Parent, if there is one, grabbing it from the DB
//		if necessary.
//		-------------------------------------------------------------------------
		String tgtParentName = featureCacheUtil.getFeatureParentName ( tgtName );
		System.debug ( 'TGT [' + tgtName + '] PARENT [' + tgtParentName + ']' );
		Feature__c tgtParentFeature;
		
		if ( tgtParentName == '' ) {
			tgtParentFeature = Null;
		}
		else if ( existingTgtAncestorByName.containsKey ( tgtParentName ) ) {
			tgtParentFeature = existingTgtAncestorByName.get ( tgtParentName );
		}
		else {
			tgtParentFeature = [ select
									Id ,
									Name__c
								from
									Feature__c
								where
									Name__c = :tgtParentName and
									Core_Feature__c = Null
								];
		}
		
//		Update the core root Feature of our tree accordingly:
//		- if target has no parent, set the root Feature's Parent Feature ref to Null
//		- if target has a parent, set the root Feature's Parent Feature ref to the target's parent.
//		Also, apply the name change to all root Features (core + override).
//		-------------------------------------------------------------------------------------------
		for ( Feature__c feat : rootFeats ) {
			feat.Name__c = feat.Name__c.replaceFirst ( rootName , tgtName );
			System.debug ( feat.Name__c );
			
			if ( feat.Core_Feature__c == Null ) {
				if ( tgtParentFeature == Null ) {
					feat.Parent_Feature__c = Null;
				}
				else {
					feat.Parent_Feature__c = tgtParentFeature.Id;
				}
			}
		}

//		Apply these updates.
//		--------------------
		update rootFeats;
				
//		Now get all Features descended from rootName and update their names.
//		--------------------------------------------------------------------
		for ( Feature__c[] featList : [ select
											Name__c
										from
											Feature__c
										where
											Name__c like :rootName + '.%'
										order by 
											Name__c
										]
		) {
			for ( Feature__c feat : featList ) {
				feat.Name__c = feat.Name__c.replaceFirst ( rootName , tgtName );
				System.debug ( feat.Name__c );
			}
			update featList;
		}

		return new AceWSResult ( True , '' );
	}
	
//	============================================================================
//	Method:	mkFeatureTreeFromCache
//
//	Desc:	Function to create a Feature tree rooted at the specified Feature
//			name, using specially-formatted Feature Cache records as the raw
//			material.
//
//			Because this is too expensive an operation for any decent-sized
//			Feature tree, this method is designed to be called iteratively; it
//			notifies the user that iteration is necessary, via the AceWSResult
//			object returned.
//		 
//	Return:	An AceWSResult object with the create results.
//	============================================================================					
	public static AceWSResult mkFeatureTreeFromCache ( String rootFeat ) {
		
		String thisMethod = 'mkFeatureTreeFromCache';
		
		if ( rootFeat == Null || rootFeat == '' ) {
			return new AceWSResult ( False , 'ERROR : Must specify a root feature.' , thisMethod );
		}
		
//		Grab the Feature Cache seed records with the specified root Feature.
//		--------------------------------------------------------------------
		Feature_Cache__c[] fcList = [ select
										Name ,
										UGPR_Id__c ,
										Feature_Name__c ,
										Attribute_Name__c ,
										Attribute_Value__c
									from
										Feature_Cache__c
									where
										Name = :rootFeat and
										UGPR_Id__c in ( 'True' , 'False' )
									];
		if ( fcList.isEmpty () ) {
			return new AceWSResult ( False , 
							'ERROR : No Feature Cache seed records with Name = root Feature [' + rootFeat + ']' ,
							thisMethod );
		}
		
//		Build a list of Features and Attributes from the Feature Cache seed records.
//		----------------------------------------------------------------------------
		Map<String , Map<String , Attribute>> featAttrMap = new Map<String , Map<String , Attribute>> {};
		
		for ( Feature_Cache__c fc : fcList ) {
			if ( !featAttrMap.containsKey ( fc.Feature_Name__c ) ) {
				featAttrMap.put ( fc.Feature_Name__c , new Map<String , Attribute> {} );
			}
			if ( fc.Attribute_Name__c != featureCacheUtil.FEATURE_NAME_STRING ) {
				Boolean bOverridable = ( fc.UGPR_Id__c == 'True' );
				featAttrMap.get ( fc.Feature_Name__c ).put ( fc.Attribute_Name__c , 
													new Attribute ( fc.Attribute_Name__c , 
																	fc.Attribute_Value__c ,
																	bOverridable )
												);
			}
		}

//		Make a sorted list of Features to be created.
//		---------------------------------------------
		String[] featNameList = new String[] {};
		for ( String featName : featAttrMap.keySet () ) {
			featNameList.add ( featName );
		}
		featNameList.sort ();

//		Initialize our SOQL governor limit variables.
//		---------------------------------------------
		Integer maxSoqlCount = Limits.getLimitQueries ();
		Integer soqlCount = Limits.getQueries ();

//		Go thru the Feature list, creating each Feature and its Attributes.
//		Do it in batches, ten Features at a time.
//		-------------------------------------------------------------------
		Map<String , Attribute[]> createAttrMap = new Map<String , Attribute[]> {};
		String[] createFeatNameList = new String[] {};
		
		for ( Integer idx = 0 ; idx < featNameList.size () ; idx++ ) {
			
			String featName = featNameList[ idx ];

			if ( maxSoqlCount - soqlCount < 20 ) {
				return new AceWSResult ( True , 
								'SOQL COUNT [' + soqlCount + '] APPROACHING LIMIT [' 
										+ maxSoqlCount + '] - EXITING THIS PASS.' ,
								thisMethod );
			} 
		
			createAttrMap.put ( featName , featAttrMap.get ( featName ).values () );
			createFeatNameList.add ( featName );
			if ( idx == featNameList.Size () - 1 || Math.mod ( idx + 1 , 6 ) == 0 ) {
				
//				...create the Features...
//				-------------------------				
				featureCacheUtil.showQueryStats ( 'BEFORE FEATURE CREATION' );
				AceWSResultList awrl = createFeatures ( createFeatNameList , False );
				for ( AceWSResult awr : awrl.getResultList () ) {
					if ( !awr.bSuccess ) {
						return new AceWSResult ( False , 'Could not create features : ' + awr , thisMethod );
					}
				}
			
//				...and their Attributes (if any)...
//				---------------------------------
				System.debug ( 'Creating attributes...' );
				featureCacheUtil.showQueryStats ( 'BEFORE ATTRIBUTE CREATION' );
				Map<String , AceWSResultList> awrlMap = setAttributes ( createAttrMap );
				featureCacheUtil.showQueryStats ( 'AFTER  ATTRIBUTE CREATION' );

				for ( String createFeatName : awrlMap.keySet () ) {
					for ( AceWSResult awr : awrlMap.get ( createFeatName ).getResultList () ) {
						if ( !awr.bSuccess ) {
							return new AceWSResult ( False , 'Could not create attributes : ' + awr , thisMethod );
						}
					}
				}
				
//				Reset the attribute buffer.
//				---------------------------
				createAttrMap.clear ();
				createFeatNameList.clear ();
			}

//			Update our SOQL usage.
//			----------------------			
			soqlCount = Limits.getQueries ();
		}
		
		return new AceWSResult ( True , '' );
	}								
}