/* 
 * Name: AceListEntry 
 * Description: 
 *
 * Confidential & Proprietary, ©2009 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
global class AceListEntry {
    webService String Id;
    webService String Name;
    webService String AceList;  
    webService String OverrideCallOrder;
    webService String OverrideRank; 
    webService SObject EntryList;
    webService String EntryListId;
    webService Date LastInteractionDate;
    
    /**
     * Field Names to be used for querying Ace_List_Entry objects
     */
    private static final String[] FIELD_NAMES = new String[] { 'Id', 'Name', 'Entry_List_Id__c', 'Override_Call_Order__c', 'Override_Rank__c', 'Ace_List__c' }; 
    
    public AceListEntry() {
    }
    
    public AceListEntry ( Ace_List_Entry__c ale ) {
        if ( ale == Null ) { return; }
        
        try { this.Id = ale.Id; } catch ( SObjectException e ) {}       
        try { this.AceList = ale.Ace_List__c; } catch ( SObjectException e ) {}     
        try { this.OverrideCallOrder = ale.Override_Call_Order__c; } catch ( SObjectException e ) {}
        try { this.OverrideRank = ale.Override_Rank__c; } catch ( SObjectException e ) {}
        try { this.EntryListId = ale.Entry_List_Id__c; } catch ( SObjectException e ) {}    
        try { this.Name = ale.Name; } catch ( SObjectException e ) {}     
//      Fill out the AceEntryListId details.
        //try { this.EntryList = new SObject (); } catch ( SObjectException e ) {} cannot construct an s-object
            
    }
    
    // ============================================================================
    //  Method: getListEntriesForList   
    //  Desc:   Retrieves the list entry records for a given list 
    //          - Record Ownership 
    //          - ACE List Shares   
    //  Args:   String: aceListId   - the if of list
    //          String queryFields  - a list of fields to query
    //          Boolean: isActive   - Contact Active status
    //          Boolean bGetLatInteraction  - Last Interaction
    //          Id userId           - User ID   
    //  Return: A list of AceLIstEntry objects                          
    //  Case No: 3641
    //  ============================================================================
      /*public static List<AceListEntry> getListEntriesForList(string aceListId, 
                                                                string queryFields, 
                                                                boolean isActive,
                                                                boolean bGetLastInteraction ,
                                                                Id userId ) { 
        
        try{
        String fieldsToGet=queryFields;     
        String[] fldNames=fieldsToGet.split(',');
        
        Ace_List__c aceList=new Ace_List__c();
        aceList=[Select Id, Content_Type__c
                                        From Ace_List__c
                                        Where Id =:aceListId];
                                            
        String sobjType=aceList.Content_Type__c;        
        String whereClause='';              
        String sortFld =Null;       
        Integer maxRecs =aceUtil.MAX_COLLECTION_SIZE; 
        
        Map<Id,AceListEntry>  aceListEntriesMap=new Map<Id, AceListEntry>();
        Map<Id, Id > entryListIdsMap = new Map<Id, Id>();//ListEntry_id,AceEntry_List_Id
        for(Ace_List_Entry__c ale : [Select Id, Entry_List_Id__c,Override_Call_Order__c,Override_Rank__c,Ace_List__c
                                    From Ace_List_Entry__c
                                    Where Ace_List__c =:aceListId])
        {   
            entryListIdsMap.put(ale.Entry_List_Id__c,ale.Id);//entryList_Id,AceListID
            AceListEntry ale1=new AceListEntry(ale);
            aceListEntriesMap.put(ale.Id,ale1);
        }       
        whereClause='Id in ( ' + aceUtil.concatList(new List<Id>(entryListIdsMap.keySet()), ' , ' , True ) + ' )';                              
        SObject[] sobjList =AceSObject.getSObjectInfo (sobjType , whereClause , sortFld , maxRecs, fldNames );
                                                
        //put sobjects in list entries Contact/Account
        for(SObject so : sobjList ) {   
            Object myId = so.get('Id');
            if (myId!=null){
                Id alc_c =entryListIdsMap.get((String)myId);
                AceListEntry item =aceListEntriesMap.get(alc_c);
                item.EntryList=so;
            }
        }       
        if ( bGetLastInteraction ) {
            getLastInteractions (aceListEntriesMap.values() , userId );
        }                                           

        return  aceListEntriesMap.values();
        }//try
        catch (Exception e)
        {
            System.debug('TgetListEntriesForList exception: ' + e.getMessage() ); 
            return null;           
        }
    }*/ 
   
    // ============================================================================
    //  Method: getListEntriesForList   
    //  Desc:   Retrieves the list entry records for a given list 
    //          - Record Ownership 
    //          - ACE List Shares   
    //  Args:   String 	aceListId   - the if of list
    //          String 	queryFields - a list of fields to query
    //          Boolean isActive   	- Contact Active status
    //			String 	startName	- string to start the search from
    //			Integer	pageSize	- number of records to query.
    //          Boolean bGetLatInteraction  - Last Interaction
    //          Id userId           - User ID   
    //  Return: A list of AceLIstEntry objects                          
    //  Case No: 3641
    //  ============================================================================
	public static AceListEntryPage getListEntriesForList(string aceListId , 
                                                        	string queryFields , 
                                                            String startName ,
                                                            Integer pageSize , 
                                                            boolean bGetLastInteraction ,
                                                            Id userId ) 
	{
		String[] fldNames = queryFields.split(',');
        
       	// Determine the Object type.
       	Ace_List__c aceList = [	Select 	Id, Content_Type__c
                				From 	Ace_List__c
                    			Where 	Id =:aceListId];                                            
        String sobjType = aceList.Content_Type__c;      
          
        String whereClause = '';              
        
        //Map of ids used for querying the object
        Map<String , AceListEntry> aleByEntryId = new Map<String , AceListEntry> {};
        	
		String aleQryClause = 'Ace_List__c = \'' + aceListId + '\' and Entry_List_Id__c != null ';
		
		SObjectPage items = AceSObject.getSObjectPage('Ace_List_Entry__c', aleQryClause, 'Name', startName, pageSize, FIELD_NAMES);
		
		//If there are no entries
		if (items.SObjectList == null || items.SObjectList.size() == 0)
		{
			return new AceListEntryPage();
		}
		
		List<AceListEntry> aceListEntries = new List<AceListEntry>();
		
		// Do the query 
        for (SObject sobj : items.SObjectList)
        {
        	AceListEntry ale = new AceListEntry ( (Ace_List_Entry__c)sobj );
        	//Add the item to the ace list entry
        	aceListEntries.add(ale);
        	//Also put it in the map
        	aleByEntryId.put ( ale.EntryListId, ale );
        }		

		// Build the where clause
        //DE963 -- rewrite the statement to check if the list contains any element -- whereClause = 'Id in ( ' + aceUtil.concatList(new List<String>(aleByEntryId.keySet()), ' , ' , True ) + ' )';                              
        whereClause = aceUtil.concatList(new List<String>(aleByEntryId.keySet()), ' , ' , True );       
        whereClause = 'Id in ( ' + whereClause + ' )';      
        
        // Query for sobjType Contact/Account 
        SObject[] sobjList = AceSObject.getSObjectInfo (sobjType , whereClause , Null , pageSize , fldNames );
                                                
        // put sobjects in list entries Contact/Account
        for(SObject so : sobjList ) {   
            String myId = '' + so.get('Id');
            if (myId != null){
            	AceListEntry item = aleByEntryId.get ( myId );
                item.EntryList = so;
            }
        }
             
        if ( bGetLastInteraction ) {
            getLastInteractions (aceListEntries , userId );
        }                                           

		return new AceListEntryPage ( aceListEntries , items.NextKey );
    }
   
//  ============================================================================
//  Method: getLastInteractions
//
//  Desc:   Function to go through the specified list of lists of AceListEntries, 
//          determining the last interaction date on each related Contact/Accpount by the 
//          specified userId.
//       
//  Return: Nothing.  The list of lists of AceListEntries is modified in situ.
//  ============================================================================                    

    public static void getLastInteractions ( List<AceListEntry> aleList,
                                                Id userId ) {
        
        Map<Id , AceListEntry> listEntryById=new Map<Id, AceListEntry>();// (listEntyID, AceListEntry)
        Schema.sObjectType objType= aleList[0].EntryList.getSObjectType();
        for (AceListEntry ale : aleList) {  
                listEntryById.put((Id)ale.EntryList.get('Id'), ale);
            }
            
            
        if (objType== Contact.sObjectType)
        {
            for ( UserContactInteraction uci :  UserContactInteraction.getUserContactInteractions (
                                                    userId ,
                                                    listEntryById.keySet ()))
            {
                AceListEntry ale = listEntryById.get(uci.ContactId );
                ale.LastInteractionDate = uci.LastInteractionDate;
            }
        }
        else if  (objType== Account.sObjectType)
        {
            for ( UserContactInteraction uci :  UserContactInteraction.getUserAccountInteractions (
                                                    userId ,
                                                    listEntryById.keySet ()))
            {
                AceListEntry ale= listEntryById.get(uci.AccountId );
                SObject so=ale.EntryList;
                System.debug('UserAccountInteraction:'+ uci.AccountId+'-'+ so.get('Name')+'-'+uci.LastInteractionDate);
                if (ale.LastInteractionDate == Null 
                            || ale.LastInteractionDate < uci.LastInteractionDate) {   
                    System.Debug('Interactiondatold:'+ale.LastInteractionDate+' InteractionDate2:'+uci.LastInteractionDate);
                    ale.LastInteractionDate = uci.LastInteractionDate;
                        
                }
                
            }
        }       
    }  
/**    
	//  ============================================================================
	//  ============================================================================
	//  CLASS:  AceContactListBuilder   
	//  Desc:   Utility class to help build a list of AceContacts, based on successive
	//          additions of Contact records, which are assumed to be sorted by
	//          Contact Name.
	//  ============================================================================
	//  ============================================================================
    class AceListEntryListBuilder 
    {        
        private Integer idx;
        private String prevName;
        private Integer maxListSize;
        private AceListEntry[] listEntryCache;        
        private AceListEntry[] listEntryList;
        public String nextName;        
        
		// ============================================================================
		// Method: Constructor 
		// Desc:   Initializes variables.
		// ============================================================================
		AceListEntryListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        AceListEntryListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevName = '';
            this.nextName = Null;
            this.maxListSize = maxListSize;
            this.listEntryCache = new List<AceListEntry> {};
            this.listEntryList = new List<AceListEntry> {};
        }   
	            
		// ============================================================================
		// Method: addAceListEntry   
		// Desc:   Adds the specified List Entry record to the AceListEntry list.
		//         If this record would put us past the max-record limit, aborts.
		// Args:   cont - the AceListEntry record
		// Return: True if the record was added; False otherwise.
		// ============================================================================
        public Boolean addAceListEntry ( AceListEntry listEntry ) {

            if ( prevName != Null && prevName != listEntry.Name ) {
                listEntryList.addAll ( listEntryCache );
                listEntryCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextName = ( listEntryCache.isEmpty () ? listEntry.Name : prevName );
                return False;
            }
            prevName = listEntry.Name;
            listEntryCache.add ( listEntry );
            return True;
        }
        
		// ============================================================================
		// Method: addCachedAceListEntrys    
		// Desc:   Adds the AceListEntry records we've built up in our internal cache, to
		//         the AceListEntry list.
		// Args:   None.
		// Return: None.
		// ============================================================================
        public void addCachedAceListEntries () {
            listEntryList.addAll ( listEntryCache );
        }
    }
*/ 
}