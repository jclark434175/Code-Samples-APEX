/*
 * Name: testDataHotelBooking
 * Description: Test Hotel Booking data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, �2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */
 
public class testDataHotelBooking
{
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Hotel Booking given a Hotel name.
	 *
	 * Notes: To be used in other test cases
	 */
	public static Hotel_Booking__c insertRecord(Id hotelId, Id conferenceId)
	{
		Hotel_Booking__c newBooking = new Hotel_Booking__c(Hotel__c = hotelId, Conference__c = conferenceId);
		insert newBooking;
		return newBooking;
	}	
}