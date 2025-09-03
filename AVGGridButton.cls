/* 
 * Name: AVGGridColumn
 * Description: Contains the definition of an AVG grid button.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public class AVGGridButton {

//	==========================================
//	Instance properties (bindable to VF page).
//	==========================================
	public String label { get; set; }
	public String target { get; set; }
	
//  ============================================================================
//  Method:	<constructor>
//
//  Desc:	Constructor.
//
//	Args:	label		- the button label.
//			target		- the URL the button should navigate to.  Adorns this
//						  URL with a 'retURL' parameter to allow other Salesforce
//						  pages to navigate back to this one.
//  ============================================================================                        
	public AVGGridButton ( String label , String target ) {
		this.label = label;
		this.target = target
						+ ( target.contains ( '?' ) ? '&' : '?' ) 
						+ 'retURL=' + ApexPages.currentPage ().getUrl ()
																.replace ( '?' , '%3F' ) 
																.replace ( '&' , '%26' )
																.replace ( '=' , '%3D' );
		System.debug ( 'BUTTON [' + label + '] TARGET [' + this.target + ']' );
	}
	
//  ============================================================================
//  Method:	doAction
//
//  Desc:	Redirects the current page to this instance's target property.
//
//	Args:	None.
//
//	Return: Page reference built from the target.
//  ============================================================================                        
	public PageReference doAction () {
		return new PageReference ( this.target );
	}

//  ============================================================================
//  Method:	mkNewURL
//
//  Desc:	STATIC METHOD.  Constructs the Salesforce 'new SObject' URL 
//			appropriate to the specified SObject type.  Determines that type's
//			Salesforce prefix and incorporates that into the URL.
//
//	Args:	SObjectType	- the SObject type (e.g. 'Contact').
//
//	Return:	The 'new' URL.
//  ============================================================================                        
	public static String mkNewURL ( String SObjectType ) {
		
		Schema.SObjectType sot = Schema.getGlobalDescribe().get ( SObjectType );
		if ( sot == Null ) {
			return '';
		}
		String sobjPfx = sot.getDescribe ().getKeyPrefix ();

		return '/' + sobjPfx + '/e';
	}

}