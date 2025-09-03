/*
 * Name:        FeatureCache
 *
 * Description:  Contains details about a FeatureCache record.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM.
 */
 
global class FeatureCache {
	
	WebService String Name;	
	WebService String UGPRId;
	WebService String UGPRName;
	WebService String UGPRType;
	WebService Boolean RollUpRoleFlag;
	WebService String FeatureName;
	WebService String AttributeName;
	WebService String AttributeValue;
		
	global FeatureCache () {
	}
	
	global FeatureCache ( Feature_Cache__c dbFC ) {
		try { this.Name = dbFC.Name; } catch ( SObjectException e ) {}
		try { this.UGPRId = dbFC.UGPR_Id__c; } catch ( SObjectException e ) {}
		try { this.UGPRName = dbFC.UGPR_Name__c; } catch ( SObjectException e ) {}
		try { this.UGPRType = dbFC.UGPR_Type__c; } catch ( SObjectException e ) {}
		try { this.RollUpRoleFlag = dbFC.Roll_Up_Role_Hierarchy__c; } catch ( SObjectException e ) {}
		try { this.FeatureName = dbFC.Feature_Name__c; } catch ( SObjectException e ) {}
		try { this.AttributeName = dbFC.Attribute_Name__c; } catch ( SObjectException e ) {}
		try { this.AttributeValue = dbFC.Attribute_Value__c; } catch ( SObjectException e ) {}
	}
	
	global FeatureCache ( String UGPRId , String UGPRName , String UGPRType ,
							Boolean bRollUpRole , 
							String featName , String attrName , String attrVal ) {
		this.UGPRId = UGPRId;
		this.UGPRName = UGPRName;
		this.UGPRType = UGPRType;
		this.RollUpRoleFlag = bRollUpRole;
		this.FeatureName = featName;
		this.AttributeName = attrName;
		this.AttributeValue = attrVal;
	}
	
	global featureCache ( Feature_UGPR__c UGPR , String featName , 
							String attrName , String attrVal ) {
		this.UGPRId = UGPR.UGPR_Id__c;
		this.UGPRName = UGPR.UGPR_Name__c;
		this.UGPRType = UGPR.UGPR_Type__c;
		this.RollUpRoleFlag = UGPR.Roll_Up_Role_Hierarchy__c;
		this.FeatureName = featName;
		this.AttributeName = attrName;
		this.AttributeValue = attrVal;
	}
	
	public Boolean matches ( Feature_Cache__c dbFC ) {
		return ( UGPRId == dbFC.UGPR_Id__c
				&& UGPRName == dbFC.UGPR_Name__c
				&& UGPRType == dbFC.UGPR_Type__c
				&& RollUpRoleFlag == dbFC.Roll_Up_Role_Hierarchy__c
				&& FeatureName == dbFC.Feature_Name__c
				&& AttributeName == dbFC.Attribute_Name__c
				&& AttributeValue == dbFC.Attribute_Value__c
			);
	}
	
	public void setDBFC ( Feature_Cache__c dbFC ) {
		dbFC.UGPR_Id__c = UGPRId;
		dbFC.UGPR_Name__c = UGPRName;
		dbFC.UGPR_Type__c = UGPRType;
		dbFC.Roll_Up_Role_Hierarchy__c = RollUpRoleFlag;
		dbFC.Feature_Name__c = FeatureName;
		dbFC.Attribute_Name__c = AttributeName; 
		dbFC.Attribute_Value__c = AttributeValue;
		
		dbFC.Name = featureCacheUtil.mkObjName ( UGPRName + ':' + FeatureName + ':' + AttributeName );
	}
	
	public void dump () {
		System.debug ( 'FC UGPR [' + UGPRType + '] [' + UGPRName + '] ['
						+ FeatureName + ']: [' + AttributeName + '] = [' + AttributeValue + ']' );
	}
}