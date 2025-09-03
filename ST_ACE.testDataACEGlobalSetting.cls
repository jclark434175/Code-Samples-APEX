/*
 * Name: testDataACEGlobalSetting
 * Description: Test ACE Glbal Setting data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
global class testDataACEGlobalSetting 
{
	/*
	 * Name: createRecord
	 * Description: Create (do not insert) a new ACE Global Setting given a name
	 *
	 * Notes: To be used in other test cases
	 */
	global static Global_Setting__c createRecord(String aName, String aValue) 
	{
		return new Global_Setting__c(Name = aName, ST_ACE__Property_Name__c = aName, ST_ACE__Property_Value__c = aValue);
	}
	
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new ACE Global Setting given a name.
	 *
	 * Notes: To be used in other test cases
	 */
	global static Global_Setting__c insertRecord(String aName, String aValue) 
	{
		Global_Setting__c aSetting = new Global_Setting__c(Name = aName, ST_ACE__Property_Name__c = aName, ST_ACE__Property_Value__c = aValue);
		insert aSetting;
		return aSetting;
	}
	
	/*
	 * Name: insertRecords
	 * Description: Create and insert a list of ACEGlobalSetting given the number of Global Setting to create
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Global_Setting__c> insertRecords(Integer numberOfRecords) 
	{
		List<Global_Setting__c> Settings = new List<Global_Setting__c>();
		for (Integer i = 0; i < numberOfRecords; i++) 
		{
			Settings.add(createRecord('Setting#' + i, '' + i));
		}
		insert Settings;
		return Settings;
	}
}