/*
 * Name: testDataAvailableHotelMeetingRoom
 * Description: Test Available Hotel Hotel Meeting Room data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */
  
public class testDataAvailableHotelMeetingRoom
{
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Available Hotel Meeting Room given a ConferenceID and Hotel Meeting Room ID.
	 *
	 * Notes: To be used in other test cases
	 */
	
	public static Meeting_Room_Booked__c insertRecord(Id ConferenceID, Id MeetingRoomID)
	{
		Meeting_Room_Booked__c newavailableHotelMeetingRoom = new Meeting_Room_Booked__c(Conference__c = ConferenceID, Hotel_Meeting_Room__c = MeetingRoomID);
		insert newavailableHotelMeetingRoom;
		return newavailableHotelMeetingRoom;
	}
	
	/*
	 * Name: updateRecord
	 * Description: Update a Available Hotel Meeting Room's Meeting room ID
	 *
	 * Notes: To be used in other test cases
	 */
	/*
	public void updateRecord(Meeting_Room_Booked__c availablehotelmeetingroom, Id aHotelMeetingRoomID) 
	{
		availablehotelmeetingroom.Hotel_Meeting_Room__c = aHotelMeetingRoomID;
		update availablehotelmeetingroom;
	}
	*/
}