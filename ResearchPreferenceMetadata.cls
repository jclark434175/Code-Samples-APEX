/* 
 * Name: ResearchPreferenceMetadata 
 * Description: Contains details of an ACE ResearchPreferenceMetadata record.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 		
global class ResearchPreferenceMetadata {
	
	webService String Id;
	webService String Name;
	webService String CUSIP;
	webService String EmployeeId;
	webService String ShortName;
	webService AceRecordType RecType;
	
	public ResearchPreferenceMetadata () {
	}

	public ResearchPreferenceMetadata ( ST_Research_Preference_Metadata__c rpm ) {
		if ( rpm == Null ) { return; }

		try { this.Id = rpm.Id; } catch ( SObjectException e ) {}
		try { this.Name = rpm.Name; } catch ( SObjectException e ) {}
		try { this.CUSIP = rpm.CUSIP__c; } catch ( SObjectException e ) {}
		try { this.EmployeeId = rpm.Employee__c; } catch ( SObjectException e ) {}
		try { this.ShortName = rpm.ST_Short_Name__c; } catch ( SObjectException e ) {}
		
		try { this.RecType = new AceRecordType ( rpm.RecordType ); } catch ( SObjectException e ) {}
	}
	
//	============================================================================
//	Method:	getResearchPreferenceMetadata	
//	Desc:	Gets a page of Research Preference Metadata records matching the
//			specified Record Type Id, or all records if no Rec Type Id specified.
//	Args:	recTypeId	- the Record Type Id
//			startName	- the RPM name to start with
//			pageSize	- the page size
//	Return: Page of matching ResearchPreferenceMetadata records.
//	Case	3987
//	============================================================================
	public static ResearchPrefMetadataPage getResearchPreferenceMetadata ( 
													String recTypeId , String startName , 
													Integer pageSize ) {
		
		if ( pageSize <= 0 || pageSize > aceUtil.MAX_COLLECTION_SIZE ) {
			pageSize = aceUtil.MAX_COLLECTION_SIZE;
		}
		
		RPMListBuilder rpmlb = new RPMListBuilder ( pageSize );

		if ( recTypeId == Null || recTypeId == '' ) {
			for ( ST_Research_Preference_Metadata__c sfRPM :
												[ select
													Id ,
													Name ,
													CUSIP__c ,
													Employee__c ,
													ST_Short_Name__c ,
													RecordType.Id ,
													RecordType.Name
												from
													ST_Research_Preference_Metadata__c
												where
													Name >= :startName
												order by 
													Name
												limit 
													:pageSize + 1
													
												]
			) {
				if ( !rpmlb.addRPM ( new ResearchPreferenceMetadata ( sfRPM ) ) ) {
					break;
				}
			}
		}
		else {
			for ( ST_Research_Preference_Metadata__c sfRPM :
												[ select
													Id ,
													Name ,
													CUSIP__c ,
													Employee__c ,
													ST_Short_Name__c ,
													RecordType.Id ,
													RecordType.Name
												from
													ST_Research_Preference_Metadata__c
												where
													Name >= :startName and
													RecordTypeId = :recTypeId
												order by 
													Name
												limit 
													:pageSize + 1
												]
			) {
				if ( !rpmlb.addRPM ( new ResearchPreferenceMetadata ( sfRPM ) ) ) {
					break;
				}
			}
		}
		
//		Flush the RPM List Builder buffer.
//		----------------------------------
		if ( rpmlb.nextName == Null ) {
			rpmlb.addCachedRPMs ();
		}
		
		return new ResearchPrefMetadataPage ( rpmlb.rpmList , rpmlb.nextName );
	}
	
//	============================================================================
//	============================================================================
//	CLASS:	RPMListBuilder	
//	Desc:	Utility class to help build a list of ResearchPreferenceMetadata,
//			based on successive additions of ResearchPreferenceMetadata records, 
//			which are assumed to be sorted by Name.
//	============================================================================
//	============================================================================
	class RPMListBuilder {
		
		private Integer idx;
		private String prevName;
		private Integer maxListSize;
		private ResearchPreferenceMetadata[] rpmCache;
		
		private ResearchPreferenceMetadata[] rpmList;
		public String nextName;
		
		
//		============================================================================
//		Method:	Constructor	
//		Desc:	Initializes variables.
//		============================================================================
		RPMListBuilder () {
			this ( aceUtil.MAX_COLLECTION_SIZE );
		}
		
		RPMListBuilder ( Integer maxListSize ) {
			this.idx = 0;
			this.prevName = '';
			this.nextName = Null;
			this.maxListSize = maxListSize;
			this.rpmCache = new ResearchPreferenceMetadata[] {};
			this.rpmList = new ResearchPreferenceMetadata[] {};
		}	
			
//		============================================================================
//		Method:	addRPM
//		Desc:	Adds the specified ResearchPreferenceMetadata record to the 
//				ResearchPreferenceMetadata list.  If this record would put us past
//				the max-record limit, aborts.
//		Args:	rpm - the ResearchPreferenceMetadata record
//		Return:	True if the record was added; False otherwise.
//		============================================================================
		public Boolean addRPM ( ResearchPreferenceMetadata rpm ) {

			if ( prevName != Null && prevName != rpm.Name ) {
				rpmList.addAll ( rpmCache );
				rpmCache.clear ();
			}
			if ( idx++ >= maxListSize ) {
				nextName = ( rpmCache.isEmpty () ? rpm.Name : prevName );
				return False;
			}
			prevName = rpm.Name;
			rpmCache.add ( rpm );
			return True;
		}
		
//		============================================================================
//		Method:	addCachedRPMs	
//		Desc:	Adds the ResearchPreferenceMetadata records we've built up in our
//				internal cache, to the ResearchPreferenceMetadata list.
//		Args:	None.
//		Return:	None.
//		============================================================================
		public void addCachedRPMs () {
			rpmList.addAll ( rpmCache );
		}
	}	
		
}