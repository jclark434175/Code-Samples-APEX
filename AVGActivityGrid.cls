/* 
 * Name: AVGActivityGrid 
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
public virtual class AVGActivityGrid extends AVGGrid {

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	private Id acctId;
	private Boolean bOpen;

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
//			bOpen		- Flag denoting open vs. closed Activities.
//			dateRange	- the Date Range picker.
//  ============================================================================                        
	public AVGActivityGrid ( String title , Id acctId , Boolean bOpen , AVGDateRange dateRange ) {
		this.init ( title , acctId , bOpen , dateRange );
		this.refreshDataPayload ();
	}
	
	public AVGActivityGrid () {
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
	public virtual void init ( String title , Id acctId , Boolean bOpen , AVGDateRange dateRange ) {
		super.init ( title , new AVGGridColumn[] {} );
		
		this.acctId = acctId;
		this.bOpen = bOpen;

		this.dateRange = dateRange;
		this.dateRange.bindAVGGrid ( this );
		
		this.cols.addAll (
			new AVGGridColumn [] {
				new AVGDateGridColumn ( 'Last Modified' , 120 ) ,
				new AVGLinkGridColumn ( 'Contact' , 1 , 80 ) ,
				new AVGBasicGridColumn ( 'Subject' , 80 ) ,
				new AVGBasicGridColumn ( 'Type' , 80 ) ,
				new AVGLinkGridColumn ( 'Assigned To' , 1 , 80 ) ,
				new AVGDateGridColumn ( 'Due Date' , 80 ) ,
				new AVGBasicGridColumn ( 'Status' , 80 )
			}
		);
	}

//  ============================================================================
//  Method:	getDataPayload
//
//  Desc:	Uses the custom AVGActivity.getActivities() method to retrieve a
//			list of AVGActivity class objects, then explicitly assigns the
//			member fields in these objects to this instance's data row cells.
//
//	Args:	None
//
//	Return: None.
//  ============================================================================                        
	public virtual override void getDataPayload () {
			
//		Execute the Apex class method to retrieve the data.
//		---------------------------------------------------
		AVGActivity[] actList;
		try {
			actList = AVGActivity.getActivities ( this.AcctId , this.bOpen , this.dateRange.startDate );
		}
		catch ( Exception e ) {
			ApexPages.addMessages ( e );
			actList = new AVGActivity[] {};
		}
			
//		Massage the resulting data, if any, into a matrix of output.
//		------------------------------------------------------------
		AVGGridRow[] data = new AVGGridRow[] {};
			
		for ( Integer i = 0 ; i < actList.size () ; i++ ) {

			String rowClass = ROW_CLASSES[ Math.mod ( i , 2 ) ];
			AVGGridRow row = new AVGGridRow ( rowClass );
			AVGActivity act = actList[ i ];

			if ( act.task != Null ) {
				row.cells.add ( this.cols[ 0 ].mkDataCell ( String.valueOf ( act.task.LastModifiedDate ) ) );
			}
			else {
				row.cells.add ( this.cols[ 0 ].mkDataCell ( String.valueOf ( act.event.LastModifiedDate ) ) );
			}
			row.cells.add ( this.cols[ 1 ].mkDataCell ( new String[] { act.contact.FirstName , act.Contact.LastName , act.Contact.Id } ) );
			if ( act.task != Null ) {
				row.cells.add ( this.cols[ 2 ].mkDataCell ( String.valueOf ( act.task.Subject ) ) );
				row.cells.add ( this.cols[ 3 ].mkDataCell ( String.valueOf ( act.task.Interaction_Type__c ) ) );
			}
			else {
				row.cells.add ( this.cols[ 2 ].mkDataCell ( String.valueOf ( act.event.Subject ) ) );
				row.cells.add ( this.cols[ 3 ].mkDataCell ( String.valueOf ( act.event.Interaction_Type__c ) ) );
			}
			row.cells.add ( this.cols[ 4 ].mkDataCell ( new String[] { act.assignedTo.FirstName , act.assignedTo.LastName , act.assignedTo.Id } ) );
			if ( act.task != Null ) {
				row.cells.add ( this.cols[ 5 ].mkDataCell ( String.valueOf ( act.task.ActivityDate ) ) );
				row.cells.add ( this.cols[ 6 ].mkDataCell ( String.valueOf ( act.task.Status ) ) );
			}
			else {
				row.cells.add ( this.cols[ 5 ].mkDataCell ( String.valueOf ( act.event.ActivityDate ) ) );
				row.cells.add ( this.cols[ 6 ].mkDataCell ( this.bOpen ? 'Open' : 'Closed' ) );
			}
			
			data.add ( row );
		}
		
		this.dataPayload = data;
		this.height = actList.size ();	
	}
}