/*
 * Name: testDataHotelMeetingRoom
 * Description: Test Hotel Meeting Room data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, �2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */
 
public class testDataHotelMeetingRoom
{
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Hotel Meeting Room given a Meeting Room Name and Hotel ID.
	 *
	 * Notes: To be used in other test cases
	 */
	public static Hotel_Meeting_Room__c insertRecord(String hotelId, String meetingroomname)
	{
		Hotel_Meeting_Room__c newHotelMeetingRoom = new Hotel_Meeting_Room__c(Hotel__c = hotelId, Name = meetingroomname);
		insert newHotelMeetingRoom;
		return newHotelMeetingRoom;
	}	
}