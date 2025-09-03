/* 
 * Name: Account 
 * Description: Contains details of an Account
 *
 * Confidential & Proprietary, ©2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class AceAccount {
	
    public static String CONTACT_COVERAGE_SCOPE = 'menuItemContactCoverage';
    public static String ACCOUNT_COVERAGE_SCOPE = 'menuItemAccountCoverage';
    public static String ALL_COVERAGE_SCOPE = 'menuItemAll';
    
    webService String Id;
    webService String Name;
    webService String Website;
    webService String AccountType;
    webService String BillingCity;
    webService String BillingCountry;
    webService String Aum;
    webService String Phone;
    webService String Tier;
    webService String ThomsonId;
    webService String WBTier;
    webService String City;
    webService String Sector;
    webService String CashEQTier;
    webService String ParentAccountId;
    webService String ParentAccountName;
    webService String ParentAccountPhone;

    // --- Not directly from SF Contact ---    
    webService Date AccountLastInteractionDate;
    
    public AceAccount() {
    }
    
    public AceAccount(Account anAccount) {
        if ( anAccount == Null ) { return; }
        
        try { this.Id = anAccount.Id; } catch ( SObjectException e ) {}
        try { this.Name = anAccount.Name; } catch ( SObjectException e ) {}
        try { this.Website = anAccount.Website; } catch ( SObjectException e ) {}
        try { this.AccountType = anAccount.Type; } catch ( SObjectException e ) {}
        try { this.BillingCountry = anAccount.BillingCountry; } catch ( SObjectException e ) {}
        try { this.BillingCity = anAccount.BillingCity; } catch ( SObjectException e ) {}
        try { this.Aum = anAccount.Aum__c; } catch ( SObjectException e ) {}
        try { this.Phone = anAccount.Phone; } catch ( SObjectException e ) {}
        try { this.Tier = anAccount.ST_ACE__Tier__c; } catch ( SObjectException e ) {}
        try { this.ThomsonId = anAccount.ST_Thomson_Id__c; } catch ( SObjectException e ) {}
        try { this.WBTier = anAccount.WB_Tier__c; } catch (SObjectException e ) {}
        try { this.Sector = anAccount.Sector__c; } catch (SObjectException e ) {}
        try { this.City = anAccount.City__c; } catch (SObjectException e ) {}
        try { this.CashEQTier = anAccount.Cash_EQ_Tier__c; } catch (SObjectException e ) {}
        try { this.ParentAccountId = anAccount.ParentId; } catch (SObjectException e ) {}
        try { this.ParentAccountName = anAccount.Parent.Name; } catch (SObjectException e ) {}
        try { this.ParentAccountPhone = anAccount.Parent.Phone; } catch (SObjectException e ) {}
    }
    
    public AceAccount ( Interest__c interest ) {
        try { this ( interest.Account__r ); } catch ( SObjectException e ) {}
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified AceAccount record to the
//          specified list of lists of AceAccount records.  Calls the
//          'list' version of this function, which does all the work.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<AceAccount>> elemListList , 
                                        AceAccount myElem ) {
        listListAdd ( elemListList , new List<AceAccount> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of AceAccount
//          records to the specified list of lists of AceAccount records.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<AceAccount>> elemListList , 
                                        List<AceAccount> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//      Go through the list of lists, finding the first list that has room for
//      our element list
//      ----------------------------------------------------------------------
        List<AceAccount> elemList = Null;
        for ( List<AceAccount> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<AceAccount> {};
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
    public static void getLastInteractions ( List<AceAccount> acl ,Id userId ) {
    	 if ( !acl.isEmpty () ) {
            Map<Id , AceAccount> acctById = new Map<Id , AceAccount> {};
            for ( AceAccount acct : acl ) {
                acctById.put ( acct.Id , acct );
            }
            for ( UserContactInteraction uci :
                        UserContactInteraction.getUserAccountInteractions (
                                                    userId ,
                                                    acctById.keySet ()
                                                )
            ) {
                AceAccount ac = acctById.get ( uci.AccountId );
                // Need to compare and assign the lastest interaction for each 
                // Contact User Interaction returned which matched with the account
                // since the returned record is not ordered by date 
				if (ac.AccountLastInteractionDate == Null ||
                    ac.AccountLastInteractionDate < uci.LastInteractionDate) {   
                    ac.AccountLastInteractionDate = uci.LastInteractionDate;
                }
            }
    	 }
    }   
    
    
    //  ============================================================================
    //  Method:         getAccount
    //  Description:    Gets the current user information           
    //  Args:           None
    //  Return:         AceAccount that contains account information                        
    //  Case No:        3668
    //  ============================================================================    
    public static AceAccount getAccount(String accountId) { 
        List<List<AceAccount>> acctListList = getAccounts(new String[] {accountId});
        if ( !acctListList.isEmpty () ) {
            return acctListList[ 0 ][ 0 ];
        }
        else {
            return Null;
        }
    }
    
    //  ============================================================================
    //  Method:         getAccounts
    //  Description:    Gets the current user information           
    //  Args:           None
    //  Return:         List of AceAccount that contains account information                        
    //  Case No:        3668
    //  ============================================================================
    public static List<List<AceAccount>> getAccounts(String[] accountIds) {     
        List<List<AceAccount>> returnList = new List<List<AceAccount>>();
        
        for(Account acct: [Select Id, Name, Website, Type, 
                                    BillingCountry, Aum__c, Phone, ST_ACE__Tier__c
                                    , BillingCity //DE908 -- add Location to the output 
                                    From Account
                                    Where Id In :accountIds]) {             
                                                    
            listListAdd ( returnList , new AceAccount(acct) );          
        }
        return returnList;
    }

//  ============================================================================
//  Method: searchAccountsByAccountName 
//  Desc:   Gets information on the Account(s) whose Name begins with the
//          specified Name string. 
//  Args:   acctName
//  Return: List of AceAccount records.                     
//  Case No: 3694
//  ============================================================================
    public static List<AceAccount> searchAccountsByAccountName ( String acctName ) {
        
        List<AceAccount> returnList = new List<AceAccount> {};
        for(Account acct: [Select Id, Name, Website, Type, 
                                    BillingCountry, Aum__c, Phone, ST_ACE__Tier__c, ParentId, Parent.Name, Parent.Phone
                                    , BillingCity //DE908 -- add Location to the output
                                    From Account
                                    Where Name like :acctName + '%' ]) {                
                                                    
            returnList.Add ( new AceAccount( acct ) );          
        }
        
        return returnList;
    }
//  ============================================================================
//  Method: searchAccountsByAccountName 
//  Desc:   Gets information on the Account(s) whose Name begins with the
//          specified Name string. 
//  Args:   acctName
//  Return: List of AceAccount records.                     
//  Defect: DE965
//  ============================================================================
    public static AceAccountPage searchAccountsByAccountName ( 	String acctName,
    				 											String startName,
    															Integer pageSize ) {
        
        if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		
		AceAccountListBuilder aalb = new AceAccountListBuilder ( pageSize );
		
        //List<AceAccount> returnList = new List<AceAccount> {};
        
        for(Account acct: [Select Id, Name, Website, Type, 
                                    BillingCountry, Aum__c, Phone, ST_ACE__Tier__c, 
                                    ParentId, Parent.Name, Parent.Phone, 
                                    BillingCity //DE908 -- add Location to the output
                                    From 
                                    	Account
                                    Where 
                                    	Name like :acctName + '%' 
                                    And
                                    	Name >= :startName
                                    order by 
                                    	Name
        							limit
        								:pageSize + 1]) {
            if ( !aalb.addAceAccount ( new AceAccount ( acct ) ) ) {
				break;
			}
        }
//		Flush the Account List Builder buffer.
//		--------------------------------------
		if ( aalb.nextName == Null ) {
			aalb.addCachedAceAccounts ();
		}
        return new AceAccountPage ( aalb.acctList , aalb.nextName );
    }
//  ============================================================================
//  Method: getAccountsCoveredByEmployee 
//  Desc:   Gets information on the Account(s) covered by the specified 
//			Employee.
//  Args:   emplId	- the Employee Id
//  Return: List of covered AceAccount records.                     
//  Case No:3897
//  ============================================================================
    public static AceAccountPage getAccountsCoveredByEmployee ( Id emplId ,
    															String startName ,
    															Integer pageSize ) {
        
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		     
		AceAccountListBuilder aalb = new AceAccountListBuilder ( pageSize );
		
        for ( Account_Coverage__c ac : [ select
        									Account__r.Id ,
        									Account__r.Name ,
        									Account__r.BillingCountry,
        									Account__r.BillingCity
        								from
        									Account_Coverage__c
        								where
        									Employee__c = :emplId and
        									Account__r.Name >= :startName
        								order by
        									Account__r.Name
        								limit
        									:pageSize + 1
        								]
        ) {
			if ( !aalb.addAceAccount ( new AceAccount ( ac.Account__r ) ) ) {
				break;
			}
        }
        
//		Flush the Account List Builder buffer.
//		--------------------------------------
		if ( aalb.nextName == Null ) {
			aalb.addCachedAceAccounts ();
		}
		
		return new AceAccountPage ( aalb.acctList , aalb.nextName );
    }        

    /**********************************************************/
//  ============================================================================
//	Search Account records given user input "searchString".
//	"searchScope" coresponds to the user's: My Contact Coverage, My Account Coverage or All Accounts
//	(see *_COVERAGE_* constants above for possible input values).
//  "searchFields" is ACE Feature Registry (AFR) : AccountSearchFields field entry.
//  "startName" and "pageSize" are used for filtering of records wrt pagination.
//
//  ============================================================================
	public static AceAccountPage searchByAccountFields (Id userId,
								  					    String searchString,
								  					    String searchScope,
								  						String searchFields,
								  						Boolean bGetLastInteraction, 
								  						String startName,
								  						Integer pageSize ) 
	{
    /**********************************************************/
        /** DEPRECATED TO USE NEW AceSObject.getSObjectPage
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}		     
		AceAccountListBuilder aalb = new AceAccountListBuilder ( pageSize );
		List<Account> acctList = new List<Account>();
		List<SObject> returnList = AdvancedSearch.searchRecords (
								AdvancedSearch.searchObjType.ACCOUNT
								, userId, searchString, searchScope
								, searchFields, startName, pageSize);
        if (returnList != null) acctList = ((List<Account>)returnList);        

        for ( Account acct : acctList) 
        {
			if ( !aalb.addAceAccount ( new AceAccount ( acct ) ) ) 
			{
				break;
			}
        }
        
//		Flush the Account List Builder buffer.
//		--------------------------------------
		if ( aalb.nextName == Null ) {
			aalb.addCachedAceAccounts ();
		}
		
        if ( bGetLastInteraction ) {        	
        	getLastInteractions ( aalb.acctList , userId );
        } 
        */
        SObjectPage items = AdvancedSearch.searchRecords (
						AdvancedSearch.searchObjType.ACCOUNT
						, userId, searchString, searchScope
						, searchFields, startName, pageSize);
						
		List<AceAccount> acctList = new List<AceAccount>();
		
		//Iterate through the list of items
		for (SObject item : items.SObjectList)
		{
			//Add the item to the account list
			acctList.add(new AceAccount((Account)item));
		}
		
		//Get the last interactions if necessary
		if (bGetLastInteraction)
		{
			getLastInteractions(acctList, userId);
		}
										
		return new AceAccountPage ( acctList , items.NextKey );
    }    
    
//	============================================================================
//	============================================================================
//	CLASS:	AceAccountListBuilder	
//	Desc:	Utility class to help build a list of AceAccounts, based on successive
//			additions of Account records, which are assumed to be sorted by
//			Account Name.
//	============================================================================
//	============================================================================
	class AceAccountListBuilder {
		
		private Integer idx;
		private String prevName;
		private Integer maxListSize;
		private AceAccount[] acctCache;
		
		private AceAccount[] acctList;
		public String nextName;
		
		
//		============================================================================
//		Method:	Constructor	
//		Desc:	Initializes variables.
//		============================================================================
		AceAccountListBuilder () {
			this ( aceUtil.MAX_COLLECTION_SIZE );
		}
		
		AceAccountListBuilder ( Integer maxListSize ) {
			this.idx = 0;
			this.prevName = '';
			this.nextName = Null;
			this.maxListSize = maxListSize;
			this.acctCache = new List<AceAccount> {};
			this.acctList = new List<AceAccount> {};
		}	
			
//		============================================================================
//		Method:	addAceAccount	
//		Desc:	Adds the specified Account record to the AceAccount list.
//				If this record would put us past the max-record limit, aborts.
//		Args:	acct - the Account record
//		Return:	True if the record was added; False otherwise.
//		============================================================================
		public Boolean addAceAccount ( AceAccount acct ) {

			if ( prevName != Null && prevName != acct.Name ) {
				acctList.addAll ( acctCache );
				acctCache.clear ();
			}
			if ( idx++ >= maxListSize ) {
				nextName = ( acctCache.isEmpty () ? acct.Name : prevName );
				return False;
			}
			prevName = acct.Name;
			acctCache.add ( acct );
			return True;
		}
		
//		============================================================================
//		Method:	addCachedAceAccounts	
//		Desc:	Adds the AceAccount records we've built up in our internal cache, to
//				the AceAccount list.
//		Args:	None.
//		Return:	None.
//		============================================================================
		public void addCachedAceAccounts () {
			acctList.addAll ( acctCache );
		}
	}
}