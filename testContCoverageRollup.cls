/** 
 * Name: testContCoverageRollup 
 * Description: Trigger to synchronize the AccountTeamMember and ContactShare
 *				records with inserts/updates/deletes to Contact_Share__c records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
public class testContCoverageRollup {
	
	private static List<Employee__c> empList = new List<Employee__c>();
	private static List<User> userList = new List<User>();

	static final String TEST_USER0_UNAME = 'testuser0@test.test';
	static final String TEST_USER0_LNAME = 'TestUser0';
	static final String TEST_USER0_ALIAS = 'tusr0';
	static final String TEST_USER1_UNAME = 'testuser1@test.test';
	static final String TEST_USER1_LNAME = 'TestUser1';
	static final String TEST_USER1_ALIAS = 'tusr1';
	
	static final String TEST_USER_EMAIL = 'testuser@tier1crm.com';
	static final String TEST_USER_TZ_SID_KEY = 'America/New_York';
	static final String TEST_USER_LOCALE_SID_KEY = 'en_CA';
	static final String TEST_USER_LANG_LOCALE_KEY = 'en_US';
	static final String TEST_USER_EMAIL_ENCODING_KEY = 'ISO-8859-1';
    
    public static testmethod void testRoles() {
    	list<Account> alist = new list<Account>();
    	list<Contact> clist = new list<Contact>();
    	
    	String BACKUP = 'Back';
    	String PRIMARY = 'Primary';
    	String OTHERS = 'Others';
    	
    	Account_Coverage__c acResult;
    	
//		Creating an employee with new user
    	setupEmployee(1);
//		Creating two accounts     	
    	Account a0 = new Account(Name = 'a0'); alist.add( a0 );
    	Account a1 = new Account(Name = 'a1'); alist.add( a1 );
    	insert alist; a0 = alist[0]; a1 = alist[1];
//		creating contact list 1    	
    	Contact a0c0 = new Contact( LastName = 'a0c0', AccountId = a0.Id); clist.add( a0c0);
    	Contact a0c1 = new Contact( LastName = 'a0c1', AccountId = a0.Id); clist.add( a0c1);
    	Contact a0c2 = new Contact( LastName = 'a0c2', AccountId = a0.Id); clist.add( a0c2);
    	insert clist; a0c0 = clist[0]; a0c1 = clist[1]; a0c2 = clist[2];
//		clear contact list    	
    	clist.clear();
//		creating contact list 2    	
    	Contact a1c0 = new Contact( LastName = 'a0c0', AccountId = a1.Id); clist.add( a1c0);
    	Contact a1c1 = new Contact( LastName = 'a0c1', AccountId = a1.Id); clist.add( a1c1);
    	insert clist; a1c0 = clist[0]; a1c1 = clist[1];
    	
    	Employee__c e0 = empList[0];
    	
//		create first contact coverage ROLE: BACKUP     	
    	Contact_Coverage__c contCover1 = new Contact_Coverage__c (
    													Contact__c = a0c0.Id, 
    													Employee__c = e0.Id,
    													Role__c = BACKUP);
		insert contCover1;
		acResult = [select Role__c from Account_Coverage__c where Employee__c = :e0.Id 
															and Account__c = :a0.Id];		
		System.assertEquals(BACKUP, acResult.Role__c);

//		create second contact coverage ROLE: PRIMARY		
		Contact_Coverage__c contCover2 = new Contact_Coverage__c (
														Contact__c = a0c1.Id, 
														Employee__c = e0.Id,
														Role__c = PRIMARY);
														
		insert contCover2;
		acResult = [select Role__c from Account_Coverage__c where Employee__c = :e0.Id 
															and Account__c = :a0.Id];		
		System.assertEquals(PRIMARY, acResult.Role__c);

//				
		Contact_Coverage__c contCover3 = new Contact_Coverage__c (
														Contact__c = a0c2.Id, 
														Employee__c = e0.Id,
														Role__c = OTHERS);
														
		insert contCover3;
		acResult = [select Role__c from Account_Coverage__c where Employee__c = :e0.Id 
															and Account__c = :a0.Id];		
		System.assertEquals(PRIMARY, acResult.Role__c);
		
		delete contCover2;
		acResult = [select Role__c from Account_Coverage__c where Employee__c = :e0.Id 
															and Account__c = :a0.Id];		
		System.assertEquals(BACKUP, acResult.Role__c);
		
		delete contCover1;
		acResult = [select Role__c from Account_Coverage__c where Employee__c = :e0.Id 
															and Account__c = :a0.Id];		
		System.assertEquals(OTHERS, acResult.Role__c);
    }
    public static testmethod void testInsertUpdate() {    	
    	list<Account> alist = new list<Account>();
    	list<Contact> clist = new list<Contact>();
//		Creating an employee with new user
    	setupEmployee(1);
//		Creating two accounts     	
    	Account a0 = new Account(Name = 'a0'); alist.add( a0 );
    	Account a1 = new Account(Name = 'a1'); alist.add( a1 );
    	insert alist; a0 = alist[0]; a1 = alist[1];
//		creating contact list 1    	
    	Contact a0c0 = new Contact( LastName = 'a0c0', AccountId = a0.Id); clist.add( a0c0);
    	Contact a0c1 = new Contact( LastName = 'a0c1', AccountId = a0.Id); clist.add( a0c1);
    	insert clist; a0c0 = clist[0]; a0c1 = clist[1];
//		clear contact list    	
    	clist.clear();
//		creating contact list 2    	
    	Contact a1c0 = new Contact( LastName = 'a0c0', AccountId = a1.Id); clist.add( a1c0);
    	Contact a1c1 = new Contact( LastName = 'a0c1', AccountId = a1.Id); clist.add( a1c1);
    	insert clist; a1c0 = clist[0]; a1c1 = clist[1];
    	
    	Employee__c e0 = empList[0];
//		create two contact coverage records     	
    	Contact_Coverage__c contCover1 = new Contact_Coverage__c (
    													Contact__c = a0c0.Id, 
    													Employee__c = e0.Id,
    													Role__c = 'Backup');
    	Contact_Coverage__c contCover2 = new Contact_Coverage__c (Contact__c = a0c1.Id, Employee__c = e0.Id, Role__c = 'Something');
		insert contCover1;
		insert contCover2;
//		there should be only one account coverage record		
		System.assertEquals(1, [select count() from Account_Coverage__c where Employee__c = :e0.Id 
																		and Account__c = :a0.Id]);
//		update with different contact of different account		
//		contCover2.Contact__c = a1c0.Id;
//		update contCover2;
//		first account should remain at account coverage		
//		System.assertEquals(1, [select count() from Account_Coverage__c where Employee__c = :e0.Id
//																		and Account__c = :a0.Id]);
//		there should be a record for the new updated account too.
//		System.assertEquals(1, [select count() from Account_Coverage__c where Employee__c = :e0.Id
//																		and Account__c = :a1.Id]);
//		update contact coverage back to previous contact		
//		contCover2.Contact__c = a0c1.Id;
//		update contCover2;
//		there shouldn't be a record in account coverage for the second account		
//		System.assertEquals(0, [select count() from Account_Coverage__c where Employee__c = :e0.Id
//																		and Account__c = :a1.Id]);
//		delete the 2nd contact coverage 
		delete contCover2;
//		still there should be a record for the first account		
		System.assertEquals(1, [select count() from Account_Coverage__c where Employee__c = :e0.Id
																		and Account__c = :a0.Id]);

		contCover1.Role__c = 'Primary';
		update contCover1;
		System.assertEquals('Primary', [select Role__c from Account_Coverage__c where Employee__c = :e0.Id
																		and Account__c = :a0.Id].Role__c);
//		delete the 1st contact coverage
		delete contCover1;
//		there shouldn't be any record in account coverage
		List<Account_Coverage__c> acList = new List<Account_Coverage__c>([
												select Id from Account_Coverage__c 
												where Employee__c = :e0.Id
												and Account__c = :a0.Id]);
												
		System.assertEquals(0, acList.size());
		
		contCover1 = new Contact_Coverage__c (	Contact__c = a0c0.Id, 
    											Employee__c = e0.Id,
    											Role__c = 'Backup');
    	insert contCover1;
    	
    	acList = new List<Account_Coverage__c>([
												select Id from Account_Coverage__c 
												where Employee__c = :e0.Id
												and Account__c = :a0.Id]);
		delete acList;
		
		update contCover1;
		
		acList = new List<Account_Coverage__c>([
												select Id from Account_Coverage__c 
												where Employee__c = :e0.Id
												and Account__c = :a0.Id]);
												
    	System.assertEquals(1, acList.size());
    }
    
	private static void setupEmployee(Integer empSize) {
		Integer EMP_SIZE = empSize;
//		setup the user list
//		-------------------
		setupUsers();
				
//		Create employees
//		----------------		
		for( Integer k = 0; k < EMP_SIZE; k++) {
			empList.Add( new Employee__c( User__c = userList[0].Id ) );
		}
		insert empList;
	}
	
	static void setupUsers () {

//		Grab the currently running user.
//		--------------------------------
		User thisUser = [ select Id , Name from User
							where Id = :UserInfo.getUserId () ]; 
		
//		Deactivate two active users from the database to make room for our test users.
//		------------------------------------------------------------------------------ 
		User[] existingUsers = [ select 
									ProfileId
								from
									User
								where
									IsActive = True and
									Id != :thisUser.Id
								limit 1
								];
		for ( User u : existingUsers ) {
			u.IsActive = False;
		}
		update existingUsers;

//		Create two test users with the deactivated users' profiles.
//		-----------------------------------------------------------
		User[] testUsers = new User[] {};
		User testUser = new User ( Username = TEST_USER0_UNAME ,
									LastName = TEST_USER0_LNAME ,
									ProfileId = existingUsers[ 0 ].ProfileId ,
									Alias = TEST_USER0_ALIAS ,
									Email = TEST_USER_EMAIL ,
									IsActive = True ,
									TimeZoneSidKey = TEST_USER_TZ_SID_KEY ,
									LocaleSidKey = TEST_USER_LOCALE_SID_KEY ,
									LanguageLocaleKey = TEST_USER_LANG_LOCALE_KEY ,
									EmailEncodingKey = TEST_USER_EMAIL_ENCODING_KEY
								);
		userList.add ( testUser );

//		Insert the test users.
//		----------------------
		System.runAs ( thisUser ) {
			insert userList;
		}		 		
    }
}