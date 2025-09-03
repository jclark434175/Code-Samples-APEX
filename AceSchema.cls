/** 
 * Name:		AceSchema 
 * Description:	Class containing SFDC Schema-related methods.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AceSchema {

//  ============================================================================
//  Method: getPicklistValues
//
//  Desc:   Method to extract a list of values for the specified picklist field
//			on the specified SObject.
//       
//  Return: The picklist values as a list of Strings.  If for any reason there
//			are no picklist values (e.g. bad SObject or field name, or 
//			non-picklist field), returns an empty list.
//  ============================================================================                        
	public static String[] getPicklistValues ( String sobjType , String fldName ) {
	
		String[] pickList = new String[] {};
		
		if ( sobjType == Null || sobjType == '' || fldName == Null || fldName == '' ) {
			return pickList;
		}
		
		Schema.SObjectType sot = Schema.getGlobalDescribe ().get ( sobjType );
		if ( sot == Null ) {
			System.debug ( 'ERROR : No such SObject : [' + sobjType + ']' );
			return pickList;
		}
		
		Schema.DescribeSObjectResult dsor = sot.getDescribe ();
		if ( dsor.fields.getMap ().get ( fldName ) == Null ) {
			System.debug ( 'ERROR : No such field [' + fldName + '] in SObject [' + sobjType + ']' );
			return pickList;
		}
		
		Schema.DescribeFieldResult dfr = dsor.fields.getMap ().get ( fldName ).getDescribe ();
		if ( dfr.getType () != Schema.DisplayType.PICKLIST ) {
			System.debug ( 'ERROR : Field [' + sobjType + '.' + fldName + '] is not a picklist.' );
			return pickList;
		}
		
		for ( Schema.PicklistEntry pel : dfr.getPicklistValues () ) {
			pickList.add ( pel.getValue () );
		}
		
		return pickList;
	}
	
//  ============================================================================
//  Method: getFieldNames
//
//  Desc:   Method to extract a list of field names for the specified SObject.
//       
//  Return: Array of field names
//
//  ============================================================================                        
	public static String[] getFieldNames ( String sobjType ) {
	
		String[] fields = new String[] {};
		
		if ( sobjType == Null || sobjType == '' ) {
			return fields;
		}
		
		Schema.SObjectType sot = Schema.getGlobalDescribe ().get ( sobjType );
		if ( sot == Null ) {
			System.debug ( 'ERROR : No such SObject : [' + sobjType + ']' );
			return fields;
		}
		Schema.DescribeSObjectResult dsor = sot.getDescribe ();
		
		for(SObjectField sof : dsor.fields.getMap ().values()) {
			fields.Add( '' + sof);
		}
		return fields;
	}
}