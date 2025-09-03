/* 
 * Name: AccountCoveragePage
 * Description: Contains a page worth of AccountCoverage records.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AccountCoveragePage {

	WebService AccountCoverage[] AccountCoverageList;
	WebService String NextName;
	
	public AccountCoveragePage () {
	}
	
	public AccountCoveragePage ( AccountCoverage[] acList ) {
		this ( acList , '' );
	}
	
	public AccountCoveragePage ( AccountCoverage[] acList , String nextName ) {
		this.AccountCoverageList = acList;
		this.NextName = nextName;
	}
}