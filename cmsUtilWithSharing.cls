public with sharing class cmsUtilWithSharing {
	
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
}