/* 
 * Name: AceWSResult 
 * Description: Encapsulates success/failure + status msg, for write-type
 * WebServices methods.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AceWSResult {

	webService Boolean bSuccess;
	webService String statusMsg;

	public AceWSResult () {
		this ( True , '' );
	}
	
	public AceWSResult ( Boolean bStatus , String msg ) {
		this ( bStatus , msg , '' );
	}

	public AceWSResult ( Boolean bStatus , String msg , String context ) {
		bSuccess = bStatus;
		statusMsg = msg;
		if ( context != Null && context != '' ) {
			System.debug ( context + ' : ' + msg );
		}
	}
	
	public void setResult ( Boolean bStatus , String msg ) {
		bSuccess = bStatus;
		statusMsg = msg;
	}	
}