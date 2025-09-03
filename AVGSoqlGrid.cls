/* 
 * Name: AVGSoqlGrid 
 * Description: Contains the details of a SOQL-driven AVG grid.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGSoqlGrid extends AVGGrid {

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	protected String sobjType;
	protected String whereClause;
	
//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	title		- the grid title.
//			sobjType	- the SObject supplying the grid contents.
//			whereClause	- the query clause of the underlying SOQL query.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//  ============================================================================                        
 	public AVGSoqlGrid ( String title , String sobjType , String whereClause , AVGGridColumn[] cols ) {
		
		this.init ( title , sobjType , whereClause , cols );
			
		this.refreshDataPayload ();
	}

	public AVGSoqlGrid () {
	}
	
//  ============================================================================
//  Method:	init
//
//  Desc:	Initializes the grid object's instance variables.
//
//	Args:	title		- the grid title.
//			sobjType	- the SObject supplying the grid contents.
//			whereClause	- the query clause of the underlying SOQL query.
//			cols		- List of AVGGridColumn objects defining the grid 
//						  columns.
//  ============================================================================                        
	public virtual void init ( String title , String sobjType , String whereClause , AVGGridColumn[] cols ) {
		super.init ( title , cols );
		
		this.sobjType = sobjType;
		this.whereClause = whereClause; 
	}
	
//  ============================================================================
//  Method:	getSObjectPayload
//
//  Desc:	Uses the contents of this instance's column array and WHERE clause
//			to construct and execute a dynamic SOQL query.
//
//	Args:	None
//
//	Return: The SObject[] result list from the SOQL query.
//  ============================================================================                        
	public virtual SObject[] getSObjectPayload () {
		
//		Construct + execute the SOQL query to populate the grid.
//		--------------------------------------------------------
		String[] fldNames = new String[] {};
		String sortFldName;
		Boolean bSortAsc = False;
		for ( Integer i = 0 ; i < this.cols.size () ; i++ ) {
			AVGGridColumn col = this.cols[ i ];
			fldNames.addAll ( col.getSfdcFlds () );
			if ( i == this.sortColIdx ) {
				sortFldName = col.getSortFld ();
				bSortAsc = col.getSortAsc ();
			}
		}
		SObject[] sobjList;
		try {
			sobjList = AceSObject.getSObjectInfo ( this.sobjType , this.whereClause , 
													sortFldName , bSortAsc , True , 
													AceUtil.MAX_COLLECTION_SIZE , fldNames );
		}
		catch ( Exception e ) {
			ApexPages.addMessages ( e );
		}
		
		return sobjList;		
	}
	
//  ============================================================================
//  Method:	getDataPayload
//
//  Desc:	Uses the getSObjectPayload() method to retrieve a SObject[] dataset,
//			and massages the dataset into a list of AVGGridRow[] objects, 
//			suitable for display by the VF page.  Stores the results in the
//			instance dataPayload variable and sets the grid height as well.
//
//	Args:	None
//
//	Return: None.
//  ============================================================================                        
	public virtual override void getDataPayload () {
		
		SObject[] sobjList = getSObjectPayload ();
		
//		Massage the resulting data, if any, into a matrix of output.
//		------------------------------------------------------------
		AVGGridRow[] data = new AVGGridRow[] {};
		if( sobjList == Null ) {
			this.height = 0;
			this.dataPayload = data;
			return;
		}
			
		for ( Integer i = 0 ; i < sobjList.size () ; i++ ) {

			String rowClass = ROW_CLASSES[ Math.mod ( i , 2 ) ];
			AVGGridRow row = new AVGGridRow ( rowClass );
			SObject sobj = sobjList[ i ];

			for ( AVGGridColumn col : this.cols ) {
				row.cells.add ( col.mkDataCell ( sobj ) );
			}
			data.add ( row );
		}
		
		this.dataPayload = data;
		this.height = sobjList.size ();
	}
}