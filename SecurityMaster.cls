/* 
 * Name: SecurityMaster 
 * Description: Contains the details of a Security Master record.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class SecurityMaster {
    webService String Id;
    webService String Symbol;
    webService String Name;
    webService String CorpAcctId;
    
    public SecurityMaster() {
    }   
    
    public SecurityMaster ( Security_Master__c sm ) {
        if ( sm == Null ) { return; }
        
        try { this.Id = sm.Id; } catch ( SObjectException e ) {}
        try { this.Symbol = sm.Symbol__c; } catch ( SObjectException e ) {}
        try { this.Name = sm.Name; } catch ( SObjectException e ) {}
        try { this.CorpAcctId = sm.Account__c; } catch ( SObjectException e ) {}
    }
    
    public SecurityMaster ( String inId , String inSym , String inName ) {
        this.Id = inId;
        this.Symbol = inSym;
        this.Name = inName;
    }   

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified SecurityMaster record to the
//          specified list of lists of SecurityMaster records.  Calls the
//          'list' version of this function, which does all the work.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<SecurityMaster>> elemListList , 
                                        SecurityMaster myElem ) {
        listListAdd ( elemListList , new List<SecurityMaster> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of SecurityMaster
//          records to the specified list of lists of SecurityMaster records.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<SecurityMaster>> elemListList , 
                                        List<SecurityMaster> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//      Go through the list of lists, finding the first list that has room for
//      our element list
//      ----------------------------------------------------------------------
        List<SecurityMaster> elemList = Null;
        for ( List<SecurityMaster> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<SecurityMaster> {};
            elemListList.add ( elemList );
        }
        
        elemList.addAll ( myElemList );
    }

//  ============================================================================
//  Method: searchSecurityMaster    
//  Desc:   Wrapper around searchSecurityMaster ( String symbols ), using an
//          actual list of symbol names rather than a delimited string.
//  Args:   symSet - set of symbols to search on.
//  Return: List of SecurityMaster records.
//  ============================================================================
    public static List<SecurityMaster> searchSecurityMaster ( Set<String> symSet ) {
        String symListStr = '';
        for ( String sym : symSet ) {
            symListStr += ( symListStr == '' ? '' : ',' ) + sym;
        }
        
        List<List<SecurityMaster>> smListList = searchSecurityMaster ( symListStr );
        if ( smListList.isEmpty () ) {
            return new List<SecurityMaster> {};
        }
        else {
            return smListList[ 0 ];
        }
    }
                                                            
//  ============================================================================
//  Method: searchSecurityMaster    
//  Desc:   Retrieves security information from Security_Master__c matching the
//          specified symbols.  
//  Args:   symList - comma-separated list of symbols to search on.
//  Return: List of lists of SecurityMaster records.
//  Case No: 3699
//  ============================================================================
    public static List<List<SecurityMaster>> searchSecurityMaster ( 
                                                            String symbols ) {
    
        List<String> symList = symbols.split ( ',' );
        List<List<SecurityMaster>> smListList = new List<List<SecurityMaster>> {};
        
        for ( Security_Master__c sm : [select Id , Name , Symbol__c , Account__c
                                        from Security_Master__c
                                        where Symbol__c in :symList] ) {
            listListAdd ( smListList , new SecurityMaster ( sm ) );
        }
        return smListList;
    }
    
//  ============================================================================
//  Method: getSecurityMasterByAcct 
//  Desc:   Retrieves security information from Security_Master__c matching the
//          specified account Ids.  
//  Args:   acctIdSet - set of accountIds to match
//  Return: List of SecurityMaster records.
//  ============================================================================
    public static List<SecurityMaster> getSecurityMasterByAcct ( Set<Id> acctIdSet ) {
        
        List<SecurityMaster> smList = new List<SecurityMaster> {};
        if ( acctIdSet == Null ) {
            return smList;
        }
        
        for ( Security_Master__c sm : [ select
                                            Id ,
                                            Name ,
                                            Symbol__c ,
                                            Account__c
                                        from
                                            Security_Master__c
                                        where
                                            Account__c in :acctIdSet
                                        ]
        ) {
            smList.add ( new SecurityMaster ( sm ) );
        }
        
        return smList;
    } 
}