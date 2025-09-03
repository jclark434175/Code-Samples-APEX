/** 
 * Name: CRCAnalystMeetings 
 * Description: Return a list of Events for the Analyst Meetings grid in CRC
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 public class CRCMarketingEvents 
 {
	
	//	============================================================================
	//	Method:	getMarketingEvents	
	//	Desc:	Gets all the Marketing_Event_Meeting__c that are from Account ID
	//	Return:	 - A List with Marketing_Event_Meeting__c objects
	//	============================================================================
	public List<Marketing_Event_Meeting__c> getMarketingEvents(String AccountID)
	{
		List<Marketing_Event_Meeting__c> allEvents = new List<Marketing_Event_Meeting__c>();
		
		for ( Marketing_Event_Meeting__c event :[select m.Contact__c, m.Contact__r.Id, m.Contact__r.Name, m.Marketing_Event__c, 
													m.Marketing_Event__r.Event_Date__c, m.Marketing_Event__r.Id, 
													m.Marketing_Event__r.Name, m.Status__c, m.Time__c, m.Venue__c 
												from Marketing_Event_Meeting__c m 
												where m.Contact__r.AccountId = :AccountID 
												order by  m.Marketing_Event__r.Event_Date__c ]) 
		{
			allEvents.add( event );
		}
		
		return allEvents;
	}
	
	

}