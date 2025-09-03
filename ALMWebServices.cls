/**
 * Name: ALMWebServices 
 * Description: Contains S/Ps for returning data to be rendered in FlexGrids.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
   
global class ALMWebServices 
{          
     
    //  ============================================================================
    //  Method:      getUserInfo
    //  Description:    See AceUser.getUserInfo
    //  ============================================================================    
    webService static AceUser getUserInfo() {
        
        return AceUser.getUserInfo ();
    }
        
    //  ============================================================================
    //  Method:      getUsers
    //  Description:    See AceUser.getUsers
    //  ============================================================================
    webService static List<List<AceUser>> getUsers(boolean activeStatus) {
        
        return AceUser.getUsers ( activeStatus );
    }
    
//  ============================================================================
//  Method: getTeamMembers  
//  Desc:   See AceUser.getTeamMembers
//  ============================================================================
    webService static List<AceUser> getTeamMembers ( Id emplId ) {
    
        return AceUser.getTeamMembers ( emplId );
    }

//  ============================================================================
//  Method: getGroups   
//  Desc:   See AceGroup.getGroups
//  ============================================================================
    webService static List<AceGroup> getGroups () {

        return AceGroup.getGroups (); 
    }      

    //  ============================================================================
    //  Method:      getRoles
    //  Description:    See AceUserRole.getRoles
    //  ============================================================================
    webService static List<AceUserRole> getRoles() {
        
        return AceUserRole.getRoles ();
    }
    
//  ============================================================================
//  Method: getEmployees    
//  Desc:   See Employee.getEmployees
//  ============================================================================
    webService static EmployeePage getEmployees ( String startName , Integer pageSize ) {
    
        return Employee.getEmployees ( startName , pageSize );
    }

//  ============================================================================
//  Method: getContactLists
//  Desc:   See ContactList.getContactLists
//  ============================================================================
    webService static List<ContactList> getContactLists( String userId,
                                                            boolean withListEntries ,
                                                            Boolean bSharedOnly ) {   

        return ContactList.getContactLists ( userId , withListEntries , bSharedOnly );
    }          
                    
//  ========= ===================================================================
//  Method: getListMembership   
//  Desc:   See ContactList.getListMembership 
//  ============================================================================
    webService static List<ContactList> getListMembership ( Id contId ) {
        
        return ContactList.getListMembership ( contId );
    }
    
    //  ============================================================================
    //  Method: getContactsForList  
    //  Desc:   See ContactListEntry.getContactsForList 
    //  ============================================================================
    webService static List<List<ContactListEntry>> getContactsForList(String[] contactListIds, 
                                                                        boolean isActive,
                                                                        boolean bGetLastInteraction ,
                                                                        Id userId ) {
        
        return ContactListEntry.getContactsForList ( contactListIds , isActive ,
                                                    bGetLastInteraction , userId );
    }

//  ============================================================================
//  Method: getCoverageForAccounts  
//  Desc:   See AccountCoverage.getCoverageForAccounts 
//  ============================================================================
    webService static AccountCoverage[] getCoverageForAccounts ( Id[] acctIdList ) {
        
        return AccountCoverage.getCoverageForAccounts ( acctIdList );
    }
    
//  ============================================================================
//  Method: getCallReportsByAccount  
//  Desc:   Retrieve the Call Reports for a particular account Id.
//  ============================================================================
    webService static SObjectPage getCallReportsByAccount ( Id accountId ,
                                                                String startName ,
                                                                Integer pageSize ) 
    {
		return CallReport.getCallReportByAccount(accountId, startName, pageSize); 	
    }
        
//  ============================================================================
//  Method: getContactCoverage  
//  Desc:   See ContactCoverage.getContactCoverage 
//  ============================================================================
    webService static ContactCoveragePage getContactCoverage ( Id emplId ,
                                                                String startName ,
                                                                Integer pageSize ) {
        
        return ContactCoverage.getContactCoverage ( emplId , startName , pageSize );
    }

//  ============================================================================
//  Method: getEmployeesCoveringContacts  
//  Desc:   See ContactCoverage.getEmployeesCoveringContacts 
//  ============================================================================
    webService static List<ContactCoverage> getEmployeesCoveringContacts ( Id[] contIdList ) {
        
        return ContactCoverage.getEmployeesCoveringContacts ( contIdList );
    }
    
//  ============================================================================
//  Method: getCoverageForContacts  
//  Desc:   See ContactCoverage.getCoverageForContacts 
//  ============================================================================
    webService static ContactCoverage[] getCoverageForContacts ( Id[] contIdList ) {
        
        return ContactCoverage.getCoverageForContacts ( contIdList );
    }
        
    //  ============================================================================
    //  Method: getListShare
    //  Desc:   See  ListShare.getListShare
    //  ============================================================================    
    webService static List<List<ListShare>> getListShare(String[] contactListIds) {
        
        return ListShare.getListShare ( contactListIds );
    }
    
    //  ============================================================================
    //  Method:      getAccount
    //  Description:    See AceAccount.getAccount
    //  ============================================================================    
    webService static AceAccount getAccount(String accountId) { 
        
        return AceAccount.getAccount ( accountId );
    }
    
    //  ============================================================================
    //  Method:      getAccounts
    //  Description:    See AceAccount.getAccounts
    //  ============================================================================
    webService static List<List<AceAccount>> getAccounts(String[] accountIds) { 
        
        return AceAccount.getAccounts ( accountIds );   
    }

//  ============================================================================
//  Method: searchAccountsByAccountName 
//  Desc:   See AceAccount.searchAccountsByAccountName
//	...............................TO BE DEPRECATED............................
//  ============================================================================
    webService static List<AceAccount> searchAccountsByAccountName ( String acctName ) {
        
        System.debug ( 'ACCT NAME : [' + acctName + ']' );
        return AceAccount.searchAccountsByAccountName ( acctName );
    }
//  ============================================================================
//  Method: searchAccountsByAccountNamePage 
//  Desc:   See AceAccount.searchAccountsByAccountNamePage
//  ============================================================================
    WebService static AceAccountPage searchAccountsByAccountNamePage ( String acctName ,
	                                                                     String startName ,
	                                                                     Integer pageSize  ) {
        return AceAccount.searchAccountsByAccountName ( acctName, startName, pageSize );
    }
  
//  ============================================================================
//  Method: getAccountsCoveredByEmployee 
//  Desc:   See AceAccount.getAccountsCoveredByEmployee
//  ============================================================================
    webService static AceAccountPage getAccountsCoveredByEmployee ( Id emplId ,
                                                                    String startName ,
                                                                    Integer pageSize ) {
        
        return AceAccount.getAccountsCoveredByEmployee ( emplId , startName , pageSize );
    }


//  ============================================================================
//  Method:      getInterests
//  Description:    See Interest.getInterests
//  ============================================================================
    WebService static InterestPage getInterests(String contactId, String accountId, 
                                                  String firstSym , String[] symbols  ) {
        
        return Interest.getInterests ( contactId , accountId , firstSym , symbols );
    }

//  ============================================================================
//  Method:      getRecentInterests
//  Description:    See Interest.getRecentInterests
//  ============================================================================
    webService static InterestPage getRecentInterests(String contactId, String accountId, 
                                                  String firstSym , Integer recordLimit,
                                                  String[] symbols ) {
        
        return Interest.getRecentInterests ( contactId , accountId , firstSym , recordLimit, symbols );
    }

    
//  ============================================================================
//  Method: searchInterest  
//  Desc:   See Interest.searchInterest
//	.............TO BE DEPRECATED WHEN ALL VERSIONS OF ALM USES searchInterestPage 
//  ============================================================================
    webService static InterestPage searchInterest ( Id acctId , String contName , String firstSym ) {
        
        return Interest.searchInterest ( acctId , contName , firstSym );
    }
//  ============================================================================
//  Method: searchInterest  
//  Desc:   See Interest.searchInterest
//  ============================================================================
    WebService static InterestPage searchInterestPage ( Id acctId , String contName , String firstSym, Integer pageSize ) {
        return InterestOLD.searchInterest ( acctId , contName , firstSym, pageSize );
    }    

//  ============================================================================
//  Method: getInterestsByContactSymReason  
//  Desc:   See Interest.getInterestsByContactSymReason
//  ============================================================================
    webService static Interest[] getInterestsByContactSymReason ( Id[] contIdList ,
                                                                    String[] symList ,
                                                                    String reason ) {
                                                                        
        return Interest.getInterestsByContactSymReason ( contIdList , symList , reason );  
    }

//  ============================================================================
//  Method: getRecentInteractions   
//  Desc:   See AceTask.getRecentInteractions
//  ============================================================================
    webService static AceTaskPage getRecentInteractions (
                                                    Id accountId ,
                                                    Id contactId ,
                                                    Integer inPastNDays ,
                                                    DateTime firstCreatedDate
                                                ) {
        
        return AceTask.getRecentInteractions ( accountId , contactId , inPastNDays , firstCreatedDate );
    } 

//  ============================================================================
//  Method: getUserTasksByRecordType    
//  Desc:   See AceTask.getUserTasksByRecordType
//  ============================================================================
    webService static List<AceTask> getUserTasksByRecordType ( Id userId ,
                                                            Id recordTypeId
                                                        ) {
        
        return AceTask.getUserTasksByRecordType ( userId , recordTypeId );
    } 
    
//  ============================================================================
//  Method: searchInterestsBySymbol 
//  Desc:   See AceContact.searchInterestsBySymbol
//  ============================================================================
    webService static List<List<AceContact>> searchInterestsBySymbol ( 
                                                Id userId ,
                                                String[] symList ,
                                                String scope ,
                                                Boolean bGetLastInteraction ) {

        if ( userId == Null ) {
            userId = UserInfo.getUserId ();
        }

        return AceContact.searchInterestsBySymbol ( userId , symList , scope ,
                                                    bGetLastInteraction );
    }
    
//  ============================================================================
//  Method: getContactsByInterestSymbol 
//  Desc:   Retrieves Contact and Account information for all Interests in the
//        	specified list of Symbols.  This will be paged based off the Account Name,
//          since contacts are not required for Interests.
//  Args:   userId - the User to search on behalf of.
//        symList - list of Symbols we are searching for Interests for.
//        scope - Search constraint directive:
//          All Coverage - any account or contact
//          My Accounts  - only Accounts covered by the userId
//          My Contacts  - 'My Accounts' plus Contacts covered by the userId
//  Return: List of AceContact records.              
//  Case No: 3702
//  ============================================================================
    webService static AceContactPage getContactsByInterestSymbols(Id userId ,
				                                                String[] symList ,
				                                                String scope ,
				                                                Boolean bGetLastInteraction,
				                                                String startName,
				                                                Integer pageSize)
	{
		if ( userId == Null ) {
            userId = UserInfo.getUserId ();
        } 
        
		return AceContact.getContactsByInterestSymbols( userId, symList, scope, bGetLastInteraction, startName, pageSize );
	}

//  ============================================================================
//  Method:      getContactsByAcctName
//  Description:    See aceContact.getContactsByAcctName
//  ============================================================================
    webService static AceContactPage getContactsByAcctName ( String acctName ,
                                                                String startName ,
                                                                Integer pageSize ) {
        
        return aceContact.getContactsByAcctName ( acctName , startName , pageSize );
    }

//  ============================================================================
//  Method:      getContactsByAcctId
//  Description:    See aceContact.getContactsByAcctId
//  ============================================================================
    webService static AceContactPage getContactsByAcctId ( Id[] acctIdList ,
                                                            String startName ,
                                                            Integer pageSize ) {
        
        return aceContact.getContactsByAcctId ( acctIdList , startName , pageSize );
    }

//  ============================================================================
//  Method:      getContactsByName
//  Description:    See aceContact.getContactsByName
//  ============================================================================
    webService static AceContactPage getContactsByName ( String contName , 
                                                            String startName ,
                                                            Integer pageSize ) {
        
        System.debug( '[' + contName + '] [' + startName + '] [' + pageSize + ']' ); 
        return aceContact.getContactsByName ( contName , startName , pageSize );
    }
    
//  ============================================================================
//  Method:      getContactctsByNameAndAcctName
//  Description:    See aceContact.getContactsByNameAndAcctName
//  ============================================================================

    webService static AceContactPage getContactsByNameAndAcctName ( String contName ,
                                                                    String acctName ,
                                                                    String startName ,
                                                                    Integer pageSize ) {

        return aceContact.getContactsByNameAndAcctName ( contName , acctName ,
                                                            startName , pageSize );
    }
    
//  ============================================================================
//  Method: searchSecurityMaster    
//  Desc:   See SecurityMaster.searchSecurityMaster
//	Future:	'InterestSubject.searchInterestSubjectsByName(    	
//		String intSubName ,
//    	String[] fields,
//    	String startName ,
//		Integer pageSize) is the InterestMaster successor to this method 
//  ============================================================================
    webService static List<List<SecurityMaster>> searchSecurityMaster ( 
                                                            String symbols ) {
    
        return SecurityMaster.searchSecurityMaster ( symbols );
    }

//  ============================================================================
//  Method: getEmployeesCoveringSymbols 
//  Desc:   See SecurityMasterCoverage.getEmployeesCoveringSymbols
//  ============================================================================
    webService static List<SecurityMasterCoverage> getEmployeesCoveringSymbols ( 
                                                                   String[] symList ) {
    
        return SecurityMasterCoverage.getEmployeesCoveringSymbols ( symList );
    }
    

//  ============================================================================
//  Method: searchMarketingEvents   
//  Desc:   See MarketingEvent.searchMarketingEvents
//  ============================================================================
    webService static List<MarketingEvent> searchMarketingEvents ( 
                                                            String eventFromDate ,
                                                            String eventToDate ) {
    
    	/** STUBBED OUT FOR TD ROLLOUT DEC 12 08 - SEAN -   
            return new MarketingEvent[] {};  */
            
        return MarketingEvent.searchMarketingEvents ( eventFromDate , eventToDate );         
    }
//  ============================================================================
//  Method: getFilteredMarketingEvents   
//  Desc:   See MarketingEvent.getFilteredMarketingEvents
//  ============================================================================
    webService static MarketingEvent[] getFilteredMarketingEvents (
                                                    String eventFromDate ,
                                                    String eventToDate ,
                                                    String city ,
                                                    String searchText ) {
        /** STUBBED OUT FOR TD ROLLOUT DEC 12 08 - SEAN -          
        return new MarketingEvent[] {};  
        */
        
        return MarketingEvent.getFilteredMarketingEvents ( eventFromDate , eventToDate ,
                                                                city , searchText );         
    }

//  ============================================================================
//  Method: searchMarketingEventsByContact
//  Desc:   See MarketingEvent.searchMarketingEventsByContqct
//  ============================================================================
    webService static List<MarketingEvent> searchMarketingEventsByContact ( 
                                                            String eventFromDate ,
                                                            String eventToDate ,
                                                            Id contId ) {
    	/** STUBBED OUT FOR TD ROLLOUT DEC 12 08 - SEAN -  
        	return new MarketingEvent[] {}; */
          
          return MarketingEvent.searchMarketingEventsByContact (
                                              eventFromDate , eventToDate , contId );         
    }

//  ============================================================================
//  Method: getMarketingEventCities   
//  Desc:   See MarketingEventCity.getMarketingEventCities
//  ============================================================================
    webService static MarketingEventCity[] getMarketingEventCities () {
    
    	/** STUBBED OUT FOR TD ROLLOUT DEC 12 08 - SEAN    
         return new MarketingEventCity[] {}; */         
         return MarketingEventCity.getMarketingEventCities ();         
    }

//  ============================================================================
//  Method: getResearchPreferences  
//  Desc:   See ResearchPreference.getResearchPreferences
//  ============================================================================
    webService static List<ResearchPreference> getResearchPreferences ( String contId ) {
        
        return ResearchPreference.getResearchPreferences ( contId );
        /** STUBBED OUT FOR CIBC ROLLOUT JAN 26 09 - JENNY -
        return new ResearchPreference[] {};*/
    }

//  ============================================================================
//  Method: getRPContactsByMetadataId  
//  Desc:   See ResearchPreference.getRPContactsByMetadataId
//  ============================================================================
    webService static AceContactPage getRPContactsByMetadataId ( String[] rpmIdList ,
                                                                String firstName ,
                                                                Integer pageSize ) {
        /** STUBBED OUT FOR CIBC ROLLOUT JAN 26 09 - JENNY -
        return new AceContactPage();
        */
        return AceContact.getRPContactsByMetadataId ( rpmIdList , firstName , pageSize );
        

    }

//  ============================================================================
//  Method: getResearchPreferenceMetadata  
//  Desc:   See ResearchPreferenceMetadata.getResearchPreferences
//  ============================================================================
    webService static ResearchPrefMetadataPage
                            getResearchPreferenceMetadata ( String recTypeId , 
                                                            String firstName ,
                                                            Integer pageSize ) {
/** STUBBED OUT FOR CIBC ROLLOUT JAN 26 09 - JENNY -
        return new ResearchPrefMetadataPage();
                */
        return ResearchPreferenceMetadata.getResearchPreferenceMetadata ( recTypeId ,
                                                                            firstName ,
                                                                            pageSize );
        
    }
    
//  ============================================================================
//  Method: getContactsByConferenceId  
//  Desc:   See AceContact.getResearchPreferences
//  ============================================================================
    webService static AceContactPage getContactsByConferenceId ( String[] confIdList ,
                                                                String startName ,
                                                                Integer pageSize
                                                            ) {
        //return new AceContactPage();                                                        
        // STUBBED OUT FOR CIBC ROLLOUT JAN 26 09 - SEAN -
        //GD - Feb11,2009 uncomment to fix the defect 
        //606 - TD: Contacts that have a "Cancelled" or "No Show" are appearing on the distribution
        /** STUBBED OUT FOR CIBC ROLLOUT MAY 19th 2008 -         
        return AceContact.getContactsByConferenceId ( confIdList , startName , pageSize );
        */
        
        return new AceContactPage();         
    }  
   
// =============================================================================
// =============================================================================
//
//  WRITE METHODS
//  
// =============================================================================
// =============================================================================

//  ============================================================================
//  Method: deleteRecords
//  Desc:   Deletes the records with the specified object Ids.  
//  Args:   sObjIds - Ids of the records to delete.
//  Return: List of Booleans, True for successful deletions; False for failures.
//  ============================================================================
    webService static AceWSResultList deleteRecords ( Id[] sObjIds ) {
        
        return aceUtil.deleteRecords ( sObjIds );
    }
    
    //  ============================================================================
    //  Method:      upsertListShares
    //  Description:    Updates or inserts the given array of objects          
    //  Args:          Array of sObjects
    //  Return:      Returns array of String; 
    //                      Record Id if success,
    //                      'false' if failure                    
    //  Case No:        3652
    //  ============================================================================    
    webService static AceWSResultList upsertListShares(List_Share__c[] listShares) {
        return aceUtil.upsertRecords(listShares);
    }
    
    //  ============================================================================
    //  Method:      updateListShares
    //  Description:    Updates the given array of list shares        
    //  Args:          Array of list share
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  Case No:        3652
    //  ============================================================================    
    webService static AceWSResultList updateListShares(List_Share__c[] listShares) {
        return aceUtil.updateRecords(listShares);
    }
    
    //  ============================================================================
    //  Method:      updateUsers
    //  Description:    Updates the given array of users      
    //  Args:          Array of users
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  Case No:        3990
    //  ============================================================================    
    webService static AceWSResultList updateUsers(User[] users) {
        return aceUtil.updateRecords(users);
    }

//  ============================================================================
//  Method:      insertContacts
//  Description:    Inserts the given list of Contact records.       
//  Args:          Array of Contact records
//  Return:      AceWSResultList containing results of insert                       
//  Case No:        3928
//  ============================================================================    
    webService static AceWSResultList insertContacts ( Contact[] contacts ) {
        return aceUtil.upsertRecords ( contacts );
    }  

//  ============================================================================
//  Method:      updateContacts
//  Description:    Updates the given list of Contact records.       
//  Args:          Array of Contact records
//  Return:      AceWSResultList containing results of update                       
//  Case No:        3934
//  ============================================================================    
    webService static AceWSResultList updateContacts ( Contact[] contacts ) {
        return aceUtil.upsertRecords ( contacts );
    }  
 
    //  ============================================================================
    //  Method:      upsertContactLists
    //  Description:    Updates or inserts the given array of objects          
    //  Args:          Array of sObjects
    //  Return:      Returns array of String; 
    //                      Record Id if success,
    //                      'false' if failure                    
    //  Case No:        3651
    //  ============================================================================    
    webService static AceWSResultList upsertContactLists(Contact_List__c[] contactLists) {
        System.debug ( 'CONTACT LISTS :\n' + contactLists );
        return aceUtil.upsertRecords(contactLists);
    }  
    
    //  ============================================================================
    //  Method:      updateContactLists
    //  Description:    Updates the given array of contact lists            
    //  Args:          Array of Contact list
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  Case No:        3651
    //  ============================================================================    
    webService static AceWSResultList updateContactLists(Contact_List__c[] contactLists) {
        return aceUtil.updateRecords(contactLists);
    }  
    
    //  ============================================================================
    //  Method:      upsertContactListEntries
    //  Description:    Updates or inserts the given array of objects          
    //  Args:          Array of sObjects
    //  Return:      Returns array of String; 
    //                      Record Id if success,
    //                      'false' if failure                    
    //  Case No:        3650
    //  ============================================================================    
    webService static AceWSResultList upsertContactListEntries (Contact_List_Entry__c[] cleList ) {
        return aceUtil.upsertRecords( cleList );
    }  
    
    //  ============================================================================
    //  Method:      updateContactListEntries
    //  Description:    Updates the given array of List Items          
    //  Args:          Array of list item
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  Case No:        3650
    //  ============================================================================    
    webService static AceWSResultList updateContactListEntries(Contact_List_Entry__c[] cleList ) {
        return aceUtil.updateRecords( cleList);
    }  

    //  ============================================================================
    //  Method:      deleteContactListEntries
    //  Description:    Deletes the specified contacts from each list the user owns  
    //  Args:          Contact Id, User Id
    //  Return:      Array of boolean
    //                      true if success
    //                      false if failure                        
    //  Case No:        3681
    //  ============================================================================
    webService static AceWSResultList deleteContactListEntries(String[] contactIds, String ownerId) {
        
        List<Id> cleIdList = new List<Id> {};
        for ( Contact_List_Entry__c cle : [Select Id
                                            From Contact_List_Entry__c
                                            Where Contact_List__r.OwnerId = :ownerId
                                            And Contact__c In :contactIds]
                                    ) {
            cleIdList.add ( cle.Id );
        }
        
        return aceUtil.deleteRecords ( cleIdList );
    }
    
//  ============================================================================
//  Method:      updateContactCoverage
//  Description:    Updates the given list of Contact Coverage records.      
//  Args:          Array of Contact Coverage records
//  Return:      AceWSResultList containing results of update                       
//  Case No:        3890
//  ============================================================================    
    webService static AceWSResultList updateContactCoverage ( Contact_Coverage__c[] ccList ) {
        return aceUtil.updateRecords( ccList );
    }  

//  ============================================================================
//  Method:      upsertContactCoverage
//  Description:    Upserts the given list of Contact Coverage records, then
//                  returns a built-out list of records (complete with Contact
//                  and Employee info) resulting from the upsert.        
//  Args:          Array of Contact Coverage records
//  Return:      List of resulting ContactCoverage records.                     
//  Case No:        3935
//  ============================================================================    
    webService static ContactCoverage[] upsertContactCoverage ( Contact_Coverage__c[] ccList ) {
        AceWSResultList awrl = aceUtil.upsertRecords( ccList );
        Id[] ccIdList = new Id[] {};
        
        for ( AceWSResult awr : awrl.getResultList () ) {
            if ( awr.bSuccess == True ) {
                ccIdList.add ( awr.statusMsg );
            }
        }
        return ContactCoverage.getContactCoverageById ( ccIdList );
    }  
    
   
//  ============================================================================
//  Method: insertInterests
//  Desc:   Inserts Interest__c records per the specified list of Interest 
//          records.    
//  Args:   interestList - list of Interest records to inesrt.
//  Return: List of inserted interestList Ids, blank for failed Inserts.
//  Case No: 3696
//  ============================================================================
    webService static AceWSResultList insertInterests ( Interest__c[] interestsToInsert ) {
        return aceUtil.upsertRecords ( interestsToInsert );
    }
    
//  ============================================================================
//  Method: updateInterests
//  Desc:   Updates Interest__c records per the specified list of Interest 
//          records.    
//  Args:   interestList - list of Interest records to update.
//  Return: List of updated interestList Ids, blank for failed Updates.
//  Case No: 3697
//  ============================================================================
    WebService static AceWSResultList updateInterests ( Interest__c[] interestsToUpdate ) {
    	String TMP_LABEL_STRING = '^Label__c^';
    	for( Integer i=0; i< interestsToUpdate.size(); i++) {
    		if (interestsToUpdate[i].Label__c == TMP_LABEL_STRING) {
    			interestsToUpdate[i].Label__c = '';
    		}
    	} 
        return aceUtil.updateRecords ( interestsToUpdate ); 
    }

//  ============================================================================
//  Method: upsertInterests
//  Desc:   Upserts Interest records per the specified list of Interest records.    
//  Args:   interestsToUpsert - list of Interest records to update.
//  Return: Result of the upsert operation
//  Case No: 4017
//  ============================================================================
    webService static AceWSResultList upsertInterests ( Interest__c[] interestsToUpsert ) {
        return aceUtil.upsertRecords ( interestsToUpsert ); 
    }

//  ============================================================================
//  Method: updateTasks
//  Desc:   Updates Task records per the specified list of Task records.    
//  Args:   taskList - list of Task records to update.
//  Return: List of updated taskList Ids, blank for failed Updates.
//  Case No: 3807
//  ============================================================================
    webService static AceWSResultList updateTasks ( Task[] tasksToUpdate ) {
        return aceUtil.updateRecords ( tasksToUpdate ); 
    }

//  ============================================================================
//  Method: updateTasks
//  Desc:   Updates Task records per the specified list of Task records.    
//  Args:   taskList - list of Task records to update.
//  Return: List of updated taskList Ids, blank for failed Updates.
//  Case No: 3807
//  ============================================================================
    webService static AceWSResultList upsertTasks ( Task[] tasksToUpsert ) {
    	for (Task t : tasksToUpsert) {//RAD DE804 2009-04-22
    	system.debug('***************TASK UPSERT: Status = ' + t.Status  
    	+ ' | Created_For_Name = ' + t.Created_For_Name__c
    	+ ' | Description = ' + t.Description
    	+ ' | Interaction_Type = ' + t.Interaction_Type__c
    	+ ' | Label = ' + t.Label__c);
    	}
        return aceUtil.upsertRecords ( tasksToUpsert ); 
    }
    
//  ============================================================================
//  Method: getEmailTemplates
//  Desc:   Retrieves email templates contained in specified folders
//  Args:   folderNames - list of folder names
//  Return: Active email templates contained in the specified folders
//  Case No: 3960
//  ============================================================================
    webService static List<EmailTemplate> getEmailTemplates ( String[] folderNames ) {
        return AceEmailTemplate.getEmailTemplates ( folderNames ); 
    }
    
//  ============================================================================
//  Method: sendBulkEmail
//  Desc:   Sends a templated email to one or more contacts
//  Args:   saveActivity - Indicates if an activity should be logged to track the email sent
//          templateId - The template to use
//          contactIds - The contacts the email should be sent to
//          documentIds - The documents that should be used as attachments
//          whatId      - The record to merge with
//  Return: Result of each email sent
//  Case No: 
//  ============================================================================
    webService static AceWSResultList sendBulkEmail ( Boolean saveActivity, Id templateId, Id whatId, Id[] contactIds, Id[] documentIds) {
        return AceEmailTemplate.sendBulkEmail ( saveActivity, templateId, whatId, contactIds, documentIds ); 
    }
    
    
//  ============================================================================
//  Method: sendPlainTextBulkEmail
//  Desc:   Sends a plain text email to one or more contacts
//  Args:   saveActivity - Indicates if an activity should be logged to track the email sent
//          contactIds - The contacts the email should be sent to
//          documentIds - The documents that should be used as attachments
//          subject - The subject of the email
//          body - The body of the email
//  Return: Result of each email sent
//  Case No: 
//  ============================================================================    
    webService static AceWSResultList sendPlainTextBulkEmail( Boolean saveActivity, String subject, String body, Id[] contactIds, Id[] documentIds ) {
        return AceEmailTemplate.sendPlainTextBulkEmail( saveActivity, subject, body, contactIds, documentIds );
    }
 
//  ============================================================================
//  Method: createEmailTemplate
//  Desc:   Creates the EmailTemplate
//  Args:   template - the template to create
//  Return: Status of the template created
//  Case No: 
//  ============================================================================
    webService static AceWSResultList createEmailTemplate ( EmailTemplate emailTemplate ) {
        return AceEmailTemplateUtil.createEmailTemplate ( emailTemplate );
    }
    
//  ============================================================================
//  Method: cloneEmailTemplateAttachments
//  Desc:   Clones attachments from one template to another
//  Args:   template - the template where attachments are clone to
//          baseTemplateId  - the template from which attachments are cloned
//  Return: Status of each attachment cloned
//  ============================================================================
    webService static AceWSResultList cloneEmailTemplateAttachments ( Id emailTemplateId, Id baseTemplateId ) {
        return AceEmailTemplateUtil.cloneEmailTemplateAttachments ( emailTemplateId, baseTemplateId );
    }

//  ============================================================================
//  Method: deleteEmailTemplate
//  Desc:   Deletes the EmailTemplate
//  Args:   template - the templates to create
//  Return: Status of each template to be created
//  Case No: 
//  ============================================================================
    webService static AceWSResultList deleteEmailTemplate ( Id templateId, Id folderId ) {
        return AceEmailTemplateUtil.deleteEmailTemplate ( templateId, folderId );
    }
    
//  ============================================================================
//  Method: getMarketingEventMeetings
//  Desc:   Gets Marketing Event Meeting records by Marketing Event Id
//          parameters - marketing event Id
//  Args:   eventId - the Marketing Event Id
//  Return: List of marekting event meeting records
//  Case:   3979
//  ============================================================================
    /** STUBBED OUT FOR TD ROLLOUT (Code In Progress) DEC 12 08 - SEAN -    
        This part of the code should be kept stubbed unless is the ALM Dev Org 
        
    webService static List<MarketingEventMeeting> getMarketingEventMeetings ( Id eventId ) {    
        return MarketingEventMeeting.getMarketingEventMeetings ( eventId );
    }

//  ============================================================================
//  Method: getMarketingEventSlots
//  Desc:   Gets Marketing Event Slot records by Marketing Event Id
//          parameters - marketing event Id
//  Args:   eventId - the Marketing Event Id
//  Return: List of marekting event slot records
//  Case:   3979
//  ============================================================================
    webService static List<MarketingEventSlot> getMarketingEventSlots ( Id eventId ) {  
        return MarketingEventSlot.getMarketingEventSlots ( eventId );
    }
*/       
//  ============================================================================
//  Method: insertMarketingEventMeetings
//  Desc:   Inserts Marketing_Event_Meeting__c records per the specified list of
//          Meeting records.    
//  Args:   meetingList - list of Marketing Event Meeting records to inesrt.
//  Return: List of inserted meetingList Ids, blank for failed Inserts.
//  Case No: 3980 (To be implemented after TD Deployment)
//  ============================================================================
    webService static AceWSResultList insertMarketingEventMeetings ( Marketing_Event_Meeting__c[] meetingsToInsert ) {
        return aceUtil.upsertRecords ( meetingsToInsert );
    }

//  ============================================================================
//  Method: updateMarketingEventMeetings
//  Desc:   Updates Marketing_Event_Meeting__c records per the specified list of
//          Meeting records.    
//  Args:   meetingList - list of Marketing Event Meeting records to update.
//  Return: List of updated meetingList Ids, blank for failed Updates.
//  Case No: 3981 (To be implemented after TD Deployment)
//  ============================================================================
    webService static AceWSResultList updateMarketingEventMeetings ( Marketing_Event_Meeting__c[] meetingsToUpdate ) {
        return aceUtil.updateRecords ( meetingsToUpdate ); 
    }
        
//  ============================================================================
//  Method: deleteMarketingEventMeetings
//  Desc:   Deletes Marketing_Event_Meeting__c records per the specified list of
//          Meeting records. 
//  Args:   meetingList - list of Marketing Event Meeting records to delete.
//  Return: Array of boolean
//              true if success
//              false if failure                        
//  Case No: 3982 (To be implemented after TD Deployment)
//  ============================================================================
    webService static AceWSResultList deleteMarketingEventMeetings( String[] meetingIdsToDelete) {
        
        List<Id> meetingIdList = new List<Id> {};
        for ( Marketing_Event_Meeting__c mem : [Select Id
                                            From Marketing_Event_Meeting__c
                                            Where Id In :meetingIdsToDelete]
                                    ) {
            meetingIdList.add ( mem.Id );
        }
        
        return aceUtil.deleteRecords ( meetingIdList );
    }

//  ============================================================================
//  Method: insertMarketingEventSlots
//  Desc:   Updates Marketing_Event_Slots__c records per the specified list of
//          Meeting records.    
//  Args:   slotList - list of Marketing Event Slot records to inesrt.
//  Return: List of updated slotList Ids, blank for failed Inserts.
//  Case No: 3983(To be implemented after TD Deployment)
//  ============================================================================
    webService static AceWSResultList insertMarketingEventSlots ( Marketing_Event_Slot__c[] slotsToInsert ) {
        return aceUtil.upsertRecords ( slotsToInsert );
    }

//  ============================================================================
//  Method: updateMarketingEventSlots
//  Desc:   Inserts Marketing_Event_Slots__c records per the specified list of
//          Meeting records.    
//  Args:   slotList - list of Marketing Event Slot records to inesrt.
//  Return: List of inserted slotList Ids, blank for failed Inserts.
//  Case No: 4012 (To be implemented after TD Deployment)
//  ============================================================================
    webService static AceWSResultList updateMarketingEventSlots ( Marketing_Event_Slot__c[] slotsToUpdate ) {
        return aceUtil.updateRecords ( slotsToUpdate );
    }

/**  END --> STUBBED OUT FOR TD ROLLOUT DEC 12 08 - SEAN - */    

//  ============================================================================
//  Method: getAccountCoverage  
//  Desc:   See AccountCoverage.getAccountCoverage 
//  ============================================================================
    webService static AccountCoveragePage getAccountCoverage ( Id emplId ,
                                                                String startName ,
                                                                Integer pageSize ) {
        
        return AccountCoverage.getAccountCoverage ( emplId , startName, pageSize );
    }

//  ============================================================================
//  Method:      updateAccountCoverage
//  Description: Updates the given list of Account Coverage records.         
//  Args:        Array of Account Coverage records
//  Return:      AceWSResultList containing results of update                       
//  ============================================================================    
    webService static AceWSResultList updateAccountCoverage ( Account_Coverage__c[] ccList ) {
        return aceUtil.updateRecords( ccList );
    }  

//  ============================================================================
//  Method: getEmployeesCoveringAccounts  
//  Desc:   See AccountCoverage.getEmployeesCoveringAccounts 
//  ============================================================================
    webService static List<AccountCoverage> getEmployeesCoveringAccounts ( Id[] acctIdList ) {
        
        return AccountCoverage.getEmployeesCoveringAccounts ( acctIdList );
    }   
         
    //  ============================================================================
    //  Method: getAceListsByOwner
    //  Desc:   See AceList.getAceListsByOwner
    //  ============================================================================
    webService static AceListPage getAceListsByOwner( String userId,
                                                        Boolean bSharedOnly,
                                                        String startName,
														Integer pageSize ) 
	{
        return AceList.getAceListsByOwner( userId, bSharedOnly, startName, pageSize );
    }   
    
    //  ============================================================================
    //  Method: getSharedAceLists
    //  Desc:   See AceList.getSharedAceLists
    //  ============================================================================
    webService static AceListPage getSharedAceLists( String userId,
                                                        Boolean bSharedOnly,
                                                        String startName,
														Integer pageSize ) 
	{
        return AceList.getSharedAceLists( userId, bSharedOnly, startName, pageSize );
    }  

    //  ============================================================================
    //  Method: getAceListShare
    //  Desc:   See  AceListShare.getListShare
    //  ============================================================================    
    webService static List<List<AceListShare>> getAceListShare(String[] aceListIds) {
        
        return AceListShare.getAceListShare ( aceListIds );
    }
    
    //  ============================================================================
    //  Method:      upsertAceLists
    //  Description: Updates or inserts the given array of objects          
    //  Args:        Array of sObjects
    //  Return:      Returns array of String; 
    //                   Record Id if success,
    //                   'false' if failure                    
    //  ============================================================================    
    webService static AceWSResultList upsertAceLists(Ace_List__c[] aceLists) {
        return aceUtil.upsertRecords(aceLists);
    }  

    //  ============================================================================
    //  Method: getListEntriesForList  
    //  Desc:   See AceListEntry.getListEntriesForList
    //  ============================================================================
    /*webService static List<AceListEntry> getListEntriesForList(string aceListId,
                                                        string queryFields, 
                                                        boolean isActive,
                                                        boolean bGetLastInteraction ,
                                                        Id userId ) {
        
        return AceListEntry.getListEntriesForList ( aceListId , queryFields, isActive ,
                                                    bGetLastInteraction , userId );
    }*/
    
    //  ============================================================================
    //  Method: getListEntriesForList  
    //  Desc:   See AceListEntry.getListEntriesForList
    //  ============================================================================
    webService static AceListEntryPage getListEntriesForList(	string aceListId,
                                                        		string queryFields, 
                                                        		String startName ,
                                                        		Integer pageSize , 
                                                        		boolean bGetLastInteraction ,
                                                        		Id userId ) {
        
        return AceListEntry.getListEntriesForList( aceListId , queryFields ,
        											startName , pageSize ,
                                                    bGetLastInteraction , userId );  
    }

    //  ============================================================================
    //  Method:      upsertAceListShares
    //  Description: Updates or inserts the given array of objects          
    //  Args:        Array of sObjects
    //  Return:      Returns array of String; 
    //                      Record Id if success,
    //                      'false' if failure                    
    //  ============================================================================    
    webService static AceWSResultList upsertAceListShares(Ace_List_Share__c[] aceListShares) {
        return aceUtil.upsertRecords(aceListShares);
    }
    
    //  ============================================================================
    //  Method:      updateAceListShares
    //  Description: Updates the given array of list shares        
    //  Args:        Array of list share
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  ============================================================================    
    webService static AceWSResultList updateAceListShares(Ace_List_Share__c[] aceListShares) {
        return aceUtil.updateRecords(aceListShares);
    }
    
    
    //GD 2009/03/17 - US391 START
    //  ============================================================================
    //  Method:         upsertAceListEntries
    //  Description:    Updates or inserts the given array of objects          
    //  Args:           Array of sObjects
    //  Return:         Returns array of String; 
    //                      Record Id if success,
    //                      'false' if failure                    
    //  ============================================================================    
    webService static AceWSResultList upsertAceListEntries (Ace_List_Entry__c[] aleList ) {
        return aceUtil.upsertRecords( aleList );
    }  

    //  ============================================================================
    //  Method: getAceListMembership   
    //  Desc:   See AceList.getListMembership 
    //	NOTE:	This method is being replaced with 
    //			getAceListMembershipPage ( Id entryId, String startName, Integer pageSize )
    //			TO BE DEPRECATED IN THE FUTURE RELEASE
    //  ============================================================================
    webService static List<AceList> getAceListMembership ( Id entryId ) {
        
        return AceList.getListMembership ( entryId );
    }
    //  ============================================================================
    //  Method: getAceListMembershipPage   
    //  Desc:   Returns Ace List details for given entry (contact, account) 
    //	NOTE: 	This webservice is replace ment for  getAceListMembership ( Id entryId ) 
    //			with paging functionalilty.
    //			getAceListMembership ( Id entryId ) TO BE DEPRECATED... 
    //  ============================================================================
	WebService static AceListPage getAceListMembershipPage ( Id entryId, String startName, Integer pageSize ) {
        
        return AceList.getListMembership ( entryId, startName, pageSize );
    }    
    //  ============================================================================
    //  Method:      updateAceLists
    //  Description:    Updates the given array of ace lists            
    //  Args:          Array of Ace list
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  ============================================================================    
    webService static AceWSResultList updateAceLists(Ace_List__c[] aceLists) {
        return aceUtil.updateRecords(aceLists);
    }  

    //  ============================================================================
    //  Method:      updateAceListEntries
    //  Description:    Updates the given array of List Items          
    //  Args:          Array of list item
    //  Return:      Returns array of boolean; 
    //                      true if success,
    //                      false if failure                        
    //  ============================================================================    
    webService static AceWSResultList updateAceListEntries(Ace_List_Entry__c[] aleList ) {
        return aceUtil.updateRecords( aleList);
    }  

    //  ============================================================================
    //  Method:         deleteAceListEntries
    //  Description:    Deletes the specified entries from each list the user owns  
    //  Args:           Entry (Contact/Account) Id, User Id
    //  Return:         Array of boolean
    //                      true if success
    //                      false if failure                        
    //  ============================================================================
    webService static AceWSResultList deleteAceListEntries(String[] entryIds, String ownerId) {
        
        List<Id> aleIdList = new List<Id> {};
        for ( Ace_List_Entry__c ale : [Select Id
                                            From Ace_List_Entry__c
                                            Where Ace_List__r.OwnerId = :ownerId
                                            And Entry_List_Id__c In :entryIds]
                                    ) {
            aleIdList.add ( ale.Id );
        }
        
        return aceUtil.deleteRecords ( aleIdList );
    }
  //GD 2009/03/17 - US391 END
  
//  ============================================================================
//  Method: searchByAccountFields (US548) 
//  Desc:   See AceAccount.searchByAccountFields
//  ============================================================================
    webService static AceAccountPage searchByAccountFields ( Id userId, 
    														String searchString,
															String searchScope, 
															String searchFields, 
															Boolean bGetLastInteraction,
															String startName,
															Integer pageSize ) {
        
        return AceAccount.searchByAccountFields ( userId, 
        										  searchString,
												  searchScope, 
												  searchFields,
												  bGetLastInteraction,
												  startName, pageSize );
    }  

//  ============================================================================
//  Method: searchByContactFields (US548) 
//  Desc:   See AceContact.searchByContactFields
//  ============================================================================
    webService static AceContactPage searchByContactFields ( Id userId, 
    														String searchString,
															String searchScope, 
															String searchFields, 
															Boolean bGetLastInteraction,
															String startName,
															Integer pageSize ) {
        
        return AceContact.searchByContactFields ( userId, 
        										  searchString,
												  searchScope, 
												  searchFields,
												  bGetLastInteraction,
												  startName, pageSize );
    }
//  ============================================================================
//  Method: getRecords  
//  Desc:   Returns list of records of type sObjType
//  ============================================================================
    webservice static SObjectPage getRecords ( 	String sObjType,
    											String whereClause, 
    											String sortFld , 
    											String startFldVal ,
    											Integer pageSize,
    											String[] fldNames ) {

		if (fldNames == null || fldNames.size() == 0) {
			fldNames = AceSchema.getFieldNames( sObjType );
		}
		
    	return AceSObject.getSObjectPage( 	sObjType, 
    										whereClause, 
    									  	(sortFld == null || sortFld == '' ? 'Name' : sortFld),
    									  	startFldVal, 
    									  	pageSize, 
    									  	fldNames);
    } 
//  ============================================================================
//  Method: updateLastDiscussed  
//  Desc:   Updates Last_Discussed__c with CreatedDate if it is null
//  ============================================================================   
    webservice static boolean updateLastDiscussed() {
    	
    	List<Interest__c> lstUpd = new List<Interest__c>();
 		Integer recLimit = 100;
 		Integer intReturn = 0;
    	Boolean result = false;
    	
    	for( Interest__c ints : [Select Last_Discussed__c, As_Of_Date__c From Interest__c
    								Where Last_Discussed__c = null
    								limit :recLimit+1]) {
    		
   			// Keep track of number of record returned
   			intReturn++;

    		// Only Update the limited number of interest records with no Last Discussed Date
    		if (intReturn <= recLimit){

    			// Assign 'As of Date' to Last Discussed Date if it is missing
    			ints.Last_Discussed__c = ints.As_Of_Date__c;
    			// If there is no 'As of Date', assign to Created Date 
    			if (ints.As_Of_Date__c == null && ints.CreatedDate != null ) {
    				ints.As_Of_Date__c = Date.valueOf('' + ints.CreatedDate);
    				ints.Last_Discussed__c = Date.valueOf('' + ints.CreatedDate);
    			}
    			lstUpd.Add( ints );
    		}
    		
		}
		
		if (lstUpd != null && lstUpd.size() > 0) {
			update lstUpd;			
		}
		
		// More then 100 records returned .. more to be updated
		if (intReturn > recLimit) {
			result = true;
		}
		
		return result;
    }
}