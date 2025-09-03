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
public class testTrgACEEntitlement
{
	// This test method test the tgContactDelete trigger.
	public static testMethod void testTrgACEEntitlementDelete () 
	{
		// Synopsis:
		// 1. Create test data
		// 		a. Single ACE Entitlement
		//      b. List of ACE Entitlement objects
		// 2. Delete-Single
		//		- Delete Single ACE Entitlement
		// 3. Delete-Bulk
		//		- Delete List of ACE Entitlement objects		
			
		// 1. Create test data.
		Entitlement__c ae = testDataACEEntitlement.insertRecord('Entitlement');
		List<Entitlement__c> aes = testDataACEEntitlement.insertRecords ( 50 );
        
        /* *****************************************************************************************
        Trigger Type: Delete-Single

        Case 2.
            Delete the ACE Entitlement.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete ae;
        
        /* *****************************************************************************************
        Trigger Type: Delete-Bulk

        Case 3.
            Delete the list of ACE Entitlement objects.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete aes;
	}
	
}