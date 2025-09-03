public with sharing class CallReportExtension 
{
    //instance of CallReport object to handle both Edit&New
    public Call_Report__c callreport {get; private set;}
    
    //Wrapper class for TASK to hold fields for related objects
    public class TaskWrapper
    {
     public Task t;
     public String Email ='';
     public Boolean bOld=false;
     
     public Task gett()   {return t;} 
    }
    //Custom page exception
    public class PageException extends Exception {}
    final Integer MAX_COLLECTION=1000;
    private String Err_Collection ='Collections cannot contain more than 1000 items';
    
    
    private String currentClientID ='';
    //One set of data foreach listbox to represent the selected items
    private String[] InternalAttIn  = new String[]{};
    private String[] InternalAttOut = new String[]{};
    private String[] ExternalAttIn  = new String[]{};
    private String[] ExternalAttOut = new String[]{};
    
    //One set of data foreach listbox to represent all items(options) 
    private List<SelectOption> optionsIn = new List<SelectOption>();
    private List<SelectOption> optionsOut = new List<SelectOption>();
    private List<SelectOption> c_optionsIn = new List<SelectOption>();
    private List<SelectOption> c_optionsOut = new List<SelectOption>();
    
    //CIBC - map ID->name of attendees for both listboxes plus original situation 
    private Map<String, String> InMap = new Map<String, String>();
    private Map<String, String> OutMap = new Map<String, String>();
    private Map<String, String> OutMap_ini = new Map<String, String>();
    
    //Client - map ID->name of attendees for both listboxes plus original situation   
    private Map<String, String> c_InMap = new Map<String, String>();
    private Map<String, String> c_OutMap = new Map<String, String>();
    private Map<String, String> c_OutMap_ini = new Map<String, String>();
    
    private String NONE_ID='999999999999999'; 
    private String Task_General_ID = null;
    
    //Strings to search Employess&Contacts  
    private String searchEmp=''; 
    private String searchCtn='';
    
    //Values to keep the list of TASKS (created, uncreated) and current editing task.
    private List<TaskWrapper> tasks = null;
    private Task edit_task=null;
        
    private Map<String, String> page_parameters = new Map<String,String>(); 
    private Boolean bNew=true;
    private String subtitle='New Call Report';
    
    //Used to determine if the call report is locked or not
    private String Lock;
    
    //=====================================================================
    //
    // Flags that will be used for hiding and showing the VF page
    // header and side bar
    //
    //=====================================================================
    public Boolean showHeader { get;set; }
    public Boolean showSidebar { get;set; }
    
    //===================================================================================
    //
    // Flag that will determine if this page is representing a New Call Report
    // This is used to ensure the callback function is only invoked on a new Saved Entry
    // Not using the bNew flag due to the unknown of how Save will be affected by turning it
    // into a property.
    //
    //===================================================================================
    public Boolean newCallReport { get;set; }
    
    /*Constructor - executes when page is loading
      ********************************************/
    public CallReportExtension(ApexPages.StandardController controller) 
    {
        page_parameters = ApexPages.currentPage().getParameters();
        if(page_parameters.keySet().contains('id'))
        {
            //Edit case
            String id = page_parameters.get('id');
            
            this.callreport = [Select Client__c, Name, OwnerId, Meeting_Date__c, Meeting_Type__c, Status__c,
                Location__c, Subject_Meeting_Objectives__c,Notes__c,Private__c,Time_Spent_Min__c, Lock__c, Logged_By__c from Call_Report__c where Id=:id]; 
            
            currentClientID = callreport.Client__c;
            bNew = false;
            newCallReport = false;
            subtitle = callreport.Name;
            Lock = this.callreport.Lock__c;
        }
        else
        {
            //New case
            this.callreport = new Call_Report__c();
            for(String s:page_parameters.keySet())
            {
                if(s.contains('id'))
                {
                    currentClientID=page_parameters.get(s);
                    break;
                }
            }
            if(currentClientID==''){
                ApexPages.addMessages(new PageException('Page with incorrect parameters'));
                bNew=true;
                return;
            }
                 
            callreport.Client__c = currentClientID;
            String UserId = UserInfo.getUserId();
            callreport.OwnerId = UserId;
            ///get the default value for Logged By field = employee(user) currently editing the report
            
            Employee__c emp = [select Id from Employee__c where User__c = :UserId];
            if(emp != null)
                callreport.Logged_By__c=emp.Id;
                       
            ///
            bNew=true;
            newCallReport = true;
        }
        
        //Check if the page parameters contain the showHeader parameter
        if (page_parameters.keySet().contains('showHeader'))
        {
            //If so set the value
            showHeader = aceUtil.getBoolValue(page_parameters.get('showHeader'));
        }
        
        //Check if the page parameters contain the showSidebar parameter
        if (page_parameters.keySet().contains('showSidebar'))
        {
            //If so set the value
            showSidebar = aceUtil.getBoolValue(page_parameters.get('showSidebar'));
        }
      
        Initialize_Internal();
        Initialize_External();
        Initialize_Tasks();
    }
    
    /*Executed when page is loaded to initialize section CIBC Attendees
      -----------------------------------------------------------------*/
    private void Initialize_Internal()
    {
        try
        {
            //get data for the right box only if update
            if(!bNew)
            {
                List<Call_Report_Attendee_Internal__c> attInt = [SELECT Employee__r.Id, Employee__r.Name from Call_Report_Attendee_Internal__c 
                    where Call_Report__c=:callReport.Id LIMIT :MAX_COLLECTION];
                for(integer i=0;i < attInt.size(); i++)
                {
                    OutMap.put(attInt[i].Employee__r.Id, attInt[i].Employee__r.Name);
                    OutMap_ini.put(attInt[i].Employee__r.Id, attInt[i].Employee__r.Name);
                }

             }
            //get data for the left box
            List<Account_Coverage__c> accCov = [SELECT Employee__r.Id, Employee__r.Name from Account_Coverage__c 
                where Account__c =:currentClientID LIMIT :MAX_COLLECTION];
            for(integer i=0; i<accCov.size();i++)
                InMap.put(accCov[i].Employee__r.Id, accCov[i].Employee__r.Name);

            if(!bNew)
            {
                //eliminate the employees already selected for CallReport 
                for(String s : OutMap.keySet())
                {
                    if(InMap.containsKey(s))
                        InMap.remove(s);
                }
            }
            //populate left&right listboxes 
            LoadListOptions();
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
    }
    /*Executed when page is loaded to initialize section Client Attendees
      -------------------------------------------------------------------*/
    private void Initialize_External()
    {
        try
        {
            //get contacts for right box
            if(!bNew)
            {
                List<Call_Report_Attendee_Client__c> attExt = 
                    [SELECT Contact__r.Id, Contact__r.Name, Contact__r.Account.Name from Call_Report_Attendee_Client__c 
                        where Call_Report__c=:callReport.Id LIMIT :MAX_COLLECTION];
                for(integer i=0;i < attExt.size(); i++)
                {
                    string contact_plus = attExt[i].Contact__r.Name + ', ' +  attExt[i].Contact__r.Account.Name;
                    c_OutMap.put(attExt[i].Contact__r.Id, contact_plus);
                    c_OutMap_ini.put(attExt[i].Contact__r.Id, contact_plus);
                }
            }
            //get contacts for left box
            List<Contact> accCon = [SELECT Id, Name, Account.Name from Contact   
                where Account.Id =:currentClientID LIMIT :MAX_COLLECTION]; 
            for(integer i=0; i<accCon.size();i++)
            {
                string contact_plus = accCon[i].Name + ', ' + accCon[i].Account.Name;
                c_InMap.put(accCon[i].Id, contact_plus);
            }

            if(!bNew)
            {
                //eliminate contacts already selected for CallReport
                for(String s : c_OutMap.keySet())
                {
                    if(c_InMap.containsKey(s))
                        c_InMap.remove(s);
                }
            }
            //populate left&right listboxes
            c_LoadListOptions();
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }       
    }
    /*Executed when page is loaded to initialize Tasks
      ------------------------------------------------*/
    private void Initialize_Tasks()
    {
        try
        {
            if(!bNew)
            {
                //Select all tasks related to the CallReport record
                List<Task> ini_tasks = [Select RecordTypeId, ActivityDate, Description, OwnerId,
                    Priority, Status, Subject, Who.Id from Task where WhatId=:callreport.Id LIMIT :MAX_COLLECTION];
                //Build the TaskWrapper list    
                if(!ini_tasks.isEmpty())
                {
                    for(Task t:ini_tasks)
                    {
                        TaskWrapper tw = new TaskWrapper();
                        tw.t = t;
                        tw.bOld = true;
                        if(tasks==null) tasks=new List<TaskWrapper>();
                        tasks.add(tw);
                    }
                }
            }
            
            //RecordType rt = [Select Id from RecordType where SobjectType='Task' AND Name='General'];
            //if(rt!=null) Task_General_ID = rt.Id;
            
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }   
    }
    /*PROPERTIES*/
    /*==========*/
    //Page subtitle - is different for New vs.Edit.
    public String  getSubtitle()
    {
        return this.subtitle;
    }
    //CIBC - Items for listboxes
    public List<SelectOption> getItemsIn()
    {
        return optionsIn; 
    }
    public List<SelectOption> getItemsOut()
    {
        return optionsOut; 
    }
    //Client -Items for listboxes
    public List<SelectOption> getc_ItemsIn()
    {
        return c_optionsIn; 
    }
    public List<SelectOption> getc_ItemsOut()
    {
        return c_optionsOut; 
    }  
    //CIBC - Selection in listboxes
    public String[] getInternalAttIn ()
    {
        return InternalAttIn;
    }
    public void setInternalAttIn(String[] InternalAttIn) 
    {
        this.InternalAttIn = InternalAttIn;
    }
    public String[] getInternalAttOut()     
    {
        return InternalAttOut;
    }
    public void setInternalAttOut(String[] InternalAttOut) 
    {
        this.InternalAttOut = InternalAttOut;
    }
    //Client - Selection in listboxes
    public String[] getExternalAttIn()     
    {
        return ExternalAttIn;
    }
    public void setExternalAttIn(String[] ExternalAttIn) 
    {
        this.ExternalAttIn = ExternalAttIn;
    }
    public String[] getExternalAttOut()     
    {
        return ExternalAttOut;
    }
    public void setExternalAttOut(String[] ExternalAttOut) 
    {
        this.ExternalAttOut = ExternalAttOut;
    }
    //Search strings for CIBC and CLIENT
    public String getsearchEmp()
    {
        return searchEmp;
    }
    public void setsearchEmp(String searchEmp)
    {
        this.searchEmp=searchEmp;
    }
    public String getsearchCtn()
    {
        return searchCtn;
    }
    public void setsearchCtn(String searchCtn)
    {
        this.searchCtn=searchCtn;
    }
    //TaskWrapper list
    public List<TaskWrapper> getTasks() 
    {
        return tasks;
    }
    /*public void setTasks(TaskWrapper[] tarr) 
    {
        tasks=tarr;
    }*/
    //Get new task to edit (current edited task)
    public Task getmyTask()
    {
        edit_task= new Task();
        edit_task.OwnerId = UserInfo.getUserId(); 
        edit_task.Priority = 'Normal';
        edit_task.Type='Other';
        edit_task.Subject='Call Report';
        edit_task.WhatId = callreport.Id;
        return edit_task;
    }
    public void setmyTask(Task t)
    {
        edit_task=t;
    }
    
    /*METHODS*/
    /*=======*/
    //CIBC Add button click  
    public void addInternals() 
    {
        try {
            if(OutMap.size()+InternalAttIn.size() > MAX_COLLECTION)
                throw new PageException(Err_Collection);
            for(String s : InternalAttIn)
            {
                OutMap.put(s, InMap.get(s));
                InMap.remove(s);
            }
            LoadListOptions();
        }
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e){ ApexPages.addMessages(e);}
    }
    //CIBC Remove button click
    public void removeInternals() 
    {
        try {
            if(InMap.size()+InternalAttOut.size() > MAX_COLLECTION)
                throw new PageException(Err_Collection);
            for(String s : InternalAttOut)
            {
                InMap.put(s, OutMap.get(s));
                OutMap.remove(s);
            }
            LoadListOptions();
        }
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e){ ApexPages.addMessages(e);}
    }
    //Client Add button click
    public void addExternals() 
    {
        try{
            if(c_OutMap.size()+ExternalAttIn.size() > MAX_COLLECTION)
                throw new PageException(Err_Collection);
            for(String s : ExternalAttIn)
            {
                c_OutMap.put(s, c_InMap.get(s));
                c_InMap.remove(s);
            }
            c_LoadListOptions();
        }
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e){ ApexPages.addMessages(e);}
    }
    //Client Remove button click
    public void removeExternals() 
    {
        try {
            if(c_InMap.size()+ExternalAttOut.size() > MAX_COLLECTION)
                throw new PageException(Err_Collection);
            for(String s : ExternalAttOut)
            {
                c_InMap.put(s, c_OutMap.get(s));
                c_OutMap.remove(s);
            }
            c_LoadListOptions();
        }
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e){ ApexPages.addMessages(e);}
    }
    //CIBC Find button click
    public PageReference Find()
    {
        Set<String> container = new Set<String>();
        System.debug('FIND STRING: '+ searchEmp);
        try
        {
            InMap.clear();
            boolean bContinue=true;
            while(bContinue)
            {
                List<List<SObject>> searchList=
                    [FIND :searchEmp IN NAME FIELDS RETURNING Employee__c(Id, Name WHERE Id NOT IN :container) 
                    LIMIT 200];
                
                Employee__c [] emps = ((List<Employee__c>)searchList[0]);
                    
                if(emps.size() == 0)
                    bContinue=false;
                else if(InMap.size()+ emps.size() > MAX_COLLECTION)
                {
                    throw new PageException(Err_Collection);
                }
                else
                {
                    for(Employee__c emp : emps)
                    {
                        InMap.put(emp.Id, emp.Name);
                        container.add(emp.Id);
                    }
                    for(String s : OutMap.keySet())
                    {
                        if(InMap.containsKey(s))
                            InMap.remove(s);
                    }
                }
            }
            if(InMap.size()==0) InMap.put(NONE_ID, '--None--');
            //System.debug('ELENA Find search size '+ InMap.size());
            LoadListOptions();
        }
        catch(SearchException se){ApexPages.addMessages(se);}
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e){ApexPages.addMessages(e);}   
        return null;        
    }
    //CIBC Clear button click
    public PageReference Clear()
    {
        try
        {
            //clear search field
            searchEmp='';
            //clear/reload "In" listbox
            InMap.clear();
            List<Account_Coverage__c> accCov =
                [SELECT Employee__r.Id, Employee__r.Name from Account_Coverage__c 
                where Account__c =:currentClientID LIMIT :MAX_COLLECTION];
            
            for(integer i=0; i<accCov.size();i++)
            {
                InMap.put(accCov[i].Employee__r.Id, accCov[i].Employee__r.Name);
            }

            for(String s : OutMap.keySet())
            {
                if(InMap.containsKey(s))
                    InMap.remove(s);
            }
            LoadListOptions();
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    //Client Find button click
    public PageReference c_Find()
    {
        Set<String> container = new Set<String>();
        
        try
        {
            System.debug('FIND c_STRING: '+ searchCtn);
            c_InMap.clear();
            boolean bContinue=true;
            while(bContinue)
            {
                List<List<SObject>> searchList=
                    [FIND :searchCtn IN NAME FIELDS RETURNING Contact(Id, Name, Account.Name WHERE Id NOT IN :container) 
                    LIMIT 200];
                Contact [] contacts = ((List<Contact>)searchList[0]);   
                System.debug('INMAP CONTACT' + container.size() + ','+ contacts.size());
                if(contacts.size()==0)
                        bContinue=false;
                else if(c_InMap.size()+ contacts.size() > MAX_COLLECTION)
                {
                    throw new PageException(Err_Collection);
                }       
                else
                {
                    for(Contact ctn : contacts)
                    {
                        string ctn_plus = ctn.Name + ', ' + ctn.Account.Name;
                        c_InMap.put(ctn.Id, ctn_plus);
                        container.add(ctn.Id);
                    }
                    for(String s : c_OutMap.keySet())
                    {
                        if(c_InMap.containsKey(s))
                            c_InMap.remove(s);
                    }
                }
            }
            
            if(c_InMap.size()==0) c_InMap.put(NONE_ID, '--None--');
            System.debug('ELENA FIND size '+ c_InMap.size());
            c_LoadListOptions();
        }
        catch(SearchException se){ ApexPages.addMessages(se);}
        catch(PageException ec){ApexPages.addMessages(ec);}
        catch(Exception e)       { ApexPages.addMessages(e); }
        return null;        
    }
    //Client Clear button click
    public PageReference c_Clear()
    {
        try
        {
            //clear search field
            searchCtn='';
            //clear/reload "In" listbox
            c_InMap.clear();
            List<Contact> accCon =
                [SELECT Id, Name, Account.Name from Contact   
                where Account.Id =:currentClientID LIMIT :MAX_COLLECTION]; 
                
            for(integer i=0; i<accCon.size();i++)
            {
                string contact_plus = accCon[i].Name + ', ' + accCon[i].Account.Name;
                c_InMap.put(accCon[i].Id, contact_plus);
            }

            for(String s : c_OutMap.keySet())
            {
                if(c_InMap.containsKey(s))
                    c_InMap.remove(s);
            }
            c_LoadListOptions();
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
        return null;
    }
    //AddTask button click
    public PageReference AddTask()
    {
        try
        {
            //if(ApexPages.hasMessages()) ApexPages.getMessages().clear();
            if(tasks==null) tasks= new List<TaskWrapper>();
            TaskWrapper tw = new TaskWrapper();
            tw.t=edit_task;
            User u = [SELECT FirstName, LastName, Email
                        from User where Id =:tw.t.OwnerId];

            tw.Email = u.Email;
            tw.t.Status='Not Started';
            if(tasks.size() >= MAX_COLLECTION)
                throw new PageException(Err_Collection);
            tasks.add(tw);
        }
        catch(QueryException qe)
        {
            ApexPages.addMessages(qe);
        }
        catch(PageException pe)
        {
            ApexPages.addMessages(pe);
        }        
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    //SAVE button click 
    public PageReference saveAttTasks() 
    {
        try
        {
            /*Update Call Report*/
            /*==================*/
            try
            {
                upsert(callreport);
            }
            catch(DmlException e)
            {
                throw new PageException('Save Call Report failed. ' + e.getMessage());
            }
            /*Save Internals Att. - use OutMap*/
            /*================================*/
            List<Call_Report_Attendee_Internal__c> attInt = new List<Call_Report_Attendee_Internal__c>();
            Set<ID> attInt_Del = new Set<ID>();
            //create list of CIBC att to be inserted
            for(String s: OutMap.keySet())
            {
                if(!OutMap_ini.containsKey(s))
                {
                    Call_Report_Attendee_Internal__c INTERNAL = new Call_Report_Attendee_Internal__c();
                    INTERNAL.Call_Report__c = callreport.Id;
                    INTERNAL.Employee__c = s;
                    attInt.add(INTERNAL);
                }
            }
            if(!bNew)
            {
                //create list of CIBC att to be deleted.
                for(String s: OutMap_ini.keySet())
                {
                    if(!OutMap.containsKey(s))
                    {
                        attInt_Del.add(s);
                    }
                }
            }
            
            //insert invitees from CIBC employees
            if(!attInt.isEmpty())
            {
                try
                {
                    if(attInt.size()>200)
                    {
                        List<Call_Report_Attendee_Internal__c> temp = new List<Call_Report_Attendee_Internal__c>();
                        for(integer i=0;i<attInt.size();i++)
                        {
                            temp.add(attInt[i]);
                            if(math.mod(i+1,200) == 0) 
                            {
                                insert temp;
                                temp.clear();
                            }                               
                        }
                        if(math.mod(attInt.size(),200) != 0) insert temp;
                    }
                    else
                        insert attInt; 
                }
                catch(DmlException e)
                {
                    throw new PageException('Insert InternalAttendees failed: ' + e.getMessage());
                }
            }
            //delete invitees from CIBC att.
            if(!attInt_Del.isEmpty())
            {
                List<Call_Report_Attendee_Internal__c> attInt_ToDel = 
                [Select Id from Call_Report_Attendee_Internal__c where Employee__r.Id IN :attInt_Del];
                
                try
                {
                    if(attInt_ToDel.size()>200)
                    {
                        List<Call_Report_Attendee_Internal__c> temp = new List<Call_Report_Attendee_Internal__c>();
                        for(integer i=0;i<attInt_ToDel.size();i++)
                        {
                            temp.add(attInt_ToDel[i]);
                            if(math.mod(i+1,200) == 0) 
                            {
                                delete temp;
                                temp.clear();
                            }                               
                        }
                        if(math.mod(attInt_ToDel.size(),200) != 0) delete temp;
                    }
                    else
                        delete attInt_ToDel; 
                }
                catch(DmlException e)
                {
                    throw new PageException('Delete InternalAttendees failed ' + e.getMessage());
                }
            }
        
            /*Save Externals Att. - use c_OutMap*/
            /*==================================*/
            List<Call_Report_Attendee_Client__c> attExt = new List<Call_Report_Attendee_Client__c>();
            Set<ID> attExt_Del = new Set<ID>();
            //create list of CLIENT att to be inserted
            for(String s: c_OutMap.keySet())
            {
                if(!c_OutMap_ini.containsKey(s))
                {
                    Call_Report_Attendee_Client__c EXTERNAL = new Call_Report_Attendee_Client__c();
                    EXTERNAL.Call_Report__c = callreport.Id;
                    EXTERNAL.Contact__c = s;
                    attExt.add(EXTERNAL);
                }
            }
            if(!bNew)
            {
                //create list of CLIENT att to be deleted
                for(String s: c_OutMap_ini.keySet())
                {
                    if(!c_OutMap.containsKey(s))
                    {
                        attExt_Del.add(s);
                    }
                }
            } 
            
            //insert invitees from CLIENT contacts
            if(!attExt.isEmpty())
            {
                try
                {
                    if(attExt.size()>200)
                    {
                        List<Call_Report_Attendee_Client__c> temp = new List<Call_Report_Attendee_Client__c>();
                        for(integer i=0;i<attExt.size();i++)
                        {
                            temp.add(attExt[i]);
                            if(math.mod(i+1,200) == 0) 
                            {
                                insert temp;
                                temp.clear();
                            }                               
                        }
                        if(math.mod(attExt.size(),200) != 0) insert temp;
                    }
                    else
                        insert attExt; 
                }
                catch(DmlException e)
                {
                    throw new PageException('Insert ExternalAttendees failed ' + e.getMessage());
                }
            }
            //delete invitees from CLIENT contacts
            if(!attExt_Del.isEmpty())
            {
                List<Call_Report_Attendee_Client__c> attExt_ToDel =
                [Select Id from Call_Report_Attendee_Client__c where Contact__c IN :attExt_Del];
                
                try
                {
                    if(attExt_ToDel.size()>200)
                    {
                        List<Call_Report_Attendee_Client__c> temp = new List<Call_Report_Attendee_Client__c>();
                        for(integer i=0;i<attExt_ToDel.size();i++)
                        {
                            temp.add(attExt_ToDel[i]);
                            if(math.mod(i+1,200) == 0) 
                            {
                                delete temp;
                                temp.clear();
                            }                               
                        }
                        if(math.mod(attExt_ToDel.size(),200) != 0) delete temp;
                    }
                    else
                        delete attExt_ToDel;
                }
                catch(DmlException e)
                {
                    throw new PageException('Delete ExternalAttendees failed: ' + e.getMessage()); 
                }
            }
            
            /*Save TASKS with reminder, send email*/
            /*====================================*/
            if(!CreateTasks())
                return null;
            
            //System.debug('Email: ' + Limits.getEmailInvocations() + ', ' + Limits.getLimitEmailInvocations());
            //System.debug('SOSL : ' + Limits.getSoslQueries() + ', ' + Limits.getLimitSoslQueries());
            //getDMLRows - getLimitDMLRows
            //getDMLStatements - getLimitDMLStatements
            //getQueries - getLimitQueries
            //getQueryRows - getLimitQueryRows              
                    
            String s = page_parameters.get('retURL');
            PageReference pageRef = new PageReference(s);
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(PageException pe){ApexPages.addMessages(pe);}
        catch(QueryException qe){ApexPages.addMessages(qe);}
        catch(Exception e){ApexPages.addMessages(e);}
        return null;
    }
       
    private boolean CreateTasks()
    {
        if(tasks==null || tasks.size()==0) return true;
        try
        {
            List<Task> task_list = new List<Task>(); 
            List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>(); 
            
            for(TaskWrapper tw : tasks)
            {
                if(tw.bOld==false)
                {
                    tw.t.WhatId = callreport.Id;
                    
                    if(tw.t.ActivityDate!= null)
                    {
                        Datetime reminder = Datetime.newInstance(tw.t.ActivityDate.year(),
                            tw.t.ActivityDate.month(), tw.t.ActivityDate.day(),
                            8,0,0);
                        
                        tw.t.ReminderDateTime=reminder;
                        tw.t.IsReminderSet=true;
                        System.debug(' REMINDER ' +  tw.t.ReminderDateTime.format());
                    }
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[]{tw.Email};
                    mail.setToAddresses(toAddresses);
                    mail.setSenderDisplayName('CIBC Call Report');
                    mail.setSubject(tw.t.Subject);
                    //Create a body more complicated than required
                    String content = 'User <b>' + UserInfo.getName() + '</b> has assigned a new task to you.<br>';
                    content += 'CALL REPORT TASK Due Date: ' + tw.t.ActivityDate + '<br>';
                    content += 'Details: <br>';
                    content += tw.t.Description + '</p>'; 
                                
                    /////////////////////////
                    //mail.setHtmlBody('<b>' + tw.t.Description + '</b>');
                    mail.setHtmlBody(content);
                    notifications.add(mail);
                    task_list.add(tw.t);
                }
            }
            //if task_list >200 divide in chunks!!!!!!!
            insert task_list;
            Messaging.sendEmail(notifications); 
            return true;
        }
        catch(DmlException e)
        {
            ApexPages.addMessages(e);
        }
        catch(EmailException ee)
        {
            ApexPages.addMessages(ee);
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
 
        return false;
    }

    //Helper function to initialize/update CIBC listboxes
    private void LoadListOptions()
    {
        optionsIn.clear();
        optionsOut.clear();
        
        List<String> InMapSortedValues = SortByName(InMap);
        List<String> OutMapSortedValues = SortByName(OutMap);
        
        /*for(String item : InMap.keySet())
            optionsIn.add(new SelectOption(item, InMap.get(item)));
        */
        for(String item : InMapSortedValues)
            optionsIn.add(new SelectOption(item, InMap.get(item)));
                
        /*for(String item : OutMap.keySet())
            optionsOut.add(new SelectOption(item, OutMap.get(item)));*/
        for(String item : OutMapSortedValues)
            optionsOut.add(new SelectOption(item, OutMap.get(item)));   
    }
   
    //Helper function to initialize/update Client listboxes
    private void c_LoadListOptions()
    {
        c_optionsIn.clear();
        c_optionsOut.clear();
        
        List<String> c_InMapSortedValues = SortByName(c_InMap);
        List<String> c_OutMapSortedValues = SortByName(c_OutMap);
        
        /*for(String item : c_InMap.keySet())
            c_optionsIn.add(new SelectOption(item, c_InMap.get(item)));
        for(String item : c_OutMap.keySet())
            c_optionsOut.add(new SelectOption(item, c_OutMap.get(item)));
        */
        for(String item : c_InMapSortedValues)
            c_optionsIn.add(new SelectOption(item, c_InMap.get(item)));
        for(String item : c_OutMapSortedValues)
            c_optionsOut.add(new SelectOption(item, c_OutMap.get(item)));
                
    }
    private List<String> SortByName(Map<String, String> map_input)
    {
        List<String> result= new List<String> ();
        List<String> temp= new List<String> ();
        for(String id_val : map_input.keySet() )
            temp.add(map_input.get(id_val)+ ':'+id_val);
        if(temp.size()>0){  
            temp.sort();
            for(String s : temp)
            {
                List<String> sep = s.split(':');
                result.add(sep.get(1));
            }
        }
        return result;      
    }
    public Boolean getLockWrite()
    {
        if (this.Lock == 'True'){
            return false;
        }
        else
            return true;
    }
    
    public Boolean getLockRead()
    {
        if (this.Lock == 'True'){
            return true;
        }
        else
            return false;
    }
    
    /**
     * Method used to return the Meeting Date as a String Date that FLEX can interpret
     *
     */
    public String getMeetingDate()
    {
        return String.valueOf(callReport.Meeting_Date__c);
    }
 }