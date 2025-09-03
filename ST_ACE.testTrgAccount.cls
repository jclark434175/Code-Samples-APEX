/*
 * Name: testTrgAccount
 * Description: Test cases for all Account triggers
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
 
global class testTrgAccount 
{
	// This test method test the tgContactDelete trigger.
	global static testMethod void testTrgAccount() 
	{
		Account act = testDataAccount.insertRecord('Account Name', 'AAA');
								
		delete act;
		
		Account[] acts = testDataAccount.createRecords(5);
		
		acts = testDataAccount.insertRecords(5);
		Account deleteRecord1 = acts[0];
		
		acts = testDataAccount.createFailedRecords(5);		
		testDataAccount.deleteRecord(deleteRecord1, false);				
	}		
	
	global static testMethod void testTrgAccount_RecordType()
	{		
		Id recordTypeId = null;
		
		Account act = testDataAccount.insertRecord('Account Name', 'AAA',  recordTypeId);
		delete act;
	}
}