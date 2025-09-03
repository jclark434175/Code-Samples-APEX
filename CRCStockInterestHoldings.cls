/** 
 * Name: CRCStockInterestHoldings 
 * Description:  Stock Interest and Holdings Meetings grid for CRC
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCStockInterestHoldings 
{
	//	============================================================================
	//	Method:	getStockInterestHoldings	
	//	Desc:	Gets all the Interest__c objects for this Account ID
	//	Return:	allStocksAndHoldings - A List with Interest__c objects
	//	============================================================================
	public List<Interest__c> getStockInterestHoldings(String AccountID)
	{
		List<Interest__c> allStocksAndHoldings = new List<Interest__c>();
		
		
		for ( Interest__c interest : [select i.Contact__c, i.Contact__r.Id, i.Contact__r.Name, i.LastModifiedDate, i.Note__c, 
											 i.Reason__c, i.Symbol__c, i.Symbol_Name__c 
										from Interest__c i 
										where i.Account__c = :AccountID
										order by i.LastModifiedDate]) 
		{
			allStocksAndHoldings.add( interest );
		}
		
		return allStocksAndHoldings;
	}
}