/* 
 * Name: AccountCoverage 
 * Description: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AccountCoverage 
{
    /**
     * String that represents whether or not the contact coverage record is active
     *
     */
    static final String IS_COVERAGE_INACTIVE = 'false';
    
    webService String Id;
    webService String Division; 
    webService String Product;
    webService Date StartDate;
    webService Date EndDate;    
    webService String Role;
    webService String Rank; 
    webService String CallOrder;  
    webService Boolean IsBackup; 
    webService AceAccount Account;
    webService Employee Employee;
    webService String BillingCity; //DE908 -- add location to the output 
        
    public AccountCoverage() {
    }
    
    public AccountCoverage ( Account_Coverage__c ac ) {
        if ( ac == Null ) { return; }
        
        try { this.Id = ac.Id; } catch ( SObjectException e ) {}        
        try { this.Division = ac.Division__c; } catch ( SObjectException e ) {}     
        try { this.Product = ac.Product__c; } catch ( SObjectException e ) {}       
        try { this.StartDate = ac.Start_Date__c; } catch ( SObjectException e ) {}
        try { this.EndDate = ac.End_Date__c; } catch ( SObjectException e ) {}
        try { this.Role = ac.Role__c; } catch ( SObjectException e ) {}
        try { this.Rank = ac.Rank__c; } catch ( SObjectException e ) {}     
        try { this.CallOrder = ac.Call_Order__c; } catch ( SObjectException e ) {}
        try { this.IsBackup = ac.Is_Backup__c; } catch ( SObjectException e ) {}      
                    
//      Fill out the account and employee details.
//      ------------------------------------------
        try { this.Account = new AceAccount ( ac.Account__r ); } catch ( SObjectException e ) {}                                            
        try { this.Employee = new Employee ( ac.Employee__r ); } catch ( SObjectException e ) {}                                            
    }

//  ============================================================================
//  Method: getCoverageForAccounts  
//  Desc:   Retrieves the account coverage records covering the specified list 
//          of Account Ids. 
//  Args:   acctIdList - the Account Id list
//  Return: List of AccountCoverage records                         
//  Case:   3941
//  ============================================================================
    public static AccountCoverage[] getCoverageForAccounts ( Id[] acctIdList ) {

        AccountCoverage[] acList = new AccountCoverage[] {};
                
        for ( Account_Coverage__c sfAC : [ select
                                                Id ,
                                                Division__c ,
                                                Product__c ,
                                                Start_Date__c ,
                                                End_Date__c ,
                                                Role__c ,
                                                Is_Backup__c ,
                                                Employee__r.Name ,
                                                Employee__r.Phone__c ,
                                                Employee__r.Product__c,
                                                Employee__r.Division__c,
                                                Account__r.Id
                                            from
                                                Account_Coverage__c
                                            where
                                                Account__c in :acctIdList and
                                                Employee__r.Inactive__c=false and
                                                Inactive__c =:IS_COVERAGE_INACTIVE                                                
                                            ]
        ) {
            acList.add ( new AccountCoverage ( sfAC ) );
        }
        return acList;
    }
    
//  ============================================================================
//  Method: getAccountCoverage
//  Desc:   Retrieves the account coverage records of a specify employee 
//  Args:   emplId - the Employee Id
//  Return: List of AccountCoverage records                         
//  Case:   
//  ============================================================================
    public static AccountCoveragePage getAccountCoverage (  String emplId ,
                                                            String startName ,
                                                            Integer pageSize ) {

        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
             
        AccountCoverageListBuilder aclb = new AccountCoverageListBuilder ( pageSize );
        
        Set<Id> acctIdSet = new Set<Id> {};
        Map<Id , AccountCoverage[]> acListByAcct = new Map<Id , AccountCoverage[]> {};
        Id userId;
                
        for ( Account_Coverage__c sfAC : [ select
                                                Id ,
                                                Division__c ,
                                                Product__c ,
                                                Start_Date__c ,
                                                End_Date__c ,
                                                Role__c ,
                                                Call_Order__c ,
                                                Rank__c,
                                                Employee__r.User__c ,
                                                Account__r.Id ,
                                                Account__r.Name ,
                                                Account__r.BillingCountry,
                                                Account__r.BillingCity, //DE908 -- add location to the output
                                                Account__r.ST_ACE__Tier__c ,
                                                Account__r.Aum__c , 
                                                Account__r.Phone ,
                                                Account__r.Website ,
                                                Account__r.WB_Tier__c ,
                                                Account__r.Sector__c ,
                                                Account__r.City__c ,
                                                Account__r.Cash_EQ_Tier__c ,
                                                Account__r.ParentId ,
                                                Account__r.Parent.Name ,
                                                Account__r.Parent.Phone                                     
                                            from
                                                Account_Coverage__c
                                            where
                                                Employee__c = :emplId and
                                                Inactive__c =:IS_COVERAGE_INACTIVE and
                                                Account__r.Name >= :startName and
                                                Account__c <> null
                                            order by
                                                Account__r.Name
                                            limit
                                                :pageSize + 1

                                            ]
        ) {
            AccountCoverage ac = new AccountCoverage ( sfAC );

            if ( !aclb.addAccountCoverage ( ac ) ) {
                break;
            }
            
    //      Accumulate a list of Accounts for which we want to grab last Interaction Date.
    //      ------------------------------------------------------------------------------          
            if ( sfAC.Account__r != Null && sfAC.Employee__r.User__c != Null ) {
                userId = sfAC.Employee__r.User__c;
                acctIdSet.add ( sfAC.Account__r.Id );
                if ( !acListByAcct.containsKey ( sfAC.Account__r.Id ) ) {
                    acListByAcct.put ( sfAC.Account__r.Id , new AccountCoverage[] {} );
                }
                acListByAcct.get ( sfAC.Account__r.Id ).add ( ac );
            }
        }

//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( aclb.nextName == Null ) {
            aclb.addCachedAccountCoverages ();
        }           
        
//      Now get Last Interaction dates for the Account referenced in the Coverage
//      records, and patch them back into the Account records.
//      --------------------------------------------------------------------------
        if ( !acListByAcct.isEmpty () ) {
            for ( UserContactInteraction uci : 
                    UserContactInteraction.getUserAccountInteractions (
                                                userId , acListByAcct.keySet ()
                                            )
            ) {
                for ( AccountCoverage ac : acListByAcct.get ( uci.AccountId ) ) {
                    if (ac.Account.AccountLastInteractionDate == Null 
                            || ac.Account.AccountLastInteractionDate < uci.LastInteractionDate) {   
                        ac.Account.AccountLastInteractionDate = uci.LastInteractionDate;
                    }
                }
            }
        }

        return new AccountCoveragePage ( aclb.acList , aclb.nextName );
    }


//  ============================================================================
//  Method: getEmployeesCoveringAccounts    
//  Desc:   Retrieves the account coverage records for the specified list of
//          account Ids. 
//  Args:   acctIdList - the Account Id list
//  Return: List of matching AccountCoverage records.                           
//  Case:   
//  ============================================================================
    public static List<AccountCoverage> getEmployeesCoveringAccounts ( Id[] acctIdList ) { 
    
        AccountCoverage[] returnList = new AccountCoverage[] {};
                
        for ( Account_Coverage__c ac : [ select
                                            Role__c ,
                                            Account__r.Id ,
                                            Account__r.Name ,
                                            Employee__r.Id ,
                                            Employee__r.Name ,
                                            Employee__r.Title__c ,
                                            Employee__r.Email__c ,
                                            Employee__r.Department__c ,
                                            Employee__r.User__c
                                        from
                                            Account_Coverage__c
                                        where
                                            Account__c in :acctIdList and
                                            Inactive__c =:IS_COVERAGE_INACTIVE and
                                            Employee__r.Inactive__c = False
                                        ]
        ) {
            returnList.add ( new AccountCoverage ( ac ) );
        }
        
        return returnList;
    }   
    
    
    
//  ============================================================================
//  ============================================================================
//  CLASS:  AccountCoverageListBuilder  
//  Desc:   Utility class to help build a list of AccountCoverages, based on 
//          successive additions of AccountCoverage records, which are assumed
//          to be sorted by Account Name.
//  ============================================================================
//  ============================================================================
    class AccountCoverageListBuilder {
        
        private Integer idx;
        private String prevName;
        private Integer maxListSize;
        private AccountCoverage[] acCache;
        
        private AccountCoverage[] acList;
        public String nextName;
        
//      ============================================================================
//      Method: Constructor 
//      Desc:   Initializes variables.
//      ============================================================================
        AccountCoverageListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        AccountCoverageListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevName = '';
            this.nextName = Null;
            this.maxListSize = maxListSize;
            this.acCache = new AccountCoverage[] {};
            this.acList = new AccountCoverage[] {};
        }   
            
//      ============================================================================
//      Method: addAccountCoverage  
//      Desc:   Adds the specified AccountCoverage record to the AccountCoverage
//              list.  If this record would put us past the max-record limit, aborts.
//      Args:   cc - the AccountCoverage record
//      Return: True if the record was added; False otherwise.
//      ============================================================================
        public Boolean addAccountCoverage ( AccountCoverage ac ) {

            if ( prevName != Null && prevName != ac.Account.Name ) {
                acList.addAll ( acCache );
                acCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextName = ( acCache.isEmpty () ? ac.Account.Name : prevName );
                return False;
            }
            prevName = ac.Account.Name;
            acCache.add ( ac );
            return True;
        }
        
//      ============================================================================
//      Method: addCachedAccountCoverages   
//      Desc:   Adds the AccountCoverage records we've built up in our internal
//              cache, to the AccountCoverage list.
//      Args:   None.
//      Return: None.
//      ============================================================================
        public void addCachedAccountCoverages () {
            acList.addAll ( acCache );
        }
    
    }   
    
    
    class AceListListBuilder 
    {        
        private Integer idx;
        private String prevName;
        private Integer maxListSize;
        private AceList[] alCache;
        
        private AceList[] alList;
        public String nextName;
        
        //      ============================================================================
        //      Method: Constructor 
        //      Desc:   Initializes variables.
        //      ============================================================================
        AceListListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        AceListListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevName = '';
            this.nextName = Null;
            this.maxListSize = maxListSize;
            this.alCache = new AceList[] {};
            this.alList = new AceList[] {};
        }   
            
        //      ============================================================================
        //      Method: addAceList  
        //      Desc:   Adds the specified AccountCoverage record to the AccountCoverage
        //              list.  If this record would put us past the max-record limit, aborts.
        //      Args:   cc - the AccountCoverage record
        //      Return: True if the record was added; False otherwise.
        //      ============================================================================
        public Boolean addAceList ( AceList al ) 
        {
            if ( prevName != Null && prevName != al.Name ) {
                alList.addAll ( alCache );
                alCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextName = ( alCache.isEmpty () ? al.Name : prevName );
                return False;
            }
            prevName = al.Name;
            alCache.add ( al );
            return True;
        }
        
        //      ============================================================================
        //      Method: addCachedAceLists   
        //      Desc:   Adds the AccountCoverage records we've built up in our internal
        //              cache, to the AccountCoverage list.
        //      Args:   None.
        //      Return: None.
        //      ============================================================================
        public void addCachedAceLists () {
            alList.addAll ( alCache );
        }    
    } 
    
}