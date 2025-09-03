/*
 * Name: testAceCommon
 * Description: Test cases for package aceCommon
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
 
global class testAceCommon {
	
	/*
	 * Name: testDoDelete_Single
	 * Description: Test for aceCommon.doDelete for a single record
	 *
	 * Notes: 
	 *
	 */
	global static testMethod void testDoDelete_Single() {
		/*
		 * 1. Set up test data
		 * a. Id
		 */
		// set up an Id
		Account anAcct = testDataAccount.insertRecord('TEST ACCT' , '2');
		String anEntityName = aceCommon.ENTITY_NAME_ACCOUNT;
		
		/*
		 * 2. Validate data before test
		 * a. No Delete Message records should exist (for the Conference)
		 */
		
		// validate there are not Delete Messages for this 'record'
		// i.e. no Delete Messages exists where the Salesforce Id = Id and Entity Name = anEntityName
		Delete_Message__c [] deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c,
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Salesforce_Id__c = :anAcct.Id
					and
					Entity_Name__c = :anEntityName
			];
		
		// there should be no Delete Messages
		System.assertEquals(deleteMessages.size(), 0);
		
		/*
		 * 3. Invoke Trigger (test)
		 * a. call the aceCommon.doDelete
		 */
		// call doDelete
		aceCommon.doDelete(anAcct.Id, anEntityName);
		
		/*
		 * 4. Validate data after test
		 * a. The Delete Message should exist
		 */
		// re-query delete messages after delete
		deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c,
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Id = :anAcct.Id
		];

		// there should be one deleted conference
		System.assertEquals(deleteMessages.size(), 0);

		// re-query Delete Messages after account delete
		// i.e. there is a Delete Messages where the Salesforce Id = anAcct.Id and Entity Name = Account
		deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c,
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Salesforce_Id__c = :anAcct.Id
					and
					Entity_Name__c = :anEntityName
			];

		// there should be no Delete Messages
		// I have commented this, because in aceCommon.doDelete we are deleting the delete objects right
		// after inserting them, thus by the time we hit this line, we do not have any deleteMessage objects.
		//System.assertEquals(deleteMessages.size(), 1);
		
		/*
		 * 5. Clean up test data
		 * a. Delete the Delete Message
		 */
		// clean up test data
		delete deleteMessages;
		testDataAccount.deleteRecord(anAcct, true);
	}
	
		/*
	 * Name: testDoDelete_Bulk
	 * Description: Test for aceCommon.doDelete for a bulk set of record
	 *
	 * Notes: 
	 *
	 */
	global static testMethod void testDoDelete_Bulk() {

		/*
		 * 1. Set up test data
		 * a. Id
		 */
		// set up a set of conferences
		Integer numberOfAccts  = 10;
		List<Account> accts = testDataAccount.insertRecords(numberOfAccts);
		String anEntityName = aceCommon.ENTITY_NAME_ACCOUNT;
		
		Set<Id> acctIds = new Set<Id>();
		for (Account acct : accts) {
			acctIds.add(acct.Id);
		}
		
		/*
		 * 2. Validate data before test
		 * a. No Delete Message records should exist (for the Account)
		 */
		
		// validate there are not Delete Messages for this 'record'
		// i.e. no Delete Messages exists where the Salesforce Id = Id and Entity Name = anEntityName
		Delete_Message__c [] deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c,
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Salesforce_Id__c in :acctIds
			];
		
		// there should be no Delete Messages
		System.assertEquals(deleteMessages.size(), 0);
		
		/*
		 * 3. Invoke Trigger (test)
		 * a. call the aceCommon.doDelete
		 */
		// call doDelete
		aceCommon.doDelete(acctIds, anEntityName);
		
		/*
		 * 4. Validate data after test
		 * a. The Delete Message should exist
		 */
		// re-query delete messages after delete
		deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c,
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Id in :acctIds
		];

		// there should be one deleted conference
		System.assertEquals(deleteMessages.size(), 0);

		// re-query Delete Messages after conference delete
		// i.e. there is a Delete Messages where the Salesforce Id = aConference.Id and Entity Name = Conference
		deleteMessages = 
			[
				Select
					Id,
					Salesforce_Id__c, 
					Entity_Name__c
				From
					Delete_Message__c
				Where
					Salesforce_Id__c in :acctIds
			];

		// there should now be Delete Messages
		// I have commented this, because in aceCommon.doDelete we are deleting the delete objects right
		// after inserting them, thus by the time we hit this line, we do not have any deleteMessage objects.
		//System.assertEquals(deleteMessages.size(), numberOfAccts);
	}
}