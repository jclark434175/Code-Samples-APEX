/*
 * Name:        cmsUtil
 *
 * Description: Utility methods, etc., in support of CMS web services.
 *               
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM Inc.
 */
 
public class cmsUtil {
	
//	Constants	
	private static final Integer LIST_SIZE = 1000;
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
	public static list<Meeting> getRegistrantSpeakerMeetings(String registrantId) {		
		map<Id, Meeting> mMeeting = new map<Id, Meeting>();
		set<Id> speakerMeetings = new set<Id>();
		set<Id> meetingIds = new set<Id>();

//		get meeting details from meeting participation
//		where registrant is a speaker or non-speaker									
		for(Meeting_Participation__c mp: [select Meeting__r.Status__c, Meeting__r.Start_Time__c, 
													Meeting__r.Start_Mins__c, Meeting__r.Start_Meridiem__c, 
													Meeting__r.Start_Hr__c, Meeting__r.End_Time__c, 
													Meeting__r.End_Mins__c, Meeting__r.End_Meridiem__c, 
													Meeting__r.End_Hr__c, Meeting__r.Date__c, Meeting__c,
													Type__c,
													Registrant__r.Role__c, 
													Registrant__r.Id,
													Registrant__r.Name,
													Registrant__r.Contact__r.Id,
													Registrant__r.Contact__r.FirstName,
													Registrant__r.Contact__r.LastName,
													Registrant__r.Account__r.Id,
													Registrant__r.Account__r.Name,
													Registrant__r.Account__r.TickerSymbol,													
													Meeting__r.Meeting_Room__r.Name,
													Meeting__r.Meeting_Room__r.Hotel__r.Name
											from Meeting_Participation__c
											where Registrant__c = :registrantId											
											]) {
//				put meeting details in meeting collection
//				assign non-meeting details outside the constructor													
				Meeting aMeeting = new Meeting(mp.Meeting__r);
				aMeeting.meetingRoomName = mp.Meeting__r.Meeting_Room__r.Name;
				aMeeting.hotelName = mp.Meeting__r.Meeting_Room__r.Hotel__r.Name;
				aMeeting.registrant = new Registrant(mp.Registrant__r);
				aMeeting.registrant.cmsContact = new CmsContact(mp.Registrant__r.Contact__r);
				aMeeting.registrant.cmsAccount = new CmsAccount(mp.Registrant__r.Account__r);
				aMeeting.registrant.cmsAccount.symbol = mp.Registrant__r.Account__r.TickerSymbol;
//				attendeeRole holds the role of the registrant at meeting participation level
//				whether registrant is a Speaker or a non-Speaker				
				aMeeting.attendeeRole = mp.Type__c; 
				mMeeting.put(mp.Meeting__c, aMeeting);
				
				meetingIds.Add(mp.Meeting__c);
		}

		if (meetingIds.size() > 0) {
//			meeting participations other than the parameter registrant			
			for(Meeting_Participation__c mp: [select Meeting__c, Type__c,
													Registrant__r.Role__c, 
													Registrant__r.Id,
													Registrant__r.Name,
													Registrant__r.Contact__r.Id,
													Registrant__r.Contact__r.FirstName,
													Registrant__r.Contact__r.LastName,
													Registrant__r.Account__r.Id,
													Registrant__r.Account__r.Name,
													Registrant__r.Account__r.TickerSymbol
											from Meeting_Participation__c
											where Meeting__c in :meetingIds
											and Registrant__c != :registrantId]) {
//				get the meeting from the collection
				Meeting aMeeting = mMeeting.get(mp.Meeting__c);
				Registrant aRegistrant = new Registrant(mp.Registrant__r);
				aRegistrant.cmsContact = new CmsContact(mp.Registrant__r.Contact__r);
				aRegistrant.cmsAccount = new CmsAccount(mp.Registrant__r.Account__r);
				aRegistrant.cmsAccount.symbol = mp.Registrant__r.Account__r.TickerSymbol;

//				if participant type is not speaker push it into 'attendees' else into 'speakers'
				if (mp.Type__c != aceCMSCommon.Type_Speaker_Public && mp.Type__c != aceCMSCommon.Type_Speaker_Private) {
					aMeeting.attendees.Add(aRegistrant);
					aMeeting.hasAttendees = true;
				}
				else {
					aMeeting.speakers.Add(aRegistrant);
				}				
				mMeeting.put(mp.Meeting__c, aMeeting);
			}												
		}	
		
		return mMeeting.values();
	}
	/*
	public static list<String> Test(String registrantId) {
		list<Meeting> mMeeting = getRegistrantSpeakerMeetings(registrantId);
		list<string> returnString = new list<String>();
		for(Meeting m: mMeeting) {
			String text = '';
			String tab = '\t';
			String creturn = '\r';
			
			text += m.id + tab + m.registrant.name + tab + m.attendeeRole + creturn;
			
			if (m.speakers.size() > 0) {
				text += tab + 'other speakers: ' + creturn;			
				for(Registrant r: m.speakers) {
					text += tab + r.name + creturn; 
				}
			}
			
			if (m.attendees.size() > 0) {
				text += tab + 'attendees: ' + creturn;			
				for(Registrant r: m.attendees) {
					text += tab + r.name + creturn; 
				}
			}			
			returnString.Add(text);
		}
		return returnString;		
	}
	*/
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
	public static list<list<Registrant>> getRegistrantsAvailability(String[] registrantIds, String conferenceId) {
		list<list<Registrant>> registrants = new list<list<Registrant>>();
		list<Registrant> cRegistrants = new list<Registrant>();
		set<id> accountIds = new set<id>();
		set<id> setRegistrantIds = new set<id>();
		map<Id, Presenting_Company__c> mapPresentingCompanies = new map<Id, Presenting_Company__c>();
		Integer counter = 0;

		if (registrantIds != null)  {
			for( Integer i=0; i < registrantIds.size(); i++ ) { setRegistrantIds.add(registrantIds[i]); }
		}
		
		if ( conferenceId == null || conferenceId == '' ) {
			Registrant errorRegistrant = new Registrant();
			errorRegistrant.error = 'Provide conference id in the parameter list';
			cRegistrants.add( errorRegistrant );
			registrants.add(cRegistrants);
			return registrants;
		}
		
		map<Id, Registrant__c> mapRegistrants = new map<Id, Registrant__c>();
		
		for(Registrant__c reg : [select Id, Name, Role__c, 
											Attendance_Start_Date__c, Attendance_End_Date__c, 
											Account__r.Id, Account__r.Name,
											Contact__r.Id, Contact__r.FirstName, Contact__r.LastName
								 	from Registrant__c
									where Conference__c = :conferenceId]) {
			if (setRegistrantIds == null || setRegistrantIds.size() == 0 ) {									 	
				mapRegistrants.put(reg.Id, reg);
				accountIds.add(reg.Account__r.Id);
			}
			else if (setRegistrantIds.contains( reg.id) ) {
				mapRegistrants.put(reg.Id, reg);
				accountIds.add(reg.Account__r.Id);
			}
		}
		
		
		for ( Presenting_Company__c pc : [	select Id, Presentation_Time__c, Account__c
											from Presenting_Company__c
											where Account__c in :accountIds
											and Conference__c = :conferenceId] ) {
			mapPresentingCompanies.put( pc.Account__c, pc);
		}

		for(Registrant__c reg: mapRegistrants.values()) {									 
			if (counter == LIST_SIZE) {
				registrants.add(cRegistrants.clone());
				cRegistrants.clear(); 
				counter = 0;
			}
			
			Presenting_Company__c pCompany = mapPresentingCompanies.get( reg.Account__r.Id );
			String presentationTime = '';
			if (pCompany != null) { presentationTime = pCompany.Presentation_Time__c; }
			
			Registrant aRegistrant = new Registrant(reg);
			aRegistrant.attendanceStartDate = reg.Attendance_Start_Date__c;
			aRegistrant.attendanceEndDate = reg.Attendance_End_Date__c;
			aRegistrant.cmsAccount = new CmsAccount(reg.Account__r);				
			aRegistrant.cmsAccount.presentationTime = presentationTime;
			aRegistrant.cmsContact = new CmsContact(reg.Contact__r);
			cRegistrants.Add(aRegistrant);	
			counter++;				
		}
//		if registrantIds is null or size is zero
//		then get all the registrants of the conference		
		/*if (registrantIds == null || registrantIds.Size() == 0 ) {
			for(Registrant__c reg : [select Id, Name, Role__c, 
											Attendance_Start_Date__c, Attendance_End_Date__c, 
											Account__r.Id, Account__r.Name,
											Contact__r.Id, Contact__r.FirstName, Contact__r.LastName
									 from Registrant__c
									 where Conference__c = :conferenceId]) { 
									 
			for(Registrant__c reg: mapRegistrants.values()) {									 
				if (counter == LIST_SIZE) {
					registrants.add(cRegistrants.clone());
					cRegistrants.clear(); 
					counter = 0;
				}
				
				Presenting_Company__c pCompany = mapPresentingCompanies.get( reg.Account__r.Id );
				String presentationTime = '';
				if (pCompany != null) { presentationTime = pCompany.Presentation_Time__c; }
				
				Registrant aRegistrant = new Registrant(reg);
				aRegistrant.attendanceStartDate = reg.Attendance_Start_Date__c;
				aRegistrant.attendanceEndDate = reg.Attendance_End_Date__c;
				aRegistrant.cmsAccount = new CmsAccount(reg.Account__r);				
				aRegistrant.cmsAccount.presentationTime = presentationTime;
				aRegistrant.cmsContact = new CmsContact(reg.Contact__r);
				cRegistrants.Add(aRegistrant);	
				counter++;				
			}	
		}		
		else {			
			for(Registrant__c reg : [select Id, Name, Role__c, 
											Attendance_Start_Date__c, Attendance_End_Date__c, 
											Account__r.Id, Account__r.Name,
											Contact__r.Id, Contact__r.FirstName, Contact__r.LastName
									 from Registrant__c
									 where Id in :registrantIds]) { 
			for(Registrant__c reg : mapRegistrants.values() ) {									 
				if (counter == LIST_SIZE) {
					registrants.add(cRegistrants.clone());
					cRegistrants.clear(); 
					counter = 0;				
				}
				Registrant aRegistrant = new Registrant(reg);
				aRegistrant.attendanceStartDate = reg.Attendance_Start_Date__c;
				aRegistrant.attendanceEndDate = reg.Attendance_End_Date__c;
				aRegistrant.cmsAccount = new CmsAccount(reg.Account__r); 
				aRegistrant.cmsContact = new CmsContact(reg.Contact__r);
				cRegistrants.Add(aRegistrant);		
				counter++;
			}				 
		}
		*/
		registrants.Add(cRegistrants.clone());		
		return registrants;
	}	
//	============================================================================
//	Method:	getTimeslotByConference
//	Detail:	Gives the timeslots for the given confernece id.
//	Args:	String: conferenceId
//	Return:	Array of TimeSlot object
//	Case No: 3703
//	Task Id: TA239
//	============================================================================			
	public static list<TimeSlot> getTimeslots(String[] timeSlotTemplateId) {		
		list<TimeSlot> returnList = new list<TimeSlot>();		
					
		for(Timeslot__c slot: [select Start_Mins__c, End_Mins__c,  
										Start_Hr__c, End_Hr__c, 
										Start_Time__c, End_Time__c, 
										Start_Meridiem__c, End_Meridiem__c, 										
										Timeslot_Template__c, Timeslot_Template__r.Description__c  
										from Timeslot__c
										where Timeslot_Template__c in :timeSlotTemplateId]) {
											
				TimeSlot aTimeSlot = new TimeSlot(slot);
				aTimeSlot.description = slot.Timeslot_Template__r.Description__c;
				returnList.Add(aTimeSlot);
		}		
		return returnList;
	}
		
//	=====================================================================================
//	Method:	getConferenceInfo
//	Detail:	Takes in a Registrant ID, brings in the Conference Info 
//	Args:	array of conference Ids
//	Return:	Array of all conferences
//	Case No: 3725 
//	Task Id: TA495
//	====================================================================================	
	public static list<Conference> getConferenceInfo(String[] conferenceIds) {
		list<Conference> conferences = new list<Conference>();		
		for(Conference__c conf : [select Name, Website__c, Web_Registration_Enabled__c, 
										Timeslot_Template__c, Start_Date__c, Registration_Availability__c, 
										Pre_Registration_Deadline__c, Open_To_Pre_Registration__c, 
										End_Date__c, Id 
										from Conference__c
										where Id in :conferenceIds]) {
			Conference aConference = new Conference(conf);
			conferences.Add(aConference);
		}
		return conferences;
	}
	
//	=====================================================================================
//	Method:	searchOpenConferences
//	Detail:	Takes in a string value and does a starts with search on open conferences
//	Args:	string conference name
//	Return:	Array of all conferences
//	====================================================================================	
	public static list<Conference> searchOpenConferences(String conferenceName) 
	{
		conferenceName = conferenceName+'%';
		
		list<Conference> conferences = new list<Conference>();		
		for(Conference__c conf : [select Name, Website__c, Web_Registration_Enabled__c, 
										Timeslot_Template__c, Start_Date__c, Registration_Availability__c, 
										Pre_Registration_Deadline__c, Open_To_Pre_Registration__c, 
										End_Date__c, Id 
										from Conference__c
										where Registration_Availability__c='Open' and Name like :conferenceName]) {
			Conference aConference = new Conference(conf);
			conferences.Add(aConference);
		}
		return conferences;
	}
	
//	=====================================================================================
//	Method:	searchAllConferences
//	Detail:	Takes in a string value and does a starts with search on all conferences
//	Args:	string conference name
//	Return:	Array of all conferences
//	====================================================================================	
	public static list<Conference> searchAllConferences(String conferenceName) 
	{
		conferenceName = conferenceName+'%';
		
		list<Conference> conferences = new list<Conference>();		
		for(Conference__c conf : [select Name, Website__c, Web_Registration_Enabled__c, 
										Timeslot_Template__c, Start_Date__c, Registration_Availability__c, 
										Pre_Registration_Deadline__c, Open_To_Pre_Registration__c, 
										End_Date__c, Id 
										from Conference__c
										where Name like :conferenceName]) {
			Conference aConference = new Conference(conf);
			conferences.Add(aConference);
		}
		return conferences;
	}
	
	
//	=====================================================================================
//	Method:	getHotelMeetingRooms
//	Detail:	Returns hotel meeting rooms for given conference id 
//	Args: conference Id
//	Return:	Array of all HotelMeetingRoom
//	Case No: 
//	Task Id: TA295 
//	====================================================================================	
	public static list<HotelMeetingRoom> getHotelMeetingRooms(String conferenceId) {
		list<HotelMeetingRoom> meetingRooms = new list<HotelMeetingRoom>();
		
		for(Meeting_Room_Booked__c mrb : [select Hotel_Meeting_Room__r.id, 
												 Hotel_Meeting_Room__r.Name,
												 Hotel_Meeting_Room__r.Type__c,
												 Hotel_Meeting_Room__r.Hotel__c,
												 Hotel_Meeting_Room__r.Hotel__r.Name
										 from Meeting_Room_Booked__c
										 where Conference__c = :conferenceId]) {
			HotelMeetingRoom aHmr = new HotelMeetingRoom(mrb.Hotel_Meeting_Room__r);
			aHmr.hotelName = mrb.Hotel_Meeting_Room__r.Hotel__r.Name;
			meetingRooms.add(aHmr);
		}
		return meetingRooms;
	}
}