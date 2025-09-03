/* 
 * Name: ContactCoveragePage
 * Description: Contains a page worth of ContactCoverage records.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class ContactCoveragePage {

	WebService ContactCoverage[] ContactCoverageList;
	WebService String NextName;
	
	public ContactCoveragePage () {
	}
	
	public ContactCoveragePage ( ContactCoverage[] ccList ) {
		this ( ccList , '' );
	}
	
	public ContactCoveragePage ( ContactCoverage[] ccList , String nextName ) {
		this.ContactCoverageList = ccList;
		this.NextName = nextName;
	}
}