/*
 * Name: testTrgContact
 * Description: Test cases for all Contact triggers
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class testTrgContact 
{
	// This test method test the tgContactDelete trigger.
	global static testMethod void testTrgContactDelete () 
	{
		// Synopsis:
		// 1. Create test data
		// 		a. Account
		//      b. List of Contacts
		// 2. Delete-Single
		//		- Delete Contact
		// 3. Delete-Bulk
		//		- Delete List of Contacts			
			
		// 1. Create test data.
		Account acct =  testDataAccount.insertRecord ( 'testAcct' , '2' );
        List<Contact> contacts = testDataContact.insertRecords ( acct.Id , 50 );
        Contact my_contact = testDataContact.insertRecord('Contact', 'Test', acct.Id);
        
        /* *****************************************************************************************
        Trigger Type: Delete-Single

        Case 2.
            Delete the Contact.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete my_contact;
        
        /* *****************************************************************************************
        Trigger Type: Delete-Bulk

        Case 3.
            Delete the list of Contact objects.

        Expected Result: SUCCEED
        ***************************************************************************************** */
        Delete contacts;
	}
	
	global static testMethod void testTrgContactDelete2()
	{
		Account acct =  testDataAccount.insertRecord ( 'testAcct' , '2' );
		Contact my_contact = testDataContact.createRecord('Contact', 'Test', acct.Id, 'EmployeeId');
		
		insert my_contact;
		
		delete my_contact;
		
	}
	
	global static testMethod void testTrgContactDelete3()
	{
		Account acct =  testDataAccount.insertRecord ( 'testAcct' , '2' );
		Contact my_contact = testDataContact.insertRecord('Contact', 'Test', acct, 'contactType');				
		delete my_contact;		
	}	
	global static testMethod void testTrgContactDelete4()
	{
		Account acct =  testDataAccount.insertRecord ( 'testAcct' , '2' );
		Contact my_contact = testDataContact.insertRecord('Contact', 'Test', acct, 'contactType');				
		delete my_contact;
	}
	global static testMethod void testTrgContactDelete_Accounts()
	{
		//insertRecords
		List<Account> accounts = testDataAccount.insertRecords(10);
		List<Contact> contacts = testDataContact.insertRecords(accounts);
		delete contacts;
		
	}
}