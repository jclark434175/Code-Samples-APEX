/* 
 * Name: AceUser 
 * Description: Contains details of a User
 *
 * Confidential & Proprietary, 2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AceUser {
    webService String Id;
    webService String Name;
    webService String FirstName;
    webService String LastName;
    webService String Email;
    webService String Phone;
    webService String OtherPhoneNumbers;
    webService String Title;
    webService String EmployeeId;
    webService String TelephonyUsername;
    webService String TelephonyPassword;
	webService String Extension;
	webService String SessionId;
	webService String Username;
	webService String EmployeeName;
	webService String EmployeeTitle;
    
    public AceUser() {
    }
    
    public AceUser(User aUser) {
        if ( aUser == Null ) { return; }
        
        try { this.Id = aUser.Id; } catch ( SObjectException e ) {}
        try { this.Name = aUser.Name; } catch ( SObjectException e ) {}
        try { this.FirstName = aUser.FirstName; } catch ( SObjectException e ) {}
        try { this.LastName = aUser.LastName; } catch ( SObjectException e ) {}
        try { this.Email = aUser.Email; } catch ( SObjectException e ) {}
        try { this.Phone = aUser.Phone; } catch ( SObjectException e ) {}
        try { this.Title = aUser.Title; } catch ( SObjectException e ) {}
        try { this.TelephonyUsername = aUser.Telephony_Username__c; } catch ( SObjectException e ) {}
        try { this.TelephonyPassword = aUser.Telephony_Password__c; } catch ( SObjectException e ) {}
        try { this.OtherPhoneNumbers = aUser.Other_Phone_Numbers__c; } catch ( SObjectException e ) {}
		try { this.Extension = aUser.Extension; } catch ( SObjectException e ) {}
		try { this.EmployeeId = aUser.ST_ACE__Employee_Id__c; } catch ( SObjectException e ) {}
		try { this.Username = aUser.Username; } catch (SObjectException e ) {}

    }
    
    public AceUser ( Id UId , String Name ) {
        this.Id = UId;
        this.Name = Name;
    }
            
//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified AceUser record to the
//          specified list of lists of AceUser records.  Calls the
//          'list' version of this function, which does all the work.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                        
    public static void listListAdd ( List<List<AceUser>> elemListList , 
                                        AceUser myElem ) {
        listListAdd ( elemListList , new List<AceUser> { myElem } );
    }

//  ============================================================================
//  Method: listListAdd
//
//  Desc:   Utility function to add the specified list of AceUser
//          records to the specified list of lists of AceUser records.
//       
//  Return: Nothing.  The list of lists of records is modified in situ.
//  ============================================================================                    
    public static void listListAdd ( List<List<AceUser>> elemListList , 
                                        List<AceUser> myElemList ) {

        Integer myElemListSize = myElemList.size ();
        if ( myElemListSize == 0 ) {
            return;
        }
        
//      Go through the list of lists, finding the first list that has room for
//      our element list
//      ----------------------------------------------------------------------
        List<AceUser> elemList = Null;
        for ( List<AceUser> listList : elemListList ) {
            if ( listList.size () <= aceUtil.MAX_COLLECTION_SIZE - myElemListSize ) {
                elemList = listList;
                break;
            }
        }
                 
        if ( elemList == Null ) {
            elemList = new List<AceUser> {};
            elemListList.add ( elemList );
        }
        
        elemList.addAll ( myElemList );
    }
    
    //  ============================================================================
    //  Method:         getUserInfo
    //  Description:    Gets the current user information           
    //  Args:           None
    //  Return:         Object AceUser that contains user information                       
    //  Case No:        3666
    //  ============================================================================    
    public static AceUser getUserInfo() {
        
        AceUser aceUsr;     
                
        Employee__c[] employee = [Select User__r.Id, User__r.Name, 
                        User__r.Email, User__r.Title, Id,
                        User__r.FirstName, User__r.LastName ,
                        User__r.Phone, 
                        User__r.Telephony_Username__c, User__r.Telephony_Password__c,
                        User__r.Other_Phone_Numbers__c,
                        User__r.Extension,
                        User__r.Username ,
                        Name ,
                        Title__c
                        From Employee__c 
                        Where User__c = :UserInfo.getUserId()
                        limit 1];
        
        if (employee.Size() > 0) {
            aceUsr = new AceUser ( employee[ 0 ].User__r );
            aceUsr.EmployeeId = employee[ 0 ].Id;
            aceUsr.EmployeeName = employee[ 0 ].Name;
            aceUsr.EmployeeTitle = employee[ 0 ].Title__c;
            aceUsr.SessionId = UserInfo.getSessionId();
        }
        else {
            aceUsr = new AceUser ();
        }

        return aceUsr;
    }

    //  ============================================================================
    //  Method:         getUsers
    //  Description:    Gets the users information          
    //  Args:           None
    //  Return:         List of AceUser that contains user information                      
    //  Case No:        3668
    //  ============================================================================
    public static List<List<AceUser>> getUsers(boolean activeStatus) {
        List<List<AceUser>> returnList = new List<List<AceUser>>();
        
        for(User usr: [Select Id, Name, 
                            FirstName, LastName, Title, Email
                            From User
                            Where IsActive = :activeStatus
                            Order By Name]) {   
                                            
            listListAdd ( returnList , new AceUser(usr) );
        }       

        return returnList;
    }
    
//  ============================================================================
//  Method: getTeamMembers  
//  Desc:   Gets team members corresponding to the specified Employee Id.
//  Args:   emplId - the employee Id
//  Return:                     
//  Case No: 3720
//  ============================================================================
    public static List<AceUser> getTeamMembers ( Id emplId ) {
    
        List<AceUser> returnList = new List<AceUser> {};
        
//      Determine the Teams the employee belongs to.
//      --------------------------------------------
        Set<Id> teamIdSet = new Set<Id> {};
        for ( Team_Member__c tm : [select Team__c from Team_Member__c
                                    where Employee__c = :emplId
                                    and Team__c != Null]
                            ) {
            teamIdSet.add ( tm.Team__c );
        }
        
        if ( teamIdSet.IsEmpty () ) {
            return returnList;
        }
        
//      Determine the other members of these teams.
//      -------------------------------------------
        Set<Id> emplIdSet = new Set<Id> {};
        Set<Id> userIdSet = new Set<Id> {};
        for ( Team_Member__c tm : [select
                                        Employee__c , 
                                        Employee__r.User__c ,
                                        Employee__r.User__r.Name ,
                                        Employee__r.User__r.FirstName ,
                                        Employee__r.User__r.LastName ,
                                        Employee__r.User__r.Email ,
                                        Employee__r.User__r.Title
                                    from Team_Member__c
                                    where
                                        Team__c in :teamIdSet and
                                        Inactive__c = False and
                                        Employee__r.User__c != Null and
                                        Employee__c != :emplId
                                    order by
                                        Employee__r.User__r.Name
                                    ]
                        ) {
            
//          Uniqueness checks - both on Employee and underlying User.
//          ---------------------------------------------------------
            if ( !emplIdSet.add ( tm.Employee__c ) ) {
                continue;
            }
            if ( !userIdSet.add ( tm.Employee__r.User__c ) ) {
                continue;
            }
            
            AceUser au = new AceUser ( tm.Employee__r.User__r );
            au.EmployeeId = tm.Employee__c;
            returnList.add ( au );
        }
            
        return returnList;                              
    }
}