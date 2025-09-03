/*
 * Name: testDataACEEntitlement
 * Description: Test ACE Entitlement data to be used in any test packages
 * Notes: 
 *
 * Confidential & Proprietary, ?2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part without written permission from STC StraightThrough.
 */
global class testDataACEEntitlement
{
	/*
	 * Name: createRecord
	 * Description: Create (do not insert) a new ACE Entitlement given a name
	 *
	 * Notes: To be used in other test cases
	 */
	global static Entitlement__c createRecord(String aName) 
	{
		return new Entitlement__c(Name = aName, Assign_By__c = 'User');
	}
	
	/*
	 * Name: insertRecord
	 * Description: Create and insert a new ACE Entitlement given a name.
	 *
	 * Notes: To be used in other test cases
	 */
	global static Entitlement__c insertRecord(String aName) 
	{
		Entitlement__c anEntitlement = new Entitlement__c(Name = aName, Assign_By__c = 'User');
		insert anEntitlement;
		return anEntitlement;
	}
	
	/*
	 * Name: insertRecords
	 * Description: Create and insert a list of ACEEntitlements given the number of Entitlements to create
	 *
	 * Notes: To be used in other test cases
	 */
	global static List<Entitlement__c> insertRecords(Integer numberOfRecords) 
	{
		List<Entitlement__c> Entitlements = new List<Entitlement__c>();
		for (Integer i = 0; i < numberOfRecords; i++) 
		{
			Entitlements.add(createRecord('Entitlement#' + i));
		}
		insert Entitlements;
		return Entitlements;
	}
}