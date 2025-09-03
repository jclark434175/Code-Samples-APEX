/* 
 * Name: AceListEntryPage
 * Description: Contains a page worth of Ace List Entry records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */

global class AceListEntryPage 
{
	WebService AceListEntry[] AceListEntryList;
	WebService String NextName;
	
	public AceListEntryPage() 
	{
	}
	
	public AceListEntryPage( AceListEntry[] aceListEntryList ) 
	{
		this ( aceListEntryList , '' );
	}
	
	public AceListEntryPage ( AceListEntry[] aceListEntryList , String nextName ) {
		this.AceListEntryList = aceListEntryList;
		this.NextName = nextName;
	}
}