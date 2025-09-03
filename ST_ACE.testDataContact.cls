/*
 * Name: testDataContact
 * Description: Test Contact data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
global class testDataContact {
	/*
	 * Name: createRecord
	 * Description: Create (do not insert) a new Contact given a First Name, Last Name and Account Id
	 *
	 * Notes: To be used in other test cases
	 */
	global static Contact createRecord(String aFirstName, String aLastName, Id anAccountId) {
		return new Contact(FirstName = aFirstName, LastName = aLastName, AccountId = anAccountId);
	}
	/*
	 * Name: createRecord
	 * Description: Create (do not insert) a new Contact given a First Name, Last Name and Account Id
	 *
	 * Notes: To be used in other test cases
	 */
	global static Contact createRecord(String aFirstName, String aLastName, Id anAccountId, String anEmployeeId) {
		return new Contact(FirstName = aFirstName, LastName = aLastName, AccountId = anAccountId, Employee_Id__c = anEmployeeId);		
	}
 	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Contact given a First Name, Last Name and Account Id
	 *
	 * Notes: To be used in other test cases
	 */
	global static Contact insertRecord(String aFirstName, String aLastName, Id anAccountId) {
		Contact aContact = new Contact(FirstName = aFirstName, LastName = aLastName, AccountId = anAccountId);
		insert aContact;
		return aContact;
	}
	
	/*
	 * Name: insertRecords
	 * Description: Create and insert a new Contact given a First Name, Last Name and Account Id
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Contact> insertRecords(Id anAccountId, Integer numberOfRecords) {
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < numberOfRecords; i++) {
			contacts.add(createRecord('Contact', '#' + i, anAccountId));
		}
		insert contacts;
		return contacts;
	}
	
	global static Contact insertRecord(String aFirstName, String aLastName, Account anAccount, String contactType) {
		Contact aContact = new Contact(Firstname = aFirstName, Lastname = aLastName, AccountId = anAccount.Id, Type__c = contactType);
		insert aContact;
		return aContact;
	}
	
	global static List<Contact> insertRecords(List<Account> accounts) {
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < accounts.Size(); i++) {
			contacts.add(createRecord('Contact', '#' + i, accounts[i].Id));
		}
		insert contacts;
		return contacts;
	}
	
	/*
	 * Name: deleteRecord
	 * Description: Clean up Contact data
	 *
	 * Notes: To be used in other test cases
	 */
	global static void deleteRecord(Contact aContact, boolean bDeleteDeleteMessage) {
		delete aContact;
		if (bDeleteDeleteMessage == true) {
			delete [
				Select
					Id
				From
					Delete_Message__c
				Where
					Salesforce_Id__c = :aContact.Id
					and
					Entity_Name__c = :aceCommon.ENTITY_NAME_CONTACT
				
			];
		}
	}
}