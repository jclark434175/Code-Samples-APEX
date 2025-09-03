/*
 * Name: testDataConference 333
 * Description: Test Conference data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from Tier1CRM Inc.
 */ 
 
public class testDataConference {
	/*
	 * Name: createRecord
	 * Description: Create (do not insert) a new Conference given a name
	 *
	 * Notes: To be used in other test cases
	 */
	 
	public static Conference__c createRecord(String aName) {
		// randomly chose the start date as today and the end date as 5 days from today
		Date aDate = System.today();
		return new Conference__c(Name = aName, Start_Date__c = aDate, End_Date__c = aDate + 5);
	}
	
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Conference given a name
	 *
	 * Notes: To be used in other test cases
	 */
	public static Conference__c insertRecord(String aConferenceName) {
		
		Date startDate = Date.Today();
		Date endDate = startDate.AddDays(30);
		
		Conference__c newConference =  new Conference__c(
				Name = aConferenceName,
				Start_Date__c = startDate, //Date.newInstance(2008, 6, 1), 
				End_Date__c = endDate, // Date.newInstance(2008, 6, 30),
				Open_To_Pre_Registration__c = true ,
				Pre_Registration_Deadline__c = startDate); //Date.newInstance(2008, 5, 31));

		insert newConference;
		
		return newConference;
	}
	
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new Conference with the given name, Start Date and End Date
	 *
	 * Notes: To be used in other test cases
	 */
	public static Conference__c insertRecord(String aConferenceName, Date StartDate, Date EndDate) {
		
		Conference__c newConference =  new Conference__c(Name = aConferenceName,
				Start_Date__c = StartDate, End_Date__c = EndDate,
				Open_to_Pre_Registration__c = true, Pre_Registration_Deadline__c = StartDate);

		insert newConference;
		
		return newConference;
	}
	
	/*
	 * Name: insertRecords
	 * Description: Create and insert a new Contact given a First Name, Last Name and Account Id
	 *
	 * Notes: To be used in other test cases
	 */
	 
	public static List<Conference__c> insertRecords(Integer numberOfRecords) {
		List<Conference__c> conferences = new List<Conference__c>();
		for (Integer i = 0; i < numberOfRecords; i++) {
			conferences.add(createRecord('Conference #' + i));
		}
		insert conferences;
		return conferences;
	}
	
	/*
	 * Name: deleteRecord
	 * Description: Clean up Conference data
	 *
	 * Notes: To be used in other test cases
	 */
	public static void deleteRecord(Conference__c aConference, boolean bDeleteDeleteMessage) {
		delete aConference;
		if (bDeleteDeleteMessage == true) {
			delete [
				Select
					Id
				From
					ST_ACE__Delete_Message__c
				Where
					ST_ACE__Salesforce_Id__c = :aConference.Id
					and
					ST_ACE__Entity_Name__c = :aceCMSCommon.ENTITY_NAME_CONFERENCE
				
			];
		}
	}
}