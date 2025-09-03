/*
 * Name: testDataTask
 * Description: Test Task data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class testDataTask {

//	Name: createRecord
//	Description: Create but do not insert a new Task with the specified Contact ID.
//
//	Notes: To be used in other test cases
//	-------------------------------------------------------------------------------
	global static Task createRecord ( Id contactId , String descr ) {
		Task newTask = new Task( WhoId = contactId , Description = descr );
		return newTask;
	}

//	Name: insertRecord
//	Description: Create and insert a new Task with the specified Contact ID.
//
//	Notes: To be used in other test cases
//	------------------------------------------------------------------------
	
	global static Task insertRecord ( Id contactId ) {
		Task newTask = createRecord ( contactId , '' );
		insert newTask;
		return newTask;
	}
	
//	Name: insertRecord
//	Description: Create and insert a new Task with the specified Contact ID
//	             and Description.
//
//	Notes: To be used in other test cases
//	-----------------------------------------------------------------------
	global static Task insertRecord ( Id contactId , String descr ) {
		Task newTask = createRecord ( contactId , descr );
		insert newTask;
		return newTask;
	}

//	Name: insertRecords
//	Description: Create and insert a list of Tasks with the specified Contact ID.
//
//	Notes: To be used in other test cases
//	-----------------------------------------------------------------------------
	global static List<Task> insertRecords( Id contactId , Integer iNumRecs ) {
		
		List<Task> newTasks = insertRecords ( contactId , '' , iNumRecs );
		return newTasks;
	}

//	Name: insertRecords
//	Description: Create and insert a list of Tasks with the specified Contact ID
//               and Description.
//
//	Notes: To be used in other test cases
//	----------------------------------------------------------------------------
	global static List<Task> insertRecords( Id contactId , String base_descr , Integer iNumRecs ) {
		
		List<Task> newTasks = new List<Task> ();
		String descr;
		for ( Integer iRec = 0 ; iRec < iNumRecs ; iRec++ ) {
			if ( base_descr != '' ) {
				descr = '(Task ' + iRec + ' of ' + iNumRecs + ') ' + base_descr;
			}
			newTasks.add ( createRecord ( contactId , descr ) );
		}
		insert newTasks;
		return newTasks;
	}
}