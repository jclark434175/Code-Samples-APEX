/*
 * Name: testDataAvailableHotelSleepingRoom
 * Description: Test Available Hotel Sleeping Room data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, �2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */
 
public class testDataAvailableHotelSleepingRoom
{
	/*
	 * Name: insertRecord
	 * Description: Create and insert a Available Hotel Sleeping Room given the ConferenceId, hotelId, 
	 *              roomtype and availableday.
	 *
	 * Notes: To be used in other test cases 
	 */
	public static Available_Hotel_Sleeping_Room__c insertRecord(Id conferenceId, Id hotelId, String roomtype, Date availableday, Double TotalRoomsAllocated)
	{
		Available_Hotel_Sleeping_Room__c newAvailableSleepingRoom = new Available_Hotel_Sleeping_Room__c(Conference__c = conferenceId, Hotel__c = hotelId, Room_Type__c = roomtype, Available_Date__c = availableday, Total_Rooms_Allocated__c = TotalRoomsAllocated);
		insert newAvailableSleepingRoom;
		return newAvailableSleepingRoom;
	}	
}