/*
 * Name: testTrgTaskUpdate.apex
 * Description: Test triggers related to Task updates/inserts.
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class testTrgTaskUpdate {
	
	global static testMethod void testTrgTaskDelete_ContactId()
	{
		Account act = testDataAccount.insertRecord('Account Name', 'AAA');
		Contact con = testDataContact.insertRecord('Joe', 'Schmoe', act.Id);
		Task tsk = testDataTask.insertRecord(con.Id);
		delete tsk;
	}
	
	global static testMethod void testTrgTaskDelete_Contacts()
	{
		Account act = testDataAccount.insertRecord('Account Name', 'AAA');
		Contact con = testDataContact.insertRecord('Joe', 'Schmoe', act.Id);
		Id contactId = con.Id;
		Integer count = 10;
		List<Task> tsks = testDataTask.insertRecords(contactId, count);
		delete tsks;
	}
	
	global static testMethod void testTrgTaskDelete_BaseDesc()
	{
		Account act = testDataAccount.insertRecord('Account Name', 'AAA');
		Contact con = testDataContact.insertRecord('Joe', 'Schmoe', act.Id);
		Id contactId = con.Id;
		Integer count = 10;
		List<Task> tsks = testDataTask.insertRecords(contactId, 'base desc', count);
		delete tsks;
	}
	
	global static testMethod void testTrgTaskDelete()
	{		
		String sAcctName = 'AccountABC';
		String sAcctTier = '1';
		String short_descr = 'Short description';
		String long_descr = 'Long drawn-out somnambulent bloated excessive description';
		
		Account a = testDataAccount.insertRecord ( sAcctName , sAcctTier );
		Contact linked_c = testDataContact.insertRecord ( 'Joe' , 'Schmoe' , a.Id );
		Contact unlinked_c = testDataContact.insertRecord ( 'Wilbur' , 'Cosznofski' , NULL );
		Task unlinked_t = testDataTask.insertRecord ( unlinked_c.Id , long_descr );
		delete unlinked_t;							
	}
	public static testMethod void testTrgTaskUpdate () {
	
//		Synopsis:
//		1. Create test data
//			a. Account
//			b. Contact1 linked to Account
//			c. Contact2 not linked to Account
//		2. Validate test data
//			a. Validate Contact1-Account relationship
//		3. Invoke + validate single-record triggers
//			a. First trigger
//				1. Create Task1 linked to Contact1, with short Description
//				2. Validate Task1 gets Account's Name + Tier
//				3. Validate Task1's Comment Summary == Description
//			b. Second trigger
//				1. Create Task2 linked to Contact2, with long Description
//				2. Validate Task2 gets NULL Name + Tier
//				3. Validate Task2's Comment Summary == (first 47 chars of Description) + '...'
//			c. Third trigger
//				1. Update Task1 - set Name + Tier to NULL, and Description to long desc
//				2. Validate Task1's Name + Tier restored to Account's Name + Tier
//				3. Validate Task1's Comment Summary == (first 47 chars of Description) + '...'
//			d. Fourth trigger
//				1. Update Task2 - set Name + Tier to non-NULL, and Description to short desc
//				2. Validate Task2's Name + Tier restored to NULL
//				3. Validate Task2's Comment Summary == Description
//		4. Invoke + validate multi-record (bulk) triggers
//			a. First trigger
//				1. Create list of 20 Tasks, half linked to Contact1 with short Desc, and
//				   half linked to Contact2 with long Desc.
//				2. Validate Tasks linked to Contact1 get Account1's Name + Tier
//				3. Validate Tasks linked to Contact1 Comment Summary == Description
//				4. Validate Tasks linked to Contact2 get NULL Name + Tier
//			b. Second trigger
//				1. Update the 20 Tasks in list - set Name + Tier to temp values
//				2. Validate Tasks linked to Contact1 restored to Account1's Name + Tier
//				3. Validate Tasks linked to Contact2 restored to NULL Name + Tier

//		Prep work - set up variables and dummy objects.
		String sAcctName = 'AccountABC';
		String sAcctTier = '1';
		String short_descr = 'Short description';
		String long_descr = 'Long drawn-out somnambulent bloated excessive description';
		
//		1.a), 1.b), 1.c) Create the Account and the linked and unlinked Contacts.
		Account a = testDataAccount.insertRecord ( sAcctName , sAcctTier );
		Contact linked_c = testDataContact.insertRecord ( 'Joe' , 'Schmoe' , a.Id );
		Contact unlinked_c = testDataContact.insertRecord ( 'Wilbur' , 'Cosznofski' , NULL );

//		2.a) Verify the linked Contact has the proper relationship to the Account,
//		and the unlinked Contact has no Account relationship.
		linked_c = [ select Account.Id from Contact where Id = :linked_c.Id ];
		System.AssertEquals ( linked_c.Account.Id , a.Id );
		unlinked_c = [ select Account.Id from Contact where Id = :unlinked_c.Id ];
		System.AssertEquals ( unlinked_c.Account.Id , NULL );
		
//		3.a.1) Create the linked Task.		
		Task linked_t = testDataTask.insertRecord ( linked_c.Id , short_descr );
		linked_t = [ Select
						Id , Client_Account_Name__c , Client_Account_Tier__c ,
						Comments_Summary__c
					from
						Task
					where WhoId = :linked_c.Id
				];
	
//		3.a.2) Validate the linked Task gets the Account's Name + Tier.	
		System.AssertEquals ( linked_t.Client_Account_Name__c , sAcctName );
		System.AssertEquals ( linked_t.Client_Account_Tier__c , sAcctTier );
		
//		3.a.3) Validate the linked Task's Comment Summary == Description.
		System.AssertEquals ( linked_t.Comments_Summary__c , short_descr );

//		3.b.1) Create the unlinked Task.
		Task unlinked_t = testDataTask.insertRecord ( unlinked_c.Id , long_descr );
		unlinked_t = [ Select
						Id , Client_Account_Name__c , Client_Account_Tier__c ,
						Comments_Summary__c
					from
					  	Task
					where WhoId = :unlinked_c.Id
				];

//		3.b.2) Validate the unlinked Task has NULL Name + Tier.
		System.AssertEquals ( unlinked_t.Client_Account_Name__c , NULL );
		System.AssertEquals ( unlinked_t.Client_Account_Tier__c , NULL );
		
//		3.a.3) Validate the linked Task's Comment Summary == (start of Description + '...')
		System.AssertEquals ( unlinked_t.Comments_Summary__c ,
								long_descr.Substring ( 0 , aceCommon.TASK_COMMENT_SUMMARY_LENGTH - 3 ) + '...' );
		
//		3.c.1) Reset the linked Task's Name + Tier.	
		linked_t.Client_Account_Name__c = NULL;
		linked_t.Client_Account_Tier__c = NULL;
		linked_t.Description = long_descr;
		Update linked_t;
		
		linked_t = [ Select
						Id , Client_Account_Name__c , Client_Account_Tier__c ,
						Comments_Summary__c
					from
						Task
					where WhoId = :linked_c.Id
				];

//		3.c.2) Validate the linked Task gets the Account's Name + Tier again.
		System.AssertEquals ( linked_t.Client_Account_Name__c , sAcctName );
		System.AssertEquals ( linked_t.Client_Account_Tier__c , sAcctTier );

//		3.c.3) Validate the linked Task's Comment Summary == (start of Description + '...')
		System.AssertEquals ( linked_t.Comments_Summary__c ,
								long_descr.Substring ( 0 , aceCommon.TASK_COMMENT_SUMMARY_LENGTH - 3 ) + '...' );

//		3.d.1) Reset the unlinked Task's Name + Tier.	
		unlinked_t.Client_Account_Name__c = sAcctName;
		unlinked_t.Client_Account_Tier__c = sAcctTier;
		unlinked_t.Description = short_descr;
		Update unlinked_t;
		
		unlinked_t = [ Select
						Id , Client_Account_Name__c , Client_Account_Tier__c ,
						Comments_Summary__c
					from
						Task
					where WhoId = :unlinked_c.Id
				];

//		3.d.2) Validate the linked Task gets NULL Name + Tier again.
		System.AssertEquals ( unlinked_t.Client_Account_Name__c , NULL );
		System.AssertEquals ( unlinked_t.Client_Account_Tier__c , NULL );
		
//		3.d.3) Validate the linked Task's Comment Summary == Description.
		System.AssertEquals ( unlinked_t.Comments_Summary__c , short_descr );

//		Cleanup before Bulk steps.
		delete linked_t;
		delete unlinked_t;
		
//		4.a.1) Create a list of linked and unlinked Tasks.
		List<Task> new_tasks = testDataTask.insertRecords ( linked_c.Id , short_descr , 10 );
		new_tasks.addAll ( testDataTask.insertRecords ( unlinked_c.Id , long_descr , 10 ) );
		
//		4.a.2) Validate the linked Tasks get the Account's Name + Tier.
		for ( Task t : [ Select
							Id , Client_Account_Name__c , Client_Account_Tier__c ,
							Description , Comments_Summary__c
						from
							Task
						where WhoId = :linked_c.Id
				]
		) {
			System.AssertEquals ( t.Client_Account_Name__c , sAcctName );
			System.AssertEquals ( t.Client_Account_Tier__c , sAcctTier );
			System.AssertEquals ( t.Description , t.Comments_Summary__c );
		}		
	
//		4.a.3) Validate the unlinked Tasks get NULL Name + Tier.
		for ( Task t : [ Select
							Id , Client_Account_Name__c , Client_Account_Tier__c ,
							Description , Comments_Summary__c
						from
							Task
						where WhoId = :unlinked_c.Id
				]
		) {
			System.debug ( t );
			System.AssertEquals ( t.Client_Account_Name__c , NULL );
			System.AssertEquals ( t.Client_Account_Tier__c , NULL );
			System.AssertEquals ( t.Description.subString ( 0 , aceCommon.TASK_COMMENT_SUMMARY_LENGTH - 3 ) + '...' ,
									t.Comments_Summary__c );
		}
		
//		4.b.1) Reset the Name + Tier + Description of the tasks to temporary values.
		String temp_descr = short_descr + ' ; ' + long_descr;
		
		for ( Task t : new_tasks ) {
			t.Client_Account_Name__c = 'Bogus Account';
			t.Client_Account_Tier__c = '99';
			t.Description = temp_descr;
		}
		Update new_tasks;		
		
//		4.b.2) Validate the linked Tasks get the Account's Name + Tier again, and 
//		       the Comment Summary gets truncated.
		for ( Task t : [ Select
							Id , Client_Account_Name__c , Client_Account_Tier__c ,
							Description , Comments_Summary__c
						from
							Task
						where WhoId = :linked_c.Id
				]
		) {
			System.AssertEquals ( t.Client_Account_Name__c , sAcctName );
			System.AssertEquals ( t.Client_Account_Tier__c , sAcctTier );
			
			System.AssertEquals ( t.Comments_Summary__c , 
									t.Description.Substring ( 0 , aceCommon.TASK_COMMENT_SUMMARY_LENGTH - 3 ) + '...' );
		}		
	
//		4.b.3) Validate the unlinked Tasks get NULL Name + Tier again.
		for ( Task t : [ Select
							Id , Client_Account_Name__c , Client_Account_Tier__c
						from
							Task
						where WhoId = :unlinked_c.Id
				]
		) {
			System.AssertEquals ( t.Client_Account_Name__c , NULL );
			System.AssertEquals ( t.Client_Account_Tier__c , NULL );
		}
	}
}