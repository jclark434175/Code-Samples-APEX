/*
 * Name: aceCommon
 * Description: Contains common functions and constants to be used in other Triggers and Packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class aceCommon 
{
	/*
	 * ACE CONSTANTS
	 * To be used in Apex Code
	 */
	 
	// Entity names
	global static final String ENTITY_NAME_ACE_ENTITLEMENT = 'ST_ACE__Entitlement__c';	 
	global static final String ENTITY_NAME_ACCOUNT = 'Account';
	global static final String ENTITY_NAME_CONTACT = 'Contact'; 
	global static final String ENTITY_NAME_GLOBAL_SETTING = 'ST_ACE__Global_Setting__c';
	global static final String ENTITY_NAME_CAMPAIGN = 'Campaign'; 
	global static final String ENTITY_NAME_EVENT = 'Event'; 
	global static final String ENTITY_NAME_TASK = 'Task'; 	
	global static final String ENTITY_NAME_FRAME_CONFIGURATION = 'ST_CRC_Frame_Configuration__c'; 	
	global static final String ENTITY_NAME_FRAME_COLUMN_CONFIGURATION = 'ST_CRC_Frame_Column_Configuration__c'; 		
	global static final String ENTITY_NAME_DISPLAY_ENTITLEMENT = 'ST_CRCDisplay_ENTITLEMENT__c'; 	
  
  	// Field names
  	global static final String FIELD_ID = 'Id'; 
	
	// Internal Account Record Type Name
	global static final String Type_Contact_Account_Internal = 'Internal';
	
	// the length of the record ids used in Salesforce formula fields
	global static final Integer RECORD_ID_LENGTH = 15; 
  
	// Length of Comment Summary in Task.
	global static final Integer TASK_COMMENT_SUMMARY_LENGTH = 50;
	
	// Length of Comment Snippet in Task. 
	global static final Integer TASK_COMMENT_SNIPPET_LENGTH = 50;
		
	/*
	 * Name: doDelete
	 * Description: Takes a single Salesforce Id and Entity name and creates a new Delete Message.
	 *
	 * Notes: 
	 *
	 */
	global static void doDelete(Id salesforceIdToDelete, String entityNameToDelete) {
		String Execute = aceCommon.ExecuteTrigger('DELETE_OBJECT_CREATION');

		if(Execute != '1')
			return;
			
		Delete_Message__c deleteMessage = new Delete_Message__c(Salesforce_Id__c = salesforceIdToDelete, Entity_Name__c = entityNameToDelete);
		insert deleteMessage;
		
		//delete deleteMessage;
	}
  
  	global static void doDelete(Set<Id> Ids, String entityNameToDelete)
  	{
  		String Execute = aceCommon.ExecuteTrigger('DELETE_OBJECT_CREATION');

		if(Execute != '1') return;
			
  		List<Delete_Message__c> deleteMessages = new List<Delete_Message__c>();
  		
  		for(Id i: Ids)
  		{
  			  Delete_Message__c tmp = new Delete_Message__c(Salesforce_Id__c = i, Entity_Name__c = entityNameToDelete);
  			  deleteMessages.add(tmp);
  		}
  		
  		insert deleteMessages;
  		
  		//delete deleteMessages;
  	}

	global static String getFullName(Contact con)
	{
		return '' + con.LastName + ', ' + con.FirstName;
	}
	
	global static String ExecuteTrigger(String PropertyName)
	{
		Global_Setting__c Property = new Global_Setting__c();
		
		try
  		{
			 Property = [	SELECT 	Property_Value__c
							FROM 	Global_Setting__c											
							WHERE 	Property_Name__c = :PropertyName];	
  		}
  		catch(Exception ex)
  		{
  			return '1';
  		}
  		
		return Property.Property_Value__c;											
	}	
}