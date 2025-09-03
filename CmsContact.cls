/* 
 * Name: Contact 
 * Description: Contains the details of a contact, and its account details
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 *  or in part without written permission from Tier1CRM Inc.
 */
  
global class CmsContact {
    webservice String Id;
    webservice String Name;
    webservice String FirstName;
    webservice String LastName;         
    
    public CmsContact() {       
    }
    
    public CmsContact(Contact aContact) {
        Id = aContact.Id;       
        FirstName = aContact.FirstName;
        LastName = aContact.LastName;
    }
}