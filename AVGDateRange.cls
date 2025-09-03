/* 
 * Name: AVGDateRange
 * Description: Contains the definition of an AVG date range picker.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGDateRange {

//	===========================
//	Static variables/constants.
//	===========================
	static final String LAST_WEEK_DATE_RANGE = 'lastWeek';
	static final String LAST_30_DAYS_DATE_RANGE = 'last30Days';
	static final String LAST_QUARTER_DATE_RANGE = 'lastQuarter';
	static final String THIS_YEAR_DATE_RANGE = 'thisYear';
	static final String LAST_YEAR_DATE_RANGE = 'lastYear';

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	private AVGGrid[] boundGridList;

//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================
	public SelectOption[] dateRangeOptions {
		get;
		set;
	}
			
	public String dateRange {
		get {
			return ( dateRange == Null ? '' : dateRange );
		}

		set {
			dateRange = value;
			String[] dates = parseDateRange ( value );
			if ( dates[ 0 ] != this.startDate || dates[ 1 ] != this.endDate ) {
				this.startDate = dates[ 0 ];
				this.endDate = dates[ 1 ];
				
				for ( AVGGrid grid : this.boundGridList ) {
					grid.refreshDataPayload ();
				}
			}
		}
	}

	public String startDate {
		get {
			return ( startDate == Null ? '' : startDate );
		}
		set;
	}
	
	public String endDate {
		get {		
			return ( endDate == Null ? '' : endDate );
		}
		set;
	}	

//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructor.
//
//	Args:	None.
//  ============================================================================                        
	public AVGDateRange () {
	
		this.boundGridList = new AVGGrid[] {};
		
		this.dateRangeOptions = new SelectOption[] {
			new SelectOption ( LAST_WEEK_DATE_RANGE , 'Last Week' ) ,
			new SelectOption ( LAST_30_DAYS_DATE_RANGE , 'Last 30 Days' ) ,
			new SelectOption ( LAST_QUARTER_DATE_RANGE , 'Last Quarter' ) ,
			new SelectOption ( THIS_YEAR_DATE_RANGE , 'This Year' ) ,
			new SelectOption ( LAST_YEAR_DATE_RANGE , 'Last Year' )
		};
	}
	
//  ============================================================================
//  Method:	bindAVGGrid
//
//  Desc:	Adds the specified AVG grid object to this instance's bound list.
//
//	Args:	grid	- the AVG grid object
//
//	Return:	Nothing.
//  ============================================================================                        
	public void bindAVGGrid ( AVGGrid grid ) {
		this.boundGridList.add ( grid );
	}
	
//  ============================================================================
//  Method:	parseDateRange
//
//  Desc:	Parses the specified date range into a start and end date.
//
//	Args:	dateRange	- the date range.
//
//	Return:	A two-part ( startDate , endDate ) string.
//  ============================================================================                        
	private String[] parseDateRange ( String dateRange ) {
		Date endDate = Date.today ();
		Date startDate;
		if ( dateRange == LAST_WEEK_DATE_RANGE ) {
			startDate = endDate.addDays ( -7 );
		}
		else if ( dateRange == LAST_30_DAYS_DATE_RANGE ) {
			startDate = endDate.addDays ( -30 );
		}
		else if ( dateRange == LAST_QUARTER_DATE_RANGE ) {
			startDate = endDate.addDays ( -90 );
		}
		else if ( dateRange == THIS_YEAR_DATE_RANGE ) {
			startDate = Date.newInstance ( endDate.year () , 1 , 1 );
		}
		else if ( dateRange == LAST_YEAR_DATE_RANGE ) {
			startDate = Date.newInstance ( endDate.year () - 1 , 1 , 1 );
		}
		else {
			System.debug ( 'Unrecognized date range [' + dateRange + ']' ); 
			return new String[] { '' , '' };
		}
		
		return new String[] { String.valueOf ( startDate ) , String.valueOf ( endDate ) };
	}
			
}