/** 
 * Name: CRCGridsWebServices 
 * Description: All Web methods for flex CRC Grids 
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
global class CRCGridsWebServices 
{
	
	//	============================================================================
	//	Static Method:	getAccountCoverage	
	//	Desc:	Gets all the Account_Coverage__c
	//	Return:	coverageList - A List with all the Account_Coverage__c objects for this Account Id
	//	============================================================================
	webservice static List<Account_Coverage__c> getAccountCoverage(String AccountID )
	{
		CRCAccountCoverage obj = new CRCAccountCoverage();
		return obj.getAccountCoverage(AccountID);
	}
	
	//	============================================================================
	//	Static Method:	getStockInterestHoldings	
	//	Desc:	Gets all the Interest__c objects for this Account ID
	//	Return:	 A List with Interest__c objects
	//	============================================================================
	webservice static List<Interest__c> getStockInterestHoldings(String AccountID )
	{
		CRCStockInterestHoldings obj = new CRCStockInterestHoldings();
		return obj.getStockInterestHoldings(AccountID);
	}
	
	
	//  ============================================================================
    //  Method:         getContacts - returns a list of Contacts for the passed Account ID
    //  Description:    See CRCContacts.getContacts
    //  ============================================================================
    webservice static List<Contact> getContacts(String AccountID) 
    {
    	CRCContacts obj = new CRCContacts();
        return obj.getContacts ( AccountID );
    }
    
    
    //	============================================================================
	//	Method:	webservice method getActivityHistory	
	//	Desc:	Gets all the Task objects for this Account Id
	//	Return:	 A List with Task objects
	//	============================================================================
	webservice static List<Task> getActivityHistory(String AccountID )
	{
		CRCActivityHistory obj = new CRCActivityHistory();
		return obj.getAllTasks(AccountID);
	}
	
	
	//	============================================================================
	//	Method:	webservice method getMarketingEvents	
	//	Desc:	Gets all the Marketing_Event_Meeting__c objects for this Account Id
	//	Return:	 A List with Marketing_Event_Meeting__c objects
	//	============================================================================
	webservice static List<Marketing_Event_Meeting__c> getMarketingEvents(String AccountID )
	{
		CRCMarketingEvents obj = new CRCMarketingEvents();
		return obj.getMarketingEvents(AccountID);
	}
	
	
	/*
	
	//	============================================================================
	//	Method:	getAnalystMeetings	
	//	Desc:	Gets all the Events that have a user with Gem user type = 'Analyst' 
	//            for the passed AccountID
	//	Return:	allMeetingsList - A List with Event objects
	//	============================================================================
	//webservice static List<Event> getAnalystMeetings(String AccountID )
	//{
		//CRCAnalystMeetings obj = new CRCAnalystMeetings();
		//return obj.getAnalystMeetings(AccountID);
	//}
	
	
	//	============================================================================
	//	Method:	webservice method  getAccountCoverage	
	//	Desc:	Gets all the Account_Coverage__c
	//	Return:	coverageList - A List with all the Account_Coverage__c objects for this Account Id
	//	============================================================================
	webservice static List<Account_Coverage__c> getAccountCoverage(String AccountID )
	{
		CRCAccountCoverage obj = new CRCAccountCoverage();
		return obj.getAccountCoverage(AccountID);
	}*/
}