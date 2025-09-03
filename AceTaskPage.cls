/* 
 * Name: AceTaskPage
 * Description: Contains a page worth of AceTask records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class AceTaskPage {

	WebService AceTask[] TaskList;
	WebService DateTime NextCreatedDate;
	
	public AceTaskPage () {
	}
	
	public AceTaskPage ( AceTask[] taskList ) {
		this ( taskList , Null );
	}
	
	public AceTaskPage ( AceTask[] taskList , DateTime nextCreatedDate ) {
		this.TaskList = taskList;
		this.NextCreatedDate = nextCreatedDate;
	}
}