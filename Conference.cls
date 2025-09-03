/* 
 * Name: Conference 
 * Description: Contains details of a Conference
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM Inc.
 */
global class Conference {
	webservice String id;
	webservice String name;
	webservice String webSite;
	webservice boolean webRegistrationEnabled;
	webservice String timeslotTemplateId;
	webservice Date startDate;
	webservice Date endDate;
	webservice String registrationAvailability;
	webservice Date preRegistrationDeadline;
	webservice boolean openToPreRegistration;
	
	public Conference(Conference__c aConference) {
		id = aConference.Id;
		name = aConference.Name;
		webSite = aConference.Website__c;
		webRegistrationEnabled = aConference.Web_Registration_Enabled__c;
		timeslotTemplateId = aConference.Timeslot_Template__c;
		startDate = aConference.Start_Date__c;
		endDate = aConference.End_Date__c;
		registrationAvailability = aConference.Registration_Availability__c;
		preRegistrationDeadline = aConference.Pre_Registration_Deadline__c;
		openToPreRegistration = aConference.Open_To_Pre_Registration__c;
	}
}