/* 
 * Name: MarketingEventSlot
 * Description: Contains details of an ACE MarketingEventSlot record.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */

global class MarketingEventSlot {

	webService String Id;
	webService String Name;
	webService String CurrentAttendees;
	webService String Description;
	webService DateTime EndTime;
	webService String MarketingEventId;
	webService String MaxAttendees;
	webService String SlotType;
	webService DateTime StartTime;
	webService String State;
	webService String Venue;
	
	public MarketingEventSlot () {
	}
	
	public MarketingEventSlot ( Marketing_Event_Slot__c mes ) {
		if ( mes == Null ) { return; }

		try { this.Id = mes.Id; } catch ( SObjectException e ) {}
		try { this.Name = mes.Name; } catch ( SObjectException e ) {}		
		try { this.CurrentAttendees = String.valueOf(mes.CurrentAttendees__c); } catch ( SObjectException e ) {}
		try { this.Description = mes.Description__c; } catch ( SObjectException e ) {}
		try { this.EndTime = mes.EndTime__c; } catch ( SObjectException e ) {}
		try { this.MarketingEventId = mes.Marketing_Event__c; } catch ( SObjectException e ) {}		
		try { this.MaxAttendees = String.valueOf(mes.MaxAttendees__c); } catch ( SObjectException e ) {}
		try { this.SlotType = mes.SlotType__c; } catch ( SObjectException e ) {}
		try { this.StartTime = mes.StartTime__c; } catch ( SObjectException e ) {}
		try { this.State = mes.State__c; } catch ( SObjectException e ) {}
		try { this.Venue = mes.Venue__c; } catch ( SObjectException e ) {}
		
	}	


//	============================================================================
//	Method:	getMarketingEventSlots
//	Desc:	Gets Marketing Event Slot records by Marketing Event Id
//			parameters - marketing event Id
//	Args:	eventId	- the Marketing Event Id
//	Return: List of marekting event slot records
//	Case:	3979
//	============================================================================
	public static List<MarketingEventSlot> getMarketingEventSlots (
													Id eventId ) {
		
		List<MarketingEventSlot> mesList = new List<MarketingEventSlot> {};		

		if (eventId != Null) {

			for ( Marketing_Event_Slot__c sfMES : [select
							Id , 
							Name ,
							CurrentAttendees__c ,
							Description__c ,
							EndTime__c ,
							Marketing_Event__c ,
							Marketing_Event__r.Id ,
							MaxAttendees__c ,
							SlotType__c ,
							StartTime__c ,
							State__c ,
							Venue__c
						from
							Marketing_Event_Slot__c
						where
							Marketing_Event__c = :eventId and
							isDeleted = false ]
				) 
			{
				mesList.add ( new MarketingEventSlot ( sfMES ) );		
			}
		}
		return mesList;
	}
		

}