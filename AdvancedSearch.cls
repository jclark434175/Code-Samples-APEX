/* 
 * Name: AdvancedSearch 
 * Description: Contains methods to execute advanced search's based off multiple fields passed in.
 *				A lot of the code has been commented out (SOSL and old code).  This is in case of future
 *				reimplementation.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
global class AdvancedSearch {
    
    /**********************************************************/ 
    public class advSearchException extends Exception {}
    /**********************************************************/ 
    
    /**********************************************************/
    /**********************************************************/ 
    global enum searchObjType {ACCOUNT, CONTACT} 
    private enum searchDBType {SOSL, SOQL} 
    private static String SEARCH_DELIMITER = ',';
    // make sure that sortable field is contained in account/ContactReturnFields below
    private static String SORT_FLD_NAME = 'Name';
    private static Integer SOSL_LIMIT = 200;
    public static String searchResult;
    public static String searchErr;
    private static String[] accountReturnFields = new String[] 
    								  { 'Id', 'Name',
                                        'Website', 'Type',
                                        'BillingCountry', 'BillingCity', 'Aum__c', 'Phone',
                                        'ST_ACE__Tier__c', 'ST_Thomson_Id__c',                                            
                                        'WB_Tier__c', 'Sector__c', 'City__c', 'Cash_EQ_Tier__c',                                        
                                        'TickerSymbol' , 'ParentId', 'Parent.Phone', 'Parent.Name', 
                                        'Owner.FirstName' }; 
    private static String[] contactReturnFields = new String[] 
    								  { 'Id', 'Name',
                                        'Title', 'FirstName', 'LastName',
                                        'Phone', 'MobilePhone', 'HomePhone', 'AssistantPhone', 'OtherPhone',
                                        'Aum__c', 'Invest_Style__c', 'Regions__c',
                                        'Sectors__c', 'Sub_Sectors__c',
                                        'Email', 'MailingCity', 'MailingCountry', 'MailingPostalCode',
                                        'MailingState', 'MailingStreet', 'ST_Inactive__c',
                                        'Account.Id', 'Account.Name',
                                        'Account.BillingCity', 'Account.ST_Thomson_Id__c',
                                        'Account.ST_ACE__Tier__c', 'Account.ParentId', 'Account.Parent.Phone',
                                        'Account.Parent.Name' };
    /**
    private static String accountReturnFields = 'Id, Name'
                                    + ' , Website, Type'
                                    + ' , BillingCountry, BillingCity, Aum__c, Phone'
                                    + ' , ST_ACE__Tier__c, ST_Thomson_Id__c'                                            
                                    + ' , WB_Tier__c, Sector__c, City__c, Cash_EQ_Tier__c'
                                    + ' , TickerSymbol , ParentId, Parent.Phone, Parent.Name' 
                                    + ' , Owner.FirstName'; 
    private static String contactReturnFields = 'Id, Name'
                                    + ' , Title, FirstName, LastName '
                                    + ' , Phone, MobilePhone, HomePhone, AssistantPhone, OtherPhone '
                                    + ' , Aum__c, Invest_Style__c, Regions__c'
                                    + ' , Sectors__c, Sub_Sectors__c'
                                    + ' , Email, MailingCity, MailingCountry, MailingPostalCode'
                                    + ' , MailingState, MailingStreet, ST_Inactive__c'
                                    + ' , Account.Id, Account.Name'
                                    + ' , Account.BillingCity, Account.ST_Thomson_Id__c '
                                    + ' , Account.ST_ACE__Tier__c, Account.ParentId, Account.Parent.Phone'
                                    + ' , Account.Parent.Name';
	*/                                                                      
    private static Datetime startQueryTime;
    
   
    /**********************************************************/    
    public AdvancedSearch() {  /* constructor */ 
    /**********************************************************/
    }    
        
    /*********************************************************
    private static long msTotalQueryTime(){    
        return system.now().getTime() - startQueryTime.getTime();
    }  */
      
    /**********************************************************/
    private static string escapeChars(string searchValue) 
    /**********************************************************/   
    { 
        if (searchValue == null || searchValue.trim() == '') return '';
        searchValue = searchValue.trim();
        searchValue = String.escapeSingleQuotes(searchValue);
        return searchValue;
    }           
               
    /*********************************************************
    private static string getWhereCond(searchObjType objectType
                    , String searchString
                    , String[] arrSearchFields
                    , String startName)       
    {
        return (getWhereCond(objectType, searchString, arrSearchFields) + ' and Name >= \'' + startName + '\'');
    }*/
    
    /**********************************************************/
    private static string getWhereCond(searchObjType objectType
                    , String searchString
                    , String[] arrSearchFields) 
    /**********************************************************/   
    {
        string whereCond = '';   
        string whereCondSub = ''; 
        searchString = escapeChars(searchString);
        List<String> searchKeys = searchString.split(SEARCH_DELIMITER, 0);
        List<String> searchSubKeys;
        for (string key :searchKeys){
            if (key.trim() != '')
            { 
				key = key.trim();
 				key = '%' + key.Replace('*', '%') + '%';
				whereCondSub = '';
				for (string field :arrSearchFields){                
					if (whereCondSub != '') whereCondSub += ' or ';
					whereCondSub += field + ' like ' + '\'' + key + '\' ';
				}
				if (whereCondSub != '') { 
					whereCondSub = '(' + whereCondSub + ')';
					if (whereCond != '') whereCond += ' or	 '; //OR search is applied instead of AND
					whereCond += whereCondSub;
				}
            }
        }        
        if (whereCond != '') whereCond = '(' + whereCond + ')'; //added for OR search        
        whereCond += ' and ST_Inactive__c = False '; 
        return whereCond;
    }
    
    /*****************************************************************
    private static List<SObject> searchBySOQL(searchObjType objectType
                    , String searchString
                    , String searchFields // comma separated string
                    , String startName
                    , Integer pageSize)     
    {
        return searchBySOQL ( objectType , searchString , searchFields ,
                                Null , startName , pageSize );
    }
       
    
    private static List<SObject> searchBySOQL(searchObjType objectType
                    , String searchString
                    , String searchFields // comma separated string
                    , String extraQryClause
                    , String startName
                    , Integer pageSize)     
    {
        String[] arrSearchFields = searchFields.split(',', 0);  // get searchable fields        
        String whereCond = getWhereCond(objectType, searchString, arrSearchFields, startName);
        if ( extraQryClause != Null && extraQryClause !='') 
        {
            whereCond += ' and ( ' + extraQryClause + ' )';
        }
        
        String returnFields = (objectType == searchObjType.ACCOUNT ? accountReturnFields : contactReturnFields) ;
        List<String> arrReturnFields = returnFields.replace(' ', '').split(',', 0);

        // Query DB for records
        return AceSObject.getSObjectInfo ( objectType + '', whereCond 
                        , SORT_FLD_NAME, pageSize, arrReturnFields);
    } */ 
    
    /*********************************************************
    private static List<SObject> searchBySOSL(searchObjType objectType
                    , String searchString
                    , String startName
                    , Integer pageSize) 
    {
        return searchBySOSL ( objectType , searchString ,
                                Null , startName , pageSize );
    }
     */
    /**********************************************************
    private static List<SObject> searchBySOSL(searchObjType objectType
                    , String searchString
                    , String extraQryClause
                    , String startName
                    , Integer pageSize) 
    {
        //initialize     
        List<List<SObject>> searchList;  
        //validate search string
        if (searchString == null || searchString.trim() == '') return null;
        searchString = escapeChars(searchString);
        //Query DB
        if (pageSize > SOSL_LIMIT) pageSize = SOSL_LIMIT;
        string searchQuery = 'FIND ' + '\'' + searchString + '\' IN ALL FIELDS '
                    + ' RETURNING ' + (objectType == searchObjType.ACCOUNT ? 
                                    'Account( ' + accountReturnFields
                                    : 'Contact( '+ contactReturnFields)
                    + ' WHERE Name >= \''  + startName + '\''
                    + (extraQryClause != Null ? ' and ( ' + extraQryClause + ' )' : '')
                    + (objectType == searchObjType.CONTACT ? ' and ST_Inactive__c = False ' : '')
                    + ' ORDER BY ' + SORT_FLD_NAME 
                    + ' LIMIT ' +  pageSize + ')';
        System.debug('************SEARCH BY SOSL FOR: '+ searchQuery);        
        // execute the query    
        searchList = search.query(searchQuery) ;
        return searchList[0];   
    }  
    */
    /**********************************************************/
    private static String scopeToCoverageModeMapping(searchObjType objectType, String searchScope)
    /**********************************************************/
    {            
        
        if (objectType == searchObjType.ACCOUNT) // Account search
        {
        	// If scope is "My Account Coverage", get accounts covered by the user
        	if (searchScope == AceAccount.ACCOUNT_COVERAGE_SCOPE) 
	        { 
	            return '' + AceCoverageUtil.CoverageMode.DIRECT_ACCOUNT_COVERAGE;
	        }
        
            // If scope is "My Contact Coverage", get accounts belonging to the user's covered contacts
            if (searchScope == AceAccount.CONTACT_COVERAGE_SCOPE)
            {
                return '' + AceCoverageUtil.CoverageMode.INDIRECT_ACCOUNT_COVERAGE;
            }               
        }
      
        else if (objectType == searchObjType.CONTACT) // Contact search 
        {         	
        	// If scope is "My Account Coverage", get contacts for the covered accounts
	        if (searchScope == AceContact.ACCOUNT_COVERAGE_SCOPE)
	        { 
	            return '' + AceCoverageUtil.CoverageMode.INDIRECT_CONTACT_COVERAGE;
	        }
        
            // If scope is "My Contact Coverage", get contacts covered by the user
            if (searchScope == AceContact.CONTACT_COVERAGE_SCOPE)
            { 
                return '' + AceCoverageUtil.CoverageMode.DIRECT_CONTACT_COVERAGE;
            }
        }
       
        return ''; // no filtering to be done
    }

//  ============================================================================
//  Method:      searchRecords
//  Description: Method that will execute a generic search query based off the passed in search fields.//                        
//  Args:        objectType - Enum representing the type of object to search on
//				 userId - User to filter the coverage on if any
//               searchString - Search String to search on the associated search fields
//               searchScope - Scope that will filter the records returned (account coverage, contact coverage, none)
//               searchFields - Fields that will be searched on
//               startName - Start Name for the next page
//               pageSize - Size of the records returned
//  Return:      SObjectPage of accounts
//  ============================================================================
    public static SObjectPage searchRecords ( searchObjType objectType
								            , Id userId
								            , String searchString
								            , String searchScope // My Contact Coverage, My Account Coverage or All Accounts
								            , String searchFields // AFR list of searchable fields
								            , String startName
								            , Integer pageSize )
	{
		//We will not support SOSL querying logic in this method.  See the commented out method below		
		//Error string that will be thrown is there is a problem
		String sErr = '';		
		
		if (searchFields ==  null || searchFields.trim() == '') 
        {
            sErr = 'No valid search fields passed in.';                         
        }
		
		if (sErr != '') 
        {           
            throw new advSearchException(sErr);
        }
				
		//If no search string is passed in		
		if (searchString == '')		
		{
			//Pass back a blank SObjectPage
			return new SObjectPage();
		}		
		
		String whereClause = '';
		
		//Get the coverage mode
		String coverageMode = scopeToCoverageModeMapping(objectType, searchScope);
		//Coverage query
		String coverageQuery = '';
		//If its not blank
        if(coverageMode != '')
        {        	
            coverageQuery = AceCoverageUtil.mkInQueryClause('Id', AceCoverageUtil.getCoverage ( userId , coverageMode , Null ));
                                
            if (coverageQuery == null || coverageQuery == '')  // no coverage
            {
            	return new SObjectPage();
            }
        }
        
        //Begin constructing the whereClause
        whereClause = getWhereCond(objectType, searchString, searchFields.split(','));
        
        if (coverageQuery != '')
        {
        	whereClause += ' and ' + coverageQuery;
        }                									
        
        String[] returnFields = (objectType == searchObjType.ACCOUNT ? accountReturnFields : contactReturnFields);
        
        return AceSObject.getSObjectPage(objectType + '', whereClause, SORT_FLD_NAME, startName, pageSize, returnFields);
	}							            
								            
    
    /**********************************************************/
    /**WebService static List<SObject> searchRecords ( 
            searchObjType objectType
            , Id userId
            , String searchString
            , String searchScope // My Contact Coverage, My Account Coverage or All Accounts
            , String searchFields // AFR list of searchable fields
            , String startName
            , Integer pageSize
            )
    /*********************************************************
    {
        List<SObject> returnList;
        searchDBType searchType = searchDBType.SOQL; // default
        if (startName == null) startName = '';
        // initialize
        startQueryTime = System.now();      
        String sResult = ''; // '0 matches';
        String sErr = '';
        
        if (searchFields ==  null || searchFields.trim() == '') 
        {
            // sErr = 'Please configure searchable fields first.'; 
            // or search by SOSL?
            sResult = 'Warning: Searched only TEXT fields due to AFR not being configured.';
            searchType = searchDBType.SOSL;
        } 
        
        if (searchString == null || searchString.trim() == '') 
        {           
            sErr = 'Search term must be at least one character.'; 
            sResult = '0 matches';
        } 
        else 
        {           
            String covQryClause = Null;
            
            if(searchScope != AceAccount.ALL_COVERAGE_SCOPE)
            {
                String coverageMode = scopeToCoverageModeMapping(objectType, searchScope);
                if(coverageMode != '')
                {
                	system.debug('*************coverageMode: ' + coverageMode);
                    List<Id[]> IdLists = AceCoverageUtil.getCoverage ( userId , coverageMode , Null );
                    covQryClause = AceCoverageUtil.mkInQueryClause ( 'Id' , IdLists );                    
	                if (covQryClause == null || covQryClause == '')  // no coverage
	                {
	                	return null; // search does not return any record
	                }
                }
            }
            
            try 
            {   
                if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) 
                {
                        pageSize = aceUtil.MAX_COLLECTION_SIZE;
                }               
                
                // search DB for the records
                returnList = (searchType == searchDBType.SOSL ? 
                        searchBySOSL(objectType, searchString, covQryClause , startName, pageSize)  
                        : searchBySOQL(objectType, searchString, searchFields, covQryClause, startName, pageSize)); 
    
                if (returnList == null || returnList.size() == 0) sResult = '0 matches'; 
                else sResult += ' ' + returnList.size() + ' match(es)';                                 
            } 
            catch(SearchException e)
            {
                    sErr = 'Search error: ' + e.getMessage();
            } 
            catch(QueryException e)
            {
                    sErr = 'Query error: ' + e.getMessage();
            } 
            catch(ListException e)
            {
                    sErr = 'List error: ' + e.getMessage();
            } 
            catch(Exception e)
            {
                    sErr = e.getMessage();
            } 
            
            if (sErr != '') sResult = 'Could not complete search';
            else sResult += ' -- Query executed in: ' + msTotalQueryTime() + 'ms';
        }
        searchErr = sErr;
        searchResult = sResult;
        system.debug('**************** sResult: ' + sResult);
        if (sErr != '') 
        {
            system.debug('**************** sErr: ' + sErr);
            throw new advSearchException(sErr);
        }
        return returnList;  
    } */
}