/* 
 * Name: SObjectPage
 * Description: Contains a page worth of SObject records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class SObjectPage {

	WebService SObject[] SObjectList;
	WebService String NextKey;
	
	public SObjectPage () {
	}
	
	public SObjectPage ( SObject[] sobjList ) {
		this ( sobjList , '' );
	}
	
	public SObjectPage ( SObject[] sobjList , String nextKey ) {
		this.SObjectList = sobjList;
		this.NextKey = nextKey;
	}
	
//	============================================================================
//	Method:	pruneSobjListByFld	
//	Desc:	Utility to prune the specified SObject list, removing records with
//			duplicate values of the specified field from the end of the list.
//			If the list is the specified maximum size, remove the last record
//			always, as it may be duplicated by a record yet to be retrieved from
//			the database (in a subsequent page of SObject records).
//	Args:	sobjList	- List of SObject records, sorted by fldName
//			fldName		- the sort field name
//			pageSize	- Maximum SObject page size
//	Return:	The field value of the pruned record(s), if any.  May modify the
//			SObject list in situ.
//	============================================================================
	public static String pruneSobjListByFld ( SObject[] sobjList , String fldName ,
												Integer pageSize ) {

		Integer listSize = sobjList.size ();
		if ( listSize < pageSize ) {
			return Null;
		}

		Object nextVal = AceUtil.getSObjFld ( sobjList[ listSize - 1 ] , fldName );
		sobjList.remove ( listSize - 1 );
		for ( Integer i = listSize - 2 ; i >= 0 ; i-- ) {
			if ( AceUtil.getSObjFld ( sobjList[ i ] , fldName ) == nextVal ) {
				sobjList.remove ( i );
			}
			else {
				break;
			}
		}
		
		return ( sobjList.isEmpty () ? Null : String.valueOf ( nextVal ) );
	}
	
}