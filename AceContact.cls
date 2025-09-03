/* 
 * Name: Contact 
 * Description: Contains the details of a contact, and its account details
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AceContact {
    
    public static String CONTACT_COVERAGE_SCOPE = 'menuItemContactCoverage';
    public static String ACCOUNT_COVERAGE_SCOPE = 'menuItemAccountCoverage';
    public static String ALL_COVERAGE_SCOPE = 'menuItemAll';
    
    webService String Id;
    webService String Title;
    webService String FirstName;
    webService String LastName;
    webService String Name;
    webService String Phone;
    webService String MobilePhone;
    webService String HomePhone;
    webService String AssistantPhone;
    webService String OtherPhone;
    webService String Aum;
    webService String InvestStyle;
    webService String Regions;
    webService String Sectors;
    webService String SubSectors;
    webService String Email;
    webService String MailingCity;
    webService String MailingCountry;
    webService String MailingPostalCode;
    webService String MailingState;   
    webService String MailingStreet;           
    webService boolean Inactive; 
    webService String AccountId;
    webService AceAccount AceAccount; 

    // --- Not directly from SF Contact ---
    webService Date LastInteractionDate;
    
    public AceContact() {
    }   
    
    public AceContact ( Contact aContact ) {
        this ( aContact , True );
    }
    
    public AceContact ( Contact aContact , Boolean bUseAccount ) {
        if ( aContact == Null ) { return; }
        
        try { this.Id = aContact.Id; } catch ( SObjectException e ) {}
        try { this.Title = aContact.Title; } catch ( SObjectException e ) {}
        try { this.FirstName = aContact.FirstName; } catch ( SObjectException e ) {}
        try { this.LastName = aContact.LastName; } catch ( SObjectException e ) {}
        try { this.Name = aContact.FirstName + ' ' + aContact.LastName; } catch ( SObjectException e ) {}
        try { this.Phone = aContact.Phone; } catch ( SObjectException e ) {}
        try { this.MobilePhone = aContact.MobilePhone; } catch ( SObjectException e ) {}
        try { this.HomePhone = aContact.HomePhone; } catch ( SObjectException e ) {}
        try { this.AssistantPhone = aContact.AssistantPhone; } catch ( SObjectException e ) {}
        try { this.OtherPhone = aContact.OtherPhone; } catch ( SObjectException e ) {}
        try { this.Aum = aContact.Aum__c; } catch ( SObjectException e ) {}
        try { this.InvestStyle = aContact.Invest_Style__c; } catch ( SObjectException e ) {}
        try { this.Regions = aContact.Regions__c; } catch ( SObjectException e ) {}
        try { this.Sectors = aContact.Sectors__c; } catch ( SObjectException e ) {}
        try { this.SubSectors = aContact.Sub_Sectors__c; } catch ( SObjectException e ) {}
        try { this.Email = aContact.Email; } catch ( SObjectException e ) {}
        try { this.MailingCity = aContact.MailingCity; } catch ( SObjectException e ) {}
        try { this.MailingCountry = aContact.MailingCountry; } catch ( SObjectException e ) {}
        try { this.MailingPostalCode = aContact.MailingPostalCode; } catch ( SObjectException e ) {}
        try { this.MailingState = aContact.MailingState; } catch ( SObjectException e ) {}
        try { this.MailingStreet = aContact.MailingStreet; } catch ( SObjectException e ) {}                        
        try { this.Inactive = aContact.ST_Inactive__c; } catch ( SObjectException e ) {}
        try { this.AccountId = aContact.AccountId; } catch ( SObjectException e ) {}
                
        if ( bUseAccount ) {
            try { this.AceAccount = new AceAccount ( aContact.Account ); } catch ( SObjectException e ) {}
        }
    }
    
    public AceContact ( Id UId , String Name ) {
        this.Id = UId;
        this.Name = Name;
    }
            
    public AceContact ( Interest__c interest ) {
        if ( interest == Null ) { return; }
        
        try { this ( interest.Contact__r , False ); } catch ( SObjectException e ) {}      
        this.AceAccount = new AceAccount ( interest );
    }   
    
//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified AceContact record to the
//        specified list of lists of AceContact records.  Calls the
//        'list' version of this function, which does all the work.
//     
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<AceContact>> elemListList , 
                                        AceContact myElem ) {
        listListAdd ( elemListList , new List<AceContact> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of AceContact
//        records to the specified list of lists of AceContact records.
//     
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<AceContact>> elemListList , 
                                        List<AceContact> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//    Go through the list of lists, finding the first list that has room for
//    our element list
//    ----------------------------------------------------------------------
        List<AceContact> elemList = Null;
        for ( List<AceContact> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<AceContact> {};
            elemListList.add ( elemList );
        }
        
        elemList.addAll ( myElemList );
    }
    
//  ============================================================================
//  Method: getLastInteractions
//
//  Desc:   Function to go through the specified list of list of Contacts, 
//        determining the last interaction date on each Contact by the 
//        specified userId.
//     
//  Return: Nothing.  The list of lists of Contacts is modified in situ.
//  ============================================================================                    
    public static void getLastInteractions ( List<List<AceContact>> contListList ,
                                                Id userId ) 
    {
        //Iterate through the list of lists
        for ( List<AceContact> acl : contListList ) 
        {
            //Call the other method that will populate the lists last interaction based off
            //a list of ace contacts
            getLastInteractions(acl, userId);
        }
    } 
    
//  ============================================================================
//  Method: getLastInteractions
//
//  Desc:   Function to go through the specified list of Contacts, 
//        determining the last interaction date on each Contact by the 
//        specified userId.
//     
//  Return: Nothing.  The list of lists of Contacts is modified in situ.
//  ============================================================================    
    public static void getLastInteractions (List<AceContact> contList, Id userId)
    {
        //Create the map of contacts 
        Map<Id , AceContact> contById = new Map<Id , AceContact> {};
        
        //For each of the contacts in the list
        for ( AceContact ac : contList ) 
        {
            //Add the contact to the map
            contById.put ( ac.Id , ac );
        }
        //Get the recent interactions
        for ( UserContactInteraction uci :
                    UserContactInteraction.getUserContactInteractions (
                                                userId ,
                                                contById.keySet ()
                                            )
        ) 
        {
            //Set the last interaction date
            AceContact ac = contById.get ( uci.ContactId );
            ac.LastInteractionDate = uci.LastInteractionDate;
        }
    }  
    
//  ============================================================================
//  Method:      getActiveContactsByAcctId
//  Description:    Utility to retrieve a list of sets of active ContactIds
//                associated with the specified AccountId.          
//  Args:          acctid - the AccountId
//  Return:      List of sets of active ContactIds.
//  ============================================================================
    public static List<Set<Id>> getActiveContactsByAcctId ( Id acctId ) {
        
        List<Set<Id>> returnList = new List<Set<Id>> {};
        for ( Contact cont : [ select
                                    Id
                                from
                                    Contact
                                where
                                    AccountId = :acctId and
                                    ST_Inactive__c = false
                            ]
        ) {
            AceUtil.setListAdd ( returnList , cont.Id , False );
        }
    
        return returnList;
    }
    
//  ============================================================================
//  Method: getContactsByInterestSymbol 
//  Desc:   Retrieves Contact and Account information for all Interests in the
//          specified list of Symbols.  This will be paged based off the Account Name,
//          since contacts are not required for Interests.
//  Args:   userId - the User to search on behalf of.
//        symList - list of Symbols we are searching for Interests for.
//        scope - Search constraint directive:
//          All Coverage - any account or contact
//          My Accounts  - only Accounts covered by the userId
//          My Contacts  - 'My Accounts' plus Contacts covered by the userId
//  Return: List of AceContact records.              
//  Case No: 3702
//  ============================================================================
    public static AceContactPage getContactsByInterestSymbols ( 
                                                Id userId ,
                                                String[] symList ,
                                                String scope ,
                                                Boolean bGetLastInteraction,
                                                String startName,
                                                Integer pageSize ) 
    {
        String coveredAccountsQuery = '';
        String coveredContactsQuery = '';
        
        //Check the scope
        if ( scope == CONTACT_COVERAGE_SCOPE )
        {
            //If its contact coverage
            //Make the query claused based off the Contact__c field.  Retrieve the list of Contact  Coverage for the user
            coveredContactsQuery = AceCoverageUtil.mkInQueryClause('Contact__c', AceCoverageUtil.getCoverage(userId, AceCoverageUtil.CoverageMode.DIRECT_CONTACT_COVERAGE, null ));
            
            //Check if there are contacts covered
            if (coveredContactsQuery == '')
            {
                //If there are none return a blank page
                return new AceContactPage();
            }
        }
        else if ( scope == ACCOUNT_COVERAGE_SCOPE )
        {
            //If its account coverage
            //Make the query clause based off the Account__c field.  Retrieve the list of Account Coverage for the user
            coveredAccountsQuery = AceCoverageUtil.mkInQueryClause('Account__c', AceCoverageUtil.getCoverage(userId, AceCoverageUtil.CoverageMode.DIRECT_ACCOUNT_COVERAGE, null ));
            
            //Check if there are accounts covered
            if (coveredAccountsQuery == '')
            {
                //If there are none return a blank page
                return new AceContactPage();
            }
        }
                    
        List<AceContact> aceContactList = new List<AceContact>();
        
        List<Set<Id>> contactListSet = new List<Set<Id>> {};
        List<Set<Id>> accountListSet = new List<Set<Id>> {};
        
        //Create the custom list of fields associated with the interest search
        List<String> fields = new List<String>
        {
            'Id' , 'Label__c' , 'Source__c' , 'As_Of_Date__c',
            'Symbol__c' , 'Symbol_Name__c' , 'Reason__c' , 'Note__c' ,
            'LastModifiedDate' , 'LastModifiedBy.Name' ,                                    
            'Account__r.Id', 'Account__r.Name' , 'Account__r.WebSite' ,
            'Account__r.Type' , 'Account__r.BillingCountry' ,
            'Account__r.Aum__c' , 'Account__r.Phone' , 
            'Account__r.ST_ACE__Tier__c' , 'Account__r.ST_Thomson_Id__c',
            'Account__r.WB_Tier__c','Account__r.Sector__c','Account__r.City__c',
            'Account__r.Cash_EQ_Tier__c',
            'Contact__r.Id' , 'Contact__r.Name' , 'Contact__r.Title' ,
            'Contact__r.FirstName' , 'Contact__r.LastName' , 'Contact__r.Phone' ,
            'Contact__r.MobilePhone' , 'Contact__r.HomePhone' , 
            'Contact__r.AssistantPhone' , 'Contact__r.OtherPhone' ,
            'Contact__r.Aum__c' , 'Contact__r.Invest_Style__c' ,
            'Contact__r.Regions__c' , 'Contact__r.Sectors__c' ,
            'Contact__r.Sub_Sectors__c' , 
            'Contact__r.Email' , 'Contact__r.ST_Inactive__c' ,
            'Contact__r.Account.ST_ACE__Tier__c'            
        };        
        
        String whereClause = 'Expired__c = false and ';
        
        //Append the list of symbols
        //TODO: Call the general utility method created for appending in clause values
        //whereClause += AceCoverageUtil.mkInQueryClause('Symbol__c', symList);
        whereClause += 'Symbol__c in (' + AceUtil.concatList ( symList , ' , ' , True ) + ')';
        
        //If there are contacts in the coverage query
        if (coveredContactsQuery != '')
        {
            //Add it to the where clause
            whereClause += ' and ' + coveredContactsQuery;
        }
        else if (coveredAccountsQuery != '')
        {
            //Otherwise if there are account coverage records
            //Add it to the where clause
            whereClause += ' and ' + coveredAccountsQuery;
        }
        
        //Get the results
        SObjectPage results = AceSObject.getSObjectPage ( 'Interest__c', whereClause, 'Account__r.Name', startName, pageSize, fields ); 
        
        for ( SObject result : results.SObjectList ) 
        {
            //Cast the SObject as an interest
            Interest__c intr = (Interest__c)result;
            
            //If the contact is inactive then move on to the next item
            if ( intr.Contact__c != Null && intr.Contact__r.ST_Inactive__c == True ) {
                continue;
            }
          
                
//          Skip dupes by maintaining a list of sets of Accounts, and one of Contacts.
//          --------------------------------------------------------------------------
            if ( intr.Contact__c != Null ) 
            {
                if ( aceUtil.setListAdd ( contactListSet , intr.Contact__c , True ) == 0 ) 
                {
                    continue;
                }
            }
            else if ( intr.Account__c != Null ) 
            {
                if ( aceUtil.setListAdd ( accountListSet , intr.Account__c , True ) == 0 ) 
                {
                    continue;
                }
            }
                            
            //Add the contact to the ace contact list
            aceContactList.add(new AceContact ( intr ) );                                                
        }

        if ( bGetLastInteraction ) {
            getLastInteractions ( aceContactList , userId );
        }
        
        return new AceContactPage( aceContactList, results.NextKey );
        //return aceContactListList;
    }        															 
    
//  ============================================================================
//  Method: searchInterestsBySymbol 
//  Desc:   Retrieves Contact and Account information for all Interests in the
//        specified list of Symbols.
//  Args:   userId - the User to search on behalf of.
//        symList - list of Symbols we are searching for Interests for.
//        scope - Search constraint directive:
//          All Coverage - any account or contact
//          My Accounts  - only Accounts covered by the userId
//          My Contacts  - 'My Accounts' plus Contacts covered by the userId
//  Return: List of AceContact records.              
//  Case No: 3702
//  ============================================================================
    public static List<List<AceContact>> searchInterestsBySymbol ( 
                                                Id userId ,
                                                String[] symList ,
                                                String scope ,
                                                Boolean bGetLastInteraction ) {

        List<Set<Id>> coveredContSetList = Null;
        List<Set<Id>> coveredAcctSetList = Null;
        
//      Contact/Account coverage, if specified.
//      ---------------------------------------
        if ( scope == CONTACT_COVERAGE_SCOPE || scope == ACCOUNT_COVERAGE_SCOPE ) {
            coveredAcctSetList = new List<Set<Id>> {};
            for ( Account_Coverage__c ac : [select Account__c
                                            from Account_Coverage__c
                                            where Employee__r.User__c = :userId]
                                    ) {
                AceUtil.setListAdd ( coveredAcctSetList , ac.Account__c , True );
            }
            
            if ( scope == CONTACT_COVERAGE_SCOPE ) {
                coveredContSetList = new List<Set<Id>> {};
                for ( Contact_Coverage__c cc : [select Contact__c
                                                from Contact_Coverage__c
                                                where Employee__r.User__c = :userId]
                                        ) {
                    AceUtil.setListAdd ( coveredContSetList , cc.Contact__c , True );
                }
            }
        }
              
        List<List<AceContact>> aceContactListList = new List<List<AceContact>> {};
        List<Set<Id>> contactListSet = new List<Set<Id>> {};
        List<Set<Id>> accountListSet = new List<Set<Id>> {};
        
        for ( Interest__c intr : [select
                                    Id , Label__c , Source__c , As_Of_Date__c,
                                    Symbol__c , Symbol_Name__c , Reason__c , Note__c ,
                                    LastModifiedDate , LastModifiedBy.Name ,
                                    
                                    Account__r.Id, Account__r.Name , Account__r.WebSite ,
                                    Account__r.Type , Account__r.BillingCountry ,
                                    Account__r.Aum__c , Account__r.Phone , 
                                    Account__r.ST_ACE__Tier__c , Account__r.ST_Thomson_Id__c,
                                    
                                    Contact__r.Id , Contact__r.Name , Contact__r.Title ,
                                    Contact__r.FirstName , Contact__r.LastName , Contact__r.Phone ,
                                    Contact__r.MobilePhone , Contact__r.HomePhone , 
                                    Contact__r.AssistantPhone , Contact__r.OtherPhone ,
                                    Contact__r.Aum__c , Contact__r.Invest_Style__c ,
                                    Contact__r.Regions__c , Contact__r.Sectors__c ,
                                    Contact__r.Sub_Sectors__c , 
                                    Contact__r.Email , Contact__r.ST_Inactive__c ,
                                    Contact__r.Account.ST_ACE__Tier__c
                                from Interest__c
                                where
                                    Symbol__c in :symList and
                                    Expired__c = False
                                ]
                                ) {

//        Three cases for inclusion (could maybe be logically grouped a bit more cleanly):
//        1) CoveredAcctSet = Null ('ALL ACCTS')
//           OR
//        2) CoveredContSet = Null AND CoveredAcctSet contains InterestAcct ('ACCT COVERAGE')
//           OR
//        3) CoveredContSet contains InterestContact
//                OR ( CoveredAcctSet contains InterestAcct and InterestContact is Null )
//                ('CONTACT COVERAGE')  
//        -----------------------------------------------------------------------------------

            if ( intr.Contact__c != Null && intr.Contact__r.ST_Inactive__c == True ) {
                continue;
            }
            
            Boolean bInclude = False;
            if ( coveredAcctSetList == Null ) {
                bInclude = True;    // case 1
            }
            else if ( coveredContSetList == Null && AceUtil.setListFind ( coveredAcctSetList , intr.Account__c ) ) {
                bInclude = True;    // case 2
            }
            else if ( ( coveredContSetList != Null && AceUtil.setListFind ( coveredContSetList , intr.Contact__c ) )
                        || ( intr.Contact__c == Null && AceUtil.setListFind ( coveredAcctSetList , intr.Account__c ) ) ) {
                bInclude = True;    // case 3
            }
            
            if ( bInclude ) {
                
//            Skip dupes by maintaining a list of sets of Accounts, and one of Contacts.
//            --------------------------------------------------------------------------
                if ( intr.Contact__c != Null ) {
                    if ( aceUtil.setListAdd ( contactListSet , intr.Contact__c , True ) == 0 ) {
                        continue;
                    }
                }
                else if ( intr.Account__c != Null ) {
                    if ( aceUtil.setListAdd ( accountListSet , intr.Account__c , True ) == 0 ) {
                        continue;
                    }
                }
                                    
                listListAdd ( aceContactListList , new AceContact ( intr ) );
            }
        }

        if ( bGetLastInteraction ) {
            getLastInteractions ( aceContactListList , userId );
        }
        return aceContactListList;
    }
    
//  ============================================================================
//  Method:      getContactsByAcctName
//  Description:    Retrieves a page of Contacts belonging to the Accounts
//                  whose Names match the specified Name fragment.        
//  Args:          acctName - the Account Name fragment.
//  Return:      Page of AceContacts with the matching Contact information.                   
//  Case No:        3886
//  ============================================================================
    public static AceContactPage getContactsByAcctName ( String acctName ,
                                                            String startName ,
                                                            Integer pageSize ) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
        
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
        
        for ( Contact cont: [ Select
                                Id , Name , Title ,
                                FirstName , LastName , Phone , 
                                MobilePhone , HomePhone ,
                                AssistantPhone , OtherPhone ,
                                Aum__c , Invest_Style__c ,
                                Regions__c , Sectors__c ,
                                Sub_Sectors__c , 
                                Email , ST_Inactive__c ,
                                Account.Id , 
                                Account.Name ,
                                Account.BillingCity,
                                Account.ST_Thomson_Id__c ,
                                Account.ST_ACE__Tier__c ,
                                Account.ParentId ,
                                Account.Parent.Name ,
                                Account.Parent.Phone
                            From
                                Contact
                            Where
                                ST_Inactive__c = False and 
                                Account.Name like :acctName + '%' and
                                Name >= :startName
                            order by
                                Name
                            limit
                                :pageSize + 1
                            ]
        ) {
            if ( !aclb.addAceContact ( new AceContact ( cont ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    }

//  ============================================================================
//  Method:      getContactsByAcctId
//  Description:    Retrieves the Contacts belonging to the specified list 
//                  of Account Ids.         
//  Args:          acctIdList   - the Account Id list.
//  Return:      List of AceContacts with the matching Contact information.                   
//  Case No:        3896 and 3898
//  ============================================================================
    public static AceContactPage getContactsByAcctId ( Id[] acctIdList ,
                                                            String startName ,
                                                            Integer pageSize ) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
        
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
        
        for ( Contact cont: [ Select
                                Id , Name , Title ,
                                FirstName , LastName , Phone , 
                                MobilePhone , HomePhone ,
                                AssistantPhone , OtherPhone ,                               
                                Aum__c , Invest_Style__c ,
                                Regions__c , Sectors__c ,
                                Sub_Sectors__c , 
                                Email , ST_Inactive__c ,
                                MailingStreet, MailingCity, 
                                MailingCountry, MailingState, 
                                MailingPostalCode,                              
                                Account.Id , 
                                Account.Name ,
                                Account.BillingCountry ,
                                Account.ST_ACE__Tier__c ,
                                Account.ST_Thomson_Id__c ,
                                Account.ParentId ,
                                Account.Parent.Name ,
                                Account.Parent.Phone
                            From
                                Contact
                            Where
                                ST_Inactive__c = False and
                                AccountId in :acctIdList and
                                Name >= :startName
                            order by
                                Name
                            limit
                                :pageSize + 1
                            ]
        ) {
            if ( !aclb.addAceContact ( new AceContact ( cont ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    }

//  ============================================================================
//  Method:      getContactsByName
//  Description:    Retrieves a page of Contacts whose First and/or Last names
//                  match the specified Name fragment.          
//  Args:          contName - the Contact Name fragment.
//  Return:      Page of AceContacts with the matching Contact information.                   
//  Case No:        3724
//  ============================================================================
    public static AceContactPage getContactsByName ( String contName ,
                                                        String startName ,
                                                        Integer pageSize ) {
                                                            
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
        
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
        for ( Contact cont: [ select
                                Id , Name , Title ,
                                FirstName , LastName , Phone ,
                                MobilePhone , HomePhone ,
                                AssistantPhone , OtherPhone ,                               
                                Aum__c , Invest_Style__c ,
                                Regions__c , Sectors__c ,
                                Sub_Sectors__c , 
                                Email , ST_Inactive__c ,
                                MailingStreet, MailingCity, 
                                MailingCountry, MailingState, 
                                MailingPostalCode,                              
                                Account.Id , 
                                Account.Name ,
                                Account.BillingCity ,
                                Account.ST_ACE__Tier__c ,
                                Account.ST_Thomson_Id__c ,
                                Account.ParentId ,
                                Account.Parent.Name ,
                                Account.Parent.Phone
                            from
                                Contact
                            where
                                ST_Inactive__c = False and (
                                    Name like :contName + '%' or
                                    Name = :contName or
                                    FirstName like :contName + '%' or
                                    LastName like :contName + '%'
                                ) and
                                Name >= :startName
                            order by
                                Name
                            limit
                                :pageSize + 1
                            ]
        ) {
            if ( !aclb.addAceContact ( new AceContact ( cont ) ) ) {
                break;
            }
        }

//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    }

        
//  ============================================================================
//  Method:      getContactsByNameAndAcctName
//  Description:    Retrieves a page of Contacts whose First and/or Last names
//                  match the specified Contact Name fragment, and whose Account
//                  name matches the specified AccountName fragment.     
//  Args:          contName - the Contact Name fragment.
//                acctName  - the Account Name fragment
//                  startName   - the starting Name of this page.
//                  pageSize    - the page size.
//  Return:      Page of AceContacts with the matching name fragments.                     
//  Case No:        3733
//  ============================================================================
    public static AceContactPage getContactsByNameAndAcctName ( 
                                                            String contName ,
                                                            String acctName ,
                                                            String startName ,
                                                            Integer pageSize
                                                        ) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
             
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
        
        for ( Contact cont: [ Select
                                Id , Name , Title ,
                                FirstName , LastName , Phone ,
                                MobilePhone , HomePhone ,
                                AssistantPhone , OtherPhone ,
                                Aum__c , Invest_Style__c ,
                                Regions__c , Sectors__c ,
                                Sub_Sectors__c , 
                                Email , ST_Inactive__c ,
                                Account.Id , 
                                Account.Name ,
                                Account.BillingCity ,
                                Account.ST_ACE__Tier__c ,
                                Account.ST_Thomson_Id__c ,
                                Account.ParentId ,
                                Account.Parent.Name ,
                                Account.Parent.Phone
                            From
                                Contact
                            Where
                                ST_Inactive__c = False and (
                                    Name = :contName or
                                    FirstName like :contName + '%' or
                                    LastName like :contName + '%'
                                ) and
                                Account.Name like :acctName + '%' and
                                Name >= :startName
                            order by
                                Name
                            limit
                                :pageSize + 1
                            ]
        ) {
            if ( !aclb.addAceContact ( new AceContact ( cont ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    }

//  ============================================================================
//  Method: getRPContactsByMetadataId   
//  Desc:   Retrieves a page of Contacts (+ their Account info) associated 
//          with Research Preferences whose Metadata Ids match the specified
//          list of Ids.
//  Args:   rpmIdList   - the list of Research Preference Metadata Ids.
//          startName   - the starting Name of this page.
//          pageSize    - the page size.
//  Return: List of matching Contacts
//  Case:   3989
//  ============================================================================
    public static AceContactPage getRPContactsByMetadataId ( String[] rpmIdList ,
                                                                String startName ,
                                                                Integer pageSize ) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
             
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
        
        if ( rpmIdList == Null || rpmIdList.isEmpty () ) {
            return new AceContactPage ( aclb.ContList , Null );
        }

//      Grab the RPM Names associated with the specified RPM Ids.
//      ---------------------------------------------------------
        Set<String> rpmTypeSet = new Set<String> {};
        Set<String> rpmNameSet = new Set<String> {};
        Set<String> rpmTypeAndNameSet = new Set<String> {};
        
        for ( ST_Research_Preference_Metadata__c sfRPM : [ select
                                                                Name ,
                                                                RecordType.Name
                                                            from
                                                                ST_Research_Preference_Metadata__c
                                                            where
                                                                Id in :rpmIdList
                                                            ]
        ) {
            rpmTypeSet.add ( sfRPM.RecordType.Name );
            rpmNameSet.add ( sfRPM.Name );
            rpmTypeAndNameSet.add ( sfRPM.RecordType.Name + ':' + sfRPM.Name );
        }
                
        for ( ST_Research_Preference__c sfRP : [ select
                                                    ST_Preference_Type__c ,
                                                    ST_Preference_Name__c ,
                                                    ST_Contact__r.Id ,
                                                    ST_Contact__r.FirstName ,
                                                    ST_Contact__r.LastName ,
                                                    ST_Contact__r.Phone ,
                                                    ST_Contact__r.Aum__c ,
                                                    ST_Contact__r.Invest_Style__c ,
                                                    ST_Contact__r.Regions__c ,
                                                    ST_Contact__r.Sectors__c ,
                                                    ST_Contact__r.Sub_Sectors__c ,
                                                    ST_Contact__r.Email ,
                                                    ST_Contact__r.Title ,
                                                    ST_Contact__r.Account.Id ,
                                                    ST_Contact__r.Account.Name ,
                                                    ST_Contact__r.Account.Aum__c ,
                                                    ST_Contact__r.Account.ST_ACE__Tier__c ,
                                                    ST_Contact__r.Account.Phone
                                                from
                                                    ST_Research_Preference__c
                                                where
                                                    ST_Contact__r.ST_Inactive__c = False and 
//                                                  ST_Research_Preference_Metadata__c in :rpmIdList
                                                    ST_Preference_Type__c in :rpmTypeSet and
                                                    ST_Preference_Name__c in :rpmNameSet and
                                                    ST_Contact__r.Name >= :startName
                                                order by
                                                    ST_Contact__r.Name
                                                limit
                                                    :pageSize + 1
                                                ]
        ) {
            if ( rpmTypeAndNameSet.contains ( sfRP.ST_Preference_Type__c + ':' + sfRP.ST_Preference_Name__c ) ) {
                if ( !aclb.addAceContact ( new AceContact ( sfRP.ST_Contact__r , True ) ) ) {
                    break;
                }
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    }
/** STUBBED OUT FOR CIBC ROLLOUT MAY 19th 2009 - 
//  ============================================================================
//  Method:      getContactsByConferenceId
//  Description:    Retrieves a page of Contacts associated with Registrants
//                  linked to the specified list of Conference Ids.  
//  Args:          confIds   - the Conference Id list.
//                  startName   - the starting Name of this page.
//                  pageSize    - the page size.
//  Return:      Page of matching AceContacts                      
//  Case No:        3993
//  ============================================================================
    public static AceContactPage getContactsByConferenceId ( String[] confIds ,
                                                                String startName ,
                                                                Integer pageSize
                                                            ) {
            
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
             
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize );
 
        for ( Registrant__c reg: [ Select
                                Contact__r.Id , 
                                Contact__r.FirstName , 
                                Contact__r.LastName , 
                                Contact__r.Phone , 
                                Contact__r.Aum__c ,
                                Contact__r.Invest_Style__c ,
                                Contact__r.Regions__c , 
                                Contact__r.Sectors__c ,
                                Contact__r.Sub_Sectors__c , 
                                Contact__r.Email , 
                                Contact__r.Title ,
                                Contact__r.Account.Id , 
                                Contact__r.Account.Name ,
                                Contact__r.Account.Aum__c ,
                                Contact__r.Account.ST_ACE__Tier__c ,
                                Contact__r.Account.Phone
                            From
                                Registrant__c
                            Where
                                Contact__r.ST_Inactive__c = False and
                                Conference__c in :confIds and  
                                Attendance_Status__c = 'Attended'and
                                Contact__r.Name >= :startName
                            order by
                                Name
                            limit
                                :pageSize + 1
                            ]
        ) {
            if ( !aclb.addAceContact ( new AceContact ( reg.Contact__r ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        
        return new AceContactPage ( aclb.contList , aclb.nextName );
    } 
  */
    /**********************************************************/
//  ============================================================================
//  Search Contact records given user input "searchString".
//  "searchScope" coresponds to the user's: My Contact Coverage, My Account Coverage or All Accounts
//  (see *_COVERAGE_* constants above for possible input values).
//  "searchFields" is ACE Feature Registry (AFR) : ContactSearchFields field entry.
//  "startName" and "pageSize" are used for filtering of records wrt pagination.
//
//  ============================================================================
    public static AceContactPage searchByContactFields (
                                Id userId
                                , String searchString
                                , String searchScope 
                                , String searchFields
                                , Boolean bGetLastInteraction 
                                , String startName
                                , Integer pageSize
                                )
    /**********************************************************/
    {
       /** Deprecated to use the new AceSObject.getSObjectPage
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }       
        AceContactListBuilder aclb = new AceContactListBuilder ( pageSize ); 
        List<Contact> contactList = new List<Contact>();
        List<SObject> returnList = AdvancedSearch.searchRecords (
                                AdvancedSearch.searchObjType.CONTACT
                                , userId, searchString, searchScope
                                , searchFields, startName, pageSize);
        if (returnList != null) contactList = ((List<Contact>)returnList);
       
        for ( Contact cont: contactList) 
        {
            if ( !aclb.addAceContact ( new AceContact ( cont ) ) ) 
            {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAceContacts ();
        }
        List<AceContact> retContList = new List<AceContact>();
        retContList = aclb.contList;
        if ( bGetLastInteraction ) {            
            List<List<AceContact>> aceContactListList = new List<List<AceContact>> {};
            aceContactListList.add(retContList);
            getLastInteractions ( aceContactListList , userId );
            retContList = aceContactListList[0];
        } 
        */
        SObjectPage items = AdvancedSearch.searchRecords (
						AdvancedSearch.searchObjType.CONTACT
						, userId, searchString, searchScope
						, searchFields, startName, pageSize);
						
		List<AceContact> contList = new List<AceContact>();
		
		//Iterate through the list of items
		for (SObject item : items.SObjectList)
		{
			//Add the item to the account list
			contList.add(new AceContact((Contact)item));
		}
		
		//Get the last interactions if necessary
		if (bGetLastInteraction)
		{
			getLastInteractions(contList, userId);
		}
        
        return new AceContactPage ( contList , items.NextKey );
    }
    
//*/  
//  ============================================================================
//  ============================================================================
//  CLASS:  AceContactListBuilder   
//  Desc:   Utility class to help build a list of AceContacts, based on successive
//          additions of Contact records, which are assumed to be sorted by
//          Contact Name.
//  ============================================================================
//  ============================================================================
    class AceContactListBuilder {
        
        private Integer idx;
        private String prevName;
        private Integer maxListSize;
        private AceContact[] contCache;
        
        private AceContact[] contList;
        public String nextName;
        
        
//      ============================================================================
//      Method: Constructor 
//      Desc:   Initializes variables.
//      ============================================================================
        AceContactListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        AceContactListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevName = '';
            this.nextName = Null;
            this.maxListSize = maxListSize;
            this.contCache = new List<AceContact> {};
            this.contList = new List<AceContact> {};
        }   
            
//      ============================================================================
//      Method: addAceContact   
//      Desc:   Adds the specified Contact record to the AceContact list.
//              If this record would put us past the max-record limit, aborts.
//      Args:   cont - the Contact record
//      Return: True if the record was added; False otherwise.
//      ============================================================================
        public Boolean addAceContact ( AceContact cont ) {

            if ( prevName != Null && prevName != cont.Name ) {
                contList.addAll ( contCache );
                contCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextName = ( contCache.isEmpty () ? cont.Name : prevName );
                return False;
            }
            prevName = cont.Name;
            contCache.add ( cont );
            return True;
        }
        
//      ============================================================================
//      Method: addCachedAceContacts    
//      Desc:   Adds the AceContact records we've built up in our internal cache, to
//              the AceContact list.
//      Args:   None.
//      Return: None.
//      ============================================================================
        public void addCachedAceContacts () {
            contList.addAll ( contCache );
        }
    }   
    
}