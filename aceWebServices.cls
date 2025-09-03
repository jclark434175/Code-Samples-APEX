/* 
 * Name: aceWebServices 
 * Description: Interface to common ACE Apex functionality.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
   
global class aceWebServices {          

//	============================================================================
//	Method:			getSObjectInfoById
//	Description:	See AceSObject.getSObjectInfoById
//	============================================================================	
	webService static SObject getSObjectInfoById ( String sobjId , String sobjType ,
													String[] fldNames ) {
		
		return AceSObject.getSObjectInfoById ( sobjId , sobjType , fldNames );
	}

//	============================================================================
//	Method:			getSObjectInfo
//	Description:	See AceSObject.getSObjectInfo
//	============================================================================	
	webService static SObject[] getSObjectInfo ( String sobjType , String whereClause , 
												String sortFld , Integer maxRecs ,
												String[] fldNames ) {
		
		return AceSObject.getSObjectInfo ( sobjType , whereClause , sortFld ,
											maxRecs , fldNames );
	}

//	============================================================================
//	Method:			getSObjectPage
//	Description:	See AceSObject.getSObjectPage
//	============================================================================	
	webService static SObjectPage getSObjectPage ( String sobjType , String whereClause , 
													String sortFld , String startFldVal ,
													Integer pageSize , String[] fldNames ) {
		
		return AceSObject.getSObjectPage( sobjType , whereClause , sortFld ,
											startFldVal , pageSize , fldNames );
	}

//  ============================================================================
//  Method: getRecordTypes  
//  Desc:   See AceRecordType.getRecordTypes
//  ============================================================================
    webService static AceRecordType[] getRecordTypes ( String SObjectType ) {
    
        return AceRecordType.getRecordTypes ( SObjectType );
    }
    
//  ============================================================================
//  Method: getEmployeesByName  
//  Desc:   See Employee.getEmployeesByName
//  ============================================================================
    webService static EmployeePage getEmployeesByName ( String empName, String startName , Integer pageSize ) {
    
        return Employee.getEmployeesByName ( empName, startName , pageSize );
    }
    
//  ============================================================================
//  Method: getPicklistValues   
//  Desc:   See AceSchema.getPicklistValues
//  ============================================================================
    webService static String[] getPicklistValues ( String sObjType, String fldName ) {
    
        return AceSchema.getPicklistValues ( sObjType, fldName );
    }       
}