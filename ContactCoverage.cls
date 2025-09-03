/* 
 * Name: ContactCoverage 
 * Description: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class ContactCoverage 
{
    /**
     * String that represents whether or not the contact coverage record is active
     *
     */
    static final String IS_COVERAGE_INACTIVE = 'false';
    static final String[] COVERAGE_ROLES = new String[] { 'Sales Primary' , 'Sales Back-up' };
    
    webService String Id;
    webService String Rank; 
    webService String Role;
    webService String CallOrder;
    webService String SpecialNotes;
    webService Boolean IsBackup; 
    webService AceContact Contact;
    webService Employee Employee;
        
    public ContactCoverage() {
    }
    
    public ContactCoverage ( Contact_Coverage__c cc ) {
        if ( cc == Null ) { return; }
        
        try { this.Id = cc.Id; } catch ( SObjectException e ) {}        
        try { this.Rank = cc.Rank__c; } catch ( SObjectException e ) {}     
        try { this.Role = cc.Role__c; } catch ( SObjectException e ) {}     
        try { this.CallOrder = cc.Call_Order__c; } catch ( SObjectException e ) {}
        try { this.SpecialNotes = cc.Special_Notes__c; } catch ( SObjectException e ) {}
        try { this.IsBackup = cc.Is_Backup__c; } catch ( SObjectException e ) {}
            
//      Fill out the contact and employee details.
//      ------------------------------------------
        try { this.Contact = new AceContact ( cc.Contact__r ); } catch ( SObjectException e ) {}                                            
        try { this.Employee = new Employee ( cc.Employee__r ); } catch ( SObjectException e ) {}                                            
    }

//  ============================================================================
//  Method: getContactCoverageById  
//  Desc:   Retrieves the contact coverage records with the specified Ids. 
//  Args:   ccIdList - the Contact Coverage Id list
//  Return: List of ContactCoverage records                         
//  Case:   In support of 3935
//  ============================================================================
    public static ContactCoverage[] getContactCoverageById ( Id[] ccIdList ) {

        ContactCoverage[] ccList = new ContactCoverage[] {};
                
        for ( Contact_Coverage__c sfCC : [ select
                                                Id ,
                                                Rank__c ,
                                                Call_Order__c ,
                                                Role__c ,
                                                Special_Notes__c ,
                                                Employee__r.User__c ,
                                                Contact__r.Id ,
                                                Contact__r.FirstName ,
                                                Contact__r.LastName ,
                                                Contact__r.Phone ,
                                                Contact__r.MobilePhone ,
                                                Contact__r.HomePhone ,
                                                Contact__r.AssistantPhone ,
                                                Contact__r.OtherPhone ,
                                                Contact__r.Aum__c ,
                                                Contact__r.Invest_Style__c ,
                                                Contact__r.Regions__c ,
                                                Contact__r.Sectors__c ,
                                                Contact__r.Sub_Sectors__c ,
                                                Contact__r.Title ,
                                                Contact__r.Email ,
                                                Contact__r.MailingStreet, 
                                                Contact__r.MailingCity, 
                                                Contact__r.MailingCountry, 
                                                Contact__r.MailingState, 
                                                Contact__r.MailingPostalCode,                                               
                                                Contact__r.Account.Id ,
                                                Contact__r.Account.Name ,
                                                Contact__r.Account.BillingCountry ,
                                                Contact__r.Account.Aum__c ,
                                                Contact__r.Account.ST_ACE__Tier__c ,
                                                Contact__r.Account.ST_Thomson_Id__c ,
                                                Contact__r.Account.Website ,
                                                Contact__r.Account.WB_Tier__c ,
                                                Contact__r.Account.Sector__c ,
                                                Contact__r.Account.City__c ,
                                                Contact__r.Account.Cash_EQ_Tier__c ,
                                                Contact__r.Account.ParentId ,
                                                Contact__r.Account.Parent.Name ,
                                                Contact__r.Account.Parent.Phone
                                            from
                                                Contact_Coverage__c
                                            where
                                                Id in :ccIdList and
                                                Inactive__c =:IS_COVERAGE_INACTIVE 
                                            ]
        ) {
            ccList.add ( new ContactCoverage ( sfCC ) );
        }
        return ccList;
    }
    
//  ============================================================================
//  Method: getContactCoverage  
//  Desc:   Retrieves a page of contact coverage records for the specified 
//          Employee. 
//  Args:   emplId      - the Employee Id
//          startName   - the starting ContactCoverage Contact LastName
//          pageSize    - the page size
//  Return: Page of ContactCoverage records                         
//  Case:   3882
//  ============================================================================
    public static ContactCoveragePage getContactCoverage ( String emplId ,
                                                            String startName ,
                                                            Integer pageSize ) { 
                                                                            
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
             
        ContactCoverageListBuilder cclb = new ContactCoverageListBuilder ( pageSize );
        
        Set<Id> contIdSet = new Set<Id> {};
        Map<Id , ContactCoverage[]> ccListByCont = new Map<Id , ContactCoverage[]> {};
        Id userId;
        
        for ( Contact_Coverage__c sfCC : [ select
                                                Id ,
                                                Rank__c ,
                                                Call_Order__c ,
                                                Role__c,
                                                Special_Notes__c ,
                                                Employee__r.User__c ,
                                                Contact__r.Id ,
                                                Contact__r.FirstName ,
                                                Contact__r.LastName ,
                                                Contact__r.Phone ,
                                                Contact__r.MobilePhone ,
                                                Contact__r.HomePhone ,
                                                Contact__r.AssistantPhone ,
                                                Contact__r.OtherPhone ,
                                                Contact__r.Aum__c ,
                                                Contact__r.Invest_Style__c ,
                                                Contact__r.Regions__c ,
                                                Contact__r.Sectors__c ,
                                                Contact__r.Sub_Sectors__c ,
                                                Contact__r.Title ,
                                                Contact__r.Email ,
                                                Contact__r.MailingStreet, 
                                                Contact__r.MailingCity, 
                                                Contact__r.MailingCountry, 
                                                Contact__r.MailingState, 
                                                Contact__r.MailingPostalCode,                                               
                                                Contact__r.Account.Id ,
                                                Contact__r.Account.Name ,
                                                Contact__r.Account.BillingCountry ,
                                                Contact__r.Account.Aum__c ,
                                                Contact__r.Account.ST_ACE__Tier__c ,
                                                Contact__r.Account.ST_Thomson_Id__c ,
                                                Contact__r.Account.Website ,
                                                Contact__r.Account.WB_Tier__c ,
                                                Contact__r.Account.Sector__c ,
                                                Contact__r.Account.City__c ,
                                                Contact__r.Account.Cash_EQ_Tier__c ,
                                                Contact__r.Account.ParentId ,
                                                Contact__r.Account.Parent.Name ,
                                                Contact__r.Account.Parent.Phone
                                            from
                                                Contact_Coverage__c
                                            where
                                                Employee__c = :emplId and
                                                Contact__r.ST_Inactive__c = False and
                                                Inactive__c =:IS_COVERAGE_INACTIVE and
                                                Contact__r.LastName >= :startName
                                            order by
                                                Contact__r.LastName
                                            limit
                                                :pageSize + 1
                                            ]
        ) {
            ContactCoverage cc = new ContactCoverage ( sfCC );

            if ( !cclb.addContactCoverage ( cc ) ) {
                break;
            }
            
//          Accumulate a list of Contacts for which we want to grab last Interaction Date.
//          ------------------------------------------------------------------------------          
            if ( sfCC.Contact__r != Null && sfCC.Employee__r.User__c != Null ) {
                userId = sfCC.Employee__r.User__c;
                contIdSet.add ( sfCC.Contact__r.Id );
                if ( !ccListByCont.containsKey ( sfCC.Contact__r.Id ) ) {
                    ccListByCont.put ( sfCC.Contact__r.Id , new ContactCoverage[] {} );
                }
                ccListByCont.get ( sfCC.Contact__r.Id ).add ( cc );
            }

        }

//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( cclb.nextName == Null ) {
            cclb.addCachedContactCoverages ();
        }
                
//      Now get Last Interaction dates for the Contacts referenced in the Coverage
//      records, and patch them back into the Contact records.
//      --------------------------------------------------------------------------
        if ( !ccListByCont.isEmpty () ) {
            for ( UserContactInteraction uci : 
                    UserContactInteraction.getUserContactInteractions (
                                                userId , ccListByCont.keySet ()
                                            )
            ) {
                for ( ContactCoverage cc : ccListByCont.get ( uci.ContactId ) ) {
                    cc.Contact.LastInteractionDate = uci.LastInteractionDate;
                }
            }
        }

        return new ContactCoveragePage ( cclb.ccList , cclb.nextName );
    }
    
//  ============================================================================
//  Method: getEmployeesCoveringContacts    
//  Desc:   Retrieves the contact coverage records for the specified list of
//          contact Ids. 
//  Args:   contIdList - the Contact Id list
//  Return: List of matching ContactCoverage records.                           
//  Case:   3899
//  ============================================================================
    public static List<ContactCoverage> getEmployeesCoveringContacts ( Id[] contIdList ) { 
    
        ContactCoverage[] returnList = new ContactCoverage[] {};
                
        for ( Contact_Coverage__c cc : [ select
                                            Role__c ,
                                            Contact__r.FirstName ,
                                            Contact__r.LastName ,
                                            Contact__r.AccountId ,
                                            Employee__r.Id ,
                                            Employee__r.Name ,
                                            Employee__r.Title__c ,
                                            Employee__r.Email__c ,
                                            Employee__r.Department__c ,
                                            Employee__r.User__c
                                        from
                                            Contact_Coverage__c
                                        where
                                            Contact__c in :contIdList and
                                            Inactive__c =:IS_COVERAGE_INACTIVE and 
//                                          Role__c in :COVERAGE_ROLES and  
                                            Employee__r.Inactive__c = False
                                        ]
        ) {
//          System.debug ( '\n\n' + cc + '\n' + cc.Contact__r + '\n' );
            returnList.add ( new ContactCoverage ( cc ) );
        }
        
        return returnList;
    }
    
//  ============================================================================
//  Method: getCoverageForContacts  
//  Desc:   Retrieves the Contact coverage records covering the specified list 
//          of Contact Ids. 
//  Args:   contIdList - the Contact Id list
//  Return: List of ContactCoverage records                         
//  Case:   3942
//  ============================================================================
    public static ContactCoverage[] getCoverageForContacts ( Id[] contIdList ) {

        ContactCoverage[] ccList = new ContactCoverage[] {};
                
        for ( Contact_Coverage__c sfCC : [ select
                                                Id ,
                                                Rank__c ,
                                                Role__c ,
                                                Call_Order__c ,
                                                Special_Notes__c ,
                                                Is_Backup__c ,
                                                Employee__r.Name ,
                                                Employee__r.Phone__c ,
                                                Employee__r.Division__c,
                                                Contact__r.Id
                                            from
                                                Contact_Coverage__c
                                            where
                                                Contact__c in :contIdList and
                                                Inactive__c =:IS_COVERAGE_INACTIVE and
                                                Employee__r.Inactive__c=false
                                            ]
        ) {
            ccList.add ( new ContactCoverage ( sfCC ) );
        }
        return ccList;
    }

//  ============================================================================
//  ============================================================================
//  CLASS:  ContactCoverageListBuilder  
//  Desc:   Utility class to help build a list of ContactCoverages, based on 
//          successive additions of ContactCoverage records, which are assumed
//          to be sorted by Contact LastName.
//  ============================================================================
//  ============================================================================
    class ContactCoverageListBuilder {
        
        private Integer idx;
        private String prevName;
        private Integer maxListSize;
        private ContactCoverage[] ccCache;
        
        private ContactCoverage[] ccList;
        public String nextName;
        
//      ============================================================================
//      Method: Constructor 
//      Desc:   Initializes variables.
//      ============================================================================
        ContactCoverageListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        ContactCoverageListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevName = '';
            this.nextName = Null;
            this.maxListSize = maxListSize;
            this.ccCache = new ContactCoverage[] {};
            this.ccList = new ContactCoverage[] {};
        }   
            
//      ============================================================================
//      Method: addContactCoverage  
//      Desc:   Adds the specified ContactCoverage record to the ContactCoverage
//              list.  If this record would put us past the max-record limit, aborts.
//      Args:   cc - the ContactCoverage record
//      Return: True if the record was added; False otherwise.
//      ============================================================================
        public Boolean addContactCoverage ( ContactCoverage cc ) {

            if ( prevName != Null && prevName != cc.Contact.LastName ) {
                ccList.addAll ( ccCache );
                ccCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextName = ( ccCache.isEmpty () ? cc.Contact.LastName : prevName );
                return False;
            }
            prevName = cc.Contact.LastName;
            ccCache.add ( cc );
            return True;
        }
        
//      ============================================================================
//      Method: addCachedContactCoverages   
//      Desc:   Adds the ContactCoverage records we've built up in our internal
//              cache, to the ContactCoverage list.
//      Args:   None.
//      Return: None.
//      ============================================================================
        public void addCachedContactCoverages () {
            ccList.addAll ( ccCache );
        }
    }   
     
}