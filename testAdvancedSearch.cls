public class testAdvancedSearch {
    
    //---------------------------------------------------------------
    public static testMethod void testSearchAccount() 
    //---------------------------------------------------------------
    { 
    	User[] users = AceTestUtil.createTestUsers ();
    	Employee__c[] empls = AceTestUtil.getTestEmployees ( users , True );
    	Id userId = users[ 0 ].Id;
    	Employee__c emp = empls[ 0 ];

        String searchString = 'acctSearch';//'Galleon Bronze'
        String searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        String searchFields = 'Name, Type, WB_Tier__c';
        String startName = '';
        Integer pageSize = 100;
        
        //-----------------------------------
        // Create test data
        //-----------------------------------
        list<Account> acctList = new list<Account>();
        list<Contact> contList = new list<Contact>();
                
        // create an Account       
        Account acct0 = new Account(Name='acctSearch Acct0', WB_Tier__c = 'TEST_Diamond');acctList.add(acct0);
        Account acct1 = new Account(Name='acctSearch Acct1');acctList.add(acct1);
        try
        {           
            insert acctList; acct0 = acctList[0]; acct1 = acctList[1];
        } catch (DmlException e) {
            System.debug('**************Error: Accounts could not be created -- ' + e.getMessage()); return;
        }  
        Contact cont0 = new Contact( LastName = 'acctSearch Cont0', AccountId = acct0.Id); contList.add( cont0);
        Contact cont1 = new Contact( LastName = 'acctSearch Cont1', AccountId = acct1.Id); contList.add( cont1);
        try
        {           
            insert contList; cont0 = contList[0]; cont1 = contList[1];
        } catch (DmlException e) {
            System.debug('**************Error: Contacts could not be created -- ' + e.getMessage()); return;
        }
/*       
        List<Employee__c> empList;   
        Employee__c emp;
        empList = [Select Id, Name from Employee__c where User__c = :userId LIMIT 1];   
        if (empList != null && empList.size() > 0) 
            emp = empList[0];
        else {// Create an employee record for the user 
            // Create an employee        
            emp = new Employee__c(Name='John SearchAccount Smith', User__c=userId);
            try
            {
                insert emp;
            } catch (DmlException e) {
                System.debug('**************Error: Employee could not be created -- ' + e.getMessage()); return;
            }
            
        }
*/        
        // Create the account coverage
        Account_Coverage__c acctCoverage = new Account_Coverage__c(
                Account__c=acct0.Id
                , Employee__c= emp.Id
                , Role__c='Primary Sales'
                , Start_Date__c = date.newinstance(2009, 1, 1) // End Date of the coverage stays NULL
                );
        try
        {
            insert acctCoverage;
        } catch (DmlException e) {
            System.debug('**************Error: Account Coverage could not be created -- ' + e.getMessage()); return;
        }
        // Create the contact coverage 
        //NOTE: Contact coverage will automatically create Account coverage for the user
        Contact_Coverage__c contCoverage = new Contact_Coverage__c (
                                                Contact__c = cont0.Id, 
                                                Employee__c = emp.Id,
                                                Role__c = 'Backup');
        try
        {
            insert contCoverage;
        } catch (DmlException e) {
            System.debug('**************Error: Contact Coverage could not be created -- ' + e.getMessage()); return;
        } 
        //-----------------------------------
        // Test search based on the scope
        //-----------------------------------
        acctList = new List<Account>();
        SObjectPage items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        List<SObject> returnList = items.SObjectList;
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.assertEquals(2, acctList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                
        searchScope= AceAccount.CONTACT_COVERAGE_SCOPE;
        acctList = new List<Account>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		returnList = items.SObjectList;                                
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.assertEquals(1,acctList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                
        searchScope= AceAccount.ACCOUNT_COVERAGE_SCOPE;
        acctList = new List<Account>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        returnList = items.SObjectList;
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.assertEquals( 1, acctList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);              
                
        //-----------------------------------
        // Search for more than one word and test search operator (AND, OR)
        //-----------------------------------
        searchString = 'acctSearch, TEST_diamond';
        searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        acctList = new List<Account>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        returnList = items.SObjectList;
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.assertEquals( 2, acctList.size(),'**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                                
        //-----------------------------------
        // Test search not returning any record
        //-----------------------------------
        searchString = 'TEST_badAcctSearch, TEST_bronze';
        searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        acctList = new List<Account>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        returnList = items.SObjectList;
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.assertEquals( 0, acctList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
        
        /**Deprecated                              
        //-----------------------------------
        // SOSL Search  
        //-----------------------------------  
        searchFields = '';
        searchString = 'acctSearch*';
        searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        acctList = new List<Account>();
        returnList = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.debug ('************SEARCH BY SOSL List size: ' + acctList.size());
        */
        //-----------------------------------
        // Test AceAccountPage search
        //-----------------------------------  
        Boolean bGetLastInteraction = true;
        searchString = 'acctSearch';
        searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        searchFields = 'Name, Type, WB_Tier__c';
        AceAccountPage acctPage = AceAccount.searchByAccountFields (userId
                    , searchString,searchScope,searchFields,bGetLastInteraction
                    , startName,pageSize );                                 
        system.assertEquals(2, acctPage.AceAccountList.size(), 
        '**************AceAccountPage Error searching "' + searchString + '" '+ ' for ' + searchScope);
         
        //-----------------------------------
        // Test error reporting
        //----------------------------------- 
        searchString = '';
        acctList = new List<Account>();
        try 
        {
            items = AdvancedSearch.searchRecords (
                                    AdvancedSearch.searchObjType.ACCOUNT
                                    , userId, searchString, searchScope
                                    , searchFields, startName, pageSize);
            returnList = items.SObjectList;
            if (returnList != null) acctList = ((List<Account>)returnList);
        } catch (Exception e) {
            System.debug('**************Error: Expected error -- ' + e.getMessage()); 
        }
        //System.debug('**************Error:  AdvancedSearch.searchErr: ' +  AdvancedSearch.searchErr); 
        system.assertNotEquals('', AdvancedSearch.searchErr, 
        '**************Error should have been returned for search: "' + searchString + '" ');
         
    }
    
    //---------------------------------------------------------------
    public static testMethod void testSearchContact() 
    //---------------------------------------------------------------
    {
    	
    	User[] users = AceTestUtil.createTestUsers ();
    	Employee__c[] empls = AceTestUtil.getTestEmployees ( users , True );
    	Id userId = users[ 0 ].Id;
    	Employee__c emp = empls[ 0 ];
    	
        String searchString = 'contSearch';
        String searchScope= AceContact.ALL_COVERAGE_SCOPE;
        String searchFields = 'Name, ST_ACE__Type__c, Sectors__c';
        String startName = '';
        Integer pageSize = 100;
        
        //-----------------------------------
        // Create test data
        //-----------------------------------
        list<Account> acctList = new list<Account>();
        list<Contact> contList = new list<Contact>();
        
        // create an Account       
        Account acct0 = new Account(Name='contSearch Acct0');acctList.add(acct0);
        Account acct1 = new Account(Name='contSearch Acct1');acctList.add(acct1);
        try
        {           
            insert acctList; acct0 = acctList[0]; acct1 = acctList[1];
        } catch (DmlException e) {
            System.debug('**************Error: Accounts could not be created -- ' + e.getMessage()); return;
        }  
        Contact cont0 = new Contact( LastName = 'contSearch Cont0', AccountId = acct0.Id, Sectors__c = 'TEST_Mining'); contList.add( cont0);
        Contact cont1 = new Contact( LastName = 'contSearch Cont1', AccountId = acct1.Id); contList.add( cont1);
        try
        {           
            insert contList; cont0 = contList[0]; cont1 = contList[1];
        } catch (DmlException e) {
            System.debug('**************Error: Contacts could not be created -- ' + e.getMessage()); return;
        }

/*                 
        List<Employee__c> empList;   
        Employee__c emp;
        empList = [Select Id, Name from Employee__c where User__c = :userId LIMIT 1];   
        if (empList != null && empList.size() > 0) 
            emp = empList[0];
        else {// Create an employee record for the user 
            // Create an employee        
            emp = new Employee__c(Name='John SearchContact Smith', User__c=userId);
            try
            {
                insert emp;
            } catch (DmlException e) {
                System.debug('**************Error: Employee could not be created -- ' + e.getMessage()); return;
            }           
        }
*/        
        // Create the account coverage
        Account_Coverage__c acctCoverage = new Account_Coverage__c(
                Account__c=acct0.Id
                , Employee__c= emp.Id
                , Role__c='Primary Sales'
                , Start_Date__c = date.newinstance(2009, 1, 1) // End Date of the coverage stays NULL
                );
        try
        {
            insert acctCoverage;
        } catch (DmlException e) {
            System.debug('**************Error: Account Coverage could not be created -- ' + e.getMessage()); return;
        }
        // Create the contact coverage 
        //NOTE: Contact coverage will automatically create Account coverage for the user
        Contact_Coverage__c contCoverage = new Contact_Coverage__c (
                                                Contact__c = cont0.Id, 
                                                Employee__c = emp.Id,
                                                Role__c = 'Backup');
        try
        {
            insert contCoverage;
        } catch (DmlException e) {
            System.debug('**************Error: Contact Coverage could not be created -- ' + e.getMessage()); return;
        } 
        //-----------------------------------
        // Test search based on the scope
        //-----------------------------------
        contList = new List<Contact>();
        SObjectPage items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        List<SObject> returnList = items.SObjectList;
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.assertEquals( 2, contList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                
        contList = new List<Contact>();
        searchScope= AceContact.ACCOUNT_COVERAGE_SCOPE;
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		returnList = items.SObjectList;                                
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.assertEquals(1, contList.size(),  '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                
        contList = new List<Contact>();
        searchScope= AceContact.CONTACT_COVERAGE_SCOPE;
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		returnList = items.SObjectList;                                
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.assertEquals(1, contList.size(),  '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                                    
        //-----------------------------------
        // Search for more than one word and test search operator (AND, OR)
        //-----------------------------------
        searchString = 'contSearch, TEST_mining';
        searchScope= AceContact.ALL_COVERAGE_SCOPE;
        contList = new List<Contact>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		returnList = items.SObjectList;                                
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.assertEquals(2, contList.size(),  '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
                                
        //-----------------------------------
        // Test search not returning any record
        //-----------------------------------
        searchString = 'TEST_badcontSearch, TEST_Technology';
        searchScope= AceContact.ALL_COVERAGE_SCOPE;
        contList = new List<Contact>();
        items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		returnList = items.SObjectList;                                
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.assertEquals(0, contList.size(), '**************Error searching "'
                + searchString + '" '+ ' for ' + searchScope);
           
        /** Deprecated                              
        //-----------------------------------
        // SOSL Search  
        //-----------------------------------  
        searchFields = '';
        searchString = 'contSearch*';
        searchScope= AceContact.ALL_COVERAGE_SCOPE;
        contList = new List<Contact>();
        returnList = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        if (returnList != null) contList = ((List<Contact>)returnList);
        system.debug ('************SEARCH BY SOSL List size: ' + contList.size());
        */
        //-----------------------------------
        // Test AceContactPage search
        //-----------------------------------  
        Boolean bGetLastInteraction = true;
        searchString = 'contSearch';
        searchScope= AceContact.ALL_COVERAGE_SCOPE;
        searchFields = 'Name, ST_ACE__Type__c, Sectors__c';
        AceContactPage contPage = AceContact.searchByContactFields (userId
                    , searchString,searchScope,searchFields,bGetLastInteraction
                    , startName,pageSize );                     
        system.assertEquals(2, contPage.AceContactList.size(), 
        '**************AceContactPage Error searching "' + searchString + '" '+ ' for ' + searchScope);
        
        
    }
    
    //RA commented out: this test method should not be part of deployment
    //---------------------------------------------------------------
    //public static testMethod void testSearchPerformance() 
    //---------------------------------------------------------------
   // {   //limitted by the number of DML row limit = 500!!!
    //  testGenerateAccounts(500) ;
   // }
    //---------------------------------------------------------------
    private static void testGenerateAccounts(integer acctNo) 
    //---------------------------------------------------------------
    {
        
        Id userId = UserInfo.getUserId();
        String searchString = 'platinum, portland';
        String searchScope= AceAccount.ALL_COVERAGE_SCOPE;
        String searchFields = 'Name, Type, WB_Tier__c, ST_ACE__Tier__c, TickerSymbol, City__c';
        String startName = '';
        Integer pageSize = 500;
        list<Account> acctList = new list<Account>();
        integer i = 0;
        Account acct;
        string wbTier = 'Bronze';
        // create an Account   
        while (i < acctNo) {
            if (i<10) wbTier = 'Diamond';
            else if (i<110) wbTier = 'Bronze';
            else 
                if (i<=500) wbTier = 'Platinum';
            acct = new Account(Name='SearchPerformance Acct' + i, WB_Tier__c=wbTier
                    , ST_ACE__Tier__c='MM', TickerSymbol='SPAcct' + i, City__c='Portland');
            acctList.add(acct);
            i++;
        }
        try
        {           
            insert acctList; 
        } catch (DmlException e) {
            System.debug('**************Error: Accounts could not be created -- ' + e.getMessage()); return;
        } 
         
          
        acctList = new List<Account>();
        SObjectPage items = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.ACCOUNT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
		List<SObject> returnList = items.SObjectList;		                                
        if (returnList != null) acctList = ((List<Account>)returnList);
        system.debug('**************Search Result: ' + AdvancedSearch.searchResult);
             
       
    }
}