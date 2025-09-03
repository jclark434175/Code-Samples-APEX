/* 
 * Name: AVGMarketingEventFeedbackGrid 
 * Description: Contains the details of a specialized AVG Activity grid, which 
 *				extends the base AVG grid by defining its own non-generic data
 *				payload retriever via Apex class method and explicitly assigning
 *				the members of the resulting custom class object records to the
 *				appropriate columns. 
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGMarketingEventFeedbackGrid extends AVGGrid {


//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	private Id acctId;
															 
//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================
	public AVGDateRange dateRange {
		get;
		set;
	}
															 
//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	title		- the grid title.
//			acctId		- the associated Account Id
//			dateRange	- the Date Range picker.
//  ============================================================================                        
	public AVGMarketingEventFeedbackGrid ( String title , Id acctId , AVGDateRange dateRange ) {
		this.init ( title , acctId , dateRange );
		this.refreshDataPayload ();
	}
	
	public AVGMarketingEventFeedbackGrid () {
	}
	
//  ============================================================================
//  Method:	init
//
//  Desc:	Initializes the grid object's instance variables.  Also initializes
//			the object's column list.
//
//	Args:	title		- the grid title.
//			acctId		- the associated Account Id
//			bOpen		- Flag denoting open vs. closed Activities.
//			dateRange	- the Date Range picker.
//  ============================================================================                        
	public virtual void init ( String title , Id acctId , AVGDateRange dateRange ) {
		super.init ( title , new AVGGridColumn[] {
				new AVGDateGridColumn ( 'Last Modified' , 120 ) ,
				new AVGLinkGridColumn ( 'Contact' , 1 , 80 ) ,
				new AVGBasicGridColumn ( 'Subject' , 80 ) ,
				new AVGBasicGridColumn ( 'Company/Analyst' , 80 ) ,
				new AVGLinkGridColumn ( 'Assigned To' , 1 , 80 ) ,
				new AVGBasicGridColumn ( 'Comments' , 1 , 200 )
			}
		);
		this.cols[ 3 ].setDelim ( ' / ' );
		
		this.acctId = acctId;

		this.dateRange = dateRange;
		this.dateRange.bindAVGGrid ( this );
	}

//  ============================================================================
//  Method:	getDataPayload
//
//  Desc:	Uses the custom AVGMarketingEventFeedback.getMktgEventFeedback()
//			method to retrieve a list of AVGMarketingEventFeedback class
//			objects, then explicitly assigns the member fields in these objects
//			to this instance's data row cells.
//
//	Args:	None
//
//	Return: None.
//  ============================================================================                        
	public virtual override void getDataPayload () {
			
//		Execute the Apex class method to retrieve the data.
//		---------------------------------------------------
		AVGMarketingEventFeedback[] mefList;
		try {
			mefList = AVGMarketingEventFeedback.getMktgEventFeedback ( this.AcctId , this.dateRange.startDate );
		}
		catch ( Exception e ) {
			ApexPages.addMessages ( e );
			mefList = new AVGMarketingEventFeedback[] {};
		}
			
//		Massage the resulting data, if any, into a matrix of output.
//		------------------------------------------------------------
		AVGGridRow[] data = new AVGGridRow[] {};
			
		for ( Integer i = 0 ; i < mefList.size () ; i++ ) {

			String rowClass = ROW_CLASSES[ Math.mod ( i , 2 ) ];
			AVGGridRow row = new AVGGridRow ( rowClass );
			AVGMarketingEventFeedback mef = mefList[ i ];

			row.cells.add ( this.cols[ 0 ].mkDataCell ( String.valueOf ( mef.feedback.LastModifiedDate ) ) );
			row.cells.add ( this.cols[ 1 ].mkDataCell ( new String[] { mef.contact.FirstName , mef.Contact.LastName , mef.Contact.Id } ) );
			row.cells.add ( this.cols[ 2 ].mkDataCell ( mef.feedback.Subject ) );

			row.cells.add ( this.cols[ 3 ].mkDataCell ( new String[] {			
															this.cols[ 3 ].getSObjFld ( mef.MarketingEvent , 'Company_Account__c' ) ,
															this.cols[ 3 ].getSObjFld ( mef.MarketingEvent , 'Analyst__c' )
														} )
													);
//			row.cells.add ( this.cols[ 3 ].mkDataCell ( mef.marketingEvent.get ( 'Company_Account__c' ) + ' / ' + mef.marketingEvent.get ( 'Analyst__c' ) ) );
			row.cells.add ( this.cols[ 4 ].mkDataCell ( new String[] { mef.assignedTo.FirstName , mef.assignedTo.LastName , mef.assignedTo.Id } ) );
			row.cells.add ( this.cols[ 5 ].mkDataCell ( new String[] { mef.feedback.Description } ) );
			
			data.add ( row );
		}
		
		this.dataPayload = data;
		this.height = data.size ();
	}
}