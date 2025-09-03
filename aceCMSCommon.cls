/*
 * Name: aceCMSCommon
 * Description: Contains common functions and constants to be used in other ACE CM specific Triggers and Packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */
global class aceCMSCommon {
	
	/*
	 * constants 
	 */ 
	 
	//Namespace name
	public static final String CMS_NAMESPACE = '';
	
	// Conference Group
	public static final String CONFERENCE_GROUP_NAME = 'ST_Conference Group';
	
	// Registrant Speaker Roles and Meeting Participation Types
	public static final String TYPE_SPEAKER_PUBLIC = 'Speaker Public';
	public static final String TYPE_SPEAKER_PRIVATE = 'Speaker Private';
	public static final String ENTITY_NAME_AVAILABLE_HOTEL_MEETING_ROOM =  CMS_NAMESPACE + 'Meeting_Room_Booked__c';
	public static final String ENTITY_NAME_AVAILABLE_HOTEL_SLEEPING_ROOM =  CMS_NAMESPACE + 'Available_Hotel_Sleeping_Room__c';
	public static final String ENTITY_NAME_CONFERENCE =  CMS_NAMESPACE + 'Conference__c';
	public static final String ENTITY_NAME_HOTEL =  CMS_NAMESPACE + 'Hotel__c';
	public static final String ENTITY_NAME_HOTEL_BOOKING = CMS_NAMESPACE + 'Hotel_Booking__c';
	public static final String ENTITY_NAME_HOTEL_MEETING_ROOM =  CMS_NAMESPACE + 'Hotel_Meeting_Room__c';
	public static final String ENTITY_NAME_MEETING = CMS_NAMESPACE + 'Meeting__c';
	public static final String ENTITY_NAME_MEETING_PARTICIPATION = CMS_NAMESPACE + 'Meeting_Participation__c';
	public static final String ENTITY_NAME_MEETING_REQUEST = CMS_NAMESPACE + 'Meeting_Request__c';
	public static final String ENTITY_NAME_PARTICIPATING_ACCOUNT =  CMS_NAMESPACE + 'Presenting_Company__c';
	public static final String ENTITY_NAME_REGISTRANT =  CMS_NAMESPACE + 'Registrant__c';
	public static final String ENTITY_NAME_SPECIAL_EVENT =  CMS_NAMESPACE + 'Special_Event__c';
	public static final String ENTITY_NAME_SPECIAL_EVENT_REGISTRATION =  CMS_NAMESPACE + 'Special_Event_Registration__c';
		
	// error messags
	public static final String ERROR_MESSAGE_SPECIAL_EVENT_REGISTRATION_CONFERENCE = 'The Registrant and Special Event are not assoicated with the same Conference.';
	public static final String ERROR_MESSAGE_SPECIAL_EVENT_REGISTRATION_DUPLICATE = 'This Registrant/Contact selected has already been registered for this Special Event.';
	public static final string ERROR_MESSAGE_PARTICIPATING_ACCOUNT_DUPLICATE = 'The selected Account has already been associated to this Conference.';
	public static final String ERROR_MESSAGE_WHILE_DELETE = 'Error while deleting records. Please contact your system administrator.';
	public static final String ERROR_MESSAGE_REGISTRANT_DUPLICATE = 'The Contact has already been associated to this Conference.';
	public static final String ERROR_MESSAGE_AVAIL_HOT_SLP_RM_DUPL = 'Sleeping Rooms for this Hotel, Date and Type have already been associated to this Conference.';
	public static final String ERROR_MESSAGE_SPEAKER_DELETE = 'Cannot delete speaker. At least one speaker is required per meeting.';
	public static final String ERROR_MESSAGE_MEETING_ROOM_ALREADY_BOOKED = 'Meeting Room conflict: Room is already booked';
	public static final String ERROR_MESSAGE_SPEAKER_ALREADY_BOOKED = 'This meeting conflicts with another at ';
	
	//Meeting Request Error Messages
	public static final String ERROR_MESSAGE_MEETING_REQUEST_ALREADY_MADE = 'A meeting request has already been made for this Registrant and Participating Account.';
	public static final String ERROR_MESSAGE_PA_NOT_ASSOCIATED_TO_CONFERENCE = 'The selected Participating Account is not associated with this Conference.';	  
  	  	
  	// Standard Error
  	public static final String ERROR_MESSAGE_STANDARD = 'An unexpected error occured. Please contact your system administrator.';
   	/*
 	 * Name: IsConferenceUser
	 * Description: Check if the user belongs to the Conference Group.
	 * @params: none
	 * @returns: boolean - true if user is in the group, false if not
	 * Notes: 
 	 */ 
 	public static boolean IsConferenceUser() {
		Id userId = UserInfo.getUserId ();
		return IsConferenceUser ( userId );
 	}

	/*
 	 * Name: IsConferenceUser
	 * Description: Check if the user passed in belongs to the Conference Group.
	 * @params: @userId - the user id in question
	 * @returns: boolean - true if user is in the group, false if not
	 * Notes: 
 	 */ 
  	webservice static boolean IsConferenceUser( Id userId ) {
		
		boolean result = false;
		
	    list<Group> grps = [ select Id from Group where Name = :CONFERENCE_GROUP_NAME and Type = :'Regular' ];
	    
	    if (grps.Size() > 0) {
	    	Integer grp_mem_count = [select Count() 
	    								from GroupMember
        	                     		where UserOrGroupId = :userId 
        	                     		and GroupId = :grps[ 0 ].Id ];		
    		result = ( grp_mem_count > 0 );
	    }	    
	    return result;	    
	}
  	 
  	/*
 	 * Name: deleteSpeaker
	 * Description: Check if the user passed in belongs to the Conference Group and deletes the given Meeting Participation record
	 * @params: @userId - the user id in question, @meetingParticipationId - the Meeting Participation record to delete
	 * @returns: boolean - true if user is in the group, false if not
	 * Notes:
 	 */  	
  	webservice static Integer deleteSpeaker(Id userId, String meetingParticipationId, Id meetingId)
  	{
  		Integer SUCCESS = 1;
  		Integer ERROR = -1;
  		Integer ERROR_INSUFFICIENT_PRIVILEGES = -2;
  		Integer ERROR_ONE_SPEAKER_REMAINING = -3;
  		Integer successResult = ERROR;
  		
  		if (IsConferenceUser(userId)) {
  			// do not allow speaker deletion if there is only one
  			Integer speakerCount = [select count()
					  				from Meeting_Participation__c
									where Meeting__c = :meetingId
					  				and (Type__c = :Type_Speaker_Public or Type__c = :Type_Speaker_Private)
									and Id <> :meetingParticipationId];			
			
			// ok to delete, speaker remaining			 						
			if (speakerCount > 0) {				
	  			try {
					delete [select Id
			  			 	from Meeting_Participation__c
			  			 	where Id = :meetingParticipationId];					
					successResult = SUCCESS;
	  			}
	  			// error deleting speaker
	  			catch(Exception e) {
					successResult = ERROR;
	  			}
			}
			else {
				successResult = ERROR_ONE_SPEAKER_REMAINING;
			}
  		}
  		else {
  			successResult = ERROR_INSUFFICIENT_PRIVILEGES;
  		}
  		return successResult;
  	}  	  	
	
 //	--------------------------------------------------------------------------------  
 //	Name: cmpTimes
 // Description:  Compares the two specified HH:MM [AP]M times.
 //	Params: time1
 //	        time2
 // Returns: -1 if time1 is earlier than time2, 1 if time1 is later, 0 if identical
 //	--------------------------------------------------------------------------------
 	public static Integer cmpTimes ( String time1 , String time2 ) {
 		String[] aTime1 = time1.split ( ' ' );
 		String[] aTime2 = time2.split ( ' ' );
 		String sAMPM1 = aTime1[ 1 ];
 		String sAMPM2 = aTime2[ 1 ];
 		aTime1 = aTime1[ 0 ].split ( ':' );
 		aTime2 = aTime2[ 0 ].split ( ':' );
 		
 		Integer iHH1 = Integer.valueOf ( aTime1[ 0 ] );
 		if ( iHH1 == 12 ) { iHH1 = 0; }
 		Integer iHH2 = Integer.valueOf ( aTime2[ 0 ] );
 		if ( iHH2 == 12 ) { iHH2 = 0; }
 		
 		if ( sAMPM1 == 'PM' ) { iHH1 += 12; }
 		if ( sAMPM2 == 'PM' ) { iHH2 += 12; }
 		
 		Integer iHHMM1 = 60 * iHH1 + Integer.valueOf ( aTime1[ 1 ] );
 		Integer iHHMM2 = 60 * iHH2 + Integer.valueOf ( aTime2[ 1 ] );
 		
 		if ( iHHMM1 > iHHMM2 ) {
 			return 1;
 		}
 		else if ( iHHMM1 < iHHMM2 ) {
 			return -1;
 		}
 		else {
 			return 0;
		}
 	}
	
  	 /*
  	 * Name: getKey  
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Conference Id and the Meeting Room Id
  	 * Params: @availableHotelMeetingRoom - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 /*public String getKey(Available_Hotel_Meeting_Room__c availableHotelMeetingRoom) {
  	 	if (availableHotelMeetingRoom == null) {
  	 		return '';
  	 	}
		return getId(availableHotelMeetingRoom.Conference__c) + getId(availableHotelMeetingRoom.Hotel_Meeting_Room__c);
  	 }*/
  	 
  	 /*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Conference Id, Date, Hotel Id, Type
  	 * Params: @availableHotelSleepingRoom - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Available_Hotel_Sleeping_Room__c availableHotelSleepingRoom) 
  	 {
  	 	String rValue = '';
  	 	
  	 	if (availableHotelSleepingRoom != null) {
	  	 	String AvailableDay = String.valueof(availableHotelSleepingRoom.Available_Date__c);
 		 	rValue = '' + AvailableDay.SubString(0, 10) + getId(availableHotelSleepingRoom.Conference__c) + getId(availableHotelSleepingRoom.Hotel__c) + availableHotelSleepingRoom.Room_Type__c;
  	 	}  	  	 	
  	 	return rValue;
  	 }
  	 
  	 /*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Conference Id and the Hotel Id
  	 * Params: @hotelBooking - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Hotel_Booking__c hotelBooking) {
  	 	String rValue = '';
  	 	
  	 	if (hotelBooking != null) {
		  	rValue = getId(hotelBooking.Conference__c) + getId(hotelBooking.Hotel__c);
  	 	}
  	 	
  	 	return rValue;
  	 }
  	 
  	/*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Participating Account Id and the Requestor Registrant Id
  	 * Params: @meetingRequest - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Meeting_Request__c meetingRequest) {
  	 	String rValue = '';
  	 	if (meetingRequest != null) {
  	 		rValue = getId(meetingRequest.Presenting_Company__c) + getId(meetingRequest.Requestor_Registrant__c);
  	 	}
 	 	return rValue;
  	 }
  	 
  	/*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Account Id and the Conference Id
  	 * Params: @participatingAccount - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Presenting_Company__c participatingAccount) {
  	 	String rValue = '';
  	 	if (participatingAccount != null) {
  	 		rValue = getId(participatingAccount.Account__c) + getId(participatingAccount.Conference__c);
  	 	}
 	 	return rValue;
  	 }
  	 
  	/*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Conference Id and Contact Id
  	 * Params: @registrant - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Registrant__c registrant) {
  	 	String rValue = '';
  	 	if (registrant != null) {
  	 		rValue = getId(registrant.Conference__c) + getId(registrant.Contact__c);
  	 	}
 	 	return rValue;
  	 }
  	   	 
  	/*
  	 * Name: getKey 
  	 * Description: Concatenates the fields that make up the records key in alphabetical order
  	 *				The Registrant Id and the Special Event Id
  	 * Params: @special EventRegistration - the record's id you would like to get
  	 * Returns: the concatenation of 
  	 * Notes: Used to help prevent duplicate records being created
  	 *		  Uses the 15-digit versions of the record ids, as this may be compared against the formula Key field of the record
  	 */
  	 public static String getKey(Special_Event_Registration__c specialEventRegistration) {
  	 	String rValue = '';
  	 	if (specialEventRegistration != null) {
  	 		rValue = getId(specialEventRegistration.Registrant__c) + getId(specialEventRegistration.Special_Event__c);
  	 	}
  	 	return rValue;
  	 }
  	 
  	 /*
  	 * Name: getId
  	 * Description: Takes an Id and converts it into its 15-character version String
  	 * Params: @anId
  	 * Returns: 
  	 * Notes: This is used in other functions which help build the unique key of a record.
  	 */
  	 public static String getId(Id anId) {
  	 	String rValue = '';
  	 	if (anId != null) {
  	 	 	String stringId = anId;
			rValue = stringId.SubString(0, ST_ACE.aceCommon.RECORD_ID_LENGTH);
  	 	}
  	 	return rValue;
  	 }  	  
  	 
  	/*
  	 * Name: EditAccess
  	 * Description: This function checks if the user has EditAccess.  In order for a user to edit an object, He/She
  	 *				must be a System Admin or Conference Group Member.  Otherwise, he must be the owner of that object.
  	 * Params: n/a
  	 * Returns: Boolean
  	 * Notes: This is used in trigger's where we need to check if the user have access to edit that object.
  	 */
  	 public static boolean EditAccess()
  	 {
  	 	boolean Access = false;
  	 	Id Profile_Id = UserInfo.getProfileId(); // get User Profile Id
  	 	Id User_Id = UserInfo.getUserId(); // get User Id
  	 	
  	 	// Query the salesforce database for Profile Name
  	 	Profile pf = [	select 	Id, Name
  	 					from 	Profile
  	 					where 	Id = : Profile_Id];
  	 	
  	 	// Check if it's a System Admin
  	 	if(pf.Name.contains('ST - System Administrator') || pf.Name.contains('System Administrator')){
  	 		// If user is a System Admin then set Access to 'True'
  	 		Access = true;
  	 	}
  	 	else { // Check if they belong to the ST_Conference Group  	 	
	  	 	GroupMember[] grp_mem = [	select 	Id, GroupId
									from 	GroupMember
									where 	Group.Name = 'ST_Conference Group'
									and UserOrGroupId = :User_Id];
			// If user belong to ST_Conference Group then set Access to 'True' 
			if(grp_mem.size() > 0) {
				Access = true;	
			}
  	 	} 
		
		// return the boolean value stating if they have access or not.
		return Access;
  	 }
  	 
  	 public static String GetRegistrantError(Integer ErrorNumber)
  	 {
  	 	String msg = '';
  	 	
  	 	if (ErrorNumber == 0)
  	 		msg = 'The Conference is not available for registration.';
  	 	else if (ErrorNumber == 1)
  	 		msg = 'The Registrant\'s Attendance Start Date must fall on or after the Conference start date: ';
  	 	else if (ErrorNumber == 2)
  	 		msg = 'The Registrant\'s Attendance End Date must fall before or on the Conference end date: ';
  	 	else if (ErrorNumber == 3)
  	 		msg = 'There are no sleeping rooms available on: ';
  	 	else if (ErrorNumber == 4)
  	 		msg = 'You must enter Hotel, Check In Date, Check Out Date and Room Type if you enter any hotel details.';
  	 	else if (ErrorNumber == 5)
  	 		msg = 'The Hotel Check In Date must be earlier than the Hotel Check Out Date and cannot be the same as the Check Out Date.';
  	 	else if (ErrorNumber == 6)
  	 		msg = 'The selected Hotel does not have sleeping rooms for this Conference';
  	 	else if (ErrorNumber == 7)
  	 		msg = 'The selected Hotel Room Type is not available at this Hotel.';
  	 		
  	 	return msg;
  	 	
  	 } 	 		
  	   	  	 
  	 public static void Update_Registrant_Hotel_Reservation(
		  	 		list<Hotel_Reservation__c> list_hotel_reservations, 
					list<Registrant__c> registrants)
  	 {
  	 	// Do a bulk insert of all the Hotel Reservation records.
		if ((list_hotel_reservations != null) && (list_hotel_reservations.Size() > 0)) {
			try {
				insert list_hotel_reservations;
			}
			catch(System.DmlException e) {
				for(Integer i = 0; i < e.getNumDml();i++) {
					// Process exception here	
					for(Registrant__c regist : registrants) {
						if(regist.Id == list_hotel_reservations[e.getDmlIndex(i)].Registrant__c) {
							regist.addError(e.getDmlMessage(i));
						}
					}
				}
			}
		}	
  	 }
  	 
  	 public static void Update_Avail_Hotel_Sleeping_Rooms(
  	 				list<Available_Hotel_Sleeping_Room__c> list_ahsr,
  	 				list<Registrant__c> registrants)
  	 {
  	 	// Do a bulk update of all the Available Hotel Sleeping Room's
		if ((list_ahsr != null) && (list_ahsr.Size() > 0)) {
			try {
				update list_ahsr;
			}
			catch(System.DmlException e) {
				for(Integer i = 0; i < e.getNumDml();i++) {
					// Process exception here
					for(Registrant__c regist : registrants) {
						if((regist.Conference__c == list_ahsr[e.getDmlIndex(i)].Conference__c) &&
						   (regist.Hotel__c == list_ahsr[e.getDmlIndex(i)].Hotel__c) &&
						   (regist.Room_Type__c == list_ahsr[e.getDmlIndex(i)].Room_Type__c) &&
						   ((regist.Hotel_Check_In_Date__c <= list_ahsr[e.getDmlIndex(i)].Available_Date__c) &&
						    (regist.Hotel_Check_Out_Date__c >= list_ahsr[e.getDmlIndex(i)].Available_Date__c)))
						{
							regist.addError(e.getDmlMessage(i));
						}
					}
				}
			}
		}
  	 }
  	 
  	 public static Integer CheckRegistrantAttendanceDateRange(Date asd, Date aed, Date csd, Date ced, Registrant__c registrant)
	 {	 	
		Integer returnInt = 0;		
		if ((asd >= csd && asd <= ced) && (aed >= csd && aed <= ced)) {}
		else {
			if((aed < csd || aed > ced) && (asd < csd || asd > ced)) {
				registrant.Attendance_Start_Date__c.addError(GetRegistrantError(1) + String.valueof(csd));						
				registrant.Attendance_End_Date__c.addError(GetRegistrantError(2) + String.valueof(ced));						
			}
			else if (aed < csd || aed > ced) {
				registrant.Attendance_End_Date__c.addError(GetRegistrantError(2) + String.valueof(ced));				
			}					
			else if (asd < csd || asd > ced) {
				registrant.Attendance_Start_Date__c.addError(GetRegistrantError(1) + String.valueof(csd));					
			}							
			returnInt = -1;
		}
		return returnInt;
	}
	
	/*
 	 * Name: updateSpeakerMeetings
	 * Description: Rebuild the Meeting Speaker fields (Speaker Ids, Speaker Names, Speaker Account Id, Speaker Account Names
	 * @params: @meeting - the meeting being interogated
	 * @returns: n/a
	 * Notes: 
 	 */
	public static void updateSpeakerMeetings(set<Id> speakerMeetingIds, list<Meeting_Participation__c> meetingParticipationsAffected) 
	{
		list<Meeting__c> list_update_meetings = new list<Meeting__c>();	
		
		// list of meetings that correspond the inserted/updated 'speaker' meeting participations
		Meeting__c[] speaker_Meetings = 	[	select 	Id, Speaker_Account_Id_s__c, 
													Speaker_Account_Name_s__c, Speaker_Id_s__c, 
													Speaker_Name_s__c, Date__c, Meeting_Room__c
												from Meeting__c 
												where Id in :speakerMeetingIds
											];
											
		// if there are meetings to be updated, begin				
		if ((speaker_Meetings != null) && (speaker_Meetings.Size() > 0)) {	
			map<String , List<Meeting_Participation__c>> map_Meeting_Participation = new map<String , List<Meeting_Participation__c>> ();
				
			for ( Meeting_Participation__c participant : [	select 
																Id, Name, Contact__c, Contact__r.Name,
																Contact__r.AccountId, Contact__r.Account.Name,
																Meeting__c, Type__c
															from Meeting_Participation__c 
															where Meeting__c in :speakerMeetingIds											
															and (Type__c = :aceCMSCommon.Type_Speaker_Public or Type__c = :aceCMSCommon.Type_Speaker_Private)
														])
			{
				// for each Meeting, retrieve the meetings list of meeting participation, create if it does not exist
				list<Meeting_Participation__c> tmp_list = map_Meeting_Participation.get ( participant.Meeting__c );
				if ( tmp_list == null ) {
					tmp_list = new list<Meeting_Participation__c> ();
				}
				// add the meeting participation to the corresponding meeting in the meeting participation map
				tmp_list.add ( participant );
				map_Meeting_Participation.put ( participant.Meeting__c , tmp_list );
			}
	
			// update the meeting with the list of speaker meeting participations
			for(Meeting__c meeting : speaker_Meetings) {
				String speaker_ids = ';';
				String account_ids = ';';
				String speaker_names = ';';
				String account_names = ';';
								
				list<Meeting_Participation__c> list_mtg_participants = new list<Meeting_Participation__c>();
				list_mtg_participants = map_Meeting_Participation.get( meeting.Id );
				
				if ( list_mtg_participants != null ) {				
					for(Meeting_Participation__c par : list_mtg_participants) {					
						if (speaker_ids == ';') {
							speaker_ids = '';
							account_ids = '';
							speaker_names = '';
							account_names = '';	
						}
						
						if (par.Meeting__c == meeting.Id && (par.Type__c == aceCMSCommon.Type_Speaker_Public || par.Type__c == aceCMSCommon.Type_Speaker_Private))
						{				
							if (!speaker_ids.contains(par.Contact__c)) speaker_names += par.Contact__r.Name + ';';
							if (!account_ids.contains(par.Contact__r.AccountId)) account_names += par.Contact__r.Account.Name + ';';
												
							speaker_ids += '' + par.Contact__c + ';';
							account_ids += '' + par.Contact__r.AccountId + ';';
						}
					}
				
					meeting.Speaker_Id_s__c = speaker_ids.substring(0, speaker_ids.length()-1);
					meeting.Speaker_Account_Id_s__c = account_ids.substring(0, account_ids.length()-1);
					meeting.Speaker_Account_Name_s__c = account_names.substring(0, account_names.length()-1);
					meeting.Speaker_Name_s__c = speaker_names.substring(0, speaker_names.length()-1);					
				}
				else {
					meeting.Speaker_Id_s__c = '';
					meeting.Speaker_Account_Id_s__c = '';
					meeting.Speaker_Account_Name_s__c = '';
					meeting.Speaker_Name_s__c = '';
				}
				list_update_meetings.add(meeting);
			}
		
			if (list_update_meetings != null) if (list_update_meetings.Size() > 0)  {		
				try {
					update list_update_meetings;
				}
				catch(System.DmlException e) {
					for(Integer i = 0; i < e.getNumDml();i++) {
						for (Meeting_Participation__c participant : meetingParticipationsAffected) {
							if(participant.Meeting__c == list_update_meetings[e.getDmlIndex(i)].Id) {
								participant.addError(e.getDmlMessage(i));
							}
						}
					}
				}
			}
		}
	}		
	
	/*
 	 * Name: getRecordType
	 * Description: Returns a map of record type  
	 * @params: object type such as 'Registrant__c'
	 * @returns: map of record type
	 * Notes: 
 	 */
	public static map<String, RecordType> getRecordType(String objectType) {
		map<String, RecordType> returnMap = new map<String, RecordType>();				
		for(RecordType rType: [select Id, Name, sObjectType from RecordType where sObjectType = :objectType]) {				
			String sObjectType = '' + rType.sObjectType;			
			if (sObjectType.contains(objectType)) {
				returnMap.put(rType.Name, rType);	
			}
		} 
		return returnMap;
	}
}