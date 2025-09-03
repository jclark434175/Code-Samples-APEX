/* 
 * Name: AceListPage
 * Description: Contains a page worth of AccountCoverage records.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
global class AceListPage 
{
	WebService AceList[] AceList;	
	WebService String NextName;
	
	public AceListPage () {
	}
	
	public AceListPage ( AceList[] aceList ) 
	{
		this ( aceList , '' );
	}
	
	public AceListPage ( AceList[] aceList , String nextName ) 
	{
		this.AceList = aceList;
		this.NextName = nextName;
	}
}