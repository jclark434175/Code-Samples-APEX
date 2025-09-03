/** 
 * Name: CRCUtil  
 * Description: Utility class for common functions
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCUtil 
{
	/*
	!!!!!!!!!!!!
	Alex note !!
	!!!!!!!!!!!
	
	ST_GEM_User_Type__c is missing in the org. Why ? :)
	
	
	
	//	============================================================================
	//	Method:	getUserListByGEMType	
	//	Desc:	Gets a list of Users based on the ST_GEM_User_Type__c field
	//  Param:  userType - the type of the user (e.g. 'Analyst')
	//	Return:	A list of User records.
	//	============================================================================
	
	public static List<User> getUserListByGEMType(String userType)
	{
		List<User> userList = new List<User> {};
		
		for ( User usr : [ select u.Id, u.ST_GEM_User_Type__c 
							from User u where u.ST_GEM_User_Type__c = :userType]) 
		{
			userList.add( usr );
		}
		
		return userList;
	}
	*/
}