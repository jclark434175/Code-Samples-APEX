/**
 * Name:        AceList.cls
 *
 * Description: Functions that are related to Ace list.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from STC Tier1CRM.
 */ 
global class AceList {
	webService String Id;
    webService String OwnerId;
    webService String OwnerName;
    webService String Name; 
    webService String SearchCriteria;
    webService String SearchDataType;
    webService String SearchScope;
    webService String SearchInterestSubjectType;
    webService String Description;
    webService boolean IsShared;
    webService DateTime CreatedDate;    
    webService String ListType;
    webService String ListContent;
    webService List<AceListEntry> AceListEntries;

    // --- not directly from SF Ace_List__c --- 
    webService String ListAccess;
    webService String ListContentsAccess;
        
    public AceList () {
    }
    
    public AceList ( Ace_List__c al ) {
        if ( al == Null ) { return; }
        
        try { this.Id = al.Id; } catch ( SObjectException e ) {}
        try { this.OwnerId = al.OwnerId; } catch ( SObjectException e ) {}
        try { this.OwnerName = al.Owner.Name; } catch ( SObjectException e ) {}
        try { this.Name = al.Name; } catch ( SObjectException e ) {}        
        try { this.SearchCriteria = al.Search_Criteria__c; } catch ( SObjectException e ) {}
        try { this.SearchDataType = al.Search_data_type__c; } catch ( SObjectException e ) {}
        try { this.SearchInterestSubjectType = al.Interest_Subject_Type__c; } catch ( SObjectException e ) {}
        try { this.SearchScope = al.Search_scope__c; } catch ( SObjectException e ) {}
        try { this.Description = al.Description__c; } catch ( SObjectException e ) {}
        try { this.IsShared = al.Is_shared__c; } catch ( SObjectException e ) {}
        try { this.CreatedDate = al.CreatedDate; } catch ( SObjectException e ) {}
        try { this.ListType = al.Type__c; } catch ( SObjectException e ) {}
        try { this.ListContent = al.Content_Type__c; } catch ( SObjectException e ) {}
                
        try {
            this.AceListEntries = new List<AceListEntry> {};
            for ( Ace_List_Entry__c ale : al.AceListEntries__r ) {
                this.AceListEntries.add ( new AceListEntry ( ale ) );
            }
        } catch ( SObjectException e ) {}
    }    
    
    //  ============================================================================
    //  Method: getAceListsByOwner
    //  Desc:   Retrieves lists that a user can see base on
    //          - Record Ownership 
    //  Args:   String: 	userId  
    //          Boolean: 	sharedOnly
    //			String:		startName
    //			Integer:	pageSize	
    //  Return: Lists where the user is the owner
    //  ============================================================================
    public static AceListPage getAceListsByOwner( String userId,
                                                    Boolean bSharedOnly,
                                                    String startName,
													Integer pageSize )  
	{   
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) 
		{
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		
		AceListBuilder alb = new AceListBuilder ( pageSize );
		
		Id uid = userId; 
		List<AceList> returnList = new List<AceList>();
		
		for(Ace_List__c al : [	Select 	
									Id, 
									OwnerId, 
									Name,
                                    Search_Criteria__c,  
                                    Search_Data_Type__c, 
                                    Interest_Subject_Type__c,
                                    Search_Scope__c,
                                    Description__c, 
                                    Is_Shared__c,
                                    Owner.Name, 
                                    Type__c,
                                    Content_Type__c, 
                                    CreatedDate
                                From	
                                	Ace_List__c
                                Where 	
                                	OwnerId = :uid and
                                	Name >= :startName
                                order by
                                	Name
                                limit
                                	:pageSize + 1])
        {
        	if ( bSharedOnly && al.Is_Shared__c == False ) 
        	{
                continue;
            }
            
            AceList aceList = new AceList( al );
            
            if ( !alb.addAceList( aceList ) ) 
            {
                break;
            }        	
        }
        
        // Flush the Ace List Builder buffer.
		// --------------------------------------
        if ( alb.nextName == Null ) 
        {
            alb.addCachedAceLists ();
        }  
        
        return new AceListPage ( alb.alList , alb.nextName );		               
    }    
    
    //  ============================================================================
    //  Method: getSharedAceLists
    //  Desc:   Retrieves lists that a user can see base on
    //          - ACE List Shares   
    //  Args:   String: 	userId  
    //          Boolean: 	sharedOnly
    //			String:		startName
    //			Integer:	pageSize	
    //  Return: Lists associated with list shares where Shared With id=my id 
    //          Lists associated with list shares where Shared with id=groups I belong to 
    //          Lists associated with list shares where Shared with id=my role
    //  ============================================================================
    public static AceListPage getSharedAceLists( String userId,
                                                    Boolean bSharedOnly,
                                                    String startName,
													Integer pageSize )  
	{
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) 
		{
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		
		AceListBuilder alb = new AceListBuilder ( pageSize );
		
		Id uid = userId;
		Id roleId;
		Set<Id> entityIds = new Set<Id>();		
		
        if ( uid == UserInfo.getUserId () ) 
        { 
            roleId = UserInfo.getUserRoleId ();
        }
        else 
        {
            roleId = [select UserRoleId from User where Id = :uid].UserRoleId;
        }
        
        // Add all group membership to the entity list.
		// --------------------------------------------
        entityIds.addAll ( aceUtil.getUserGroups ( uid , roleId ) );
                
        //Add user role id to the list
        entityIds.Add(roleId);
        
        //Add user Id to the list
        entityIds.Add( uid );
        
        for(Ace_List_Share__c aceListShare : [Select 
        											Ace_List__r.Id, 
                                                    Ace_List__r.OwnerId, 
                                                    Ace_List__r.Name,                                                   
                                                    Ace_List__r.Search_Criteria__c, 
                                                    Ace_List__r.Search_Data_Type__c,
                                                    Ace_List__r.Search_Scope__c,
                                                    Ace_List__r.Description__c,
                                                    Ace_List__r.Is_Shared__c,
                                                    Ace_List__r.Owner.Name, 
                                                    Ace_List__r.Type__c,
                                                    Ace_List__r.Content_Type__c,
                                                    Ace_List__r.CreatedDate,                    
                                                    List_Access__c,
                                                    List_Contents_Access__c
                                        		From 	
                                        			Ace_List_Share__c
                                            	Where 	
                                            		Entity_Id__c In :entityIds and
                                            		Ace_List__r.Name >= :startName
                                            	order by
                                					Ace_List__r.Name
                                				limit
                                					:pageSize + 1])  
		{
			if ( bSharedOnly && aceListShare.Ace_List__r.Is_Shared__c == False ) 
			{
                continue;
            }
            AceList al = new AceList ( aceListShare.Ace_List__r );
            al.ListAccess = aceListShare.List_Access__c;
            al.ListContentsAccess = aceListShare.List_Contents_Access__c;
            
            if ( !alb.addAceList( al ) ) 
            {
                break;
            } 
		}    
		
		// Flush the Ace List Builder buffer.
		// --------------------------------------
        if ( alb.nextName == Null ) 
        {
            alb.addCachedAceLists ();
        }    
        
        return new AceListPage ( alb.alList , alb.nextName );		 	       
	}
    
//  ============================================================================
//  Method: getListMembership   
//  Desc:   Retrieves the Ace Lists of which the specified Contact/Account is a 
//          member. 
//  Args:   ContactId/AccountID--Entry_List_Id__c of Ace_List_entry
//  Return: List of AceList records.                        
//  CaseNo: 3830
//	NOTE:	This to be replace with getListMembership(contId, startName, pageSize)
//  ============================================================================
    public static List<AceList> getListMembership ( Id contId ) {
        
        Set<Id> alIdSet = new Set<Id> {};
        List<AceList> alList = new List<AceList> {};
        
        for ( Ace_List_Entry__c ale : [ select
                                                Ace_List__c ,
                                                Ace_List__r.Name ,
                                                Ace_List__r.Owner.Name
                                            from
                                                Ace_List_Entry__c
                                            where
                                                Entry_List_Id__c = :contId
                                            ]
        ) {
            if ( !alIdSet.add ( ale.Ace_List__c ) ) {
                continue;
            }
            alList.add ( new AceList ( ale.Ace_List__r ) );
        }
        
        return alList;
    }      
    
//  ============================================================================
//  Method: getListMembership   
//  Desc:   Retrieves the Ace Lists of which the specified Contact/Account is a 
//          member. 
//  Args:   ContactId/AccountID--Entry_List_Id__c of Ace_List_entry
//  Return: List of AceList records.                        
//  CaseNo: 3830
//  ============================================================================
    public static List<AceList> getListMembership ( Id contId, String userId ) {
        
        Set<Id> entityIds = new Set<Id>();
        Set<Id> alIdSet = new Set<Id> {};
        Set<Id> shareIds = new Set<Id>();
        List<AceList> alList = new List<AceList> {};
        
        Id roleId;
        if ( userId == UserInfo.getUserId () ) 
            roleId = UserInfo.getUserRoleId ();
        else
            roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        
//      Add all group membership to the entity list.
//      --------------------------------------------
        entityIds.addAll ( aceUtil.getUserGroups ( userId , roleId ) );
                
        //Add user role id to the list
        entityIds.Add(roleId);
        
        //Add user Id to the list
        entityIds.Add( userId );
        
		for(Ace_List_Share__c aceListShare : [Select Ace_List__c
	                                            From Ace_List_Share__c
	                                            Where Entity_Id__c In :entityIds
	                                            ])  {
            if (aceListShare.Ace_List__c != null) shareIds.add( aceListShare.Ace_List__c );
		}
                                            	
        for ( Ace_List_Entry__c ale : [ select
                                                Ace_List__c ,
                                                Ace_List__r.Name ,
                                                Ace_List__r.Owner.Name,
                                                Ace_List__r.Is_Shared__c
                                            from
                                                Ace_List_Entry__c
                                            where
                                                Entry_List_Id__c = :contId
                                            And (
                                            	Ace_List__r.OwnerId = :userId
                                            	Or
                                            	Ace_List__c IN :shareIds)
                                            ]
        ) {
            if ( !alIdSet.add ( ale.Ace_List__c ) || ale.Ace_List__r.Is_Shared__c == false ) {
                continue;
            }
            alList.add ( new AceList ( ale.Ace_List__r ) );
        }
        return alList;
    }
//  ============================================================================
//  Method: getListMembership   
//  Desc:   Retrieves the Ace Lists of which the specified Contact/Account is a 
//          member. 
//  Args:   ContactId/AccountID--Entry_List_Id__c of Ace_List_entry
//  Return: List of AceList records.                        
//  CaseNo: 3830
//	NOTE: 	This is the replacement of getListMembership(Id contId)
//  ============================================================================

    public static AceListPage getListMembership ( 	Id contId,
                                                  	String startName,
													Integer pageSize) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
        
        AceListBuilder alb = new AceListBuilder ( pageSize );
        
        Set<Id> alIdSet = new Set<Id> {};
        List<AceList> alList = new List<AceList> {};
        
        for ( Ace_List_Entry__c ale : [ select	Name,
                                                Ace_List__c ,
                                                Ace_List__r.Name ,
                                                Ace_List__r.Owner.Name
                                            from
                                                Ace_List_Entry__c
                                            where
                                                Entry_List_Id__c = :contId 
                                            And 
                                            	Ace_List__r.Name >= :startName 
                                            Order by Ace_List__r.Name                                 
                                            limit
                                                :pageSize
                                            ]
        ) {
           	if ( !alIdSet.add ( ale.Ace_List__c ) ) {
                continue;
            }
            if ( !alb.addAceList ( new AceList ( ale.Ace_List__r ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( alb.nextName == Null ) {
            alb.addCachedAceLists ();
        } 
        
		return new AceListPage ( alb.alList , alb.nextName );
    } 

    public static AceListPage getListMembership ( Id contId, 
    												String userId,
                                                    String startName,
													Integer pageSize) {
														
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
            pageSize = aceUtil.MAX_COLLECTION_SIZE;
        }
        
        AceListBuilder alb = new AceListBuilder ( pageSize );
        
        Set<Id> entityIds = new Set<Id>();
        Set<Id> alIdSet = new Set<Id> {};
        Set<Id> shareIds = new Set<Id>();
        
        Id roleId;
        if ( userId == UserInfo.getUserId () ) 
            roleId = UserInfo.getUserRoleId ();
        else
            roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        
//      Add all group membership to the entity list.
//      --------------------------------------------
        entityIds.addAll ( aceUtil.getUserGroups ( userId , roleId ) );
                
        //Add user role id to the list
        entityIds.Add(roleId);
        
        //Add user Id to the list
        entityIds.Add( userId );
        
		for(Ace_List_Share__c aceListShare : [Select Ace_List__c
	                                            From Ace_List_Share__c
	                                            Where Entity_Id__c In :entityIds
	                                            ])  {
            if (aceListShare.Ace_List__c != null) shareIds.add( aceListShare.Ace_List__c );
		}

        for ( Ace_List_Entry__c ale : [ select
                                                Ace_List__c ,
                                                Ace_List__r.Name ,
                                                Ace_List__r.Owner.Name,
                                                Ace_List__r.Is_Shared__c
                                            from
                                                Ace_List_Entry__c
                                            where
                                            	Entry_List_Id__c = :contId
                                            And
                                            	Ace_List__r.Is_Shared__c = false
                                            And
                                            	Ace_List__r.Name >= :startName
                                            And (
                                            	Ace_List__r.OwnerId = :userId
                                            	Or
                                            	Ace_List__c IN :shareIds)
                                            Order by Ace_List__r.Name
                                            limit
                                                :pageSize + 1
                                            ]
        ) {
            if ( !alIdSet.add ( ale.Ace_List__c )) continue;
           	
            if ( !alb.addAceList ( new AceList ( ale.Ace_List__r ) ) ) {
                break;
            }
        }
        
//      Flush the Contact List Builder buffer.
//      --------------------------------------
        if ( alb.nextName == Null ) {
            alb.addCachedAceLists ();
        } 
        
         return new AceListPage ( alb.alList , alb.nextName );
    }
    
    //  ============================================================================
	//  ============================================================================
	//  CLASS:  AceListListBuilder  
	//  Desc:   Utility class to help build a list of AceLists, based on 
	//          successive additions of AceList records, which are assumed
	//          to be sorted by Ace List Name.
	//  ============================================================================
	//  ============================================================================
    class AceListBuilder 
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
        AceListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        AceListBuilder ( Integer maxListSize ) {
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