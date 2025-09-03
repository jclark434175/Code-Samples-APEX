public class AceTestUtil {

	static final String TEST_USER_FNAME = 'Tesste';
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
	
	static final String[] PROFILE_TYPES = new String[] { 'Salesforce Platform' , 'Salesforce' };
	
	public static User[] createTestUsers () {
		
		User user0 , user1;

//		Grab the currently running user.
//		--------------------------------
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId () ];
		
//		Create a couple of test Users.
//		------------------------------
		user0 = new User ( Username = TEST_USER0_UNAME ,
							FirstName = TEST_USER_FNAME ,
							LastName = TEST_USER0_LNAME ,
							Alias = TEST_USER0_ALIAS ,
							Email = TEST_USER_EMAIL ,
							IsActive = True ,
							TimeZoneSidKey = TEST_USER_TZ_SID_KEY ,
							LocaleSidKey = TEST_USER_LOCALE_SID_KEY ,
							LanguageLocaleKey = TEST_USER_LANG_LOCALE_KEY ,
							EmailEncodingKey = TEST_USER_EMAIL_ENCODING_KEY
						);
		
		user1 = user0.clone ( False , True );
		user1.Username = TEST_USER1_UNAME;
		user1.LastName = TEST_USER1_LNAME;
		user1.Alias = TEST_USER1_ALIAS;
		
		User[] noProfileUsers = new User[] { user0 , user1 };
		User[] profileUsers = new User[] {};
		String failureReason = '';
								
//		Grab and deactivate a bunch of Users.
//		-------------------------------------
		Id[] currUserIds = new Id[] { UserInfo.getUserId () };
		while ( !noProfileUsers.isEmpty () ) {
			User[] currUsers = [ select
									Name ,
									ProfileId
								from
									User
								where
									IsActive = True and
									Profile.UserLicense.Name in :PROFILE_TYPES and
									Id not in :currUserIds
								limit
									2
								];
			if ( currUsers.isEmpty () ) {
				break;
			}
			for ( User u : currUsers ) {
				u.IsActive = False;
				currUserIds.add ( u.Id );
			}
			
//			Do the deactivation DML.
//			------------------------
			AceWSResultList awrl;
			System.runAs ( thisUser ) {		
				awrl = AceUtil.upsertRecords ( currUsers );
			}
			AceWSResult[] awrList = awrl.getResultList ();
					
//			Find any two successfully deactivated Users and use their Profiles in our
//			test Users.
//			-------------------------------------------------------------------------
			for ( Integer idx = 0 ; idx < awrList.size () ; idx++ ) {
				System.debug ( '\nUSER [' + currUsers[ idx ] + ']\nDEACTIVATE RESULT [' + awrList[ idx ] + ']' );
				if ( awrList[ idx ].bSuccess && !noProfileUsers.isEmpty () ) { 
					noProfileUsers[ 0 ].ProfileId = currUsers[ idx ].ProfileId;
					profileUsers.add ( noProfileUsers[ 0 ] );
					noProfileUsers.remove ( 0 );
				}
				else {
					failureReason += '\nExisting User "' + currUsers[ idx ].Name 
											+ '" : deactivation failure : "' + awrList[ idx ].statusMsg + '"';			
				}
			}
		}

//		Insert the test Users we now have Profiles for.
//		-----------------------------------------------
		if ( !profileUsers.isEmpty () ) {
			System.debug ( 'About to insert test users :' );	
			for ( User u : profileUsers ) {
				System.debug ( u );
			}
			insert profileUsers;
		}
				
//		If we did not find two successfully deactivated Users, it may have been because:
//		- there are fewer than two active Users in the system (other than the current User)
//		- All of the deactivations (or all but one) failed for some reason
//		Either way - try creating Users from scratch, using Salesforce Platform and 
//		Salesforce profiles.
//		----------------------------------------------------------------------------------
		if ( !noProfileUsers.isEmpty () ) {
			
//			Grab the Ids of the Profiles we'll be using.
//			--------------------------------------------
			Map<String , Id> profileIdByName = new Map<String , Id> {};
			for ( Profile prof : [ select
										Name ,
										UserLicense.Name
									from
										Profile
									where
										UserLicense.Name in :PROFILE_TYPES
								]
			) {
				System.debug ( 'PROFILE [' + prof.UserLicense.Name + '] ID [' + prof.Id + ']' );
				profileIdByName.put ( prof.UserLicense.Name , prof.Id );	
			}

//			Go thru the Profiles, assigning them to the remaining Users.
//			------------------------------------------------------------
			for ( String profileName : profileIdByName.keySet () ) {
				if ( noProfileUsers.isEmpty () ) {
					break;
				}
				for ( User u : noProfileUsers ) {
					u.ProfileId = profileIdByName.get ( profileName );
				}

				System.debug ( 'About to insert users with profile [' + profileName + ']:' );
				for ( User u : noProfileUsers ) {
					System.debug ( u );
				}
				AceWSResultList awrl = AceUtil.upsertRecords ( noProfileUsers );
				System.debug( awrl );
				AceWSResult[] awrList = awrl.getResultList ();
				for ( Integer idx = awrList.size () - 1 ; idx >= 0 ; idx-- ) {
					if ( awrList[ idx ].bSuccess ) { 
						profileUsers.add ( noProfileUsers[ idx ] );
						noProfileUsers.remove ( idx );
					}
					else {
						failureReason += '\nTest User "' + profileUsers[ idx ].FirstName + ' ' + profileUsers[ idx ].LastName
										+ '" (profile "' + profileName + '") : insert failure : "' + awrList[ idx ].statusMsg + '"';
					} 	
				}
			}
		}
		
		if ( !noProfileUsers.isEmpty () ) {
			
//			After all this effort, STILL cannot create two test users.
//			----------------------------------------------------------
			System.assert ( False , 'Could not create Test Users.  Errors encountered:'
									+ failureReason
									+ '\nPlease modify existing User record(s) to allow Test User creation.' );
		}

//		Finally, grab the Users back out of the DB so we can get their Name fields.
//		---------------------------------------------------------------------------		
		Map<Id , User> userMap = new Map<Id , User> (
						 [ select
								Department ,
								Email ,
								FirstName ,
								IsActive ,
								LastName ,
								MobilePhone ,
								Name ,
								Phone ,
								Title ,
								UserRoleId
							from
								User
							where
								Id in ( :profileUsers[ 0 ].Id , :profileUsers[ 1 ].Id )
							]
						);					

		profileUsers[ 0 ] = userMap.get ( profileUsers[ 0 ].Id );
		profileUsers[ 1 ] = userMap.get ( profileUsers[ 1 ].Id );
        System.debug ( 'USER 0 : [' + profileUsers[ 0 ].Id + '] [' + profileUsers[ 0 ].Name + ']' );
        System.debug ( 'USER 1 : [' + profileUsers[ 1 ].Id + '] [' + profileUsers[ 1 ].Name + ']' );
        		 		
		return profileUsers;
	}	
	
//  ============================================================================
//  Method: getTestEmployees
//  Desc:   Retrieves Employee records matching the specified list of Users
//			from the database, creating the Employee records if they don't
//			exist (if indicated).
//  Args:   userList	- List of users
//			bCreate		- True to create new Employees if necessary; False otherwise
//  Return: List of Employee records, in the same order as the input User list.
//  ============================================================================
	public static Employee__c[] getTestEmployees ( User[] userList , Boolean bCreate ) {
		
		Set<String> fNameSet = new Set<String> {};
		Set<String> lNameSet = new Set<String> {};
		Map<String , Integer> userIdxByName = new Map<String , Integer> {};
		
		for ( Integer idx = 0 ; idx < userList.size () ; idx++ ) {
			User u = userList[ idx ];
			fNameSet.add ( u.FirstName );
			lNameSet.add ( u.LastName );
			userIdxByName.put ( u.FirstName + ':' + u.LastName , idx );
		}
		for ( String uName : userIdxByName.keySet () ) {
			Integer idx = userIdxByName.get ( uName );
			System.debug ( '[' + uName + '] [' + idx + '] [' + userList[ idx ] + ']' );
		}

//		Grab the Employees from the DB that match the input Users.
//		----------------------------------------------------------
		Employee__c[] emplList = new Employee__c[ userList.size () ];
		Map<String , Employee__c> emplByName = new Map<String , Employee__c> {};
		
		for ( Employee__c empl : [ select
										Department__c ,
										Email__c ,
										First_Name__c ,
										Inactive__c ,
										Internal_Contact__c ,
										Last_Name__c ,
										Mobile__c ,
										Name ,
										Phone__c ,
										Title__c ,
										User__c
									from
										Employee__c
									where
										First_Name__c in :fNameSet and
										Last_Name__c in :lNameSet
									]
		) {
			System.debug ( 'Checking DB Empl : [' + empl + ']' );
			String emplName = empl.First_Name__c + ':' + empl.Last_Name__c;
			Integer idx = userIdxByName.get ( emplName );
			if ( idx != Null ) {
				emplList[ idx ] = empl;
				userIdxByName.remove ( emplName );
			}
		} 
		
//		If we matched all Users to Employees, return the Employees now.
//		---------------------------------------------------------------
		if ( userIdxByName.isEmpty () || !bCreate ) {
			return emplList;
		}
		
//		Now create Employees for the Users we didn't find a DB match for.
//		-----------------------------------------------------------------
		Employee__c[] newEmplList = new Employee__c[] {};		
		for ( Integer idx : userIdxByName.values () ) {
			User u = userList[ idx ];
			emplList[ idx ] = new Employee__c ( First_Name__c = u.FirstName , Last_Name__c = u.LastName , 
												User__c = u.Id );
			newEmplList.add ( emplList[ idx ] );
		}
		insert newEmplList;
		
		return emplList;
	}

}