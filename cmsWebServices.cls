/* 
 * Name: cmsWebServices 
 * Description: 
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM Inc.
 */
 
global class cmsWebServices {

//	Constants	
	private static final Integer LIST_SIZE = 1000;
	
//	============================================================================
//	Method:	getTimeslotByConference
//	Detail:	Gives the timeslots for the given confernece id.
//	Args:	String: conferenceId
//	Return:	Array of TimeSlot object
//	Case No: 3703
//	Task Id: TA239
//	============================================================================			
	webservice static list<TimeSlot> getTimeslots(String[] timeSlotTemplateId) {
		return cmsUtil.getTimeslots(timeSlotTemplateId);
	} 
	
//	=====================================================================================
//	Method:	getRegistrantSpeakerMeetings
//	Detail:	3704 - Takes in a Registrant ID and gives the Meetings where the registrant is a speaker  
//			and weather the meeting has attendee's or not(boolean)
//			3714 - Takes in a Registrant ID and gives the Meetings where the registrant's 
//			role type is 'Speaker Public' or 'Speaker Private' and the registrant is an Attendee  
//	Args:	String: registrantId
//	Return:	Array of Meetings
//	Case No: 3704, 3714
//	Task Id: TA241, TA275
//	====================================================================================
	webservice static list<Meeting> getRegistrantSpeakerMeetings(String registrantId) {		
		return cmsUtil.getRegistrantSpeakerMeetings(registrantId);
	}	
	
//	=====================================================================================
//	Method:	getRegistrantsAvailability
//	Detail:	Takes in a Registrant ID and gives the registrant's information and their attendance 
//			start and end date  
//	Args:	array of registrantIds and conference Id.
//	Return:	Array of all registrants of the conference, if registrantIds is null/empty
//			Array of registrants, if registrantIds is not null/empty
//	Case No: 3713 
//	Task Id: TA240
//	====================================================================================
	webservice static list<list<Registrant>> getRegistrantsAvailability(String[] registrantIds, String conferenceId) {			
		return cmsUtil.getRegistrantsAvailability(registrantIds, conferenceId);
	}
//	=====================================================================================
//	Method:	getConferenceInfo
//	Detail:	Takes in a Registrant ID, brings in the Conference Info 
//	Args:	array of conference Ids
//	Return:	Array of all conferences
//	Case No: 3725 
//	Task Id: TA495 
//	====================================================================================	
	webservice static list<Conference> getConferenceInfo(String[] conferenceIds) {		
		return cmsUtil.getConferenceInfo(conferenceIds);
	}

//  ============================================================================
//  Method:         insertRegistrants
//  Description:    Inserts the given list of registrant records.         
//  Args:           Array of Registrant records
//  Return:         AceWSResultList containing results of insert                        
//  ============================================================================    
    webservice static AceWSResultList insertRegistrants ( Registrant__c[] registrants ) {
        return aceUtil.upsertRecords ( registrants, false );
    }
	

//	=====================================================================================
//	Method:	searchAllConferences
//	Detail:	Search all conferences by name using a starts with search.  This webservice call will be executed following sharing rules
//	Args:	Conference name
//	====================================================================================
	webservice static list<Conference> searchAllConferences (String conferenceName) {
		list<Conference> result = cmsUtilWithSharing.searchAllConferences( conferenceName );
		return result;
	}

//	=====================================================================================
//	Method:	searchOpenConferences
//	Detail:	Search open conferences by name using a starts with search. This webservice call will be executed following sharing rules
//	Args:	Conference name
//	====================================================================================
	webservice static list<Conference> searchOpenConferences (String conferenceName) {
		list<Conference> result = cmsUtilWithSharing.searchOpenConferences( conferenceName );
		return result;
	}
	
	
//	============================================================================
//	Method:	insertMeetings
//	Desc:	Inserts Meeting__c records per the specified list of meeting records.	
//	Args:	MeetingList - list of Meeting__c records to insert.
//	Return:	List of inserted Meeting Ids, blank for failed Meetings.
//	============================================================================
	webservice static AceWSResultList insertMeetings ( Meeting__c[] meetingsToInsert ) {
		AceWSResultList result = aceUtil.upsertRecords ( meetingsToInsert );
		return result;
	}

//	============================================================================
//	Method:	updateMeetings
//	Desc:	Updates Meeting__c records per the specified list of meeting records.
//	Args:	MeetingList - list of Meeting__c records to insert.
//	Return:	List of inserted Meeting Ids, blank for failed Meetings.
//	============================================================================
	webservice static AceWSResultList updateMeetings ( Meeting__c[] meetingsToUpdate ) {
		AceWSResultList result = aceUtil.updateRecords ( meetingsToUpdate );
		return result;
	}
	
//	============================================================================
//	Method:	insertMeetingParticipions
//	Desc:	Inserts Meeting_Participation__c records per the specified list 
//			of records.	
//	Args:	mpList - list of Meeting_Participation__c records to insert.
//	Return:	AceWSResultList record containing results of insert.
//	============================================================================
	webservice static AceWSResultList insertMeetingParticipations ( 
											Meeting_Participation__c[] mpList ) {
		AceWSResultList result = aceUtil.upsertRecords ( mpList );
		return result;
	}
	
//	============================================================================
//	Method:	deleteRecords
//	Desc:	Deleting records using ids.
//	Args:	Salesforce record ids.
//	Return:	AceWSResultList true if success, false otherwise.
//	============================================================================
	webservice static AceWSResultList deleteRecords ( Id[] sObjIds ) {
		AceWSResultList result = aceUtil.deleteRecords ( sObjIds );
		return result;
	}	
//	=====================================================================================
//	Method:	getHotelMeetingRooms
//	Detail:	Returns hotel meeting rooms for given conference id 
//	Args: conference Id
//	Return:	Array of all HotelMeetingRoom
//	Case No: 
//	Task Id: TA295 
//	====================================================================================	
	webservice static list<HotelMeetingRoom> getHotelMeetingRooms(String conferenceId) {
		return cmsUtil.getHotelMeetingRooms(conferenceId);
	}
//	=====================================================================================
//	Method:	insertMeetingRoomsBooked
//	Detail:	Inserts Meeting_Room_Booked__c records per the specified list of records.	
//	Args:	MeetingRoomBookedList - list of Meeting_Room_Booked__c records to insert. 
//	Task Id: TA296 
//	====================================================================================
	webservice static AceWSResultList insertMeetingRoomsBooked (Meeting_Room_Booked__c[] mrbList ) {
		AceWSResultList result = aceUtil.upsertRecords ( mrbList );
		return result;
	}
//	=====================================================================================
//	Method:	updateMeetingRoomsBooked
//	Detail:	Updates Meeting_Room_Booked__c records per the specified list of records.	
//	Args:	MeetingRoomBookedList - list of Meeting_Room_Booked__c records to insert. 
//	Task Id: TA296 
//	====================================================================================
	webservice static AceWSResultList updateMeetingRoomsBooked (Meeting_Room_Booked__c[] mrbList ) {
		AceWSResultList result = aceUtil.updateRecords ( mrbList );
		return result;
	}	
}