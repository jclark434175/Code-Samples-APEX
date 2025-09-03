/* 
 * Name: AVGBasicGridColumn 
 * Description: Implements the AVGGridColumn interface in a basic way.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGBasicGridColumn implements AVGGridColumn {

//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	public String[] sfdcFlds;
	public String sortFldName;
	public Integer sortFldIdx;
	public Boolean bSortAsc;
	public Integer width;
	public String label;
	public String delim;
	
//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors of various flavours.
//
//	Args:	label		- The column label.
//			width		- The column width.
//			sfdcFlds	- The list of SFDC object fld names to populate this column. 
//			sortFldIdx	- Of the array of strings eventually populating this
//						  column's cells, which string of the array we sort on
//						  (for cases where we are not using SObjects).
//			sortFld		- Of the list of strings in sfdcFlds, which to sort on.
//  ============================================================================                        
	public AVGBasicGridColumn ( String label , Integer width ) {
		this ( label , 0 , width );
	}
	
	public AVGBasicGridColumn ( String label , Integer sortFldIdx , Integer width ) {
		this.label = label;
		this.width = width;
		this.sortFldIdx = sortFldIdx;
		
		this.delim = ' ';
		this.bSortAsc = True;
	}

	public AVGBasicGridColumn ( String[] sfdcFlds , String label , Integer width ) {
		this ( sfdcFlds , 0 , label , width );
	}
		
	public AVGBasicGridColumn ( String[] sfdcFlds , Integer sortFldIdx , String label , Integer width ) {
		this ( label , width );
		this.sfdcFlds = sfdcFlds;
		this.sortFldIdx = sortFldIdx;
	}

	public AVGBasicGridColumn ( String[] sfdcFlds , String sortFld , String label , Integer width ) {
		this ( label , width );
		this.sfdcFlds = sfdcFlds;
		for ( Integer idx = 0 ; idx < sfdcFlds.size () ; idx++ ) {
			if ( sfdcFlds[ idx ] == sortFld ) {
				this.sortFldIdx = idx;
				break;
			}
		}
	}
	
	public AVGBasicGridColumn () {}
	
//  ============================================================================
//  Method:	getSFDCFlds
//			setSFDCFlds
//			getSortFld
//			setSortFld
//			getSortAsc
//			toggleSortAsc
//			getWidth
//			getLabel
//
//  Desc:	Various simple methods to get + set instance variables, implementing
//			the AVGGridColumn interface.
//  ============================================================================                        
	public String[] getSfdcFlds () {
		return this.sfdcFlds;
	}
	public void setSFDCFlds ( String[] sfdcFlds ) {
		this.sfdcFlds = sfdcFlds;
	}
	
	public String getSortFld () {
		return sortFldName;
	}
	public void setSortFld ( String sortFldName ) {
		this.sortFldName = sortFldName;
	}
	
	public void toggleSortAsc () {
		this.bSortAsc = !this.bSortAsc;
	}
	public Boolean getSortAsc () {
		return this.bSortAsc;
	}
	
	public Integer getWidth () {
		return this.width;
	}

	public String getLabel () {
		return this.label;
	}

	public String getDelim () {
		return this.delim;
	}

	public void setDelim ( String delim ) {
		this.delim = delim;
	}

//  ============================================================================
//  Method:	mkHdrCell
//
//  Desc:	Creates an AVGGridCell for this column's header, including an up or
//			down arrow denoting whether this is the sort column and which 
//			direction the sorting is in.
//
//	Args:	bSortCol	- flag indicating whether this is the sort column.
//
//	Return:	The header cell.
//  ============================================================================                        
	public AVGGridCell mkHdrCell ( Boolean bSortCol ) {
		String dispHdr = this.label;
		if ( bSortCol ) {
			dispHdr += ' ' + ( this.bSortAsc ? '&darr;' : '&uarr;' );
		}
		return new AVGGridCell ( this.width , dispHdr );
	}

//  ============================================================================
//  Method:	mkDataCell
//
//  Desc:	Creates an AVGGridCell containing the data in the specified SObject,
//			as determined from this instance's sfdcFlds array.
//
//	Args:	sobj	- The SObject.
//
//	Return:	The data cell.
//  ============================================================================                        
	public virtual AVGGridCell mkDataCell ( SObject sobj ) {
		String[] dispStrList = new String[] {};
		String sortStr = '';
		for ( Integer idx = 0 ; idx < this.sfdcFlds.size () ; idx++ ) {
			String fldName = this.sfdcFlds[ idx ];
			String fldStr = getSObjFld ( sobj , fldName );
			if ( idx == this.sortFldIdx ) {
				sortStr = fldStr;
			}
			dispStrList.add ( fldStr );
		}
		String dispStr = formatDispStr ( dispStrList );
		return new AVGGridCell ( this.width , dispStr , sortStr );
	}
	
//  ============================================================================
//  Method:	mkDataCell
//
//  Desc:	Creates an AVGGridCell containing the specified string.
//
//	Args:	fld		- the string
//
//	Return:	The data cell.
//  ============================================================================                        
	public virtual AVGGridCell mkDataCell ( String fld ) {
		return mkDataCell ( new String[] { fld } );
	}
	
//  ============================================================================
//  Method:	mkDataCell
//
//  Desc:	Creates an AVGGridCell containing the data in the specified list of
//			strings.
//
//	Args:	fldList	- the list of strings.
//
//	Return:	The data cell.
//  ============================================================================                        
	public virtual AVGGridCell mkDataCell ( String[] fldList ) {
		String dispStr = formatDispStr ( fldList );
		return new AVGGridCell ( this.width , dispStr , fldList[ this.sortFldIdx ] );
	}
	
//  ============================================================================
//  Method:	formatDispStr
//
//  Desc:	Concatenates the specified list of strings.  This method would
//			typically be overridden by any child class of this class. 
//
//	Args:	dispStrList	- The list of strings.
//
//	Return:	The concatenated string.
//  ============================================================================                        
	public virtual String formatDispStr ( String[] dispStrList ) {
		String dispStr = '';
		for ( String str : dispStrList ) {
			dispStr += ( dispStr == '' ? '' : this.delim ) + str;
		}
		return dispStr;
	}
	
//  ============================================================================
//  Method:	getSObjFld
//
//  Desc:	Grabs the value of the field with the specified name from the
//			specified SObject.  If the field is a relationship field (e.g.
//			'Contact.Phone', this method recurses into the relationship object
//			to get the field value.
//
//	Args:	sobj	- the SObject
//			fldName	- the field name
//
//	Return: The field value (blank string if not found).
//  ============================================================================                        
	public String getSObjFld ( SObject sobj , String fldName ) {
		if ( !fldName.contains ( '.' ) ) {
			Object obj = sobj.get ( fldName );
			String fldVal = ( obj == Null ? '' : String.valueOf ( sobj.get ( fldName ) ) );
			return ( fldVal == Null ? '' : fldVal );
		}
		else {
			Pattern fldPtrn = Pattern.compile ( '^([^.]+)\\.(.*)$' );
			Matcher fldMatcher = fldPtrn.matcher ( fldName );
			if ( !fldMatcher.matches () ) {
				return '';
			}
			else {
				SObject refSobj = sobj.getSObject ( fldMatcher.group ( 1 ) );
				String refFldName = fldMatcher.group ( 2 );
				return ( refSObj == Null ? '' : getSObjFld ( refSobj , refFldName ) );
			}
		}
	}
	
//  ============================================================================
//  Method:	sortData
//
//  Desc:	Sorts the specified list of strings.  If the strings are all numeric,
//			sorts them numerically; otherwise does a straight string sort.
//			Reverses the sort if this instance's bSortAsc variable is False.
//			In either case - keeps NULL values at the bottom of the sorted list.
//
//	Args:	dataList	- the list of strings.
//
//	Return: An integer array, indexing into the original string list.
//  ============================================================================                        
	public Integer[] sortData ( String[] dataList ) {
		
//		Inspect the fields to see if we should be sorting numerically.
//		--------------------------------------------------------------
		Boolean bNumeric = True;
		Map<String , Integer[]> idxsByFld = new Map<String , Integer[]> {};
		Map<Decimal , Integer[]> idxsByDFld = new Map<Decimal , Integer[]> {};  
		Integer[] nullIdxList = new Integer[] {};

		for ( Integer idx = 0 ; idx < dataList.size () ; idx++ ) {
			String fld = dataList[ idx ];

//			Capture Null fields for inclusion at the BOTTOM of the sorted list.
//			-------------------------------------------------------------------
			if ( fld == Null || fld == '' ) {
				nullIdxList.add ( idx );
				continue;
			}
			
			if ( bNumeric ) {
				try {
					Decimal dFld = Decimal.valueOf ( fld );
					if ( !idxsByDFld.containsKey ( dFld ) ) {
						idxsByDFld.put ( dFld , new Integer[] {} );
					}
					idxsByDFld.get ( dFld ).add ( idx );
				}
				catch (TypeException te ){
					bNumeric = False;
				}
			}

			fld = fld.toUpperCase ();
			if ( !idxsByFld.containsKey ( fld ) ) {
				idxsByFld.put ( fld , new Integer[] {} );
			}
			idxsByFld.get ( fld ).add ( idx );
		}

		Integer[] sortedIdxList = new Integer[] {};
		if ( bNumeric ) {
			List<Decimal> dFldList = new List<Decimal> ( idxsByDFld.keySet () );
			dFldList.sort ();
			for ( Decimal dFld : dFldList ) {
				sortedIdxList.addAll ( idxsByDFld.get ( dFld ) );
			}
		}
		else {
			List<String> fldList = new List<String> ( idxsByFld.keySet () );
			fldList.sort ();
			for ( String fld : fldList ) {
				sortedIdxList.addAll ( idxsByFld.get ( fld ) );
			}
		}	

//		Reverse the sort if necessary.
//		------------------------------
		if ( ( !this.bSortAsc && !bNumeric ) || ( this.bSortAsc && bNumeric ) ) {
			Integer[] revSortedIdxList = new Integer[] {};
			for ( Integer idx = sortedIdxList.size () - 1 ; idx >= 0 ; idx-- ) {
				revSortedIdxList.add ( sortedIdxList[ idx ] );
			}
			sortedIdxList = revSortedIdxList;
		}
		
//		Add on the Nulls/blanks, which we always want to appear at the end.
//		-------------------------------------------------------------------
		sortedIdxList.addAll ( nullIdxList );
		return sortedIdxList;
	}
}