/* 
 * Name: AVGTest 
 * Description: Test methods for core AVG infrastructure
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
@isTest
private class AVGTest {

	public static testMethod void testAVG () {

		Test.startTest();
		
//		Create a legitimate SOQL grid.
//		------------------------------		
		AVGGridColumn[] avggCols = new AVGGridColumn[] {
			new AVGLinkGridColumn ( new String[] { 'FirstName' , 'LastName' , 'Id' } , 
									'LastName' , 'User' , 100 ) ,
			new AVGLinkGridColumn ( new String[] { 'CreatedBy.Name' , 'CreatedById' } , 
									'CreatedBy.Name' , 'CreatedBy' , 100 ) ,
			new AVGBasicGridColumn ( new String[] { 'Email' } , 'Email' , 80 ) ,
			new AVGDateGridColumn ( new String[] { 'CreatedDate' } , 'Created' , 80 ) ,
			new AVGCurrencyGridColumn ( new String[] { 'Phone' } , 'Phone' , 80 )
		};
		AVGGrid avgg =  new AVGSoqlGrid ( 'SOQL GRID' , 'User' , 
										'IsActive = True' , 
										avggCols );
										
//		Grab its data.
//		--------------
		AVGGridRow[] avggData = avgg.data;
		
//		Set the sort field legitimately.
//		--------------------------------
		ApexPages.currentPage ().getParameters ().put ( AVGGrid.CLICKED_CELL_PARAM , 'bogus:bogus:0:bogus' );
		avgg.setSortFld ();
		avggData = avgg.data;
		AVGGridRow avggHdr = avgg.hdr;

//		Grab the data again.
//		--------------------
		avgg.refreshDataPayload ();		
		avggData = avgg.data;

//		Toggle the sort field and grab the data again.
//		----------------------
		avgg.setSortFld ();
		avgg.refreshDataPayload ();		
		avggData = avgg.data;

//		Set the sort field in a variety of ILLEGITIMATE ways.
//		-----------------------------------------------------
		ApexPages.currentPage ().getParameters ().put ( AVGGrid.CLICKED_CELL_PARAM , 'bogus:bogus:bogus:bogus' );
		avgg.setSortFld ();		
		ApexPages.currentPage ().getParameters ().put ( AVGGrid.CLICKED_CELL_PARAM , 'bogus' );
		avgg.setSortFld ();
		ApexPages.currentPage ().getParameters ().remove ( AVGGrid.CLICKED_CELL_PARAM );
		avgg.setSortFld ();		
		
//		Create a bogus SOQL grid.
//		-------------------------		
		avgg =  new AVGSoqlGrid ( 'SOQL GRID' , 'User' , 
									'BogusFld = True' , 
									avggCols );
		avggData = avgg.data;

//		Create a new Data Range grid.
//		-----------------------------
		avgg = new AVGDateRangeGrid ( 'DATE RANGE GRID' , 'User' , 'IsActive = True' ,
										'CreatedDate' , avggCols );
		( (AVGDateRangeGrid)avgg ).dateRange.dateRange = ( (AVGDateRangeGrid)avgg ).dateRange.dateRange;
 				
		( (AVGDateRangeGrid)avgg ).dateRange.startDate = '';
		( (AVGDateRangeGrid)avgg ).dateRange.endDate = '';
		avgg.refreshDataPayload ();

//		Construct some grid buttons.
//		----------------------------
		Test.setCurrentPage ( new PageReference ( 'https://www.salesforce.com' ) );
		
		System.debug ( 'TEST URL [' + ApexPages.currentPage ().getUrl () + ']' );
		avgg.buttons = new AVGGridButton[] {
							new AVGGridButton ( 'TestLabel' , AVGGridButton.mkNewURL ( 'User' ) )
		};
		avgg.buttons[ 0 ].doAction ();
		
//		Miscellaneous constructors.
//		---------------------------
		avgg = new AVGSoqlGrid ();
		avgg = new AVGDateRangeGrid ();
		
		AVGGridColumn avggCol = new AVGBasicGridColumn ();
		avggCol = new AVGDateGridColumn ( 'TestCol' , 50 );
		avggCol = new AVGDateGridColumn ( new String[] { 'TestFld' } , 'TestCol' , 50 );
		avggCol = new AVGLinkGridColumn ( 'TestCol' , 0 , 50 );
		avggCol = new AVGLinkGridColumn ( new String[] { 'TestFld' } , 'TestCol' , 50 );
		avggCol = new AVGCurrencyGridColumn ( 'TestCol' , 0 , 50 );
		avggCol = new AVGCurrencyGridColumn ( new String[] { 'TestFld' } , '' , 'TestCol' , 50 );

//		Exercise miscellaneous methods in AVGBasicGridColumn.
//		-----------------------------------------------------
		avggCol.setSFDCFlds ( new String[] { 'TestFld' } );
		avggCol.setSortFld ( 'TestFld' );
		avggCol.getWidth ();
		avggCol.getLabel ();
		avggCol.setDelim ( 'TestDelim' );
		avggCol.getDelim ();
		avggCol.mkDataCell ( 'TestData' );

//		Miscellaneous other stuff.
//		--------------------------
		AVGUtil.mkDateTime ( 'TestDate' );		
	}
}