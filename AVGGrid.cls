/* 
 * Name: AVGGrid 
 * Description: Contains the details of a basic AVG grid. All concrete AVG grids are
 *				implemented as child classes of this class.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public abstract class AVGGrid {

//	===========================
//	Static variables/constants.
//	===========================
	public static final String TITLE_CLASS = 'avgTitle';
	public static final String[] ROW_CLASSES = new String[] { 'rowWhite' , 'rowShaded' };
	public static final String CLICKED_CELL_PARAM = 'clickedHdrCell';

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	protected AVGGridRow[] dataPayload;

	protected AVGGridColumn[] cols;
	protected Integer sortColIdx;
	protected Map<Integer, Integer[]> sortIdxByCol;

//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================

//	Note conversion from input value (number of rows in grid) to a pixel value.
//	---------------------------------------------------------------------------
	public Integer height {
		set {
			height = Math.min ( 250 , ( value + 1 ) * 30 );
			System.debug ( 'GRID [' + this.title + '] HEIGHT [' + value + ']' );
		}
		get;
	}
	
	public String title { 
		get; 
		set;
	}
	
	public Boolean useContextMenu {
		get;
		set;
	}
	
	public AVGGridButton[] buttons {
		get;
		set;
	}

	public AVGGridRow hdr {
		
		get {
			
//			Construct a list of header output.
//			----------------------------------
			AVGGridRow hdr = new AVGGridRow ( TITLE_CLASS );
			for ( Integer i = 0 ; i < this.cols.size () ; i++ ) {
				AVGGridColumn col = this.cols[ i ];
				hdr.cells.add ( col.mkHdrCell ( ( i == this.sortColIdx ) ) );
			}
			
			return hdr;
		}
		
		set;
	}

	public AVGGridRow[] data {

		get {

//			Initialize our column sorting map if necessary.
//			-----------------------------------------------
			if ( this.sortIdxByCol == Null ) {
				this.sortIdxByCol = new Map<Integer , Integer[]> {};
			}
		
			if ( this.dataPayload == Null ) {
				return new AVGGridRow[] {};
			}

//			Re-create the sorting index if necessary.
//			-----------------------------------------
			if ( this.sortColIdx != Null && !this.sortIdxByCol.containsKey ( this.sortColIdx ) ) {
				String[] sortDataList = new String[] {};
				for ( AVGGridRow row : dataPayload ) {
					System.debug ( '...SORTING : ADDING SORT DATA FROM [' + row.cells[ this.sortColIdx ] + ']' );
					sortDataList.add ( row.cells[ this.sortColIdx ].sortData );
				}
				Integer[] sortIdxList = cols[ this.sortColIdx ].sortData ( sortDataList );
				this.sortIdxByCol.put ( this.sortColIdx , sortIdxList );
				system.debug ( '...SORT IDX BY COL [' + this.sortColIdx + '] NOW :\n' + this.sortIdxByCol );
			}
		
//			Now assemble the SORTED data list.
//			----------------------------------
			if ( this.sortColIdx == Null ) {
				return this.dataPayload;
			}
			else {
				AVGGridRow[] sortedData = new AVGGridRow[] {};
				Integer[] sortIdxList = this.sortIdxByCol.get ( this.sortColIdx );
				for ( Integer idx : sortIdxList ) {
					sortedData.add ( dataPayload[ idx ] );
				}
				this.dataPayload = sortedData;
			}
		
//			Assign proper row classes to the data list.
//			-------------------------------------------
			for ( Integer idx = 0 ; idx < this.dataPayload.size () ; idx++ ) {
				this.dataPayload[ idx ].rowClass = ROW_CLASSES[ Math.mod ( idx , 2 ) ];
			}	
		
			return this.dataPayload;	
		}
		
		set;
	}


//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	title		- the grid title.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//  ============================================================================                        
 	public AVGGrid ( String title , AVGGridColumn[] cols ) {
		init ( title , cols );
	}
	
	public AVGGrid ( String title ) {
		this ( title , new AVGGridColumn[] {} );
	}
	
	public AVGGrid () {
	}

//  ============================================================================
//  Method:	init
//
//  Desc:	Initializes the grid object's instance variables.
//
//	Args:	title		- the grid title.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//  ============================================================================                        
	public virtual void init ( String title , AVGGridColumn[] cols ) {
		this.title = title;
		this.cols = cols;
		this.useContextMenu = False;
		
		this.sortColIdx = Null;
	}

//  ============================================================================
//  Method:	refreshDataPayload
//
//  Desc:	Calls the class-specific getDataPayload() method and clears out
//			the cached column sort index map.
//
//	Args:	None
//
//	Return: Nothing.	
//  ============================================================================
	public void refreshDataPayload () {
		
		this.getDataPayload ();
		this.sortIdxByCol = Null;
	}                        
	
//  ============================================================================
//  Method:	getDataPayload
//
//  Desc:	Abstract method definition - to be overridden by all child classes.
//			This is how the grids get data into their 'dataPayload' member
//			variables.
//
//	Args:	None
//
//	Return: Nothing.	
//  ============================================================================                        
	public abstract void getDataPayload ();

//  ============================================================================
//  Method:	setSortFld
//
//  Desc:	Parses the 'clickedHdrCell' page parameter, which needs to have been
//			set by an apex:actionSupport component on the VF page, to determine
//			the array index of the cell that was clicked.  Uses this index to
//			identify which column to sort the grid by (and in which direction). 
//
//	Args:	None
//
//	Return: Null (not redirecting to another page)	
//  ============================================================================                        
	public PageReference setSortFld () {

		String clickedCellId = ApexPages.CurrentPage().getParameters().get ( CLICKED_CELL_PARAM );
		if ( clickedCellId == Null ) {
			return Null;
		}
		String[] idParts = clickedCellId.split ( ':' );
		if ( idParts.size () < 2 ) {
			return Null;
		}
		
		Integer sortColIdx;
		try {
			sortColIdx = Integer.valueOf ( idParts[ idParts.size () - 2 ] );
		}
		catch ( TypeException e ) {
			return Null;
		}
		
		System.debug ( 'SET SORT FLD : SORT COL IDX [' + sortColIdx + '] THIS SORT COL IDX [' + this.sortColIdx + '] SORT IDX BY COL [' + this.sortIdxByCol + ']' );
		if ( sortColIdx == this.sortColIdx ) {
			this.cols[ this.sortColIdx ].toggleSortAsc ();
			if ( this.sortIdxByCol != Null ) {
				this.sortIdxByCol.remove ( this.sortColIdx );
			}
		}
		this.sortColIdx = sortColIdx;

		return Null;
	}
	
}