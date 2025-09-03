/* 
 * Name: AVGCurrencyGridColumn 
 * Description: Extends AVGBasicGridColumn with some currency-specific cell
 *				formatting.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGCurrencyGridColumn extends AVGBasicGridColumn {

//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	label		- The column label.
//			width		- The column width.
//			sfdcFlds	- The list of SFDC object fld names to populate this column. 
//			sortFldIdx	- Of the array of strings eventually populating this
//						  column's cells, which string of the array we sort on
//						  (for cases where we are not using SObjects).
//			sortFld		- Of the list of strings in sfdcFlds, which to sort on.
//  ============================================================================                        
	public AVGCurrencyGridColumn ( String label , Integer sortFldIdx , Integer width ) {
		super ( label , sortFldIdx , width );
	}
	
	public AVGCurrencyGridColumn ( String[] sfdcFlds , String label , Integer width ) {
		super ( sfdcFlds , label , width );
	}
	
	public AVGCurrencyGridColumn ( String[] sfdcFlds , String sortFld , String label , Integer width ) {
		super ( sfdcFlds , sortFld , label , width );
	}
	
//  ============================================================================
//  Method:	formatDispStr
//
//  Desc:	Converts the specified string list to a currency string, simply by
//			extracting its leftmost string, formatting it to 2 decimal places
//			and prepending a '$' to it. 
//
//	Args:	dispStrList	- The list of strings.
//
//	Return:	The currency-ified string.
//  ============================================================================                        
	public virtual override String formatDispStr ( String[] dispStrList ) {
		
		String dispStr = dispStrList[ 0 ];
		if ( dispStr != Null ) {
			String currData;
			try {
				Decimal decData = Decimal.valueOf ( dispStr ).setScale ( 2 );
				currData = convertToCurrency ( decData );
			}
			catch ( Exception e ) {
				currData = dispStr;
			}
			return currData;
		}
		else {
			return Null;
		}
	}
	
//  ============================================================================
//  Method:	convertToCurrency
//
//  Desc:	Converts the specified decimal to a currency, by interpolating 
//			commas and prepending a '$'.
//
//	Args:	currVal	- the decimal currency value.
//
//	Return:	The currency-ified string.
//  ============================================================================                        
	static String convertToCurrency ( Decimal currVal ) {
		
		String rawCurrStr = currVal.toPlainString ();
		String currStr = '';
		Pattern currPtrn = Pattern.compile ( '^(-?)([\\d]+)(\\d{3}(\\.\\d*)?)$' );
		while ( True ) {
			Matcher m = currPtrn.matcher ( rawCurrStr );
			if ( m.matches () ) {
				currStr = m.group ( 3 ) + ( currStr == '' ? '' : ',' ) + currStr;
				rawCurrStr = m.group ( 1 ) + m.group ( 2 );
			}
			else {
				currStr = rawCurrStr + ( currStr == '' ? '' : ',' ) + currStr;
				break;
			}
		}
		
		return '$' + currStr;
	}
}