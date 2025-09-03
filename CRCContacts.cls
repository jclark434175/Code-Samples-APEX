/** 
 * Name: CRCContacts 
 * Description: Contacts list
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCContacts 
{			
	//	============================================================================
	//	Method:	getContacts	
	//	Desc:	Gets all Contacts records for the passed Account Id
	//	Args:	AccId - The Account id
	//	Return:	A list of Contacts records.
	//	============================================================================
	public List<Contact> getContacts (String AccountID) 
	{
		List<Contact> contList = new List<Contact> {};
		
		for ( Contact cont : [ select Id, Name, Phone, Title, Email
							   from Contact 
							   where AccountId = :AccountID]) 
		{
			contList.add(cont);
		}
		
		return contList;
	}	
}