/** 
 * Name: testALMWebServices 
 * Description: Contains testMethods for webservices in ALMWebServices
 *
 * Confidential & Proprietary, ©2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
public class testALMWebServices {   
    
    public class TestException extends Exception {}

    private static Account acct0 , acct1;
    private static Contact cont0 , cont1 , cont2 , cont3;
    private static Contact_List__c cl0 , cl1;
    private static Contact_List_Entry__c cl0_e0 , cl0_e1 , cl1_e0 , cl1_e1;
    private static Ace_List__c al0 , al1;
    private static Ace_List_Entry__c al0_e0 , al0_e1 , al1_e0 , al1_e1;    
    private static Task task0 , task1;
    private static Security_Master__c sm0 , sm1;

    private static Marketing_Event__c event;
    private static Marketing_Event_Meeting__c eventMtg;
    private static Marketing_Event_Account_Xref__c eventAcctXref;
    private static Marketing_Region__c meRegion;
    private static Marketing_City__c meCity;

    private static ST_Research_Preference__c pref;
    private static ST_Research_Preference_Metadata__c rpm;

    private static User user0 , user1;
    private static Employee__c empl0 , empl1;
    private static RecordType rt;
    
    private static String TEST_ACCT0_NAME = 'Test Account 0';
    private static String TEST_ACCT1_NAME = 'Test Account 1';
    private static String TEST_CONT_FNAME = 'Test-Contact';
    private static String TEST_CONT0_LNAME = 'Contact-0';
    private static String TEST_CONT1_LNAME = 'Contact-1';
    private static String TEST_CONT2_LNAME = 'Contact-2';
    private static String TEST_CONT3_LNAME = 'Contact-3';
    private static String TEST_CLIST0_NAME = 'Test Contact List 0';
    private static String TEST_CLIST1_NAME = 'Test Contact List 1';
    
    private static String TEST_CLIST0_ENTRY0_NAME = 'Test Contact List 0 Entry 0';
    private static String TEST_CLIST0_ENTRY1_NAME = 'Test Contact List 0 Entry 1';
    private static String TEST_CLIST1_ENTRY0_NAME = 'Test Contact List 1 Entry 0';
    private static String TEST_CLIST1_ENTRY1_NAME = 'Test Contact List 1 Entry 1';

    // US391 - Account Centric List
    private static String TEST_ALIST0_NAME = 'Test Ace List 0';
    private static String TEST_ALIST1_NAME = 'Test Ace List 1';
    private static String TEST_ALIST0_ENTRY0_NAME = 'Test Ace List 0 Entry 0';
    private static String TEST_ALIST0_ENTRY1_NAME = 'Test Ace List 0 Entry 1';
    private static String TEST_ALIST1_ENTRY0_NAME = 'Test Ace List 1 Entry 0';
    private static String TEST_ALIST1_ENTRY1_NAME = 'Test Ace List 1 Entry 1'; 
    
    private static String TEST_ACOV_DIVISION = 'Test Acct Coverage Division';
    private static String TEST_ACOV_PRODUCT = 'Test Acct Coverage Product';
    private static String TEST_ACOV_RANK = '1';
    private static String TEST_ACOV_CALLORDER = '1'; 
        
    private static String TEST_CCOV_RANK = 'CCOV1';
    private static String TEST_CCOV_ROLE = 'Sales Primary';
    private static String TEST_CCOV_NOTES = 'Test Contact Coverage Notes';
    
    private static String TEST_SYMBOL_0 = 'TESTSYM0';
    private static String TEST_SYMBOL_1 = 'TESTSYM1';
    private static String TEST_SYM_NAME_0 = 'Test Symbol Name 0';
    private static String TEST_SYM_NAME_1 = 'Test Symbol Name 1';
    
    private static String TEST_SMCCOV_ROLE = 'Primary Analyst';
    
    private static String TEST_INTEREST_LABEL = 'Test Interest Label';
    private static String TEST_INTEREST_SOURCE = 'Test Interest Source';
    private static String TEST_INTEREST_REASON = 'Test Interest Reason';
    private static String TEST_INTEREST_NOTE = 'Test Interest Note';

    private static String TEST_TEAM_NAME = 'Test Team';
    private static String TEST_TASK_NAME = 'Test Task';
    
    private static String TEST_EMPLOYEE0_NAME = 'Test Employee 0';
    private static String TEST_EMPLOYEE1_NAME = 'Test Employee 1';
    
    //Test User Constants
    static final String TEST_USER0_UNAME = 'testuser0@tier1crm.com';
    static final String TEST_USER0_LNAME = 'TestUser0';
    static final String TEST_USER0_ALIAS = 'tusr0';
    static final String TEST_USER1_UNAME = 'testuser1@tier1crm.com';
    static final String TEST_USER1_LNAME = 'TestUser1';
    static final String TEST_USER1_ALIAS = 'tusr1';
    
    static final String TEST_USER_EMAIL = 'testuser@tier1crm.com';
    static final String TEST_USER_TZ_SID_KEY = 'America/New_York';
    static final String TEST_USER_LOCALE_SID_KEY = 'en_CA';
    static final String TEST_USER_LANG_LOCALE_KEY = 'en_US';
    static final String TEST_USER_EMAIL_ENCODING_KEY = 'ISO-8859-1';
    
    private static String TEST_MARKETING_EVENT_NAME = 'Test Marketing Event';
    private static String TEST_MARKETING_REGION = 'Wild West';
    private static String TEST_MARKETING_CITY = 'Testopolis';
    
    private static String TEST_RESEARCH_PREF_NAME = 'Test Research Pref Name';
    private static String TEST_RESEARCH_PREF_TYPE = 'Test Research Pref Type';
    
    private static String TEST_RPM_NAME = 'Test RPM Name';
        
    private static String BOGUS_STR = 'XXBOGUSXX';
    private static Date TODAY = Date.Today ();
    private static Id NULL_ID = Null;
    
//  ============================================================================
//  Method: mkBogusId   
//  Desc:   Creates a bogus Id from the supplied valid Id. 
//  Args:   realId - the valid Id.
//  Return: The bogus Id.       
//  ============================================================================
    private static String mkBogusId ( Id realId ) {
        
        String bogusId = realId;
        bogusId = String.valueOf ( Integer.valueOf ( bogusId.substring ( 0 , 1 ) + 1 ) )
                        + bogusId.substring ( 1 );      
        return bogusId;
    }
    
//  ============================================================================
//  Method: setupTestEnv    
//  Desc:   Sets up test SF object records, for use by the Test methods. 
//  Args:   None.
//  Return: None.                       
//  ============================================================================
    private static void setupTestEnv () {
        setupTestEnv ( True );
    }
    
    private static void setupTestEnv ( Boolean bSetupEmpls ) {
        
//      Create accounts.
//      ----------------        
        acct0 = new Account ( Name = TEST_ACCT0_NAME );
        acct1 = new Account ( Name = TEST_ACCT1_NAME );
        insert new List<Account> { acct0 , acct1 };
        
//      Create contacts.
//      ----------------        
        cont0 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT0_LNAME ,
                                AccountId = acct0.Id , ST_Inactive__c = False );
        cont1 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT1_LNAME , 
                                AccountId = acct1.Id , ST_Inactive__c = False );
        cont2 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT2_LNAME , 
                                AccountId = acct0.Id , ST_Inactive__c = False );
        cont3 = new Contact ( FirstName = TEST_CONT_FNAME , LastName = TEST_CONT3_LNAME , 
                                AccountId = acct1.Id , ST_Inactive__c = False );
        ALMWebServices.insertContacts ( new Contact[] { cont0 , cont1 , cont2 , cont3 } );

//      Update them - to exercise the WebSvc method.
//      --------------------------------------------
        ALMWebServices.updateContacts ( new Contact[] { cont0 , cont1 , cont2 , cont3 } );

//      Set up Users and create Employees, if required.
//      -----------------------------------------------
        if ( bSetupEmpls ) {
            setupTestEmpls ();
        }
        
//      Create contact lists (use WebSvc method).
//      -----------------------------------------
        cl0 = new Contact_List__c ( Name = TEST_CLIST0_NAME , OwnerId = user0.Id , Is_Shared__c = False );
        cl1 = new Contact_List__c ( Name = TEST_CLIST1_NAME , OwnerId = user0.Id , Is_Shared__c = True );
        
        List<Contact_List__c> clList = new List<Contact_List__c> { cl0 , cl1 };
        AceWSResultList awl = ALMWebServices.upsertContactLists ( clList );
        System.assertEquals ( 2 , awl.getResultList().size () );
        for ( Integer i = 0 ; i < 2 ; i++ ) {
            System.assertEquals ( True , awl.getResult( i ).bSuccess );
            System.assertEquals ( clList[ i ].Id , awl.getResult( i ).statusMsg );
        }
        
//      Create contact list entries (use WebSvc method).
//      ------------------------------------------------
        cl0_e0 = new Contact_List_Entry__c ( Name = TEST_CLIST0_ENTRY0_NAME , Contact_List__c = cl0.Id ,
                                                Contact__c = cont0.Id );
        cl0_e1 = new Contact_List_Entry__c ( Name = TEST_CLIST0_ENTRY1_NAME , Contact_List__c = cl0.Id ,
                                                Contact__c = cont1.Id );
        cl1_e0 = new Contact_List_Entry__c ( Name = TEST_CLIST1_ENTRY0_NAME , Contact_List__c = cl1.Id ,
                                                Contact__c = cont2.Id );
        cl1_e1 = new Contact_List_Entry__c ( Name = TEST_CLIST1_ENTRY1_NAME , Contact_List__c = cl1.Id ,
                                                Contact__c = cont3.Id );
                                                
        List<Contact_List_Entry__c> cleList = new List<Contact_List_Entry__c> { cl0_e0 , cl0_e1 , cl1_e0 , cl1_e1 };
        awl = ALMWebServices.upsertContactListEntries ( cleList );
        System.assertEquals ( 4 , awl.getResultList().size () );
        for ( Integer i = 0 ; i < 4 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( cleList[ i ].Id , awl.getResult( i ).statusMsg );
        }       

//      US391  - Create Ace lists (use WebSvc method).
//      GD 2009/03/17 - START
//      -----------------------------------------
        al0 = new Ace_List__c ( Name = TEST_ALIST0_NAME , OwnerId = user0.Id , Is_Shared__c = False, Content_Type__c='Contact' );
        al1 = new Ace_List__c ( Name = TEST_ALIST1_NAME , OwnerId = user0.Id , Is_Shared__c = True, Content_Type__c='Account' );

        List<Ace_List__c> alList = new List<Ace_List__c> { al0 , al1 };
        awl = ALMWebServices.upsertAceLists ( alList );
        System.assertEquals ( 2 , awl.getResultList().size () );
        for ( Integer i = 0 ; i < 2 ; i++ ) {
            System.assertEquals ( True , awl.getResult( i ).bSuccess );
            System.assertEquals ( alList[ i ].Id , awl.getResult( i ).statusMsg );
        }


//      Create Ace list entries (use WebSvc method).
//      ------------------------------------------------
        al0_e0 = new Ace_List_Entry__c ( Name = TEST_ALIST0_ENTRY0_NAME , Ace_List__c = al0.Id ,
                                            Entry_List_Id__c = cont0.Id );

        al0_e1 = new Ace_List_Entry__c ( Name = TEST_ALIST0_ENTRY1_NAME , Ace_List__c = al0.Id ,
                                            Entry_List_Id__c = cont1.Id );

        al1_e0 = new Ace_List_Entry__c ( Name = TEST_ALIST1_ENTRY0_NAME , Ace_List__c = al1.Id ,
                                            Entry_List_Id__c = acct0.Id );

        al1_e1 = new Ace_List_Entry__c ( Name = TEST_ALIST1_ENTRY1_NAME , Ace_List__c = al1.Id ,
                                            Entry_List_Id__c = acct1.Id );

        List<Ace_List_Entry__c> aleList = new List<Ace_List_Entry__c> { al0_e0 , al0_e1 , al1_e0 , al1_e1 };
        awl = ALMWebServices.upsertAceListEntries ( aleList );
        System.assertEquals ( 4 , awl.getResultList().size () );
        for ( Integer i = 0 ; i < 4 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( aleList[ i ].Id , awl.getResult( i ).statusMsg );
        }     

//      GD 2009/03/17 - END

//      Create tasks.
//      -------------
        rt = [select Id from RecordType 
                where SObjectType = 'Task' 
                and Name = 'Interaction'
                limit 1];
        
        task0 = new Task ( WhatId = acct0.Id , ActivityDate = TODAY );
        task1 = new Task ( WhatId = acct0.Id , WhoId = cont0.Id , ActivityDate = TODAY ,
                            RecordTypeId = rt.id );
        AceWSResultList awrl = ALMWebServices.upsertTasks ( new Task[] { task0 , task1 } );
        System.debug ( 'UPSERT TASKS RESULT:\n' + awrl );
        System.debug ( [select Id , IsClosed from Task where Id in ( :task0.Id , :task1.Id )] );
    }

    private static void setupTestEmpls () {

        User[] users = AceTestUtil.createTestUsers ();
        user0 = users[ 0 ];
        user1 = users[ 1 ];

        Employee__c[] empls = AceTestUtil.getTestEmployees ( users , True );
        empl0 = empls[ 0 ];
        empl1 = empls[ 1 ];
    }
    
    private static void setupTestSyms () {
        
        sm0 = new Security_Master__c ( Name = TEST_SYMBOL_0 , Symbol__c = TEST_SYMBOL_0 );
        sm1 = new Security_Master__c ( Name = TEST_SYMBOL_1 , Symbol__c = TEST_SYMBOL_1 );
        insert new List<Security_Master__c> { sm0 , sm1 };
    }
        
    private static void setupMarketingEvents () {
        event = new Marketing_Event__c ( Name = TEST_MARKETING_EVENT_NAME ,
                                            Event_Date__c = TODAY ,
                                            IsActive__c = True );
        insert event;
        
        eventMtg = new Marketing_Event_Meeting__c ( Marketing_Event__c = event.Id ,
                                            Contact__c = cont0.Id );
        insert eventMtg;
        
        eventAcctXref = new Marketing_Event_Account_Xref__c (
                                            Marketing_Event__c = event.Id ,
                                            Account__c = acct0.Id );
        insert eventAcctXref;
        
        meRegion = new Marketing_Region__c ( Name = TEST_MARKETING_REGION );
        insert meRegion;
        
        meCity = new Marketing_City__c ( Name = TEST_MARKETING_CITY , 
                                            Region__c = meRegion.Id );
        insert meCity;
    }
                
    private static void setupResearchPrefs () {   
        rpm = new ST_Research_Preference_Metadata__c ( Name = TEST_RPM_NAME );
        Insert rpm;
        rpm = [ select RecordType.Name , Name 
                from ST_Research_Preference_Metadata__c
                where Id = :rpm.Id ];
                                            
        pref = new ST_Research_Preference__c (
                                            ST_Preference_Type__c = rpm.RecordType.Name ,
                                            ST_Preference_Name__c = rpm.Name ,
                                            ST_Contact__c = cont0.Id
//                                          ST_Research_Preference_Metadata__c = rpm.Id
                                        );                                      
        Insert pref;
    }
        
    
//  ============================================================================
//  Method:         test_Users
//  Description:    Tests WebSvc methods associated with Users and Employees.
//  ============================================================================
    public static testMethod void test_Users() {
        
        setupTestEmpls ();
        
        List<List<AceUser>> aceUsers = new List<List<AceUser>>();
        aceUsers = ALMWebServices.getUsers(true);
        aceUsers = ALMWebServices.getUsers(false);

        AceUser aceUsr = ALMWebServices.getUserInfo();

//      Exercise the AceUser constructors.
//      ----------------------------------  
        AceUser au = new AceUser ();
        au = new AceUser ( [select Id from User where Id = :user0.Id] );
    }   

//  ============================================================================
//  Method:         test_Groups
//  Description:    Tests Groups     
//  ============================================================================
    public static testMethod void test_Groups() {
        List<AceGroup> grps = ALMWebServices.getGroups();
        System.assertNotEquals ( Null , grps );

//      Exercise the AceGroup constructors.
//      ----------------------------------- 
        AceGroup ag = new AceGroup ();
        ag = new AceGroup ( [select Id from Group limit 1] );
    }
    
//  ============================================================================
//  Method:         test_Roles
//  Description:    Tests Roles  
//  ============================================================================
    public static testMethod void test_Roles() {

        setupTestEmpls ();

        List<AceUserRole> roles = ALMWebServices.getRoles();
        System.assertNotEquals ( Null , roles );

//      Exercise the AceUserRole constructors.
//      --------------------------------------  
        AceUserRole ag = new AceUserRole ();
        ag = new AceUserRole ( [select Id from UserRole limit 1] );
    }
    
//  ============================================================================
//  Method:         test_Employees
//  Description:    Tests Employees
//  ============================================================================
    public static testMethod void test_Employees() {

        setupTestEmpls ();

        EmployeePage emplPage = ALMWebServices.getEmployees ( Null , 100 );
        System.assertNotEquals ( Null , emplPage );
        
        //Test the method to get employees by name
        
        /** STUBBED OUT FOR CIBC ROLLOUT FEB 05 09 - SEAN -         
        emplPage = aceWebServices.getEmployeesByName ( 'Test', Null, 100 );
        System.assertNotEquals ( Null, emplPage );
        */
//      Exercise the Employee and EmployeePage constructors.
//      ----------------------------------------------------
        Employee e = new Employee ();
        e = new Employee ( [select Id from Employee__c where Id = :empl0.Id] );
        
        emplPage = new EmployeePage ();
        emplPage = new EmployeePage ( new Employee[] { e } );
    }

    
//  ============================================================================
//  Method:         test_ContactLists
//  Description:    Tests WebSvc methods associated with Contact Lists and
//                  Contact List Entries.
//  ============================================================================
    public static testMethod void test_ContactLists() {     

//      Get some initial numbers for our test user.
//      -------------------------------------------
        setupTestEmpls ();
        
        List<Integer> clOrigSizeList = new List<Integer> {};
        List<ContactList> clList = ALMWebServices.getContactLists ( user0.Id , False , True );
        clOrigSizeList.add ( clList.Size () );
        clList = ALMWebServices.getContactLists ( user0.Id , True , True );
        clOrigSizeList.add ( clList.Size () );
    
        setupTestEnv ( False );
        
//      Exercise the retrieval methods.
//      -------------------------------
        clList = ALMWebServices.getContactLists ( user0.Id , False , True );
        System.assertEquals ( 1 , clList.Size () - clOrigSizeList[ 0 ] );
        clList = ALMWebServices.getContactLists ( user0.Id , True , True );
        System.assertEquals ( 1 , clList.Size () - clOrigSizeList[ 1 ] );
        
        List<List<ContactListEntry>> cleListList = ALMWebServices.getContactsForList ( new String[] { cl0.Id } , True , 
                                                                                        True , user0.Id );
        System.assertNotEquals ( Null , cleListList );
        System.assertEquals ( 0 , cleListList.Size () );
        cleListList = ALMWebServices.getContactsForList ( new String[] { cl0.Id } , False , True , user0.Id );
        System.assertNotEquals ( Null , cleListList );
        System.assertNotEquals ( Null , cleListList[ 0 ] );
        System.assertEquals ( 2 , cleListList[ 0 ].Size () );
        
        clList = ALMWebServices.getListMembership ( cont0.Id );

        List<AceList> aList = AceList.getListMembership ( cont0.Id, UserInfo.getUserId() );
//              
        System.assertEquals ( 1 , clList.size () );
        System.assertEquals ( clList[ 0 ].Id , cl0.Id );
        
//      Exercise the update methods.
//      ----------------------------
        cl0.Name = TEST_CLIST1_NAME;
        AceWSResultList awl = ALMWebServices.updateContactLists ( new List<Contact_List__c> { cl0 } );
        System.assertEquals ( 1 , awl.getResultList().size () );
        System.assertEquals ( True , awl.getResult ( 0 ).bSuccess );
        System.assertEquals ( cl0.Id , awl.getResult( 0 ).statusMsg );

        cl0_e0.Name = TEST_CLIST1_ENTRY0_NAME;
        awl = ALMWebServices.updateContactListEntries   ( new List<Contact_List_Entry__c> { cl0_e0 } );
        System.assertEquals ( 1 , awl.getResultList().size () );
        System.assertEquals ( True , awl.getResult ( 0 ).bSuccess );
        System.assertEquals ( cl0_e0.Id , awl.getResult( 0 ).statusMsg );
            
//      Exercise the delete method.
//      This should delete one of the four Contact_List_Entry records.
//      --------------------------------------------------------------      
        awl = ALMWebServices.deleteContactListEntries ( new String[] { cont0.Id } , user0.Id );
        System.assertEquals ( 1 , awl.getResultList().size () );
        System.assertEquals ( True , awl.getResult ( 0 ).bSuccess );

//      Exercise the ContactList constructors.
//      --------------------------------------  
        ContactList cl = new ContactList ();
        cl = new ContactList ( [select Id from Contact_List__c where Id = :cl1.Id] );
    }

//  ============================================================================
//  Method:         test_AccountCoverage
//  Description:    Tests WebSvc methods associated with Account Coverage.
//  ============================================================================
    public static testMethod void test_AccountCoverage() {      

        setupTestEnv ();

//      Add an Account Coverage record.
//      -------------------------------
        Account_Coverage__c sfAC = new Account_Coverage__c ( 
                                                Division__c = TEST_ACOV_DIVISION ,
                                                Product__c = TEST_ACOV_PRODUCT ,
                                                Rank__c = TEST_ACOV_RANK ,
                                                Call_Order__c = TEST_ACOV_CALLORDER ,
                                                Start_Date__c = TODAY ,
                                                End_Date__c = TODAY ,
                                                Employee__c = empl0.Id ,
                                                Account__c = acct0.Id
                                            );
        insert sfAC;
        
        AccountCoverage[] acList1;
        acList1 = ALMWebServices.getCoverageForAccounts ( new Id[] { acct0.Id , acct1.Id } );
        System.assertEquals ( 1 , acList1.Size() );

        AccountCoveragePage acPage = ALMWebServices.getAccountCoverage ( empl0.Id , Null , 
                                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertEquals ( 1 , acPage.AccountCoverageList.Size() );

        AccountCoverage[] acList = ALMWebServices.getEmployeesCoveringAccounts ( new Id[] { acct0.Id } );
        System.assertEquals ( 1 , acList.Size() );
        
        acList = ALMWebServices.getEmployeesCoveringAccounts ( new Id[] { acct1.Id } );
        System.assertEquals ( 0 , acList.Size() );

//      Exercise the 'stub/null' constructors.
//      --------------------------------------  
        AccountCoverage ac = new AccountCoverage ();
        ac = new AccountCoverage ( [select Id from Account_Coverage__c where Id = :sfAC.Id] );      
    }   


//  ============================================================================
//  Method:         test_ContactCoverage
//  Description:    Tests WebSvc methods associated with Contact Coverage.
//  ============================================================================
    public static testMethod void test_ContactCoverage() {      

        setupTestEnv ();
        
//      Add a Contact Coverage record.
//      ------------------------------
        Contact_Coverage__c sfCC = new Contact_Coverage__c ( 
                                                Rank__c = TEST_CCOV_RANK ,
                                                Role__c = TEST_CCOV_ROLE ,
                                                Special_Notes__c = TEST_CCOV_NOTES ,
                                                Employee__c = empl0.Id ,
                                                Contact__c = cont0.Id
                                            );
        ALMWebServices.upsertContactCoverage ( new Contact_Coverage__c[] { sfCC } );

//      Tweak a Task to trigger a User Contact Interaction record creation.
//      -------------------------------------------------------------------
        task1.Status = aceUtil.TASK_COMPLETED_STATUS;
        ALMWebServices.updateTasks ( new Task[] { task1 } );
        
        for ( User_Contact_Interaction__c uci : [select User__r.Name , Contact__r.Name 
                                                from User_Contact_Interaction__c
                                                where Contact__c in ( :cont0.Id , :cont1.Id )] ) {
            System.debug ( uci.User__r.Name + ' - ' + uci.Contact__r.Name );
        }
        ContactCoveragePage ccPage = ALMWebServices.getContactCoverage ( empl0.Id , Null ,
                                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertEquals ( 1 , ccPage.ContactCoverageList.Size () );
        
        ContactCoverage[] ccList = ALMWebServices.getEmployeesCoveringContacts ( new Id[] { cont0.Id } );
        System.assertEquals ( 1 , ccList.Size() );
        
        ccList = ALMWebServices.getEmployeesCoveringContacts ( new Id[] { cont1.Id } );
        System.assertEquals ( 0 , ccList.Size() );

        ccList = ALMWebServices.getCoverageForContacts ( new Id[] { cont0.Id , cont1.Id } );
        System.assertEquals ( 1 , ccList.Size() );
                
//      Exercise the Update web svc calls.
//      ----------------------------------
        ALMWebServices.updateContactCoverage ( new Contact_Coverage__c[] { sfCC } );

//      Exercise the 'stub/null' constructors.
//      --------------------------------------  
        ContactCoverage cc = new ContactCoverage ();
        cc = new ContactCoverage ( [select Id from Contact_Coverage__c where Rank__c = :TEST_CCOV_RANK limit 1] );
    }   

//  ============================================================================
//  Method:         test_ListShares
//  Description:    Tests WebSvc methods associated with ListShares.
//  ============================================================================
    public static testMethod void test_ListShares() {
        
        setupTestEnv ();
        
        Id roleId = user0.UserRoleId;
        if ( roleId == Null ) {
            roleId = [ Select Id from UserRole limit 1 ].Id;
        }
        
        List_Share__c ls1 = new List_Share__c ( Contact_List__c = cl0.Id , Entity_Id__c = user0.Id );
        List_Share__c ls2 = new List_Share__c ( Contact_List__c = cl0.Id , Entity_Id__c = roleId );
        List_Share__c ls3 = new List_Share__c ( Contact_List__c = cl1.Id , Entity_Id__c = roleId );
        List<List_Share__c> lsList = new List<List_Share__c> { ls1 , ls2 , ls3 };
        AceWSResultList awl = ALMWebServices.upsertListShares ( lsList );
        System.debug ( 'AWL for LIST SHARE UPSERT:\n' + awl );
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 3 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( lsList[ i ].Id , awl.getResult ( i ).statusMsg );
        }
        
//      Test the case where an entire upsert fails.
//      -------------------------------------------
        awl = ALMWebServices.upsertListShares ( new List<List_Share__c> { ls1 , ls2 , ls1 } );      
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 3 ; i++ ) {
            System.assertEquals ( False , awl.getResult ( i ).bSuccess );
        }

//      Test the case where an upsert partially fails.
//      ----------------------------------------------
        List_Share__c good_ls1 = ls1;
        ls1 = new List_Share__c ( Contact_List__c = user0.Id , Entity_Id__c = user0.Id );
        awl = ALMWebServices.upsertListShares ( new List<List_Share__c> { ls1 , ls2 , ls3 } );      
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        System.assertEquals ( False , awl.getResult ( 0 ).bSuccess );
        for ( Integer i = 1 ; i < 3 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( lsList[ i ].Id , awl.getResult ( i ).statusMsg );
        }
        ls1 = good_ls1;
        
        List<List<ListShare>> lsListList = ALMWebServices.getListShare ( new List<Id> { cl0.Id } );
        System.assertNotEquals ( Null , lsListList );
        System.assertNotEquals ( Null , lsListList[ 0 ] );
        System.assertEquals ( 2 , lsListList[ 0 ].Size () );
        
//      Exercise the Update code.
//      -------------------------
        ALMWebServices.updateListShares ( lsList );
                
        List<ContactList> rList1 = ALMWebServices.getContactLists( user0.Id , True , False );
        List<ContactList> rList2 = ALMWebServices.getContactLists( user0.Id , False , False );      
        
//      Exercise the generic Delete method.
//      -----------------------------------
        awl = ALMWebServices.deleteRecords ( new List<Id> { ls1.Id , ls2.Id } );
        System.assertEquals ( 2 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 2 ; i++ ) {
            System.assertEquals ( True , awl.getResult( i ).bSuccess );
            System.assertEquals ( lsList[ i ].Id , awl.getResult( i ).statusMsg );
        }

//      Exercise a Delete failure.
//      --------------------------      
        awl = ALMWebServices.deleteRecords ( new List<Id> { ls1.Id } );
        System.assertEquals ( 1 , awl.getResultList ().Size () );
        System.assertEquals ( False , awl.getResult( 0 ).bSuccess );
        
//      Exercise some AceWSResultList failure stuff.
//      --------------------------------------------
        awl.setResult ( -1 , True , '' );
        awl.getResult ( -1 );

//      Exercise the ListShare constructors.
//      ------------------------------------    
        ListShare ls = new ListShare ();
        ls = new ListShare ( [select Id from List_Share__c where Id = :ls3.Id] );
    }

//  ============================================================================
//  US391 Account Centric List
//  Method:         test_AceListShares
//  Description:    Tests WebSvc methods associated with ListShares.
//  ============================================================================
    public static testMethod void test_AceListShares() {
        
        setupTestEnv ();
        
        Id roleId = user0.UserRoleId;
        if ( roleId == Null ) {
        	roleId = [ Select Id from UserRole limit 1 ].Id;
        }
        
        Ace_List_Share__c als1 = new Ace_List_Share__c ( Ace_List__c = al0.Id , Entity_Id__c = user0.Id );
        Ace_List_Share__c als2 = new Ace_List_Share__c ( Ace_List__c = al0.Id , Entity_Id__c = roleId );
        Ace_List_Share__c als3 = new Ace_List_Share__c ( Ace_List__c = al1.Id , Entity_Id__c = roleId );
        List<Ace_List_Share__c> alsList = new List<Ace_List_Share__c> { als1 , als2 , als3 };
        AceWSResultList awl = ALMWebServices.upsertAceListShares ( alsList );
        System.debug ( 'AWL for ACE LIST SHARE UPSERT:\n' + awl );
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 3 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( alsList[ i ].Id , awl.getResult ( i ).statusMsg );
        }        

        
//      Test the case where an entire upsert fails.
//      -------------------------------------------
        awl = ALMWebServices.upsertAceListShares ( new List<Ace_List_Share__c> { als1 , als2 , als1 } );      
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 3 ; i++ ) {
            System.assertEquals ( False , awl.getResult ( i ).bSuccess );
        }

//      Test the case where an upsert partially fails.
//      ----------------------------------------------
        Ace_List_Share__c good_als1 = als1;
        als1 = new Ace_List_Share__c ( Ace_List__c = user0.Id , Entity_Id__c = user0.Id );
        awl = ALMWebServices.upsertAceListShares ( new List<Ace_List_Share__c> { als1 , als2 , als3 } );      
        System.assertNotEquals ( Null , awl );
        System.assertEquals ( 3 , awl.getResultList ().Size () );
        System.assertEquals ( False , awl.getResult ( 0 ).bSuccess );
        for ( Integer i = 1 ; i < 3 ; i++ ) {
            System.assertEquals ( True , awl.getResult ( i ).bSuccess );
            System.assertEquals ( alsList[ i ].Id , awl.getResult ( i ).statusMsg );
        }
        als1 = good_als1;
        
        List<List<AceListShare>> alsListList = ALMWebServices.getAceListShare ( new List<Id> { al0.Id } );
        System.assertNotEquals ( Null , alsListList );
        System.assertNotEquals ( Null , alsListList[ 0 ] );
        System.assertEquals ( 2 , alsListList[ 0 ].Size () );
        
//      Exercise the Update code.
//      -------------------------
        ALMWebServices.updateAceListShares ( alsList );
                
        AceListPage listPage1 = ALMWebServices.getAceListsByOwner( user0.Id , False , '', 1000 );
        AceListPage listPage2 = ALMWebServices.getSharedAceLists( user0.Id , False , '', 1000 );
        
//      Exercise the generic Delete method.
//      -----------------------------------
        awl = ALMWebServices.deleteRecords ( new List<Id> { als1.Id , als2.Id } );
        System.assertEquals ( 2 , awl.getResultList ().Size () );
        for ( Integer i = 0 ; i < 2 ; i++ ) {
            System.assertEquals ( True , awl.getResult( i ).bSuccess );
            System.assertEquals ( alsList[ i ].Id , awl.getResult( i ).statusMsg );
        }

//      Exercise a Delete failure.
//      --------------------------      
        awl = ALMWebServices.deleteRecords ( new List<Id> { als1.Id } );
        System.assertEquals ( 1 , awl.getResultList ().Size () );
        System.assertEquals ( False , awl.getResult( 0 ).bSuccess );
        
//      Exercise some AceWSResultList failure stuff.
//      --------------------------------------------
        awl.setResult ( -1 , True , '' );
        awl.getResult ( -1 );

//      Exercise the ListShare constructors.
//      ------------------------------------    
        AceListShare als = new AceListShare ();
        als = new AceListShare ( [select Id from Ace_List_Share__c where Id = :als3.Id] );
    }
    
//  ============================================================================
//  Method:         test_Interests
//  Description:    Tests WebSvc methods associated with Interests.
//  ============================================================================
    public static testMethod void test_Interests() {
        
        setupTestEnv ();
        setupTestSyms ();
        setupMarketingEvents ();
        setupResearchPrefs ();

//      Set up Coverage.
//      ----------------
        Account_Coverage__c ac = new Account_Coverage__c ( Account__c = acct0.Id , 
                                                            Employee__c = empl0.Id );   
        insert ac;      
        Contact_Coverage__c cc = new Contact_Coverage__c ( Contact__c = cont1.Id , 
                                                            Employee__c = empl0.Id, Role__c = 'Primary' );   
        insert cc;
            
//      Set up Interests - exercise the Interest insert/update code.
//      ------------------------------------------------------------
        Interest__c int0 = new Interest__c ( Account__c = acct0.Id , Contact__c = cont0.Id , 
                                            Symbol__c = TEST_SYMBOL_0 , Symbol_Name__c = TEST_SYM_NAME_0 ,
                                            Label__c = TEST_INTEREST_LABEL , Source__c = TEST_INTEREST_SOURCE ,
                                            As_Of_Date__c = TODAY , Reason__c = TEST_INTEREST_REASON ,
                                            Note__c = TEST_INTEREST_REASON
                                        );
        Interest__c int1 = new Interest__c ( Account__c = acct1.Id , Contact__c = cont1.Id , 
                                            Symbol__c = TEST_SYMBOL_1 , Symbol_Name__c = TEST_SYM_NAME_1 ,
                                            Label__c = TEST_INTEREST_LABEL , Source__c = TEST_INTEREST_SOURCE ,
                                            As_Of_Date__c = TODAY , Reason__c = TEST_INTEREST_REASON ,
                                            Note__c = TEST_INTEREST_REASON
                                        );
        ALMWebServices.insertInterests ( new List<Interest__c> { int0 , int1 } );
        ALMWebServices.updateInterests ( new List<Interest__c> { int0 , int1 } );
        
        String[] symList = new String[] { TEST_SYMBOL_0 , TEST_SYMBOL_1 }; 

//      Exercise the getInterests method.
//      --------------------------------        

        InterestPage ip = ALMWebServices.getInterests ( cont0.Id , acct0.Id , 
                                                         Null, new List<String> {} );
        ip = ALMWebServices.getInterests ( cont1.Id , acct1.Id , Null, symList );   
        ip = ALMWebServices.getInterests ( cont1.Id , '' , Null, symList  );    
        
        ip = ALMWebServices.getInterests ( '' , '' , Null, symList );
        ip = ALMWebServices.getInterests ( '' , acct1.Id , Null , Null );
        
        ip = ALMWebServices.getInterests ( cont0.Id , acct0.Id , 'INTEREST:' + TEST_SYMBOL_0, Null );
        ip = ALMWebServices.getInterests ( cont0.Id , acct0.Id , TEST_SYMBOL_0, Null );

//      Exercise the searchInterestsBySymbol method.
//      --------------------------------------------
        List<List<AceContact>> contListList = ALMWebServices.searchInterestsBySymbol (
                                                                user0.Id ,
                                                                symList ,
                                                                AceContact.CONTACT_COVERAGE_SCOPE ,
                                                                True );
        contListList = ALMWebServices.searchInterestsBySymbol ( Null ,
                                                                symList ,
                                                                AceContact.ACCOUNT_COVERAGE_SCOPE ,
                                                                True );
        contListList = ALMWebServices.searchInterestsBySymbol ( user0.Id ,
                                                                symList ,
                                                                AceContact.ALL_COVERAGE_SCOPE ,
                                                                True );
//      Exercise the getContactsByInterestSymbols method.
//      --------------------------------------------
        AceContactPage interestContactPage = ALMWebServices.getContactsByInterestSymbols (
                                                                user0.Id ,
                                                                symList ,
                                                                AceContact.CONTACT_COVERAGE_SCOPE ,
                                                                True,
                                                                '',
                                                                1000 );
        interestContactPage = ALMWebServices.getContactsByInterestSymbols ( Null ,
                                                                symList ,
                                                                AceContact.ACCOUNT_COVERAGE_SCOPE ,
                                                                True,
                                                                '',
                                                                1000 );
        interestContactPage = ALMWebServices.getContactsByInterestSymbols ( user0.Id ,
                                                                symList ,
                                                                AceContact.ALL_COVERAGE_SCOPE ,
                                                                True,
                                                                '',
                                                                1000 );                                                                

//      Exercise the searchInterest method.
//      -----------------------------------
        ip = ALMWebServices.searchInterest ( acct0.Id , TEST_CONT_FNAME , '' );
        ip = ALMWebServices.searchInterest ( acct0.Id , TEST_CONT_FNAME + ' ' + TEST_CONT0_LNAME , '' );
        ip = ALMWebServices.searchInterest ( acct0.Id , TEST_CONT_FNAME + ' ' + TEST_CONT0_LNAME , '' );
        ip = ALMWebServices.searchInterestPage ( acct0.Id , TEST_CONT_FNAME + ' ' + TEST_CONT0_LNAME , '', 200 );

//      Exercise the getInterestsByContactSymReason method.
//      ---------------------------------------------------
        Interest[] intList;
        
        intList = ALMWebServices.getInterestsByContactSymReason ( new Id[] { Cont0.Id } ,
                                                                    symList , TEST_INTEREST_REASON );
        System.assertEquals ( 1 , intList.size () );

        intList = ALMWebServices.getInterestsByContactSymReason ( new Id[] { Cont1.Id } ,
                                                                    symList , TEST_INTEREST_REASON );
        System.assertEquals ( 1 , intList.size () );

        intList = ALMWebServices.getInterestsByContactSymReason ( new Id[] {} ,
                                                                    symList , TEST_INTEREST_REASON );
        System.assertEquals ( 0 , intList.size () );

        intList = ALMWebServices.getInterestsByContactSymReason ( new Id[] { Cont0.Id } ,
                                                                    new String[] {} , TEST_INTEREST_REASON );
        System.assertEquals ( 0 , intList.size () );

        intList = ALMWebServices.getInterestsByContactSymReason ( new Id[] { Cont0.Id } ,
                                                                    new String[] {} , '' );
        System.assertEquals ( 0 , intList.size () );

//      Exercise the Interest and InterestPage constructors.
//      ----------------------------------------------------
        Interest intr = new Interest ();
        intr = new Interest ( [select Id from Interest__c where Id = :int0.Id] );
        
        ip = new InterestPage ();
        ip = new InterestPage ( new Interest[] { intr } );
        
//      Exercise one extra Account constructor.
//      ---------------------------------------
        AceAccount a = new AceAccount ( int1 );     
    }
     
//  ============================================================================
//  Method:         test_Accounts
//  Description:    Tests WebSvc methods associated with Accounts.
//  ============================================================================
    public static testMethod void test_Accounts() {
        
        setupTestEnv ();
        
//      ----------------------------------------------------------------------  
//      Test 1: Retrieve a single valid AceAccount.
//      Expect: Valid AceAccount returned.
//      ----------------------------------------------------------------------  
        AceAccount aceA = ALMWebServices.getAccount ( acct0.Id );
        System.assertNotEquals ( Null , aceA );

//      ----------------------------------------------------------------------  
//      Test 2: Retrieve a single invalid AceAccount.
//      Expect: NULL AceAccount returned.
//      ----------------------------------------------------------------------  
        String badId = mkBogusId ( acct0.Id );
        aceA = ALMWebServices.getAccount ( badId );
        System.assertEquals ( Null , aceA );
        
//      ----------------------------------------------------------------------  
//      Test 3: Retrieve two valid AceAccounts.
//      Expect: Two AceAccounts returned, in a list of lists.
//      ----------------------------------------------------------------------  
        List<List<AceAccount>> acctList = ALMWebServices.getAccounts ( 
                                                new List<Id> { acct0.Id , acct1.id } );
        System.assertNotEquals ( Null , acctList );
        System.assertNotEquals ( Null , acctList[ 0 ] );
        System.assertEquals ( 2 , acctList[ 0 ].size () );
        
//      ----------------------------------------------------------------------  
//      Test 4: Retrieve two valid AceAccounts, plus one invalid one.
//      Expect: Two AceAccounts returned, in a list of lists (as above).
//      ----------------------------------------------------------------------  
        acctList = ALMWebServices.getAccounts ( new List<Id> { acct0.Id , acct1.id , badId } );
        System.assertNotEquals ( Null , acctList );
        System.assertNotEquals ( Null , acctList[ 0 ] );
        System.assertEquals ( 2 , acctList[ 0 ].size () );

//      ----------------------------------------------------------------------  
//      Test 5: Search for a valid AceAccount by name.
//      Expect: An AceAccount returned.
//      ----------------------------------------------------------------------  
        List<AceAccount> srchAcctList = ALMWebServices.searchAccountsByAccountName ( acct0.Name );
        System.debug ( srchAcctList);
        System.assertNotEquals ( Null , srchAcctList );
        System.assertEquals ( 1 , srchAcctList.size () );
        System.assertEquals ( srchAcctList[ 0 ].Name , acct0.Name );

//      ----------------------------------------------------------------------  
//      Test 5: Search for AceAccounts covered by Employee.
//      Expect: An AceAccount returned.
//      ----------------------------------------------------------------------  
        
//      Set up account coverage.
//      ------------------------        
        Account_Coverage__c ac = new Account_Coverage__c ( Account__c = acct0.Id , 
                                                            Employee__c = empl0.Id );   
        insert ac;

        AceAccountPage aaPage = ALMWebServices.getAccountsCoveredByEmployee ( empl0.Id , Null ,
                                                                                aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , aaPage );
        System.assertEquals ( 1 , aaPage.AceAccountList.Size () );
        System.assertEquals ( acct0.Id , aaPage.AceAccountList[ 0 ].Id );

        aaPage = ALMWebServices.getAccountsCoveredByEmployee ( empl1.Id , Null ,
                                                                aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , aaPage );
        System.assertEquals ( 0 , aaPage.AceAccountList.Size () );

//      Exercise the AceAccount constructors.
//      -------------------------------------   
        AceAccount aa = new AceAccount ();
        aa = new AceAccount ( [select Id from Account where Id = :acct0.Id] );
    }

//  ============================================================================
//  Method:         test_Contacts
//  Description:    Tests WebSvc methods associated with Contacts.
//  ============================================================================
    public static testMethod void test_Contacts() {
        
        setupTestEnv ();

//      ----------------------------------------------------------------------  
//      Test 1: Search for AceContacts by Account Name
//      Expect: An AceContact returned.
//      ----------------------------------------------------------------------  
        AceContactPage contPage = ALMWebServices.getContactsByAcctName ( acct0.Name , Null , 
                                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( Null , contPage.NextName );
        System.assertEquals ( 2 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 2: Search for AceContacts by invalid Account Name
//      Expect: No AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByAcctName ( acct0.Name + BOGUS_STR , Null , 
                                                            aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 0 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 3: Search for AceContacts by Account Id
//      Expect: An AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByAcctId ( new Id[] { acct0.Id } , Null , 
                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 2 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 4: Search for AceContacts by invalid Account Id
//      Expect: No AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByAcctId ( new Id[] { cont0.Id } , Null , 
                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 0 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 5: Search for AceContacts by Contact Name
//      Expect: An AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByName ( TEST_CONT_FNAME , Null , 
                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 4 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 6: Search for AceContacts by invalid Contact Name
//      Expect: No AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByName ( TEST_CONT_FNAME + BOGUS_STR , Null , 
                                                        aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 0 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 7: Search for AceContacts by Contact Name and Acct name
//      Expect: An AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByNameAndAcctName ( 
                                                TEST_CONT_FNAME , acct0.Name , 
                                                Null , aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 2 , contPage.AceContactList.size () );

//      ----------------------------------------------------------------------  
//      Test 8: Search for AceContacts by Contact Name and invalid Acct name
//      Expect: No AceContact returned.
//      ----------------------------------------------------------------------  
        contPage = ALMWebServices.getContactsByNameAndAcctName ( 
                                                TEST_CONT_FNAME , acct0.Name + BOGUS_STR , 
                                                Null , aceUtil.MAX_COLLECTION_SIZE );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 0 , contPage.AceContactList.size () );

//      -------------------------------------------------------------------
//      Test 9: Search for AceContacts by Contact Name with page size of 2.
//      Expect: Two AceContacts returned; nextName = the next Contact
//      -------------------------------------------------------------------
        contPage = ALMWebServices.getContactsByName ( TEST_CONT_FNAME , Null , 2 );
        System.assertNotEquals ( Null , contPage );
        System.assertEquals ( 2 , contPage.AceContactList.size () );
        System.assert ( contPage.NextName.contains ( TEST_CONT_FNAME ) );
        
//      Exercise the AceContact and AceContactPage constructors.
//      --------------------------------------------------------
        AceContact ac = new AceContact ();
        ac = new AceContact ( [select Id from Contact where Id = :cont0.Id] );
        
        contPage = new AceContactPage ();
        contPage = new AceContactPage ( new AceContact[] { ac } );
    }

//  ============================================================================
//  Method:         test_UserContactInteractions
//  Description:    Tests WebSvc methods associated with User Contact
//                  Interactions.  Most of the functionality around this object
//                  is trigger-based, and tested indirectly elsewhere, via
//                  creation of Task and Interaction records.
//  ============================================================================
    public static testMethod void test_UserContactInteractions() {
        
        setupTestEnv ();
        
//      Tweak a Task to trigger a User Contact Interaction record creation.
//      -------------------------------------------------------------------
        task1.Status = aceUtil.TASK_COMPLETED_STATUS;
        ALMWebServices.updateTasks ( new Task[] { task1 } );
        
//      Exercise the UserContactInteraction constructors.
//      -------------------------------------------------   
        UserContactInteraction uci = new UserContactInteraction ();
        uci = new UserContactInteraction ( [select Id 
                                            from User_Contact_Interaction__c 
                                            limit 1] );
    }

//  ============================================================================
//  Method:         test_Interactions
//  Description:    Tests WebSvc methods associated with Interactions.
//  ============================================================================
    public static testMethod void test_Interactions() {
        
        setupTestEnv ();
        
        AceTaskPage atp = ALMWebServices.getRecentInteractions ( Null , Null , 14 , Null ); 
        atp = ALMWebServices.getRecentInteractions ( acct0.Id , Null , 14 , Null ); 
        atp = ALMWebServices.getRecentInteractions ( acct0.Id , cont0.Id , 14 , Null );
        
        ALMWebServices.getUserTasksByRecordType ( user1.Id , rt.Id );

//      Exercise the aceTask and aceTaskPage constructors.
//      --------------------------------------------------  
        AceTask t = new AceTask ();
        t = new AceTask ( [select Id from Task where Id = :task0.Id] );
        
        atp = new AceTaskPage ();
        atp = new AceTaskPage ( new AceTask[] { t } );
    }   
    
//  ============================================================================
//  Method:         test_SecurityMaster
//  Description:    Tests WebSvc methods associated with Security_Master.
//  ============================================================================
    public static testMethod void test_SecurityMaster() {
        
        setupTestSyms ();
        
        ALMWebServices.searchSecurityMaster ( TEST_SYMBOL_0 + ',' + TEST_SYMBOL_1 );

//      Exercise the SecurityMaster constructors.
//      -----------------------------------------   
        SecurityMaster sm = new SecurityMaster ();
        sm = new SecurityMaster ( [select Id from Security_Master__c where Id = :sm0.Id] );
        sm = new SecurityMaster ( sm0.Id , TEST_SYMBOL_0 , TEST_SYM_NAME_0 );
    }

//  ============================================================================
//  Method:         test_SecurityMasterCoverage
//  Description:    Tests WebSvc methods associated with Security_Master_Coverage.
//  ============================================================================
    public static testMethod void test_SecurityMasterCoverage() {
        
        setupTestSyms ();
        setupTestEmpls ();
        
//      Add a Security Master Coverage record.
//      --------------------------------------
        Security_Master_Coverage__c sfSMC = new Security_Master_Coverage__c ( 
                                                    Role__c = TEST_SMCCOV_ROLE ,
                                                    Employee__c = empl0.Id ,
                                                    Security_Master__c = sm0.Id
                                                );
        Insert sfSMC;
        
        SecurityMasterCoverage[] smcList = new SecurityMasterCoverage[] {};
    
        smcList = ALMWebServices.getEmployeesCoveringSymbols ( new String[] { sm0.Symbol__c } );
        System.assertEquals ( 1 , smcList.Size() );

        smcList = ALMWebServices.getEmployeesCoveringSymbols ( new String[] { sm1.Symbol__c } );
        System.assertEquals ( 0 , smcList.Size() );

//      Exercise the SecurityMasterCoverage constructors.
//      -------------------------------------------------   
        SecurityMasterCoverage smc = new SecurityMasterCoverage ();
        smc = new SecurityMasterCoverage ( [select Id from Security_Master_Coverage__c where Id = :sfSMC.Id] );
    }

//  ============================================================================
//  Method:         test_Teams
//  Description:    Tests WebSvc methods associated with Teams.
//  ============================================================================
    public static testMethod void test_Teams() {
        
        setupTestEmpls ();
    
        Team__c team = new Team__c ( Name = TEST_TEAM_NAME );
        Insert team;
        
        Team_Member__c[] tmList = new List<Team_Member__c> {
                                    new Team_Member__c ( Team__c = team.Id ,
                                                            Employee__c = empl0.Id ,
                                                            Inactive__c = False ) ,
                                    new Team_Member__c ( Team__c = team.Id ,
                                                            Employee__c = empl1.Id ,
                                                            Inactive__c = False )
                                };                                      
        insert tmList;
        
//      Should add stuff here, for other Employees belonging to this Employee's team.
//      -----------------------------------------------------------------------------       
        
        ALMWebServices.getTeamMembers ( empl0.Id );

    }

//  ============================================================================
//  Method:         test_MarketingEvents
//  Description:    Tests WebSvc methods associated with Marketing Events 
//                  and Marketing Event Cities.
//  ============================================================================
    public static testMethod void test_MarketingEvents() {
        
        setupTestEnv ();
        setupMarketingEvents ();
        
        Integer meCount = 0;
        for ( MarketingEvent me : ALMWebServices.searchMarketingEvents ( 
                                                                String.valueOf ( TODAY ) ,
                                                                String.valueOf ( TODAY )
                                                            ) ) {
            if ( me.Name == TEST_MARKETING_EVENT_NAME ) {
                meCount++;
            }
        }
        System.assertEquals ( 1 , meCount);
        
        meCount = 0;
        for ( MarketingEvent me : ALMWebServices.searchMarketingEvents ( 
                                                                String.valueOf ( TODAY.addDays ( 1 ) ) ,
                                                                String.valueOf ( TODAY.addDays ( 2 ) )
                                                            ) ) {
            if ( me.Name == TEST_MARKETING_EVENT_NAME ) {
                meCount++;
            }
        }
        System.assertEquals ( 0 , meCount );

//      Marketing Event Cities...
//      -------------------------
        Integer mecCount = 0;
        for ( MarketingEventCity mec : ALMWebServices.getMarketingEventCities () ) {
            if ( mec.Name == TEST_MARKETING_CITY ) {
                mecCount++;
            }
        }
        System.assertEquals ( 1 , mecCount );
        
//      Exercise the MarketingEvent constructors.
//      -----------------------------------------   
        MarketingEvent me = new MarketingEvent ();
        me = new MarketingEvent ( [select Id from Marketing_Event__c where Id = :event.Id] );
        
        MarketingEventCity mec = new MarketingEventCity ();
        mec = new MarketingEventCity ( [select Id from Marketing_City__c where Id = :meCity.Id] );
    }

//  ============================================================================
//  Method:         test_ResearchPrefs
//  Description:    Tests WebSvc methods associated with Research Preferences.
//  ============================================================================
    public static testMethod void test_ResearchPrefs() {
        
        setupTestEnv ();
        setupResearchPrefs ();
        
        ResearchPreference[] rpList = ALMWebServices.getResearchPreferences ( cont0.Id ); 
        System.assertEquals ( 1 , rpList.Size () );

        rpList = ALMWebServices.getResearchPreferences ( cont1.Id ); 
        System.assertEquals ( 0 , rpList.Size () );
        
        AceContactPage contPage = ALMWebServices.getRPContactsByMetadataId ( new Id[] { rpm.Id } , Null , 100 );
        System.assertEquals ( 1 , contPage.aceContactList.Size () );
        
        rpm = [ select Id , RecordTypeId
                from ST_Research_Preference_Metadata__c
                where Id = :rpm.Id ];
                
        ResearchPrefMetadataPage rpmPage = ALMWebServices.getResearchPreferenceMetadata ( rpm.RecordTypeId , Null , 100 );
        System.debug ( rpmPage.rpmList.Size () );
        
        rpmPage= ALMWebServices.getResearchPreferenceMetadata ( Null , Null , 100 );
        System.debug ( rpmPage.rpmList.Size () );
         
//      Exercise the ResearchPreference and ResearchPreferenceMetadata constructors.
//      ----------------------------------------------------------------------------
        ResearchPreference rp = new ResearchPreference ();
        rp = new ResearchPreference ( [select Id from ST_Research_Preference__c where Id = :pref.Id] );

        ResearchPreferenceMetadata new_rpm = new ResearchPreferenceMetadata ();
        new_rpm = new ResearchPreferenceMetadata ( [select Id from ST_Research_Preference_Metadata__c 
                                                where Id = :rpm.Id] );
                                                
        rpmPage = new ResearchPrefMetadataPage ();
        rpmPage = new ResearchPrefMetadataPage ( new ResearchPreferenceMetadata[] { new_rpm } );
    }


    /**
    static testmethod void test_getContactList() {
        List<Contact_List__c> lcl = new List<Contact_List__c>();
        for(Integer i=0; i < 500; i++ ) { lcl.Add( new Contact_List__c() ); } 
        insert lcl;
        SObjectPage result = ALMWebservices.getContactList('', 200);
    }
    */
    static testmethod void test_getRecords() {
        List<Contact_List__c> lcl = new List<Contact_List__c>();
        for(Integer i=0; i < 500; i++ ) { lcl.Add( new Contact_List__c() ); } 
        insert lcl;
        SObjectPage result = ALMWebservices.getRecords(
                                                'Contact_List__c',  //  sObjType
                                                '',                 //  whereClause, 
                                                '',                 //  sortFld 
                                                '',                 //  startFldVal ,
                                                200,                //  pageSize
                                                null);              //  fldNames
        System.assertEquals(199, result.SObjectList.size());
    }
    
    static testmethod void test_getCallReportsByAccount() {
        acct0 = new Account ( Name = TEST_ACCT0_NAME );
        insert acct0;
        
        List<Call_Report__c> crList = new List<Call_Report__c>();
        for(Integer j = 0; j < 200; j++) {          
            Call_Report__c cr = new Call_Report__c ( Client__c = acct0.Id,
                                                     Meeting_Date__c = System.now(),
                                                     Subject_Meeting_Objectives__c = 'Conference' + j,
                                                     Meeting_Type__c = 'Analysis',
                                                     Location__c = 'Toronto',
                                                     Notes__c = 'Notes');           
            crList.Add(cr);
        }
        
        insert crList;
        
        SObjectPage result = ALMWebservices.getCallReportsByAccount(
                                                                    acct0.Id,
                                                                    null,
                                                                    200);
        System.assertEquals(199, result.SObjectList.size());
    }
    
    static testmethod void test_updateLastDiscussed() {
        Interest__c ints = new Interest__c();
        insert ints;
        
        Boolean result = ALMWebServices.updateLastDiscussed();
    }
    
    static testmethod void testgetAceListMembership() {
		Account a1 = new Account(Name = 'MyAccount'); insert a1;
		Contact c1 = new Contact(LastName = 'LastName1', AccountId = a1.Id); insert c1;
		Contact c2 = new Contact(LastName = 'LastName2', AccountId = a1.Id); insert c2;
		
		Ace_List__c aal1 = new Ace_List__c();
		aal1.Name = 'Ace List 1';
		insert aal1;
		
		Ace_List_Entry__c ae1 = new Ace_List_Entry__c();
		ae1.Ace_List__c = aal1.Id;
		ae1.Entry_List_Id__c = c1.Id;
		insert ae1;
		
		Ace_List_Entry__c ae2 = new Ace_List_Entry__c();
		ae2.Ace_List__c = aal1.Id;
		ae2.Entry_List_Id__c = c2.Id;
		insert ae2;
		
		AceListPage alp1 = ALMWebServices.getAceListMembershipPage(c1.Id, null, -1000);
		AceListPage alp2 = AceList.getListMembership(c1.Id, UserInfo.getUserId(), null, -1000);
	}
}