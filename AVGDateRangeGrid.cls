/* 
 * Name: AVGDateRangeGrid 
 * Description: Contains the details of a AVG Date Range grid, which 
 *				extends the AVG SOQL grid by folding in a Date Range picker
 *				whose value modifies the SOQL query's WHERE clause.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGDateRangeGrid extends AVGSoqlGrid {

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	protected String dateFld;
	protected String baseWhereClause;
	
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
//			sobjType	- the SObject supplying the grid contents.
//			whereClause	- the query clause of the underlying SOQL query.
//			dateFld		- the name of the Date field to apply the Date Range
//						  picker to.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//			dateRange	- the Date Range picker.
//  ============================================================================                        
 	public AVGDateRangeGrid ( String title , String sobjType , String whereClause , String dateFld , AVGGridColumn[] cols , 
 								AVGDateRange dateRange ) {
 		this.init ( title , sobjType , whereClause , dateFld , cols , dateRange );
 		this.refreshDataPayload ();
 	}
 	
 	public AVGDateRangeGrid ( String title , String sobjType , String whereClause , String dateFld , AVGGridColumn[] cols ) {
 		this ( title , sobjType , whereClause , dateFld , cols , new AVGDateRange () );
 	}
 	
 	public AVGDateRangeGrid () {
 	}
 	
//  ============================================================================
//  Method:	init
//
//  Desc:	Initializes the grid object's instance variables.
//
//	Args:	title		- the grid title.
//			sobjType	- the SObject supplying the grid contents.
//			whereClause	- the query clause of the underlying SOQL query.
//			dateFld		- the name of the Date field to apply the Date Range
//						  picker to.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//			dateRange	- the Date Range picker.
//  ============================================================================                        
 	public virtual void init ( String title , String sobjType , String whereClause , String dateFld , AVGGridColumn[] cols , 
 								AVGDateRange dateRange ) {
 
 		super.init ( title , sobjType , whereClause , cols );
		
 		this.dateFld = dateFld;
 		this.baseWhereClause = whereClause;
 		
 		this.dateRange = dateRange;
 		this.dateRange.dateRange = this.dateRange.dateRangeOptions[ 0 ].getValue ();
 		this.dateRange.bindAVGGrid ( this );
 	}
 	
//  ============================================================================
//  Method:	getSObjectPayload
//
//  Desc:	Wraps around the parent class' getSObjectPayload by modifying the
//			SOQL query's WHERE clause based on the state of this instance's 
//			Date Picker, before executing the SOQL query.
//
//	Args:	None
//
//	Return: The SObject[] result list from the SOQL query.
//  ============================================================================                        
	public virtual override SObject[] getSObjectPayload () {

		if ( this.dateRange == Null ) {
			return Null;
		} 		
		
 		String startDate = this.dateRange.startDate;
 		String endDate = this.dateRange.endDate;
 		if ( startDate != '' && endDate != '' ) {
 			this.whereClause = this.baseWhereClause
 								+ ' and ' + this.dateFld + ' >= ' + startDate
 								+ ' and ' + this.dateFld + ' <= ' + endDate;
		}
		else {
			this.whereClause = this.baseWhereClause;
		}
 		return super.getSObjectPayload();
 	}
}