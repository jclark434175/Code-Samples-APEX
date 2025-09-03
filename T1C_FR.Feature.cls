/*
 * Name:        Feature
 *
 * Description:  Feature object contains details about a feature and its attributes.
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2007 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from STC StraightThrough.
 */
 
global class Feature {
		
	WebService String Name;	
	WebService Attribute[] Attributes = new Attribute[] {};
	WebService Feature[] SubFeatures = new Feature[] {};
	
	global Feature(String fName) {
		Name = fName;
	}
	
	public String getAttributeValue(String aName) {
		String rValue = ''; 		
		for(Attribute attr: Attributes) {
			if (attr.Name == aName) {
				rValue = attr.Value;
			}			
		}
		return rValue;
	}
}