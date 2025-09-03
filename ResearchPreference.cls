/* 
 * Name: ResearchPreference 
 * Description: Contains details of an ACE ResearchPreference record.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 		
global class ResearchPreference {
	
	webService String Id;
	webService DateTime CreatedDate;
	webService String PreferenceName;
	webService String PreferenceType;
	webService String CorpAcctId;
	
	public ResearchPreference () {
	}

	public ResearchPreference ( ST_Research_Preference__c rp ) {
		if ( rp == Null ) { return; }

		try { this.Id = rp.Id; } catch ( SObjectException e ) {}
		try { this.CreatedDate = rp.CreatedDate; } catch ( SObjectException e ) {}
		try { this.PreferenceName = rp.ST_Preference_Name__c; } catch ( SObjectException e ) {}
		try { this.PreferenceType = rp.ST_Preference_Type__c; } catch ( SObjectException e ) {}
		try { this.CorpAcctId = rp.ST_Ticker__c; } catch ( SObjectException e ) {}
	}
	
//	============================================================================
//	Method:	getResearchPreferences	
//	Desc:	Gets Research Preference records for the corresponding Contact Id.
//	Args:	contId - the Contact Id
//	Return: List of matching ResearchPreference records.
//	Case No: 3810
//	============================================================================
	public static List<ResearchPreference> getResearchPreferences ( String contId ) {
		
		List<ResearchPreference> rpList = new List<ResearchPreference> {};
		
		for ( ST_Research_Preference__c sfRP : [select
													Id ,
													CreatedDate ,
													ST_Preference_Name__c ,
													ST_Preference_type__c
												from
													ST_Research_Preference__c
												where
													ST_Contact__c = :contId
												]
		) {
			rpList.add ( new ResearchPreference ( sfRP ) );
		}
		
		return rpList;
	}
	
//	============================================================================
//	Method:	getResearchPrefsByAcctContSym	
//	Desc:	Gets Research Preference records for the corresponding ContactId,
//			AccountId and/or SymbolAccountId list.
//	Args:	acctid - the Account Id
//			contId - the Contact Id
//			corpAcctIdSet - the symbols' Account Ids
//	Return: List of matching ResearchPreference records.
//	============================================================================
	public static List<ResearchPreference> getResearchPrefsByAcctContSym (
													Id acctId , Id contId ,
													Set<Id> corpAcctIdSet ) {

//		3 scenarios:
//		1) ContactId + corpAcctIdList both specified
//		2) ContactId specified; corpAcctIdList not specified
//		3) AccountId + corpAcctIdList both specified
//		----------------------------------------------------

		List<ResearchPreference> rpList = new List<ResearchPreference> {};
		List<ST_Research_Preference__c> sfRPList = new List<ST_Research_Preference__c> {};
		
		if ( corpAcctIdSet == Null ) {
			sfRPList = [ select
							Id ,
							CreatedDate ,
							ST_Preference_Name__c ,
							ST_Preference_Type__c ,
							ST_Ticker__c
						from
							ST_Research_Preference__c
						where
							ST_Contact__c = :contId and
							ST_Ticker__c != Null
						];
		}
		else if ( contId == Null ) {			
			sfRPList = [ select
							Id ,
							CreatedDate ,
							ST_Preference_Name__c ,
							ST_Preference_Type__c ,
							ST_Ticker__c
						from
							ST_Research_Preference__c
						where
							ST_Contact__r.AccountId = :acctId and
							ST_Ticker__c in :corpAcctIdSet
						];
		}
		else {			
			sfRPList = [ select
							Id ,
							CreatedDate ,
							ST_Preference_Name__c ,
							ST_Preference_Type__c ,
							ST_Ticker__c
						from
							ST_Research_Preference__c
						where
							ST_Contact__c = :contId and
							ST_Ticker__c in :corpAcctIdSet
						];
		}
		
		for ( ST_Research_Preference__c sfRP : sfRPList ) {
			rpList.add ( new ResearchPreference ( sfRP ) );
		}
		
		return rpList;
	}								


}