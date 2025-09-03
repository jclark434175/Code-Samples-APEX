public class CallReportExtensionTests 
{    
    public static testMethod void testCRController_Update() {
        PageReference pageRef = Page.CallReportEdit;
        Test.setCurrentPage(pageRef);
        
        ////Edit CallReport
        Account t_a = new Account(Name='CallReportTestAccount');
        insert t_a;
        if(t_a.Id == null){ System.debug('!!!!!!!!!!!!!!!!!!!Account not created'); return;}
 
		User[] users = AceTestUtil.createTestUsers ();

		Employee__c[] empls = AceTestUtil.getTestEmployees ( users , True );
		Employee__c t_e1 = empls[ 0 ];
		Employee__c t_e2 = empls[ 1 ];
        
        System.debug('!!!!!!!!!!!!!!! USER: ' + users[0].Name + ', '+ users[0].Email);       
        System.debug('!!!!!!!!!!!!!!! USER: ' + users[1].Name + ', '+ users[1].Email);
        
        if(t_e1==null) {System.debug('!!!!!!!!!!!!!!!!!!!Employee not created'); return;}
        System.debug('!!!!!!!!!!!!!!! EMPLOYEES: ' + t_e1.Name + ', '+ t_e1.Id + '; ' + t_e2.Name + ', '+ t_e2.Id);
         
        Account_Coverage__c t_ac1 = new Account_Coverage__c(Account__c=t_a.Id, Employee__c=t_e1.Id); //, Employee_Team_ID__c='123');
        insert t_ac1;
        Account_Coverage__c t_ac2 = new Account_Coverage__c(Account__c=t_a.Id, Employee__c=t_e2.Id); //Employee_Team_ID__c='1234');
        insert t_ac2;
        if(t_ac1.Id==null || t_ac2.Id==null) {System.debug('!!!!!!!!!!!!!!!!!!!Account Coverage not created'); return;}
        System.debug('!!!!!!!!!!!!!!! ACC COVERAGE1: ' + t_ac1.Name + ', '+ t_ac1.Id);
        System.debug('!!!!!!!!!!!!!!! ACC COVERAGE2: ' + t_ac2.Name + ', '+ t_ac2.Id);
        
        Contact t_c1 = new Contact(FirstName='John', LastName='Green', AccountID=t_a.Id);
        insert t_c1;
        Contact t_c2 = new Contact(FirstName='John', LastName='Brown', AccountID=t_a.Id);
        insert t_c2;
        if(t_c1.Id == null || t_c2.Id==null) {System.debug('!!!!!!!!!!!!!!!!Contacts not created'); return;}
        System.debug('!!!!!!!!!!!!!!! CONTACTS: ' + t_c1.Id + ', '+ t_c2.Id);
        Call_Report__c callreport = new Call_Report__c(Client__c=t_a.Id, Meeting_Date__c=Datetime.Now(), 
            Meeting_Type__c='Conference', Notes__c='notes');
        insert callreport;
        if(callreport.Id == null) {System.debug('!!!!!!!!!!!!!!!!CALL REPORT not created'); return;}
        Call_Report_Attendee_Internal__c INTERNAL = new Call_Report_Attendee_Internal__c();
        INTERNAL.Call_Report__c = callreport.Id;
        INTERNAL.Employee__c = t_e1.Id;
        insert INTERNAL;
        Call_Report_Attendee_Client__c EXTERNAL = new Call_Report_Attendee_Client__c();
        EXTERNAL.Call_Report__c = callreport.Id;
        EXTERNAL.Contact__c = t_c1.Id;
        insert EXTERNAL;
        
        //create a task
        Task t_t = new Task(OwnerId = UserInfo.getUserId(), Priority = 'Normal',Type='Other',
                WhatId = callreport.Id, WhoId=t_c1.Id, ActivityDate=Date.today());
        insert t_t;
        
        
        //Call_Report__c callreport =[Select Id, Name from Call_Report__c LIMIT 1];
        /////////////////////////////////////////////////////////////////////////
        System.debug('!!!!!!!CALLREPORT UPDATED '+ callreport.Id);
        
        ApexPages.currentPage().getParameters().put('id',callreport.Id);
        String ret='/apex/FIC_Client_View?id=' + t_a.Id;
        ApexPages.currentPage().getParameters().put('retURL', ret);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(callreport);
        CallReportExtension controller = new CallReportExtension(sc);
        
        System.assert(controller.getSubtitle().startsWith('CR'), 'Error: Subtitle not set correctly');
        System.assert(controller.getItemsIn().size()==1, 'Error in initializing the page');
        System.assert(controller.getItemsOut().size()==1, 'Error in initializing the page');
        System.assert(controller.getc_ItemsIn().size()==1, 'Error in initializing the page');
        System.assert(controller.getc_ItemsOut().size()==1, 'Error in initializing the page');
        System.assert(controller.getsearchEmp()=='', 'Error initializing property searchEmp');
        System.assert(controller.getsearchCtn()=='', 'Error initializing property searchCtn');
        System.assert(controller.getTasks().size()==1, 'Error initializing the tasks');
        
        //===========================
        controller.setsearchEmp('Impossible');
        controller.Find();
        System.assert(controller.getItemsIn().size()==1, 'Error CIBC Find');
        System.assert(controller.getItemsIn()[0].getLabel()=='--None--', 'Error CIBC Find');    
        controller.Clear();
        System.assert(controller.getItemsIn().size()==1, 'Error Clear CIBC function');
        
        controller.setsearchCtn('*');
        controller.c_Find();
        System.assert(controller.getc_ItemsIn().size()==1, 'Error Client Find');
        System.assert(controller.getc_ItemsIn()[0].getLabel()=='--None--', 'Error Client Find');    
        controller.c_Clear();
        System.assert(controller.getc_ItemsIn().size()==1, 'Error Clear Client function');
        
        //============================
        String [] att_in = controller.getInternalAttIn();
        System.assert(att_in.size()==0, 'Error reading CIBC selection box1');
        String[] set_in = new String[]{t_e2.Id};
        controller.setInternalAttIn(set_in);
        System.assert(controller.getInternalAttIn().size()==1, 'Error setting CIBC IN  selection');
        controller.addInternals();
        System.assert(controller.getItemsIn().size()==0, 'Error addInternals');
        System.assert(controller.getItemsOut().size()==2, 'Error addInternals');
        String[] att_out = controller.getInternalAttOut();
        System.assert(att_out.size()==0, 'Error reading CIBC selection box2');
        String[] set_out = new String[]{t_e1.Id};
        controller.setInternalAttOut(set_out);
        System.assert(controller.getInternalAttOut().size()==1, 'Error setting CIBC OUT  selection');
        controller.removeInternals();
        System.assert(controller.getItemsIn().size()==1, 'Error removeInternals');
        System.assert(controller.getItemsOut().size()==1, 'Error removeInternals');
        
        String [] ctn_in = controller.getExternalAttIn();
        System.assert(ctn_in.size()==0, 'Error reading Client selection box1');
        String[] c_set_in = new String[]{t_c2.Id};
        controller.setExternalAttIn(c_set_in);
        System.assert(controller.getExternalAttIn().size()==1, 'Error setting Client IN  selection');
        controller.addExternals();
        System.assert(controller.getc_ItemsIn().size()==0, 'Error addExternals');
        System.assert(controller.getc_ItemsOut().size()==2, 'Error addExternals');
        String[] ctn_out = controller.getExternalAttOut();
        System.assert(ctn_out.size()==0, 'Error reading Client selection box2');
        String[] c_set_out = new String[]{t_c1.Id};
        controller.setExternalAttOut(c_set_out);
        System.assert(controller.getExternalAttOut().size()==1, 'Error setting Client OUT selection');
        controller.removeExternals();
        System.assert(controller.getc_ItemsIn().size()==1, 'Error removeExternals');
        System.assert(controller.getc_ItemsOut().size()==1, 'Error removeExternals');
        
        //=============================
        Task t = controller.getmyTask();
        t.ActivityDate=Date.today();
        Contact c = [Select Id from Contact LIMIT 1];
        t.WhoId=c.Id; //t_c1.Id;
        controller.setmyTask(t);
        
        controller.AddTask();
        System.assert(controller.getTasks().size()==2, 'Error AddTask');
        
        String nextPage = controller.saveAttTasks().getUrl();
        System.assertEquals(ret, nextPage);
    }
    public static testMethod void testCRController_New() {
        PageReference pageRef = Page.CallReportEdit;
        Test.setCurrentPage(pageRef);
        
        //New CallReport
        Call_Report__c callreport=new Call_Report__c();
        Account t_a = new Account(Name='CallReportTestNewAccount');
        insert t_a;
        if(t_a.Id == null){ System.debug('!!!!!!!!!!!!!!!!!!!Account not created'); return;}
       
        ApexPages.currentPage().getParameters().put('XXXXXXXXXXXXXXXXX_lkid',t_a.Id);
        String ret='/apex/FIC_Client_View?id='+ t_a.Id;
        ApexPages.currentPage().getParameters().put('retURL', ret);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(callreport);
        CallReportExtension controller = new CallReportExtension(sc);
       
        String nextPage = controller.saveAttTasks().getUrl();
        System.assertEquals(ret, nextpage);
        
    }
    public static testMethod void testCRController_New1() {
        PageReference pageRef = Page.CallReportEdit;
        Test.setCurrentPage(pageRef);
        
        //New CallReport, no parameters
        Call_Report__c callreport=new Call_Report__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(callreport);
        CallReportExtension controller = new CallReportExtension(sc);
        System.assert(controller.saveAttTasks()==null, 'Fatal error on page');
                
    }
}