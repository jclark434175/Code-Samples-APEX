/* 
 * Name: SecurityMasterCoverage 
 * Description: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class SecurityMasterCoverage 
{
    static final String[] COVERAGE_ROLES = new String[] { 'Primary Analyst' , 'Assistant Analyst' };
    
    webService String Id;
    webService String Role; 
    webService SecurityMaster SecurityMaster;
    webService Employee Employee;
        
    public SecurityMasterCoverage() {
    }
    
    public SecurityMasterCoverage ( Security_Master_Coverage__c smc ) {
        if ( smc == Null ) { return; }
        
        try { this.Id = smc.Id; } catch ( SObjectException e ) {}       
        try { this.Role = smc.Role__c; } catch ( SObjectException e ) {}        
            
//      Fill out the security master and employee details.
//      --------------------------------------------------
        try { this.SecurityMaster = new SecurityMaster ( smc.Security_Master__r ); } catch ( SObjectException e ) {}                                            
        try { this.Employee = new Employee ( smc.Employee__r ); } catch ( SObjectException e ) {}                                           
    }
    
//  ============================================================================
//  Method: getEmployeesCoveringSymbols 
//  Desc:   Retrieves the security master coverage records for the specified
//          list of symbols. 
//  Args:   symList - the symbol list
//  Return: List of matching SecurityMasterCoverage records.                            
//  Case:   3900
//  ============================================================================
    public static List<SecurityMasterCoverage> getEmployeesCoveringSymbols ( String[] symList ) { 
    
        SecurityMasterCoverage[] returnList = new SecurityMasterCoverage[] {};
                
        for ( Security_Master_Coverage__c smc : [ select
                                                        Id ,
                                                        Role__c ,
                                                        Security_Master__r.Symbol__c ,
                                                        Employee__r.Id ,
                                                        Employee__r.Name ,
                                                        Employee__r.Title__c ,
                                                        Employee__r.Email__c ,
                                                        Employee__r.Department__c ,
                                                        Employee__r.User__c
                                                    from
                                                        Security_Master_Coverage__c
                                                    where
                                                        Security_Master__r.Symbol__c in :symList and
                                                        Role__c in :COVERAGE_ROLES and  
                                                        Employee__r.Inactive__c = False
                                                    ]
        ) {
            returnList.add ( new SecurityMasterCoverage ( smc ) );
        }
        
        return returnList;
    }
}