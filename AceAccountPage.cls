/* 
 * Name: AceAccountPage
 * Description: Contains a page worth of Account records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AceAccountPage {

	WebService AceAccount[] AceAccountList;
	WebService String NextName;
	
	public AceAccountPage () {
	}
	
	public AceAccountPage ( AceAccount[] acctList ) {
		this ( acctList , '' );
	}
	
	public AceAccountPage ( AceAccount[] acctList , String nextName ) {
		this.AceAccountList = acctList;
		this.NextName = nextName;
	}
}