/* 
 * Name: Registrant 
 * Description: Contains the details of a registrant, and his contact details
 *
 * Confidential & Proprietary, �2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 *  or in part without written permission from Tier1CRM Inc.
 */
 
global class Registrant {
    webservice String id;
    webservice String name;
    webservice String role;
    webservice Date attendanceStartDate;
    webservice Date attendanceEndDate;
    webservice String error;

//Non-entity fields 
    webservice CmsContact cmsContact;   
    webservice CmsAccount cmsAccount;
    
    public Registrant(Registrant__c aRegistrant) {
        id = aRegistrant.Id;
        name = aRegistrant.Name;
        role = aRegistrant.Role__c;     
        cmsContact = new CmsContact();
        cmsAccount = new CmsAccount();
    }
    
    public Registrant() {
        cmsContact = new CmsContact();
        cmsAccount = new CmsAccount();
    }
}