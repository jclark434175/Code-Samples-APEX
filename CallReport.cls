/* 
 * Name: CallReport 
 * Description: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */

global with sharing class CallReport {
	
	public CallReport(){
	}
	
//  ============================================================================
//  Method: getCallReportByAccount  
//  Desc:   Retrieves a page of call report records for the specified 
//          Account. 
//  Args:   accountId      	- the Account Id
//          startSubject   	- the starting Call Report start name
//          pageSize    	- the page size
//  Return: Page of Call Report records                         
//  US:   	6000
//  ============================================================================
	public static SObjectPage getCallReportByAccount ( 	String accountId,
															String startName,
															Integer pageSize ) {
		
       String[] fldNames = new String[] {
                                        	'Id',
                                        	'Name',
        									'Client__c',
        									'Meeting_Date__c',
        									'Subject_Meeting_Objectives__c',
        									'Meeting_Type__c',
        									'Location__c',
        									'Notes__c',
        									'Created_By_Employee__c'
                                    	};
    	
    	String whereClause = 'Client__c =\'' + accountId + '\'';
    	
    	return AceSObject.getSObjectPage('Call_Report__c', whereClause, 
    									  'Name',
    									  startName, pageSize, fldNames);
	}
	
//  ============================================================================
//  ============================================================================
//  CLASS:  CallReportListBuilder  
//  Desc:   Utility class to help build a list of CallReports, based on 
//          successive additions of CallReports records, which are assumed
//          to be sorted by Subject.
//  ============================================================================
//  ============================================================================
    class CallReportListBuilder {
        
        private Integer idx;
        private String prevSubject;
        private Integer maxListSize;
        private Call_Report__c[] crCache;
        
        private Call_Report__c[] crList;
        public String nextSubject;
        
//      ============================================================================
//      Method: Constructor 
//      Desc:   Initializes variables.
//      ============================================================================
        CallReportListBuilder () {
            this ( aceUtil.MAX_COLLECTION_SIZE );
        }
        
        CallReportListBuilder ( Integer maxListSize ) {
            this.idx = 0;
            this.prevSubject = '';
            this.nextSubject = Null;
            this.maxListSize = maxListSize;
            this.crCache = new Call_Report__c[] {};
            this.crList = new Call_Report__c[] {};
        }   
            
//      ============================================================================
//      Method: addCallReport  
//      Desc:   Adds the specified CallReport record to the CallReport
//              list.  If this record would put us past the max-record limit, aborts.
//      Args:   cr - the Call Report record
//      Return: True if the record was added; False otherwise.
//      ============================================================================
        public Boolean addCallReport ( Call_Report__c cr ) {
            if ( prevSubject != Null && prevSubject != cr.Subject_Meeting_Objectives__c ) {
                crList.addAll ( crCache );
                crCache.clear ();
            }
            if ( idx++ >= maxListSize ) {
                nextSubject = ( crCache.isEmpty () ? cr.Subject_Meeting_Objectives__c : prevSubject );
                return False;
            }
            prevSubject = cr.Subject_Meeting_Objectives__c;
            crCache.add ( cr );
            return True;
        }
        
//      ============================================================================
//      Method: addCachedCallReports   
//      Desc:   Adds the CallReport records we've built up in our internal
//              cache, to the CallReport list.
//      Args:   None.
//      Return: None.
//      ============================================================================
        public void addCachedCallReports () {
            crList.addAll ( crCache );
        }
    }
}