/* 
 * Name: ResearchPrefMetadataPage
 * Description: Contains a page worth of ResearchPreferenceMetadata records.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
  
global class ResearchPrefMetadataPage {

	WebService ResearchPreferenceMetadata[] rpmList;
	WebService String NextName;
	
	public ResearchPrefMetadataPage () {
	}
	
	public ResearchPrefMetadataPage ( ResearchPreferenceMetadata[] rpmList ) {
		this ( rpmList , '' );
	}
	
	public ResearchPrefMetadataPage ( ResearchPreferenceMetadata[] rpmList , String nextName ) {
		this.rpmList = rpmList;
		this.NextName = nextName;
	}
}