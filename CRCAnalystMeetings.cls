/** 
 * Name: CRCAnalystMeetings 
 * Description: Return a list of Events for the Analyst Meetings grid in CRC
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCAnalystMeetings 
{	
	/*
	!!!!!!!!!!!!
	note
	ST_GEM_User_Type__c is missing in the org so CRCUtil is not working. Please fix.
	Alex.
	!!!!!!!!!!!
	
	
	
	//	============================================================================
	//	Method:	getAnalystMeetings	
	//	Desc:	Gets all the Events that have a user with Gem user type = 'Analyst'
	//	Return:	allMeetingsList - A List with Event objects
	//	============================================================================
	public List<Event> getAnalystMeetings(String AccountID)
	{
		List<Event> analystMeetings = new List<Event>();
		List<Event> allTheMeetings = this.getAllMeetings(AccountID);
		List<User> analystUsers = CRCUtil.getUserListByGEMType('Analyst');
		for ( Event meetingObj : allTheMeetings)
		{
			for(User userObj : analystUsers)
			{
				if(meetingObj.OwnerId == userObj.Id)
				{
					analystMeetings.add(meetingObj);
				}
			}
		}
		return analystMeetings;
	}
	
	//	============================================================================
	//	Method:	getAllMeetings	
	//	Desc:	Gets all the Events 
	//	Return:	allMeetingsList - A List with Event objects
	//	============================================================================
	public List<Event> getAllMeetings(String AccountID)
	{
		List<Event> allMeetingsList = new List<Event>();
		for ( Event meetingEvent : [select e.Who.Name, e.WhoId, e.Type, e.Owner.Name, e.Owner.Id,e.OwnerId, e.ActivityDate 
							from Event e where e.Type = 'Meeting' and e.WhoId = :AccountID order by e.ActivityDate]) 
		{
			allMeetingsList.add( meetingEvent );
		}
		return allMeetingsList;
	}
	*/
}