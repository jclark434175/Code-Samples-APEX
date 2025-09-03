/** 
 * Name: CRCAccountCoverage 
 * Description:  Account Coverage grid for CRC
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCAccountCoverage 
{
	//	============================================================================
	//	Method:	getAccountCoverage	
	//	Desc:	Gets all the Account_Coverage__c
	//	Return:	coverageList - A List with all the Account_Coverage__c objects for this Account Id
	//	============================================================================
	public List<Account_Coverage__c> getAccountCoverage(String AccountID)
	{
		List<Account_Coverage__c> coverageList	= new List<Account_Coverage__c>();
		
		for (Account_Coverage__c coverage : [ select a.Employee__c, a.Employee__r.Id, a.Employee__r.Name, a.Role__c 
											  from Account_Coverage__c a
											  where a.Account__r.Id  = :AccountID
											  order by  a.Employee__c ])
		{
			coverageList.add( coverage );
		}
		
		return coverageList;
	}
}