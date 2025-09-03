/*
 * Name:        Attribute
 *
 * Description:  Attribute object contains details about attribute of a feature such as name and value.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from STC StraightThrough.
 */
global class Attribute {
	
	WebService String Value;
	WebService String Name;	
	WebService Boolean bUserOverridable;	
	
	global Attribute(String pName, String pValue) {		
		Name = pName;
		Value = pValue;
		bUserOverridable = True;
	}
	
	global Attribute(String pName, String pValue , Boolean bOverridable ) {		
		Name = pName;
		Value = pValue;
		bUserOverridable = bOverridable;
	}
}