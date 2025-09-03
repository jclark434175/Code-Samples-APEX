/*
 * Name: testDataAccount
 * Description: Test Account data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
 
global class testDataAccount {

 	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Account given a name and tier
	 *
	 * Notes: To be used in other test cases
	 */
	global static Account insertRecord(String anAccountName, String aTier) {
		Account anAccount = new Account(Name = anAccountName, Tier__c = aTier);
		insert anAccount;
		return anAccount;
	}
	
	/*
	 * Name: insertRecord 
	 * Description: Create and insert a new Account given a name, tier and record type
	 *
	 * Notes: To be used in other test cases
	 */
	 
	global static Account insertRecord(String anAccountName, String aTier, Id recordTypeId) {
		
		//Account anAccount = new Account(Name = anAccountName, Tier__c = aTier, RecordTypeId = recordTypeId);
		Account anAccount = new Account(Name = anAccountName, Tier__c = aTier);
		insert anAccount;
		return anAccount;
	}
	
	/*
	 * Name: insertRecords
	 * Description: Create and insert a new Account given a name, tier and record type
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Account> createRecords(Integer numOfRecords) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numOfRecords; i++) {
			accounts.add(new Account(Name = 'Account ' + i, Tier__c = 'AA'));
		}
		return accounts;
	}
	
	global static List<Account> insertRecords ( Integer numOfRecords ) {
		List<Account> accounts = createRecords ( numOfRecords );
		insert accounts;
		return accounts;
	}
	
	/*
	 * Name: createRecords
	 * Description: Creates Accounts given record type ids
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Account> createRecords(Id[] recordTypeIds) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < recordTypeIds.Size(); i++) 
		{
			accounts.add(new Account(Name = 'Account ' + i, RecordTypeId = recordTypeIds[i]));
		}
		return accounts;
	}
	/*
	 * Name: insertFailedRecords
	 * Description: Create and insert a new Account given a name, tier and record type
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Account> createFailedRecords(Integer numOfRecords) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numOfRecords; i++) {
			accounts.add(new Account(Name = ''));
		}
		return accounts;
	}
	
	/*
	 * Name: deleteRecord
	 * Description: Clean up Account data
	 *
	 * Notes: To be used in other test cases
	 */
	global static void deleteRecord(Account anAccount, boolean bDeleteDeleteMessage) {
		delete anAccount;
		if (bDeleteDeleteMessage == true) {
			delete [
				Select
					Id
				From
					Delete_Message__c
				Where
					Salesforce_Id__c = :anAccount.Id
					and
					Entity_Name__c = :aceCommon.ENTITY_NAME_ACCOUNT
				
			];
		}
	}
}