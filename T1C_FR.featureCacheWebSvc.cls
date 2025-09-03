/*
 * Name:        featureCacheWebSvc
 *
 * Description: Web Service methods for the Feature Cache infrastructure.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM.
 */ 
 
global class featureCacheWebSvc {
	
//	#############################################################################
//
//	EXPOSED WEBSERVICE METHODS
//
//	#############################################################################

//	============================================================================
//	Method:	rebuildFeatureCache
//
//	Desc:	Function to rebuild all Feature Cache records corresponding to
//			the specified set of Feature Names.
//		 
//	Return:	Nothing.
//	============================================================================					
	Webservice static void rebuildFeatureCache ( String[] featureNameList ) {
		
		Set<Id> userSet;
		Set<String> featureNameSet;
	
		Map<String , Boolean[]> familyByFName;
		
//		Convert lists to sets, for internal consumption.
//		------------------------------------------------
		if ( featureNameList != Null ) {
			familyByFName = new Map<String , Boolean[]> {};
			for ( String fName : featureNameList ) {
				familyByFName.put ( fName , new Boolean[] { True , True } );
			}						
		}	
		featureCacheUtil.rebuildFeatureCache ( familyByFName );			
	}
	
//	============================================================================
//	Method:	createFeature
//
//	Desc:	Wrapper function around 'createFeatures' for single-Feature
//			insertion.
//		 
//	Return:	AceWSResultList record containing create results.
//	============================================================================					
	WebService static AceWSResultList createFeature ( String featureName , Boolean bPermissionReqd ) {
		
		return featureCacheWSUtil.createFeatures ( new String[] { featureName } , bPermissionReqd );
	}

//	============================================================================
//	Method:	createFeatures
//
//	Desc:	Function to insert core Features with the specified names and
//			permissionability flag.
//		 
//	Return:	AceWSResultList record containing create results.
//	============================================================================						
	WebService static AceWSResultList createFeatures ( String[] featureNameList , Boolean bPermissionReqd ) {
		
		return featureCacheWSUtil.createFeatures ( featureNameList , bPermissionReqd );
	}

//	============================================================================
//	Method:	deleteFeature
//
//	Desc:	Wrapper function around 'deleteFeatures' for single-Feature
//			deletion.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================					
	WebService static AceWSResultList deleteFeature ( String featureName ) {
		
		return deleteFeatures ( new String[] { featureName }  );
	}

//	============================================================================
//	Method:	deleteFeatures
//
//	Desc:	Function to delete Features with the specified names.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================						
	WebService static AceWSResultList deleteFeatures ( String[] featureNameList ) {
		
		return featureCacheWSUtil.deleteFeatures ( featureNameList );
	}

//	============================================================================
//	Method:	setAttribute
//
//	Desc:	Wrapper function around 'setAttributes' for single-Attribute
//			insertion/update.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================					
	WebService static AceWSResultList setAttribute ( String featureName , String attribName , String attribVal ,
											Boolean bUserOverridable ) {

		Attribute[] attribList = new Attribute[] {
										new Attribute ( attribName , attribVal , bUserOverridable )
									};
		return featureCacheWSUtil.setAttributes ( featureName , attribList );
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
	WebService static AceWSResultList setAttributes ( String featureName ,
														Attribute[] attribList ) {

		return featureCacheWSUtil.setAttributes ( featureName , attribList );
	}
	
//	============================================================================
//	Method:	overrideAttribute
//
//	Desc:	Wrapper function around 'overrideAttribute' for single-Attribute
//			insertion/update.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================					
	WebService static AceWSResultList overrideAttribute ( Id whoId , String whoType , 
															String featureName , 
															String attribName , String attribVal ) {

		Attribute[] attribList = new Attribute[] { new Attribute ( attribName , attribVal ) };
		return overrideAttributes ( whoId , whoType , featureName , attribList );
	}

//	============================================================================
//	Method:	overrideAttribute
//
//	Desc:	Function to override the specified Attributes for the specified
//			User/Group/Role/Profile.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================					
	WebService static AceWSResultList overrideAttributes ( Id whoId , String whoType ,
															String featureName ,
															Attribute[] attribList ) {

		return featureCacheWSUtil.overrideAttributes ( whoId , whoType , featureName , attribList );
		
	}

//	============================================================================
//	Method:	setUserAttribute
//
//	Desc:	Wrapper function around 'setUserAttributes' for single-Attribute
//			insertion/update.
//		 
//	Return:	Nothing.
//	============================================================================					
	WebService static AceWSResultList setUserAttribute ( Id userId , String featureName , 
														String attribName , String attribVal ) {

		return setUserAttributes ( userId , featureName ,
									new Attribute[] { new Attribute ( attribName , attribVal ) } );
	}
	
//	============================================================================
//	Method:	setUserAttributes
//
//	Desc:	Function to insert/update the User Attributes corresponding to the
//			specified list of Attribute names and values.
//		 
//	Return:	AceWSResultList record containing insert/update results.
//	============================================================================					
	WebService static AceWSResultList setUserAttributes ( Id userId , String featureName ,
											Attribute[] attribList ) {

		return featureCacheWSUtil.overrideAttributes ( userId , featureCacheUtil.USER_STRING , featureName , 
														attribList );
	}

//	============================================================================
//	Method:	deleteAttribute
//
//	Desc:	Wrapper function around 'deleteAttributes' for single-Attribute
//			deletion.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================					
	WebService static AceWSResultList deleteAttribute ( String featureName , String attribName ) {

		return deleteAttributes ( featureName , new String[] { attribName } );
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
	WebService static AceWSResultList deleteAttributes ( String featureName , String[] attribList ) {

		return featureCacheWSUtil.deleteAttributes ( featureName , attribList );
	}		

//	============================================================================
//	Method:	unOverrideAttribute
//
//	Desc:	Function to remove the Override Attribute corresponding to the
//			specified Attribute name.  Wrapper around unOverrideAttributes,
//			which does all the work.
//		 
//	Return:	AceWSResultList record containing unoverride results.
//	============================================================================					
	WebService static AceWSResultList unOverrideAttribute ( Id whoId , String whoType ,
													String featureName , String attribName ) {

		return unOverrideAttributes ( whoId , whoType , featureName , 
														new String[] { attribName } );
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
	WebService static AceWSResultList unOverrideAttributes ( Id whoId , String whoType ,
													String featureName , 
													String[] attribList ) {

		return featureCacheWSUtil.unOverrideAttributes ( whoId , whoType ,
														featureName , attribList );
	}

//	============================================================================
//	Method:	deleteUserAttribute
//
//	Desc:	Wrapper function around 'deleteUserAttributes' for single-Attribute
//			deletion.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================					
	WebService static AceWSResultList deleteUserAttribute ( Id userId , String featureName , 
																String attribName ) {

		return deleteUserAttributes ( userId , featureName , new String[] { attribName } );
	}

//	============================================================================
//	Method:	deleteUserAttributes
//
//	Desc:	Function to remove the User Attributes corresponding to the
//			specified list of Attribute names.
//			Simply calls unOverrideAttributes, which supersedes this fn.
//		 
//	Return:	AceWSResultList record containing delete results.
//	============================================================================					
	WebService static AceWSResultList deleteUserAttributes ( Id userId , String featureName , 
																String[] attribList ) {

		return unOverrideAttributes ( userId , featureCacheUtil.USER_STRING , featureName , attribList );
	}	
	
//	============================================================================
//	Method:	permissionFeature
//
//	Desc:	Wrapper function around 'permissionFeatures' for single-Feature
//			permissioning.
//		 
//	Return:	AceWSResultList record containing permissioning results.
//	============================================================================					
	WebService static AceWSResultList permissionFeature ( String featureName , 
															Id whoId , String whoType ,
															Boolean bRollUpRoleHierarchy ) {	

		return permissionFeatures ( new String[] { featureName } , 
													whoId , whoType , bRollUpRoleHierarchy );
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
	WebService static AceWSResultList permissionFeatures ( String[] featureNames , 
															Id whoId , String whoType ,
															Boolean bRollUpRoleHierarchy ) {	

		return featureCacheWSUtil.permissionFeatures ( featureNames ,
														whoId , whoType ,
														bRollUpRoleHierarchy );
	}

//	============================================================================
//	Method:	unPermissionFeature
//
//	Desc:	Wrapper function around 'unPermissionFeatures' for single-Feature
//			un-permissioning.
//		 
//	Return:	AceWSResultList record containing unpermissioning results.
//	============================================================================					
	WebService static AceWSResultList unPermissionFeature ( String featureName , 
															Id whoId , String whoType ) {

		return unPermissionFeatures ( new String[] { featureName } , whoId , whoType );
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
	WebService static AceWSResultList unPermissionFeatures ( String[] featureNames , 
															Id whoId , String whoType ) {

		return featureCacheWSUtil.unPermissionFeatures ( featureNames , whoId , whoType );
	}
		
//	============================================================================
//	Method:	getAttribute
//
//	Desc:	Function get the AttributeValue corresponding to the specified
//			UserId , AttributeName and FeatureName.
//		 
//	Return:	The AttributeValue.
//	============================================================================					
	WebService static String getAttribute ( Id userId , String featureName , String attribName ) {

		Feature[] featAttrList = featureCacheUtil.getFeatureAttributes ( userId , featureName , attribName , False );
		if ( featAttrList.Size() > 0 ) {			
			return featAttrList[ 0 ].getAttributeValue(attribName);
		}
		else {
			return '';
		}
	}
	
//	============================================================================
//	Method:	getAttributes
//
//	Desc:	Function get the AttributeName/AttributeValue pairs corresponding
//			to the specified UserId and FeatureName.
//		 
//	Return:	A list of <AttributeName, AttributeValue> lists.
//	============================================================================					
	WebService static Attribute[] getAttributes ( Id userId , String featureName ) {
		
		Feature[] featList = featureCacheUtil.getFeatureAttributes ( userId , featureName , Null , False );
		Attribute[] attributeList = new Attribute[] {};
		if ( featList.Size() > 0 ) {
			attributeList = featList[ 0 ].Attributes;
		}
		
		return attributeList;
	}
	
//	============================================================================
//	Method:	getAttributeTree
//
//	Desc:	Function to get the FeatureName/AttributeName/AttributeValue triplets
//			corresponding to the specified UserId, and FeatureName + all its
//			children.
//		 
//	Return:	A list of <FeatureName, AttributeName, AttributeValue> lists.
//	============================================================================					
	WebService static Feature[] getAttributeTree ( Id userId , String featureRootName ) {

		return featureCacheUtil.getFeatureAttributes ( userId , featureRootName , Null , True );
	}	
	
//	============================================================================
//	Method:	mvFeatureTree
//
//	Desc:	Function to re-root the specified Feature tree
//		 
//	Return:	An AceWSResult object with the move results.
//	============================================================================					
	WebService static AceWSResult mvFeatureTree ( String rootName , String tgtName ) {
	
		return featureCacheWSUtil.mvFeatureTree ( rootName , tgtName );
	}
	
//	============================================================================
//	Method:	mkFeatureTreeFromCache
//
//	Desc:	Function to create a Feature tree rooted at the specified Feature
//			name, using specially-formatted Feature Cache records as the raw
//			material.
//		 
//	Return:	An AceWSResult object with the create results.
//	============================================================================					
	WebService static AceWSResult mkFeatureTreeFromCache ( String rootFeat ) {
		
		return featureCacheWSUtil.mkFeatureTreeFromCache ( rootFeat );
	}						
}