/* 
 * Name: Account 
 * Description: Contains details of an Account
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM Inc.
 */
 
global class CmsAccount {
    webservice String id;
    webservice String name; 
  webservice String tier;
    webservice String symbol;
    webservice String presentationTime;
    
    public CmsAccount() {}
    
    public CmsAccount(Account anAccount) {
        if (anAccount != null) {
            id = anAccount.Id;
            name = anAccount.Name;          
        }
    }
}