/* 
 * Name: testContactListEntry 
 * Description: 
 *
 * Confidential & Proprietary, ©2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 *
*/

public class testContactListEntry 
{
	public static testMethod void insertContactListEntry() 	
	{	
		//Create contact
		Contact con = new Contact(LastName = 'Lastname');
		insert con;
			
		//Create Contact List
		Contact_List__c cl = new Contact_List__c(Name = 'CL_1');
		insert cl;
				
		//Create a list item without contact
		Contact_List_Entry__c cle_1 = new Contact_List_Entry__c(Name = 'CLE of CL_1', Contact_List__c = cl.Id);		
		insert cle_1;		
				
		//Verify the result
		Contact_List_Entry__c result1 = [Select Key__c From Contact_List_Entry__c Where Id = :cle_1.Id];
		System.assertEquals(result1.Key__c, '' + cl.Id);					
		
		//Create a list item with contact
		Contact_List_Entry__c cle_2 = new Contact_List_Entry__c(Name = 'CLE of CL_1', Contact_List__c = cl.Id, Contact__c = con.Id);		
		insert cle_2;
		
		//Verify the result
		Contact_List_Entry__c result2 = [Select Key__c From Contact_List_Entry__c Where Id = :cle_2.Id];
		System.assertEquals(result2.Key__c, '' + cl.Id + con.Id);					
	}
}