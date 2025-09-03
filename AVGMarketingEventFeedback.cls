/* 
 * Name: AVGMarketingEventFeedback 
 * Description: Contains the details of a Marketing Event Feedback task, with its
 *				associated Marketing Event, Contact and User objects. 
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class AVGMarketingEventFeedback {

	static final String EVENT_FEEDBACK_RECORD_TYPE = 'Event Feedback';
	
	public Task feedback;
	public SObject marketingEvent;
	public Contact contact;
	public User assignedTo;
	
//  ============================================================================
//  Method: <constructor>
//
//  Desc:   Builds a new AVGMarketingEventFeedback object out of the specified
//			constituents.
//  ============================================================================                    
	public AVGMarketingEventFeedback ( Task feedback , SObject mktgEvent ,
										Contact contact , User assignedTo ) {
		this.feedback = feedback;
		this.marketingEvent = mktgEvent;
		this.contact = contact;
		this.assignedTo = assignedTo;
	}

//  ============================================================================
//  Method: getMktgEventFeedback
//
//  Desc:   Gets the Marketing Event Feedback Tasks belonging to Contacts with 
//			the specified Account Id, modified more recently than the specified
//			threshold date.
//     
//  Return: List of AVGMarketingEventFeedback objects.
//  ============================================================================                    
	public static AVGMarketingEventFeedback[] getMktgEventFeedback ( Id acctId , String thresholdDate ) {
	
		AVGMarketingEventFeedback[] feedbackList = new AVGMarketingEventFeedback[] {};
		
//		First, grab the record type Id of interest.
//		-------------------------------------------
		Id recordTypeId;
		RecordType[] rtList = [ select
									Id
								from
									RecordType
								where
									SObjectType = 'Task' and
									Name = :EVENT_FEEDBACK_RECORD_TYPE
								];
		if ( rtList.isEmpty () ) {
			return feedbackList;
		}
		recordTypeId = rtList[ 0 ].Id;
		
//		Next, cache the contacts associated with this account.
//		------------------------------------------------------
		Map<Id , Contact> contById = new Map<Id , Contact> (
										[ select
												FirstName ,
												LastName
											from
												Contact
											where
												AccountId = :acctId 
											limit 1000 ]
										);

//		Next, grab the Tasks (Marketing Event Feedbacks) of interest.
//		-------------------------------------------------------------
		Datetime threshDate = Datetime.newInstance ( 1900 , 1 , 1 );
		if ( thresholdDate != Null ) {
			String[] dateParts = thresholdDate.split ( '-' );
			if ( dateParts.size () == 3 ) {
				try {
					threshDate = Datetime.newInstance ( Integer.valueOf ( dateParts[ 0 ] ) ,
														Integer.valueOf ( dateParts[ 1 ] ) ,
														Integer.valueOf ( dateParts[ 2 ] )
													);
				}
				catch ( TypeException te ) {
				}
			}
		}
		
		Task[] taskList = [ select
								LastModifiedDate ,
								WhoId ,
								Subject ,
								WhatId ,
								OwnerId ,
								Description
							from
								Task
							where
								RecordTypeId = :recordTypeId and
								WhoId in :contById.keySet () and
								LastModifiedDate >= :threshDate
							limit 1000
							];
		if ( taskList.isEmpty () ) {
			return feedbackList;
		}

		Set<Id> taskWhatIdSet = new Set<Id> {};
		Set<Id> taskOwnerIdSet = new Set<Id> {};
		for ( Task task : taskList ) {
			taskWhatIdSet.add ( task.WhatId );
			taskOwnerIdSet.add ( task.OwnerId );
		}

//		Next, grab the associated Marketing Events.  Note - doing this dynamically
//		so the class will compile even on orgs without GEM.
//		--------------------------------------------------------------------------
		SObject[] meList = AceSObject.getSObjectInfo ( 'Marketing_Event__c' ,
								'Id in ( ' + aceUtil.concatList ( new List<Id> ( taskWhatIdSet ) , ' , ' , True ) + ' )' ,
								Null , False , True ,
								aceUtil.MAX_COLLECTION_SIZE ,
								new String[] { 'Company_Account__c' , 'Analyst__c' }
							);
		Map<Id , Integer> meIdxById = new Map<Id , Integer> {};
		for ( Integer i = 0 ; i < meList.Size () ; i++ ) {
			meIdxById.put ( meList[ i ].Id , i );
		}

//		...and grab the associated Assigned-to Users.
//		---------------------------------------------
		Map<Id , User> userById = new Map<Id , User> (
									[ select
											FirstName ,
											LastName
										from
											User
										where
											Id in :taskOwnerIdSet
										]
									);				

//		Now, build the class object list.
//		---------------------------------
		for ( Task task : taskList ) {
			Integer idx = meIdxById.get ( task.WhatId );

//			Skip records not associated with Marketing Events.
//			--------------------------------------------------			
			if ( idx == Null ) {
				continue;
			}
			SObject mktgEvent = meList[ idx ];
			
			User user = userById.get ( task.OwnerId );
			Contact cont = contById.get ( task.WhoId );
			
			feedbackList.add ( new AVGMarketingEventFeedback ( task , mktgEvent , cont , user ) );
		}
		
		return feedbackList;
	}							

}