/* 
 * Name: AVGDateGridColumn 
 * Description: Extends AVGBasicGridColumn with some Date-specific cell formatting.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGDateGridColumn extends AVGBasicGridColumn {

//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	label		- The column label.
//			width		- The column width.
//			sfdcFlds	- The list of SFDC object fld names to populate this column. 
//  ============================================================================                        
	public AVGDateGridColumn ( String label , Integer width ) {
		super ( label , width );	
	}
	
	public AVGDateGridColumn ( String[] sfdcFlds , String label , Integer width ) {
		super ( sfdcFlds , label , width );
	}
	
//  ============================================================================
//  Method:	formatDispStr
//
//  Desc:	Splits the first element of the specified list of strings, and
//			extracts the first word from this element (this would be the DATE
//			component of a 'DATE TIME' string). 
//
//	Args:	dispStrList	- The list of strings.
//
//	Return:	The extracted DATE component.
//  ============================================================================                        
	public virtual override String formatDispStr ( String[] dispStrList ) {
		
		String dispStr = dispStrList[ 0 ];
		if ( dispStr != Null ) {
			return dispStr.split ( ' ' )[ 0 ];
		}
		else {
			return '';
		}
	}
	
}