/* 
 * Name: AceGroup 
 * Description: Contains details of the ACE representation of a Group.
 *
 * Confidential & Proprietary, 2008 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class AceGroup {
	
	private static String REGULAR_GROUP_TYPE = 'Regular';
	
	webService String Id;
	webService String Name;
	
	public AceGroup() {
	}
	
	public AceGroup(Group aGroup) {
		if ( aGroup == Null ) { return; }
		
		try { this.Id = aGroup.Id; } catch ( SObjectException e ) {}
		try { this.Name = aGroup.Name; } catch ( SObjectException e ) {}
	}
	
//	============================================================================
//	Method:	getGroups	
//	Desc:	Retrieves all Regular-type Groups. 
//	Args:	None.
//	Return:	List of AceGroups records.					
//	Case No: 3677
//	============================================================================
	public static List<AceGroup> getGroups () {

		List<AceGroup> grpList = new list<AceGroup> {};	
		for ( Group grp : [select Id , Name from Group 
							where Type = :REGULAR_GROUP_TYPE
							order by Name]
				) {
			grpList.add ( new AceGroup ( grp ) );
		}
	
		return grpList;
	}
}