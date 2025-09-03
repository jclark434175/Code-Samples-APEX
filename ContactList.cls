/*
 * Name:        ContactList.cls
 * ***** This class has been replaced by AceList in ALM 3.0 *****
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from STC StraightThrough.
 */ 
 
global class ContactList
{                             
    webService String Id;
    webService String OwnerId;
    webService String OwnerName;
    webService String Name; 
    webService String SearchCriteria;
    webService String SearchDataType;
    webService String SearchScope;
    webService String Description;
    webService boolean IsShared;
    webService DateTime CreatedDate;    
    webService String ListType;
    webService List<ContactListEntry> ContactListEntries;

    // --- not directly from SF Contact_List__c --- 
    webService String ListAccess;
    webService String ListContentsAccess;
        
    public ContactList () {
    }
    
    public ContactList ( Contact_List__c cl ) {
        if ( cl == Null ) { return; }
        
        try { this.Id = cl.Id; } catch ( SObjectException e ) {}
        try { this.OwnerId = cl.OwnerId; } catch ( SObjectException e ) {}
        try { this.OwnerName = cl.Owner.Name; } catch ( SObjectException e ) {}
        try { this.Name = cl.Name; } catch ( SObjectException e ) {}        
        try { this.SearchCriteria = cl.Search_Criteria__c; } catch ( SObjectException e ) {}
        try { this.SearchDataType = cl.Search_data_type__c; } catch ( SObjectException e ) {}
        try { this.SearchScope = cl.Search_scope__c; } catch ( SObjectException e ) {}
        try { this.Description = cl.Description__c; } catch ( SObjectException e ) {}
        try { this.IsShared = cl.Is_shared__c; } catch ( SObjectException e ) {}
        try { this.CreatedDate = cl.CreatedDate; } catch ( SObjectException e ) {}
        try { this.ListType = cl.Type__c; } catch ( SObjectException e ) {}
        
        try {
            this.ContactListEntries = new List<ContactListEntry> {};
            for ( Contact_List_Entry__c cle : cl.ContactListEntries__r ) {
                this.ContactListEntries.add ( new ContactListEntry ( cle ) );
            }
        } catch ( SObjectException e ) {}
    }

    //  ============================================================================
    //  Method: getContactLists
    //  Desc:   Retrieves lists that a user can see base on 
    //          - Record Ownership 
    //          - ACE List Shares   
    //  Args:   String: userId
    //          Boolean: withListEntries  
    //          Boolean: sharedOnly
    //  Return: When withListEntries is false:
    //          Lists where I am the owner
    //          Lists associated with list shares where Shared With id=my id 
    //          Lists associated with list shares where Shared with id=groups I belong to 
    //          Lists associated with list shares where Shared with id=my role
    //       
    //          When withListEntries is true:
    //          Lists where I am the owner
    //          Lists associated with list shares where Shared With id=my id 
    //          Lists associated with list shares where Shared with id=groups I belong to 
    //          Lists associated with list shares where Shared with id=my role
    //          +
    //          List Items associated with contact list                 
    //  Case No: 3639, 3640
    //  ============================================================================
    public static List<ContactList> getContactLists( String userId,
                                                            boolean withListEntries ,
                                                            Boolean bSharedOnly ) {   
        if (withListEntries)
            return getContactListEntries(userId , bSharedOnly );
        else        
            return getContactLists(userId , bSharedOnly );          
    }           
                    

    private static List<ContactList> getContactLists(String userId , Boolean bSharedOnly ) {
        
        Id uid = userId;
        Set<Id> entityIds = new Set<Id>();
        List<ContactList> returnList = new List<ContactList>();
        
        for(Contact_List__c contactList : [Select Id, OwnerId, Name,
                                                Search_Criteria__c,  
                                                Search_Data_Type__c, Search_Scope__c,
                                                Description__c, Is_Shared__c,
                                                Owner.Name, Type__c, CreatedDate
                                                From Contact_List__c
                                                Where OwnerId = :uid])
        {
            if ( bSharedOnly && contactList.Is_Shared__c == False ) {
                continue;
            }
            returnList.Add( new ContactList( contactList ) );   
        }
        
        Id roleId;
        if ( uid == UserInfo.getUserId () ) { 
            roleId = UserInfo.getUserRoleId ();
        }
        else {
            roleId = [select UserRoleId from User where Id = :uid].UserRoleId;
        }
        
//      Add all group membership to the entity list.
//      --------------------------------------------
        entityIds.addAll ( aceUtil.getUserGroups ( uid , roleId ) );
                
        //Add user role id to the list
        entityIds.Add(roleId);
        
        //Add user Id to the list
        entityIds.Add( uid );
        
        System.debug ( Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows() );
        for(List_Share__c listShare : [Select Contact_List__r.Id, 
                                                    Contact_List__r.OwnerId, 
                                                    Contact_List__r.Name,                                                   
                                                    Contact_List__r.Search_Criteria__c, 
                                                    Contact_List__r.Search_Data_Type__c,
                                                    Contact_List__r.Search_Scope__c,
                                                    Contact_List__r.Description__c,
                                                    Contact_List__r.Is_Shared__c,
                                                    Contact_List__r.Owner.Name, 
                                                    Contact_List__r.Type__c,
                                                    Contact_List__r.CreatedDate,                    
                                                    List_Access__c,
                                                    List_Contents_Access__c
                                            From List_Share__c
                                            Where Entity_Id__c In :entityIds
                                            ])  {
                                                
            if ( bSharedOnly && listShare.Contact_List__r.Is_Shared__c == False ) {
                continue;
            }
            ContactList cl = new ContactList ( listShare.Contact_List__r );
            cl.ListAccess = listShare.List_Access__c;
            cl.ListContentsAccess = listShare.List_Contents_Access__c;
            returnList.add ( cl );
        }
        
        return ( returnList );
    }

    private static List<ContactList> getContactListEntries( String userId , Boolean bSharedOnly )
    {   
        Set<Id> entityIds = new Set<Id>();
        List<ContactList> returnList = new List<ContactList>();
        
        for(Contact_List__c contactList : [Select Id, OwnerId, Name,
                                                Search_Criteria__c, 
                                                Search_Data_Type__c, Search_Scope__c,
                                                Description__c, Is_Shared__c,
                                                Owner.Name,
                                                Type__c,
                                                CreatedDate,
                                                (Select Id, Contact__c, 
                                                Override_Call_Order__c, Override_Rank__c
                                                From ContactListEntries__r)
                                            From Contact_List__c
                                            Where OwnerId = :userId])
        {
            if ( bSharedOnly && contactList.Is_Shared__c == False ) {
                continue;
            }
            returnList.Add ( new ContactList( contactList ) );
        }
                             
        for(GroupMember grpMember: [Select GroupId From GroupMember Where UserOrGroupId = :userId]) {
            entityIds.Add(grpMember.GroupId);
        }
        
        //Add user role id to the list
        entityIds.Add(UserInfo.getUserRoleId());
        
        //Add user Id to the list
        entityIds.Add(userId);
        
        Set<Id> contactListIds = new Set<Id>();     
        
        for(List_Share__c listShare : [Select Contact_List__c, Contact_List__r.Id, 
                                                Contact_List__r.OwnerId, 
                                                Contact_List__r.Name,                                               
                                                Contact_List__r.Search_Criteria__c, 
                                                Contact_List__r.Search_Data_Type__c,
                                                Contact_List__r.Search_Scope__c,
                                                Contact_List__r.Description__c,
                                                Contact_List__r.Is_Shared__c,       
                                                Contact_List__r.Owner.Name,         
                                                Contact_List__r.Type__c,
                                                Contact_List__r.CreatedDate,                                                            
                                                List_Access__c,                                             
                                                List_Contents_Access__c
                                        From List_Share__c
                                        Where Entity_Id__c In :entityIds
                                        ])
        {           
            if ( bSharedOnly && listShare.Contact_List__r.Is_Shared__c == False ) {
                continue;
            }
            contactListIds.Add(listShare.Contact_List__c);

            ContactList cl = new ContactList ( listShare.Contact_List__r );
            cl.ListAccess = listShare.List_Access__c;
            cl.ListContentsAccess = listShare.List_Contents_Access__c;
            returnList.add ( cl );
        }               
                
        Map<Id, List<ContactListEntry>> mapContactListEntry = new Map<Id, List<ContactListEntry>>();
        List<ContactListEntry> tmpContactListEntry = new List<ContactListEntry>();      
        Id previousId = null;
                    
        for(Contact_List_Entry__c sf_cle : [Select Id, Contact__c, Contact_List__c,
                                            Override_Call_Order__c, Override_Rank__c
                                            From Contact_List_Entry__c
                                            Where Contact_List__c In :contactListIds
                                            Order By Contact_List__c])
        {                       
            if (previousId != sf_cle.Contact_List__c && previousId != null) {               
                mapContactListEntry.put(previousId, tmpContactListEntry.clone());
                tmpContactListEntry.clear();
            }           
            ContactListEntry cle = new ContactListEntry( sf_cle );
            tmpContactListEntry.add(cle);
            
            //set the previous id with current          
            previousId = sf_cle.Contact_List__c;
        }
        
        for(ContactList cl: returnList) {       
            if (cl.ContactListEntries == null) {
                cl.ContactListEntries = mapContactListEntry.get(cl.Id);
            }                   
        }       
        
        return ( returnList );
    }
    
//  ============================================================================
//  Method: getListMembership   
//  Desc:   Retrieves the Contact Lists of which the specified Contact is a 
//          member. 
//  Args:   ContactId
//  Return: List of ContactList records.                        
//  CaseNo: 3830
//  ============================================================================
    public static List<ContactList> getListMembership ( Id contId ) {
        
        Set<Id> clIdSet = new Set<Id> {};
        List<ContactList> clList = new List<ContactList> {};
        
        for ( Contact_List_Entry__c cle : [ select
                                                Contact_List__c ,
                                                Contact_List__r.Name ,
                                                Contact_List__r.Owner.Name
                                            from
                                                Contact_List_Entry__c
                                            where
                                                Contact__c = :contId
                                            ]
        ) {
            if ( !clIdSet.add ( cle.Contact_List__c ) ) {
                continue;
            }
            clList.add ( new ContactList ( cle.Contact_List__r ) );
        }
        
        return clList;
    }             
}