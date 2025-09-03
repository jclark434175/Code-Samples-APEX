/* 
 * Name: AceContactPage
 * Description: Contains a page worth of Contact records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AceContactPage {

	WebService AceContact[] AceContactList;
	WebService String NextName;
	
	public AceContactPage () {
	}
	
	public AceContactPage ( AceContact[] contList ) {
		this ( contList , '' );
	}
	
	public AceContactPage ( AceContact[] contList , String nextName ) {
		this.AceContactList = contList;
		this.NextName = nextName;
	}
}