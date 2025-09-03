/**  
 * Name: CRCActivityHistory 
 * Description: Returns a list of Tasks for the Activity History grid in CRC for this Account Id
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class CRCActivityHistory 
{	
	//	============================================================================
	//	Method:	getAllTasks	
	//	Desc:	Gets all the Task objects for this Account Id
	//	Return:	taskList - A List with all the Task objects 
	//	============================================================================
	public List<Task> getAllTasks(String AccountID)
	{
		List<Task> taskList = new List<Task>();
		
		for ( Task taskObj : [ select t.LastModifiedDate, t.Who.Name, t.WhoId, t.Subject, 
										t.Interaction_Type__c, t.Owner.Name, t.Owner.Id, t.ActivityDate, t.Status 
							   from Task t 
							   where t.WhatId = :AccountID
							   order by  t.LastModifiedDate ]) 
		{
			taskList.add( taskObj );
		}
		
		return taskList;		
	}
}