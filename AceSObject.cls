/* 
 * Name: AceSObject 
 * Description: Contains methods relating to generic SObject retrieval.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AceSObject {

//  ============================================================================
//  Method:	getSObjectInfoById
//  Desc:	Retrieves the specified list of fields from the specified
//			SObject, selecting the record with the specified Id.	
//  Args:	sobjId		- the SObject record Id.
//			sobjType	- the SObject type.
//			fldNames	- the fields to retrieve.
//  Return:	The specified SObject, or Null if sobjId has no match.  Throws an
//			error if the SObject type or any field name is incorrect.				   
//  ============================================================================
	public static SObject getSObjectInfoById ( String sobjId , String sobjType , 
												String[] fldNames ) {
		
		Sobject[] sobjList = getSObjectInfo ( sobjType , 
												'Id = \'' + sobjId + '\'' ,
												Null , Null , fldNames );
		if ( sobjList == Null || sobjList.isEmpty () ) {
			return Null;
		}
		else {
			return sobjList[ 0 ];
		}
	}
	
//  ============================================================================
//  Method:	getSObjectInfo
//  Desc:	Retrieves the specified list of fields from the specified
//			SObject, using the specified whereClause as a query filter, sorting
//			by the specified field and limiting the result set to the specified
//			number of records (default : 1000).	
//  Args:	sobjType	- the SObject type.
//			whereClause	- the query clause.
//			sortFld		- the field to sort on.
//			bSortAsc	- ascending/descending sort order flag.
//			bNullsLast	- flag indicating Nulls last (Nulls first if not set).
//			maxRecs		- the maximum # of records to return.
//			fldNames	- the fields to retrieve.
//  Return:	A list of matching SObjects.  Throws an error if the SObject type
//			or if the sort field or any other field name is incorrect.	
//	ADD SPECIAL CHAR PROTECTION			   
//  ============================================================================
	public static SObject[] getSObjectInfo ( String sobjType , String whereClause , 
												String sortFld , Integer maxRecs ,
												String[] fldNames ) {
		return getSObjectInfo ( sobjType , whereClause , sortFld , True , False , 
								maxRecs , fldNames );
	}
	
	public static SObject[] getSObjectInfo ( String sobjType , String whereClause , 
												String sortFld , Boolean bSortAsc ,
												Boolean bNullsLast , Integer maxRecs ,
												String[] fldNames ) {
		
		if ( fldNames == Null || fldNames.isEmpty() ) {
			return Null;
		}
		if ( maxRecs == Null || maxRecs < 1 || maxRecs > AceUtil.MAX_COLLECTION_SIZE ) {
			maxRecs = AceUtil.MAX_COLLECTION_SIZE;
		}
		
		String soqlQry = 'select '
							+ aceUtil.concatList ( fldNames , ' , ' ) + ' '
						+ 'from '
							+ sobjType + ' ';

		if ( whereClause != Null && whereClause != '' ) {
			soqlQry 	+= ( whereClause.contains ( 'where ' ) ? '' : 'where ' ) + whereClause + ' ';
		}
		if ( sortFld != Null && sortFld != '' ) {
			soqlQry		+= 'order by ' + sortFld + ' ' 
							+ ( bSortAsc ? '' : 'desc' ) 
							+ ( bNullsLast ? ' nulls last ' : '' );
		}
		soqlQry			+= 'limit ' + maxRecs;

		System.debug ( 'SOQL QRY:\n' + soqlQry );
		return Database.query ( soqlQry );
	}
	
//  ============================================================================
//  Method:	getSObjectPage
//  Desc:	Retrieves a page of SObjects of the specified type, sorted on the
//			specified field and starting at the specified fld value.
//			Uses 'getSObjectInfo' to do the heavy lifting.
//  Args:	sobjType	- the SObject type.
//			whereClause	- the query clause.
//			sortFld		- the field to sort on.
//			startFldVal	- the starting sort fld value
//			pageSize	- the max. # of recs in the returned page
//			fldNames	- the fields to retrieve.
//  Return:	A SObjectPage record containing the retrieved SObjects, plus the
//			start point of the next page, if any.	
//  ============================================================================
	public static SObjectPage getSObjectPage ( String sobjType , String whereClause ,
												String sortFld , String startFldVal ,
												Integer pageSize , String[] fldNames ) {
		
		if ( pageSize <= 1 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		
		if ( whereClause == Null ) {
			whereClause = '';
		}
		else if ( whereClause != '' ) {
			whereClause = 'where ' + whereClause;
		}
		whereClause += aceUtil.mkPageQryClause ( ( whereClause != '' ) , sortFld , startFldVal );

//		In order for the paging algorithm to work, we need to explicitly include our 
//		sort field in the query.  Add it to the field list here, if necessary.
//		----------------------------------------------------------------------------		
		Boolean bAddSortFld = True;
		for ( String fld : fldNames ) {
			if ( fld == sortFld ) {
				bAddSortFld = False;
				break;
			}
		}
		if ( bAddSortFld ) {
			fldNames.add ( sortFld );
		}
		SObject[] sobjList = getSObjectInfo ( sobjType , whereClause , sortFld , pageSize , fldNames );
		String nextFldVal = SObjectPage.pruneSobjListByFld ( sobjList , sortFld , pageSize );
		
		return new SObjectPage ( sobjList , nextFldVal );
	} 
}