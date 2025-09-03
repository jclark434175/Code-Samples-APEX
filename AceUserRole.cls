/* 
 * Name: AceUserRole 
 * Description: Contains details of an AceUserRole
 *
 * Confidential & Proprietary, ©2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class AceUserRole {
	
	private static String ROLE_PORTAL_TYPE_NONE = 'None';
	
	webService String Id;
	webService String Name;
	
	public AceUserRole () {
	}
	
	public AceUserRole ( UserRole ur ) {
		if ( ur == Null ) { return; }
		
		try { this.Id = ur.Id; } catch ( SObjectException e ) {}
		try { this.Name = ur.Name; } catch ( SObjectException e ) {}
	}
	
	//	============================================================================
	//	Method:			getRoles
	//	Description: 	Returns all role records		
	//	Args:			None
	//	Return:			All role records; Array of AceUserRole type	 				
	//	Case No: 		3678
	//	============================================================================
	public static List<AceUserRole> getRoles() {		
		List<AceUserRole> returnList =new List<AceUserRole>();		
		for(UserRole usrRole : [Select Id, Name 
								From UserRole 
								Where PortalType = :ROLE_PORTAL_TYPE_NONE 
								Order By Name]) {
			returnList.Add( new AceUserRole ( usrRole ) );							
		}
		return returnList;
	}
	
	
}