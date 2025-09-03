/** 
 * Name: NewTaskPageControllerExtension
 * Description: Controller used by the NewTask Visual Force Page
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class NewTaskPageControllerExtension
{
    private ApexPages.StandardController controller;
                
    public NewTaskPageControllerExtension(ApexPages.StandardController controller)
    {
        try
        {
        	savedTask = (Task)controller.getRecord();        	
        	//Get the page parameters
        	Map<String, String> pageParameters = ApexPages.currentPage().getParameters();        	        	                    
            //Assign the who id
            savedTask.WhoId = pageParameters.get('who_id');
            //Assign the what id
            savedTask.WhatId = pageParameters.get('what_id');
            //Assign the owner of the task
            savedTask.OwnerId = UserInfo.getUserId();
            //Assign the default values to the picklist values
            savedTask.Status = 'Not Started';
            savedTask.Priority = 'Normal';
        }
        catch(Exception ignore)
        {}
        
        this.controller = controller;
    }
        
    public PageReference doSave()
    {
        savedTask = (Task)controller.getRecord(); 
        
        if (savedTask.ActivityDate == null)
        {
        	savedTask.ActivityDate = Date.today();
        }
              
        Database.saveResult sr = Database.Insert(savedTask);
        //reget the updated record
        savedTask = [select Id , ActivityDate , Status , 
                                            Interaction_Type__c , Subject , Description ,
                                            AccountId , WhoId , Who.Name , Account.Name ,
                                            Owner.Name , CreatedDate, CreatedBy.Name
                                        from Task where Task.Id = :((Task)controller.getRecord()).Id];
        return null;
    }

    private Task savedTask
    {
        get;
        set;
    }
    
    public Task getSavedTask()
    {
        try
        {
            Task[] tasks = [ select Id , ActivityDate , Status , 
                                            Interaction_Type__c , Subject , Description ,
                                            AccountId , WhoId , Who.Name , Account.Name ,
                                            Owner.Name , CreatedDate, CreatedBy.Name
                                        from Task where Task.Id = :savedTask.Id ];
            
            if (tasks.size() > 0)
            {
                return tasks[0];    
            }
            
            return null;                            
        }
        catch(Exception error)
        {           
        }
        
        return null;
    }
    
    public String getActivityDate()
    {
    	return String.valueOf(savedTask.ActivityDate);
    }
}