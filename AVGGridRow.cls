/* 
 * Name: AVGGridRow
 * Description: Contains the definition of an AVG grid row.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGGridRow {

//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================
	public AVGGridCell[] cells { get; set; }
	public String rowClass { get; set; }
	
//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructor.
//
//	Args:	rowClass	- the HTML class of this row.
//  ============================================================================                        
	public AVGGridRow ( String rowClass ) {
		this.rowClass = rowClass;
		this.cells = new AVGGridCell[] {};
	}
}