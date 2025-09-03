/* 
 * Name: ContactListEntry 
 * ***** This class has been replaced by AceListEntry in ALM 3.0 *****
 *
 * Confidential & Proprietary, ©2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class ContactListEntry 
{
    webService String Id;
    webService String ContactList;  
    webService String OverrideCallOrder;
    webService String OverrideRank; 
    webService AceContact AceContact;
    
    public ContactListEntry() {
    }
    
    public ContactListEntry ( Contact_List_Entry__c cle ) {
        if ( cle == Null ) { return; }
        
        try { this.Id = cle.Id; } catch ( SObjectException e ) {}       
        try { this.ContactList = cle.Contact_List__c; } catch ( SObjectException e ) {}     
        try { this.OverrideCallOrder = cle.Override_Call_Order__c; } catch ( SObjectException e ) {}
        try { this.OverrideRank = cle.Override_Rank__c; } catch ( SObjectException e ) {}
            
//      Fill out the contact details.
//      -----------------------------       
        try { this.AceContact = new AceContact ( cle.Contact__r ); } catch ( SObjectException e ) {}                                            
    }
    
//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified ContactListEntry record to the
//          specified list of lists of ContactListEntry records.  Calls the
//          'list' version of this function, which does all the work.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<ContactListEntry>> elemListList , 
                                        ContactListEntry myElem ) {
        listListAdd ( elemListList , new List<ContactListEntry> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of ContactListEntry
//          records to the specified list of lists of ContactListEntry records.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<ContactListEntry>> elemListList , 
                                        List<ContactListEntry> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//      Go through the list of lists, finding the first list that has room for
//      our element list
//      ----------------------------------------------------------------------
        List<ContactListEntry> elemList = Null;
        for ( List<ContactListEntry> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<ContactListEntry> {};
            elemListList.add ( elemList );
        }
        
        elemList.addAll ( myElemList );
    }

    //  ============================================================================
    //  Method: getContactsForList  
    //  Desc:   Retrieves the contact records for a given list 
    //          - Record Ownership 
    //          - ACE List Shares   
    //  Args:   String[]: contactListIds
    //          Boolean: isActive           => Contact Active status    
    //  Return: Contacts associated with a given list                           
    //  Case No: 3641
    //  ============================================================================
    public static List<List<ContactListEntry>> getContactsForList(String[] contactListIds, 
                                                                    boolean isActive,
                                                                    boolean bGetLastInteraction ,
                                                                    Id userId ) { 
                                                                            
        List<List<ContactListEntry>> returnList = new List<List<ContactListEntry>>();
        for(Contact_List_Entry__c cle : [Select Id, Contact__c, Contact__r.Id, 
                                    Contact__r.Title , Contact__r.FirstName,
                                    Contact__r.LastName, Contact__r.Phone,
                                    Contact__r.MobilePhone , Contact__r.HomePhone ,
                                    Contact__r.AssistantPhone , Contact__r.OtherPhone ,
                                    Contact__r.Aum__c, Contact__r.Invest_Style__c,
                                    Contact__r.Regions__c, Contact__r.Sectors__c,
                                    Contact__r.Sub_Sectors__c, 
                                    Contact__r.Account.Id, Contact__r.Account.Name, 
                                    Contact__r.Account.Aum__c, Contact__r.Account.ST_Thomson_Id__c,
                                    Contact__r.Account.ST_ACE__Tier__c ,
                                    Contact__r.Email,  
                                    Contact__r.MailingStreet, Contact__r.MailingCity, 
                                    Contact__r.MailingCountry, Contact__r.MailingState, Contact__r.MailingPostalCode,
                                    Override_Call_Order__c, Override_Rank__c,
                                    Contact_List__c, Contact__r.ST_Inactive__c
                                    From Contact_List_Entry__c
                                    Where Contact_List__c In :contactListIds
                                    And Contact__r.ST_Inactive__c = :isActive])
        {   
            ContactListEntry item = new ContactListEntry ( cle );
            listListAdd ( returnList , item );
        }           
        
        if ( bGetLastInteraction ) {
            getLastInteractions ( returnList , userId );
        }       
        return returnList;
    }

//  ============================================================================
//  Method: getLastInteractions
//
//  Desc:   Function to go through the specified list of lists of ContactListEntries, 
//          determining the last interaction date on each related Contact by the 
//          specified userId.
//       
//  Return: Nothing.  The list of lists of ContactListEntries is modified in situ.
//  ============================================================================                    
    public static void getLastInteractions ( List<List<ContactListEntry>> cleListList ,
                                                Id userId ) {
        for ( List<ContactListEntry> clel : cleListList ) {         
            Map<Id , AceContact> contById = new Map<Id , AceContact> {};
            for ( ContactListEntry cle : clel ) {
                contById.put ( cle.AceContact.Id , cle.AceContact );
            }
            for ( UserContactInteraction uci :
                        UserContactInteraction.getUserContactInteractions (
                                                    userId ,
                                                    contById.keySet ()
                                                )
            ) {
                AceContact ac = contById.get ( uci.ContactId );
                ac.LastInteractionDate = uci.LastInteractionDate;
            }
        }
    }                                                       
}