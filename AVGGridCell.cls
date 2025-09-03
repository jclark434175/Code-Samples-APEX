/* 
 * Name: AVGGridCell
 * Description: Contains the definition of an AVG grid cell.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGGridCell {
	
//	==========================================
//	Instance variables (not bound to VF page).
//	==========================================
	public String sortData;
	
//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================
	public Integer width { get; set; }
	public String data { get; set; }

//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructors.
//
//	Args:	width		- the cell width.
//			data		- The data to display in the cell.
//			sortData	- The data we use when sorting on this cell's column.
//  ============================================================================                        
	public AVGGridCell ( Integer width , String data ) {
		this ( width , data , '' );
	}
	
	public AVGGridCell ( Integer width , String data , String sortData ) {
		this.width = width;
		this.data = data;
		this.sortData = sortData;
	}
}