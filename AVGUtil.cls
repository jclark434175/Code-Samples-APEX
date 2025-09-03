/** 
 * Name: AVGUtil  
 * Description: Utility class for common functions
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
public class AVGUtil {
	
//  ============================================================================
//  Method:	mkDateTime
//
//  Desc:	Makes the specified Date string Datetime-compatible by appending
//			a suitable suffix to it. 
//
//	Args:	dateStr	- the Date string
//
//	Return:	The modified Datetime-type string.
//  ============================================================================                        
	public static String mkDateTime ( String dateStr ) {
		return dateStr + 'T00:00:00Z';		
	}
}