/* 
 * Name: AVGMarketingEventGrid 
 * Description: Contains the details of a specialized AVG Marketing Event grid,
 *				which extends the AVG Date Range grid (itself extending the AVG
 *				SOQL grid) by managing its own column definitions + SOQL query
 *				WHERE clause, and post-processing the output of the resulting
 *				query.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGMarketingEventGrid extends AVGDateRangeGrid {

//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	title		- the grid title.
//			acctId		- the associated Account Id
//			dateRange	- the Date Range picker.
//  ============================================================================                        
	public AVGMarketingEventGrid ( String title , Id acctId , AVGDateRange dateRange ) {
		init ( title , acctId , dateRange );
		this.refreshDataPayload ();
	}
	
	public AVGMarketingEventGrid () {
	}
	
//  ============================================================================
//  Method:	init
//
//  Desc:	Initializes the grid object's instance variables.  Simply a wrapper
//			around the parent class' init() method, creating the grid's column
//			objects here instead of having them supplied by the caller via class
//			constructor.
//
//	Args:	title		- the grid title.
//			acctId		- the associated Account Id
//			dateRange	- the Date Range picker.
//  ============================================================================                        
 	public virtual void init ( String title , Id acctId , AVGDateRange dateRange ) {
 									
 		super.init ( title , 'Marketing_Event_Meeting__c' , 'Contact__r.AccountId = \'' + acctId + '\'' ,
 						'Marketing_Event__r.Event_Date__c' , 
						new AVGGridColumn[] {
							new AVGDateGridColumn ( new String[] { 'Marketing_Event__r.Event_Date__c' } , 'Date' , 80 ) ,
							new AVGLinkGridColumn ( new String[] { 'Contact__r.FirstName' , 'Contact__r.LastName' , 'Contact__c' } , 'Contact__r.LastName' , 'Contact' , 80 ) ,
							new AVGLinkGridColumn ( new String[] { 'Marketing_Event__r.Name' , 'Marketing_Event__c' } , 'Event Name' , 80 ) ,
							new AVGBasicGridColumn ( new String[] { 'Marketing_Event__r.Company_Account__c' , 'Marketing_Event__r.Analyst__c' } , 'Company/Analyst' , 80 ) ,
							new AVGBasicGridColumn ( new String[] { 'Marketing_Event__r.RecordType.Name' } , 'Type' , 140 ) ,
							new AVGBasicGridColumn ( new String[] { 'Marketing_Event__r.Marketing_City__r.Name' } , 'Location' , 80 )
						} ,
						dateRange
					);
 	}

//  ============================================================================
//  Method:	getSObjectPayload
//
//  Desc:	Wraps around the parent class' getSObjectPayload by pruning 
//			duplicate Contact/MarketingEvent entries out of the resulting
//			SObject list.
//
//	Args:	None
//
//	Return: The pruned SObject[] result list from the SOQL query.
//  ============================================================================                        
	public virtual override SObject[] getSObjectPayload () {

//		Execute the Apex class method to retrieve the data.
//		---------------------------------------------------
		SObject[] sobjList = super.getSObjectPayload ();
		if ( sobjList == Null ) {
			return sobjList;
		}
				
//		Trim out all but one record per Contact/Marketing Event.
//		--------------------------------------------------------
		Set<String> contMeSet = new Set<String> {};
		
		for ( Integer idx = sobjList.size () - 1 ; idx >= 0 ; idx-- ) {
		
			String contId = String.valueOf ( sobjList[ idx ].get ( 'Contact__c' ) );
			String meId = String.valueOf ( sobjList[ idx ].get ( 'Marketing_Event__c' ) );
			
			if ( !contMeSet.add ( contId + ':' + meId ) ) {
				sobjList.remove ( idx );
			}
		}		
	
		return sobjList;
	}
}