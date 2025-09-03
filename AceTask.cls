/* 
 * Name: AceTask 
 * Description: Contains static Task-related methods.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AceTask {
    
    webService String Id;
    webService String Description;
    webService String Subject;
    webService Date ActivityDate;
    webService String CreatedForName;
    webService String CreatedByName;
    webService String InteractionType;
    webService String Label;
    webService Double CallRating;
    webService String Reason; 
    webService DateTime CreatedDate;
    webService String Status;
    webService String RecordTypeId;
    webService AceContact Contact;
    webService AceAccount Account;
    webService AceUser CreatedFor;
    webService AceUser Owner;

    public AceTask () {
    }   
    
    public AceTask ( Task t ) {
        if ( t == Null ) { return; }
        
        try { this.Id = t.Id; } catch ( SObjectException e ) {}
        try { this.Description = t.Description; } catch ( SObjectException e ) {}
        try { this.Subject = t.Subject; } catch ( SObjectException e ) {}
        try { this.ActivityDate = t.ActivityDate; } catch ( SObjectException e ) {}
        try { this.CreatedForName = t.Created_For_Name__c; } catch ( SObjectException e ) {}
        try { this.CreatedByName = t.CreatedBy.Name; } catch ( SObjectException e ) {}
        try { this.InteractionType = t.Interaction_Type__c; } catch ( SObjectException e ) {}
        try { this.Label = t.Label__c; } catch ( SObjectException e ) {}
        try { this.CallRating = t.Call_Rating__c; } catch ( SObjectException e ) {}
        try { this.Reason = t.Reason__c; } catch ( SObjectException e ) {}
        try { this.CreatedDate = t.CreatedDate; } catch ( SObjectException e ) {}
        try { this.Status = t.Status; } catch ( SObjectException e ) {}
        try { this.RecordTypeId = t.RecordTypeId; } catch ( SObjectException e ) {}
        
        try { this.Owner = new AceUser ( t.Owner.Id , t.Owner.Name ); } catch ( SObjectException e ) {}
    }       
        
//  ============================================================================
//  Method: getUserTasksByRecordType    
//  Desc:   Gets all open Tasks owned by the specified user, of the specified
//          Record Type.
//          Filters Tasks whose WhoIds are not pointing at active Contacts.
//  Args:   userId - the Task owner Id
//          recTypeId - the desired record type Id
//  Return:                     
//  Case No: 3729
//  ============================================================================
    public static List<AceTask> getUserTasksByRecordType ( Id userId , Id recTypeId ) {

        List<AceTask> taskList = new List<AceTask> {};
        Map<Id , Id> acctIdByTask = new Map<Id , Id> {};
        Map<Id , Id> contIdByTask = new Map<Id , Id> {};
        Map<Id , Set<Id>> taskIdsByCont = new Map<Id , Set<Id>> {};     
        Map<Id , Id> createdForIdByTask = new Map<Id , Id> {};
        Map<Id , AceTask> aceTaskById = new Map<Id , AceTask> {};
        
//      Grab the Task objects.
//      ----------------------      
        for ( Task t : [select
                            Id , Description , Subject , ActivityDate , 
                            Created_For_Name__c , CreatedBy.Name , 
                            Interaction_Type__c , Label__c , Call_Rating__c , 
                            Reason__c , CreatedDate , Status , RecordTypeId ,
                            WhoId , AccountId , Created_For_Id__c
                        from
                            Task
                        where
                            OwnerId = :userId and
                            RecordTypeId = :recTypeId and
                            IsClosed = False
                    ]
        ) {
            acctIdByTask.put ( t.Id , t.AccountId );
            contIdByTask.put ( t.Id , t.WhoId );
            if ( !taskIdsByCont.containsKey ( t.WhoId ) ) {
                taskIdsByCont.put ( t.WhoId , new Set<Id> {} );
            }
            taskIdsByCont.get ( t.WhoId ).add ( t.Id );
            createdForIdByTask.put ( t.Id , t.Created_For_Id__c );

            aceTask aceT = new AceTask ( t );
            aceTaskById.put ( t.Id , aceT );
        }
        
        
//      Now get the matching Contacts.
//      ------------------------------
        Set<Id> contIdToSkipSet = new Set<Id> {};
        Map<Id , Contact> contById = new Map<Id , Contact> {};
        
        for ( Contact cont : [select
                                    Id , FirstName , LastName , Phone ,
                                    MobilePhone , HomePhone ,
                                    AssistantPhone , OtherPhone ,
                                    Aum__c , Invest_Style__c , Regions__c ,
                                    Sectors__c , Sub_Sectors__c ,
                                    Email , Title , ST_Inactive__c, 
                                    Account.ST_Thomson_Id__c , Account.ST_ACE__Tier__c
                                from
                                    Contact
                                where
                                    Id in :contIdByTask.Values () and
                                    ST_Inactive__c = False
                            ] 
        ) {
            contById.put ( cont.Id , cont );
        }
        
//      Prune Tasks not associated with active Contacts.
//      ------------------------------------------------
        for ( Id taskId : contIdByTask.keySet () ) {
            if ( !contById.containsKey ( contIdByTask.get ( taskId ) ) ) {
                aceTaskById.remove ( taskId );
                acctIdByTask.remove ( taskId );
                createdForIdByTask.remove ( taskId );
            }
        }

//      Now get the matching Accounts.
//      ------------------------------
        Map<Id , Account> acctById = new Map<Id , Account> {};
        for ( Account acct : [select
                                    Id ,
                                    Name , 
                                    Aum__c ,
                                    ST_ACE__Tier__c ,
                                    Phone ,
                                    Website ,
                                    WB_Tier__c ,
                                    Sector__c ,
                                    City__c ,
                                    Cash_EQ_Tier__c ,
                                    ParentId ,
                                    Parent.Name ,
                                    Parent.Phone
                                from
                                    Account
                                where
                                    Id in :acctIdByTask.Values ()
                            ]
        ) {
            AcctById.put ( acct.Id , acct );
        }
        
//      Now get the matching CreatedFor info.
//      -------------------------------------
        Map<Id , User> createdForById = new Map<Id , User> {};
        for ( User u : [select
                            Id ,
                            Email 
                        from
                            User
                        where
                            Id in :createdForIdByTask.Values ()
                        ]
        ) {
            CreatedForById.put ( u.Id , u );
        }
        
//      Now put it all together.
//      ------------------------
        for ( Id taskId : aceTaskById.keySet () ) {
            AceTask at = aceTaskById.get ( taskId );
            Id contId = contIdByTask.get ( taskId );
            if ( contId != Null ) {
                at.Contact = new AceContact ( ContById.get ( contId ) , False );
            }
            Id acctId = acctIdByTask.get ( taskId );
            if ( acctId != Null ) {
                at.Account = new AceAccount ( AcctById.get ( acctId ) );
            }
            Id createdForId = createdForIdByTask.get ( taskId );
            if ( createdForId != Null ) {
                at.CreatedFor = new AceUser ( createdForById.get ( createdForId ) );
            }
        }
        
        return aceTaskById.Values ();
    }
    
//  ============================================================================
//  Method: getRecentInteractions   
//  Desc:   Retrieves the recent/future interactions for the specified Account
//          and/or Contact, a page at a time (sorted by CreatedDate).
//  Args:   AccountId
//          ContactId
//          inPastNDays
//          firstCreatedDate
//  Return: An AceTaskpage record, containing a page of AceTask records.                        
//  Case No: 3676
//  ============================================================================
    public static AceTaskPage getRecentInteractions (
                                                    Id acctId ,
                                                    Id contId ,
                                                    Integer inPastNDays ,
                                                    DateTime firstCreatedDate
                                                ) {

        List<AceTask> taskList= new List<AceTask> ();
        if ( acctId == Null ) {
            return new AceTaskPage ( taskList , Null );
        }
        
        if ( firstCreatedDate == Null ) {
            firstCreatedDate = DateTime.newInstance ( 0 );  // dawn of time
        }

//      If a Contact was not specified, get the specified Account's active Contacts.
//      ----------------------------------------------------------------------------
        List<Set<Id>> activeContIdSetList;
        if ( contId == Null ) {
            activeContIdSetList = AceContact.getActiveContactsByAcctId ( acctId );
        }

//      Get account particulars.
//      ------------------------
        Account[] acctList = [ select
                                    Id ,
                                    Name , 
                                    Aum__c ,
                                    ST_ACE__Tier__c ,
                                    Phone
                                from
                                    Account
                                where
                                    Id = :acctId
                            ];
        if ( acctList.Size() == 0 ) {
            return new AceTaskPage ( taskList , Null );
        }
        Account acct = acctList[ 0 ];

        Date threshDate = Date.today ().addDays ( inPastNDays * -1 );
        
//      Grab the Tasks associated with this Account (+ possibly Contact).
//      The 'tl' arrays are 200 Task records in size.
//      -----------------------------------------------------------------       
        List<Task[]> taskListList = new List<Task[]> {};
        Map<Id , Id> acctIdByTask = new Map<Id , Id> {};
        
        if ( contId == Null ) {
            for ( Task[] tl : [ select Id , ActivityDate , Status , 
                                    Interaction_Type__c , Subject , Description ,
                                    AccountId , WhoId , Who.Name ,
                                    Owner.Name , CreatedDate, Created_For_Name__c,
                                    CreatedBy.Name
                                from Task
                                where ActivityDate >= :threshDate
                                and AccountId = :acctId 
                                and CreatedDate >= :firstCreatedDate 
                                order by CreatedDate ]
            ) {
                taskListList.add ( tl );
            }                   
        }
        else {
            for ( Task[] tl : [ select Id , ActivityDate , Status , 
                                    Interaction_Type__c , Subject , Description ,
                                    AccountId , WhoId , Who.Name ,
                                    Owner.Name , CreatedDate, Created_For_Name__c,
                                    CreatedBy.Name
                                from Task
                                where ActivityDate >= :threshDate
                                and AccountId = :acctId 
                                and WhoId = :contId 
                                and CreatedDate >= :firstCreatedDate 
                                order by CreatedDate ]
            ) {
                taskListList.add ( tl );
            }                   
        }

        List<AceTask> taskCache = new List<AceTask> {};
        DateTime prevCreatedDate , nextCreatedDate;
        Integer idx = 0;

//      Go through the Tasks, skipping those belonging to inactive Contacts, 
//      until we have a page of Task records.
//      --------------------------------------------------------------------
        for ( Task[] tl : taskListList ) {
            for ( Task t : tl ) {
                
                if ( activeContIdSetList != Null
                        && !AceUtil.setListFind ( activeContIdSetList , t.WhoId ) ) {
                    continue;
                }
    
                if ( idx++ > aceUtil.MAX_COLLECTION_SIZE ) {
                    nextCreatedDate = ( taskCache.isEmpty () ? t.CreatedDate : prevCreatedDate );
                    break;
                }
                if ( prevCreatedDate != Null && prevCreatedDate != t.CreatedDate ) {
                    taskList.addAll ( taskCache );
                    taskCache.clear ();
                }
                prevCreatedDate = t.CreatedDate;
                AceTask aceT = new AceTask ( t );
                aceT.Contact = new AceContact ( t.Who.Id , t.Who.Name );
                aceT.Account = new AceAccount ( acct );             
                taskCache.add ( aceT );
            }
            if ( idx > aceUtil.MAX_COLLECTION_SIZE ) {
                break;
            }
        }
        if ( nextCreatedDate == Null ) {
            taskList.addAll ( taskCache );
        }
        
        return new AceTaskPage ( taskList , nextCreatedDate );
    }                       
}