/* 
 * Name: Meeting 
 * Description: Contains details of a meeting
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM Inc.
 */
 
global class Meeting {
	webservice String id; 
	webservice String startTime; 
	webservice String endTime; 
	webservice Double startHour; 
	webservice String startMeridiem;
	webservice Double startMinutes;
	webservice Double endHour;
	webservice String endMeridiem;
	webservice Double endMinutes;
	webservice Date meetingDate;
	webservice Registrant registrant;
	webservice String hotelName;
	webservice String meetingRoomName;
	
//	Non-entity fields

//	registrant's role in the meeting participation level
	webservice String attendeeRole;	
	webservice boolean hasAttendees = false;

//	speakers and attendees refer to other speakers and attendees other than 'registrant'	
	webservice list<Registrant> speakers;
	webservice list<Registrant> attendees;
	
	public Meeting(Meeting__c aMeeting) {
		id = aMeeting.Id;
		startTime = aMeeting.Start_Time__c;
		endTime = aMeeting.End_Time__c;
		startHour = aMeeting.Start_Hr__c;
		startMeridiem = aMeeting.Start_Meridiem__c;
		startMinutes = aMeeting.Start_Mins__c;
		endHour = aMeeting.End_Hr__c;
		endMeridiem = aMeeting.End_Meridiem__c;
		endMinutes = aMeeting.End_Mins__c;
		meetingDate = aMeeting.Date__c;
		registrant = new Registrant();	
		speakers = new list<Registrant>();
		attendees = new list<Registrant>();
	}	
}