/*
 * Name: testDataHotel
 * Description: Test Hotel data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, �2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */

public class testDataHotel
{
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Hotel given a Hotel name.
	 *
	 * Notes: To be used in other test cases
	 */
	public static Hotel__c insertRecord(String hotelName) 
	{		
		Hotel__c newHotel =  new Hotel__c (Name = hotelName);
		insert newHotel;
		return newHotel;
	} 	
}