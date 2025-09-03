/* 
 * Name: AceRecordType 
 * Description: Contains details of a core SF RecordType record.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 		
global class AceRecordType {
	
	webService String Id;
	webService String Name;
	webService String SObjectType;
	webService String Description;
	
	public AceRecordType () {
	}
	
	public AceRecordType ( RecordType rt ) {
		if ( rt == Null ) { return; }

		try { this.Id = rt.Id; } catch ( SObjectException e ) {}
		try { this.Name = rt.Name; } catch ( SObjectException e ) {}
		try { this.SObjectType = rt.SObjectType; } catch ( SObjectException e ) {}
		try { this.Description = rt.Description; } catch ( SObjectException e ) {}
	}
	
//	============================================================================
//	Method: getRecordTypes   
//	Desc:   Retrieves Record Type information for the specified SObject type, 
//			or all SObject types if one was not specified.
//	Args:   SObjectType - the object type
//	Return: List of Record Type info.
//	Case:	4018                  
//  ============================================================================
	public static AceRecordType[] getRecordTypes ( String SObjectType ) {
		
		AceRecordType[] rtList = new AceRecordType[] {};
		
		String soqlQry = 'select '
							+ 'SObjectType , '
							+ 'Name , '
							+ 'Description '
						+ 'from '
							+ 'RecordType ';
		if ( SObjectType != Null && SObjectType != '' ) {
			soqlQry += 'where '
						+ 'SObjectType = \'' + SObjectType + '\' '
					+ 'order by '
						+ 'SObjectType';
		}
		
		for ( RecordType sfRT : Database.query ( soqlQry ) ) {
			rtList.add ( new AceRecordType ( sfRT ) );
		}
		
		return rtList;
	}
}