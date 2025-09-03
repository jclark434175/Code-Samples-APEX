/**
 * Name: CRCTestWebServices 
 * Description: Contains test methods for webservices for CRC
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCTestWebServices
{
	private static String TEST_ACCT1_NAME = 'Test Account 1';
	private static String TEST_ACCT2_NAME = 'Test Account 2';
	private static String TEST_CONT_FNAME = 'Test_Contact';
	private static String TEST_CONT1_LNAME = 'Contact_1';
	private static String TEST_CONT2_LNAME = 'Contact_2';
	private static String TEST_CONT3_LNAME = 'Contact_3';
	private static String TEST_CONT4_LNAME = 'Contact_4';
	
	private static Account acct1 , acct2;
	private static Contact cont1 , cont2 , cont3 , cont4;
	private static Task task1 , task2;
	private static RecordType rt;
	private static User user1 , user2;
	private static Date TODAY = Date.Today ();
	
	
	
	testmethod static void testgetContacts()
	{
		System.debug('************ start testgetContacts ***********');
		Account testAcc = new Account();
		testAcc.Name = 'test';
		insert testAcc;
		Contact testCont  = new Contact();
		testCont.LastName = 'test Contact';
		testCont.AccountId = testAcc.Id;
		insert testCont;
		List<Contact> tempList;
		CRCContacts obj = new CRCContacts();
		tempList = obj.getContacts(testAcc.Id) ;
		System.assert(tempList != null );
		System.debug(tempList);
		tempList = CRCGridsWebServices.getContacts(testAcc.Id) ;
		System.assert(tempList != null );
		System.debug(tempList);
		System.debug('***********  done testgetContacts ************');
	}
	
	testmethod static void testgetAccountCoverage()
	{
		System.debug('************ start testgetAccountCoverage **********');
		Account testAcc = new Account();
		testAcc.Name = 'test';
		insert testAcc;
		Employee__c testEmployee = new Employee__c();
		testEmployee.Name = 'test';
		insert testEmployee;
		Account_Coverage__c newAC = new Account_Coverage__c();
		newAC.Name = 'test';
		newAC.Role__c = 'test role';
		newAC.Employee__c = testEmployee.Id;
		List<Account_Coverage__c> coverageList;
		CRCAccountCoverage obj = new CRCAccountCoverage();
		coverageList = obj.getAccountCoverage(testAcc.Id) ;
		System.assert(coverageList != null );
		System.debug(coverageList);
		coverageList = CRCGridsWebServices.getAccountCoverage(testAcc.Id) ;
		System.assert(coverageList != null );
		System.debug(coverageList);
		System.debug('************ done testgetAccountCoverage ***********');
		
	}
	
	testmethod static void testgetStockInterestHoldings()
	{
		System.debug('************ start testgetStockInterestHoldings **********');
		Account testAcc = new Account();
		testAcc.Name = 'test';
		insert testAcc;
		Contact testCont  = new Contact();
		testCont.LastName = 'test Contact';
		testCont.AccountId = testAcc.Id;
		insert testCont;
		Interest__c newInterest = new Interest__c();
		newInterest.Name = 'test';
		newInterest.Reason__c = 'test Reason';
		newInterest.Note__c = 'CRM';
		newInterest.Symbol__c = 'CRM';
		newInterest.Contact__c = testCont.Id;
		
		List<Interest__c> interestList;
		CRCStockInterestHoldings obj = new CRCStockInterestHoldings();
		interestList = obj.getStockInterestHoldings(testAcc.Id) ;
		System.assert(interestList != null );
		System.debug(interestList);
		interestList = CRCGridsWebServices.getStockInterestHoldings(testAcc.Id);
		System.assert(interestList != null );
		System.debug(interestList);
		System.debug('************ done testgetStockInterestHoldings ***********');
		
	}
	
	testmethod static void testgetActivityHistory()
	{
		System.debug('************ start testgetActivityHistory ***********');
		//Create accounts.
		//	----------------		
		acct1 = new Account ( Name = TEST_ACCT1_NAME );
		acct2 = new Account ( Name = TEST_ACCT2_NAME );
		insert new List<Account> { acct1 , acct2 };
		
		//	Create contacts.
		//	----------------		
		cont1 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT1_LNAME ,AccountId = acct1.Id  );
		cont2 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT2_LNAME , AccountId = acct2.Id  );
		cont3 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT3_LNAME , AccountId = acct1.Id );
		cont4 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT4_LNAME , AccountId = acct2.Id  );
		insert new List<Contact> { cont1 , cont2 , cont3 , cont4 } ;
	
		//	Set up Users. 
		//	-------------

		//	Create tasks.
		//	-------------
		//rt = [select Id from RecordType where SObjectType ='Task' and Name ='Interaction' limit 1];
		
		task1 = new Task ( WhatId = acct1.Id , ActivityDate = TODAY );
		task2 = new Task ( WhatId = acct1.Id , WhoId = cont1.Id , ActivityDate = TODAY  );
		insert new List<Task> {  task1 , task2 } ;
		//System.debug('***********************');
		//System.debug ( [select Id ,IsClosed from Task where Id in ( :task1.Id , :task2.Id )] );
		
		
		List<Task> taskList = CRCGridsWebServices.getActivityHistory(acct1.Id);
		System.assert(taskList != null );
		System.debug(taskList);
		CRCActivityHistory obj = new CRCActivityHistory();
		taskList = obj.getAllTasks(acct1.Id) ;
		System.assert(taskList != null );
		System.debug(taskList);
		System.debug('************ done testgetActivityHistory ***********');
	}
	
	
}