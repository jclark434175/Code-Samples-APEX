/* 
 * Name: AVGActivity 
 * Description: Contains the details of a Marketing Event Feedback task, with its
 *				associated Marketing Event, Contact and User objects. 
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class AVGActivity {

	static final String EVENT_STD_RECORD_TYPE = 'Standard Event';
	static final Set<String> TASK_RECORD_TYPES = new Set<String> { 'General Activity' , 'Interaction' , 'Call Request' }; 
	
	public Task task;
	public Event event;
	public Contact contact;
	public User assignedTo;
	
//  ============================================================================
//  Method: <constructor>
//
//  Desc:   Builds a new AVGActivity object out of the specified constituents.
//			Note that one and only one of 'task' and 'event' is ever non-Null.
//  ============================================================================                    
	public AVGActivity ( Task task , Event event , Contact contact , User assignedTo ) {
		this.task = task;
		this.event = event;
		this.contact = contact;
		this.assignedTo = assignedTo;
	}

//  ============================================================================
//  Method: getActivities
//
//  Desc:   Gets the Activities belonging to Contacts with the specified
//			Account Id:
//			* if bOpen is True, gets Open Tasks and Activities whose
//			  ActivityDate is today or later.
//			* if bOpen is False, gets Closed Tasks and Activities whose
//			  ActivityDate is yesterday or earlier - both modified more 
//			  recently than the specified thresholdDate. 
//     
//  Return: List of AVGActivity objects.
//  ============================================================================                    
	public static AVGActivity[] getActivities ( Id acctId , Boolean bOpen , String thresholdDate ) {
	
		AVGActivity[] activityList = new AVGActivity[] {};
		
//		First, grab the record type Ids of interest.
//		-------------------------------------------
		Id eventRecTypeId;
		Id[] taskRecTypeIds = new Id[] {};
		for ( RecordType rt : [ select
									SObjectType ,
									Name
								from
									RecordType
								where
									SObjectType in ( 'Task' , 'Event' ) and (
										Name = :EVENT_STD_RECORD_TYPE or
										Name in :TASK_RECORD_TYPES
									)
								]
		) {
			if ( rt.SObjectType == 'Task' && TASK_RECORD_TYPES.contains ( rt.Name ) ) {
				taskRecTypeIds.add ( rt.Id );
			}
			else if ( rt.SObjectType == 'Event' && rt.Name == EVENT_STD_RECORD_TYPE ) {
				eventRecTypeId = rt.Id;
			}
		}
		if ( taskRecTypeIds.isEmpty () && eventRecTypeId == Null ) {
			return activityList;
		}
		
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
		if ( contById.isEmpty () ) {
			return activityList;
		}

//		Build the Task and Activity query clauses per the input args.
//		-------------------------------------------------------------
		String eventWhere = 'WhoId in ( ' + aceUtil.concatList ( new List<Id> ( contById.keySet () ) , ' , ' , True ) + ' )'
							+ ' and RecordTypeId = \'' + eventRecTypeId + '\'';
		String taskWhere = 'WhoId in ( ' + aceUtil.concatList ( new List<Id> ( contById.keySet () ) , ' , ' , True ) + ' )'
							+ ' and RecordTypeId in ( ' + aceUtil.concatList ( taskRecTypeIds , ' , ' , True ) + ' )';
							
		String today = String.valueOf ( Date.Today () );
		if ( bOpen ) {
			eventWhere += ' and ActivityDate >= ' + today; 
			taskWhere += ' and IsClosed = False';
		}
		else {
			eventWhere += ' and ActivityDate < ' + today;
			taskWhere += ' and IsClosed = True';
			
			if ( thresholdDate != Null && thresholdDate != '' ) {
				taskWhere += ' and LastModifiedDate >= ' + AVGUtil.mkDateTime ( thresholdDate );
				eventWhere += ' and LastModifiedDate >= ' + AVGUtil.mkDateTime ( thresholdDate );
			}
		}
		
//		Next, grab the Tasks and Events of interest.
//		--------------------------------------------
		SObject[] taskList;
		if ( !taskRecTypeIds.isEmpty () ) {
			taskList = AceSObject.getSObjectInfo ( 'Task' , taskWhere , Null , False , True , 
													AceUtil.MAX_COLLECTION_SIZE ,
													new String[] { 'LastModifiedDate' , 'WhoId' , 'Subject' , 'Interaction_Type__c' , 'OwnerId' , 'ActivityDate' , 'Status' }
												);
		}
		SObject[] eventList;
		if ( eventRecTypeId != Null ) {
			eventList = AceSObject.getSObjectInfo ( 'Event' , eventWhere , Null , False , True , 
													AceUtil.MAX_COLLECTION_SIZE ,
													new String[] { 'LastModifiedDate' , 'WhoId' , 'Subject' , 'Interaction_Type__c' ,'OwnerId' , 'ActivityDate' }
												);
		}
		
//		Assemble the owner Ids and grab the associated Users' names.
//		------------------------------------------------------------
		Set<Id> ownerIdSet = new Set<Id> {};
		if ( taskList != Null ) {
			for ( SObject sobj : taskList ) {
				ownerIdSet.add ( String.valueOf ( ( (Task)sobj ).get ( 'OwnerId' ) ) );
			}
		}
		if ( eventList != Null ) {
			for ( SObject sobj : eventList ) {
				ownerIdSet.add ( String.valueOf ( ( (Event)sobj ).get ( 'OwnerId' ) ) );
			}
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
											Id in :ownerIdSet
										]
									);				

//		Now, build the class object list.
//		---------------------------------
		if ( taskList != Null ) {
			for ( Task task : (List<Task>)taskList ) {
				
				Contact cont = contById.get ( task.WhoId );
				User user = userById.get ( task.OwnerId );			
				
				activityList.add ( new AVGActivity ( task , Null , cont , user ) );
			}
		}
		
		if ( eventList != Null ) {
			for ( Event event : (List<Event>)eventList ) {
				
				Contact cont = contById.get ( event.WhoId );
				User user = userById.get ( event.OwnerId );			
				
				activityList.add ( new AVGActivity ( Null , event , cont , user ) );
			}
		}
		
		return activityList;
	}							

}