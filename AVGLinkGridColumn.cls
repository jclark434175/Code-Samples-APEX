/* 
 * Name: AVGLinkGridColumn 
 * Description: Extends AVGBasicGridColumn with some hyperlink-specific cell
 *				formatting.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGLinkGridColumn extends AVGBasicGridColumn {

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
	public AVGLinkGridColumn ( String label , Integer sortFldIdx , Integer width ) {
		super ( label , sortFldIdx , width );
	}
	
	public AVGLinkGridColumn ( String[] sfdcFlds , String label , Integer width ) {
		super ( sfdcFlds , label , width );
	}
	
	public AVGLinkGridColumn ( String[] sfdcFlds , String sortFld , String label , Integer width ) {
		super ( sfdcFlds , sortFld , label , width );
	}
	
//  ============================================================================
//  Method:	formatDispStr
//
//  Desc:	Creates a hyperlink HTML fragment fromt he specified list of strings.
//			Treats the rightmost string in the list as the 'target' - the Id of
//			the SObject we're hyperlinking to. 
//
//	Args:	dispStrList	- The list of strings.
//
//	Return:	The assembled HTML fragment.
//  ============================================================================                        
	public virtual override String formatDispStr ( String[] dispStrList ) {
	
		String tgtIdStr = dispStrList.remove ( dispStrList.size () - 1 );
		String dispStr = super.formatDispStr ( dispStrList );

//		return '<a href="/' + tgtIdStr + '">' + dispStr + '</a>';
		return '<a href="/' + tgtIdStr + '" target="_top">' + dispStr + '</a>';
//		return '<a href="/' + tgtIdStr + '?isdtp=mn" target="_blank">' + dispStr + '</a>';
	}
}