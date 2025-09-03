/*
 * Name: testTrgACEEntitlement
 * Description: Test cases for all ACE Entitlements
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
global class testTrgACEGlobalSetting 
{
	// This test method test the testTrgACEGlobalSettingDelete trigger.
	global static testMethod void testTrgACEGlobalSettingDelete () 
	{
		// Synopsis:
		// 1. Create test data
		// 		a. Single ACE Global Setting
		//      b. List of ACE Global Setting objects
		// 2. Delete-Single
		//		- Delete Single ACE Global Setting
		// 3. Delete-Bulk
		//		- Delete List of ACE Global Setting objects		
			
		// 1. Create test data.
		Global_Setting__c ags = testDataACEGlobalSetting.insertRecord('Entitlement', '' + 1);
		List<Global_Setting__c> agss = testDataACEGlobalSetting.insertRecords ( 50 );
        
        /* *****************************************************************************************
        Trigger Type: Delete-Single

        Case 2.
            Delete the ACE Global Setting.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete ags;
        
        /* *****************************************************************************************
        Trigger Type: Delete-Bulk

        Case 3.
            Delete the list of ACE Global Setting objects.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete agss;
	}
	
	global static testMethod void testTrgACEGlobalSettingDelete_Value()
	{
		 /* *****************************************************************************************
        Trigger Type: Delete-Single

        Case 2.
            Delete the ACE Global Setting. This is to cover the method 
            createRecord(String aName, String aValue) in testDataACEGlobalSetting

        Expected Result: SUCCEED
        ***************************************************************************************** */
		Global_Setting__c ags = testDataACEGlobalSetting.createRecord('PropertyName', 'PropertyValue');		
		insert ags;
		delete ags;
	}
}