/* 
 * Name: AceWSResultList
 * Description: Encapsulates a list of AceWSResult objects.
 *
 * Confidential & Proprietary, 2008 STC StraightThrough Inc.
 * Property of STC StraightThrough Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from STC StraightThrough.
 */
 
global class AceWSResultList {
	
	webService List<AceWSResult> resultList;
	
	public AceWSResultList () {
		resultList = new List<AceWSResult> {};
	}

	public AceWSResultList ( Integer listSize , Boolean bStatus ) {
		resultList = new List<AceWSResult> {};
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
	
	public List<AceWSResult> getResultList () { 
		return resultList;
	}
	
	public AceWSResult getResult ( Integer idx ) {
		if ( idx < 0 || idx >= resultList.size () ) {
			System.debug ( 'Result list index [' + idx + '] out of bounds.' );
			return Null;
		}
		return resultList[ idx ];
	}
}