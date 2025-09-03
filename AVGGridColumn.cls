/* 
 * Name: AVGGridColumn
 * Description: Contains the interface definition of an AVG grid column.  All concrete
 *				AVG grid column objects implement this interface.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public interface AVGGridColumn {

	String[] getSFDCFlds ();
	void setSFDCFlds ( String[] sfdcFlds );
	
	String getSortFld ();
	void setSortFld ( String fldName );
	Boolean getSortAsc ();
	void toggleSortAsc ();
	Integer getWidth ();
	String getLabel ();
	String getDelim ();
	void setDelim ( String delim );
	
	AVGGridCell mkHdrCell ( Boolean bSortCol );
	AVGGridCell mkDataCell ( SObject sobj );
	AVGGridCell mkDataCell ( String[] fldList );
	AVGGridCell mkDataCell ( String fld );
	
	String getSObjFld ( SObject sobj , String fld );
	
	String formatDispStr ( String[] dispStrList );

	Integer[] sortData ( String[] dataList );
}