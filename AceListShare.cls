/* 
 * Name: AceListShare 
 * Description: 
 *
 * Confidential & Proprietary, ©2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
global class AceListShare {

    webService String Id;
    webService String EntityId;
    webService String EntityName;
    webService String SharedWithType;
    webService String ListAccess;
    webService String ListContentsAccess;
    webService String AceList;
    
    public AceListShare () {
    }
    
    public AceListShare ( Ace_List_Share__c ls ) {
        if ( ls == Null ) { return; }
        
        try { this.Id = ls.Id; } catch ( SObjectException e ) {}
        try { this.EntityId = ls.Entity_Id__c; } catch ( SObjectException e ) {}
        try { this.EntityName = ls.Entity_Name__c; } catch ( SObjectException e ) {}
        try { this.SharedWithType = ls.Shared_With_Type__c; } catch ( SObjectException e ) {}
        try { this.ListAccess = ls.List_Access__c; } catch ( SObjectException e ) {}
        try { this.ListContentsAccess = ls.List_Contents_Access__c; } catch ( SObjectException e ) {}
        try { this.AceList = ls.Ace_List__c;  } catch ( SObjectException e ) {}
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified aceListShare record to the
//          specified list of lists of aceListShare records.  Calls the
//          'list' version of this function, which does all the work.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<aceListShare>> elemListList , 
                                        aceListShare myElem ) {
        listListAdd ( elemListList , new List<aceListShare> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of aceListShare
//          records to the specified list of lists of aceListShare records.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<aceListShare>> elemListList , 
                                        List<aceListShare> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//      Go through the list of lists, finding the first list that has room for
//      our element list
//      ----------------------------------------------------------------------
        List<aceListShare> elemList = Null;
        for ( List<aceListShare> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<aceListShare> {};
            elemListList.add ( elemList );
        }
        
        elemList.addAll ( myElemList );
    }

    //  ============================================================================
    //  Method: getAceListShare
    //  Desc:   Returns Ace_List_Share__c records for a given ace_list__c identified in as 
    //          a webservice parameter      
    //  Args:   String[]: aceListIds        
    //  Return: Ace List share associated with a given ace list                         
    //  ============================================================================    
    public static List<List<AceListShare>> getAceListShare(String[] aceListIds) {
        
        List<List<AceListShare>> pAceListShareList = new List<List<AceListShare>>();     

        for(Ace_List_Share__c alshare: [Select 	Id, 
        										Entity_Id__c,
                                    			Entity_Name__c, 
                                    			Shared_With_Type__c,
                                    			List_Access__c, 
                                    			List_Contents_Access__c,
                                    			Ace_List__c
                                    	From Ace_List_Share__c Where Ace_List__c In :aceListIds])
        {   
            listListAdd ( pAceListShareList , new AceListShare ( alshare ) );
        }

        return pAceListShareList;
    }    

}