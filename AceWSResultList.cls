/* 
 * Name: AceWSResultList
 * Description: Encapsulates a list of AceWSResult objects.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
 
global class AceWSResultList {
	
	webService AceWSResult[] resultList;
	
	public AceWSResultList () {
		resultList = new AceWSResult[] {};
	}

	public AceWSResultList ( Integer listSize , Boolean bStatus ) {
		resultList = new AceWSResult[] {};
		for ( Integer i = 0 ; i < listSize ; i++ ) {
			resultList.add ( new AceWSResult ( bStatus , '' ) );
		}
	}

	public void setResult ( Boolean bStatus , String msg ) {
		for ( AceWSResult result : resultList ) {
			result.setResult ( bStatus , msg );
		}
	}

	public void setResult ( Integer idx , Boolean bStatus , String msg ) {
		if ( idx < 0 || idx >= resultList.size () ) {
			System.debug ( 'Result list index [' + idx + '] out of bounds.' );
			return;
		}
		resultList[ idx ].setResult ( bStatus , msg );
	}
	
	public AceWSResult[] getResultList () { 
		return resultList;
	}
	
	public AceWSResult getResult ( Integer idx ) {
		if ( idx < 0 || idx >= resultList.size () ) {
			System.debug ( 'Result list index [' + idx + '] out of bounds.' );
			return Null;
		}
		return resultList[ idx ];
	}
	
//  ============================================================================
//  Method: copyResults
//  Desc:	Append AceWSResult objects to the internal list of AceWSResult 
//  Args:	srcResultList - Another list of AceWSResults
//  ============================================================================
	public void copyResults ( AceWSResultList srcResultList ) {
		resultList.addAll ( srcResultList.getResultList () );
	}
		
}