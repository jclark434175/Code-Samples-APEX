public class PhilboCRCExtension 
{

	//private static String ID_COVERAGE_GRID = 'coverageGrid';
	
	private Map<String , KevinMenuPrototypeSortState> sortByName
					= new Map<String , KevinMenuPrototypeSortState> {};
	
	/**
	*	Bound to front end
	*/
	public String b_startDate {get{if(b_startDate==null)return ''; else return b_startDate;}set;}
	public String b_endDate {get{if(b_endDate==null)return ''; else return b_endDate;}set;}
	
	public String testProp {
		get {
			System.debug ( 'testProp getter : [' + testProp + ']' );
			return testProp;
		}
		set {
			System.debug ( 'testProp setter : [' + value + ']' );
			testProp = value;
		}
	}
	
	public String clickedComponentInputId;
	
	public String getClickedComponentInputId () {
		system.debug ( 'clickedCompId getter : [' + clickedComponentInputId + ']' );
		system.debug ( '...sort map :\n' + sortByName );
		return ( clickedComponentInputId == Null ? '' : clickedComponentInputId );
	}
	
	public void setClickedComponentInputId ( String value ) {
		system.debug ( 'clickedCompId setter : [' + value + ']' );
		system.debug ( 'SORT MAP INITIALLY: \n' + sortByName );
		clickedComponentInputId = value;
		String[] idParts = value.split ( ':' );
		system.debug ( 'ID PARTS : [' + idParts + ']' );
		if ( idParts.size () >= 7 ) {
			String tblName = idParts[ 4 ];
			String colName = idParts[ 6 ];
			KevinMenuPrototypeSortState sortObj = sortByName.get ( tblName );
			if ( sortObj == Null ) {
				sortByName.put ( tblName , new KevinMenuPrototypeSortState ( tblName , colName , True ) );
			}
			else if ( sortObj.sortField != colName ) {
				sortObj.sortField = colName;
			}
			else {
				sortObj.sortAsc = !sortObj.sortAsc;
			}
			system.debug ( 'SORT MAP NOW: \n' + sortByName );
		}
		else {
			system.debug ( 'Invalid component Id : [' + value + ']' );
		}
	}

	private String addSortHtml ( string baseStr , String tblName , String fldName ) {
	
		KevinMenuPrototypeSortState sortObj = sortByName.get ( tblname );
		if ( sortObj != Null && sortObj.sortField == fldName ) {
			baseStr += '        ' + ( sortObj.sortAsc ? 'v' : '^' );
		}
		return baseStr;
	}
	
	public String[] bogusVal {
		get {
			return new String[] { 'a' , 'b' , 'c' , 'd' };
		}
		set;
	}
		
	public String rsnHdr {
		get {
			return ( addSortHtml ( 'Reason' , 'interestResultsHdr' , 'Reason__c' ) );
		}
		set;
	}
	public String contHdr {
		get {
			return ( addSortHtml ( 'Contact' , 'interestResultsHdr' , 'Contact__c' ) );
		}
		set;
	}
	public String symHdr {
		get {
			return ( addSortHtml ( 'Symbol' , 'interestResultsHdr' , 'Symbol__c' ) );
		}
		set;
	}
	
	/**
	*	Account id in context
	*/
	private Id accountId;
	
	/**
	*	Date values in context
	*/	
	private String startDate;
	private String endDate;
	
	//private KevinMenuPrototypeSortStateList sortStateMgr;
	
	/**
	*	Constructor
	*/
	public PhilboCRCExtension () {}
	
	public PhilboCRCExtension(ApexPages.StandardController controller)
	{
		//save the account id in context
		this.accountId = ApexPages.currentPage().getParameters().get('id');
		
		//initialize the sort state list
		//sortStateMgr = new KevinMenuPrototypeSortStateList();
		
	}


	/**
	*	Getter for interest data
	*/
	public Interest__c[] interests {
		
		get {
			if ( b_StartDate == '' || b_endDate == '' ) {
				return new Interest__c[] {};
			}
			
			System.debug ( 'interestResults : BOUND DATES : [' + b_startDate + '] [' + b_endDate + ']' );
			System.debug ( 'interestResults : SORT MAP :\n' + sortByName );
			
			String qryStr = 'select '
								+ 'Symbol__c , '
								+ 'Source__c , '
								+ 'Reason__c , '
								+ 'Name , '
								+ 'Contact__c , '
								+ 'As_Of_Date__c '
							+ 'from '
								+ 'Interest__c '
							+ 'where '
								+ 'Account__c = \'' + accountId + '\' and '
								+ 'As_of_Date__c >= ' + startDate + ' and '
								+ 'As_of_Date__c <= ' + endDate + ' '
							;
			
			KevinMenuPrototypeSortState sortObj = sortByName.get ( 'interestResultsHdr' );
			if ( sortObj != Null ) {
				qryStr += 'order by ' + sortObj.sortField + ' ';
				if ( !sortObj.sortAsc ) {
					qryStr += 'desc ';
				}
			}
			
			System.debug ( 'QRY STR:\n' + qryStr );
			
			interests = Database.query ( qryStr );
			System.debug ( 'INTERESTS:\n' + interests );
			return interests;
		}
		
		set;
	}
		
	
	/**
	*	Getter for contact coverage data
	*/
	public List<Contact_Coverage__c> contactCoverage 
	{
		get{
			
			//String QUERY_COVERAGE = 'select c.Role__c, c.Id, c.Employee__r.Name, c.Contact__r.Id, c.Contact__r.Name From Contact_Coverage__c c where c.Contact__r.AccountId = '+this.accountId;
			
			//String queryStr = sortStateMgr.buildQueryStr(ID_COVERAGE_GRID, QUERY_COVERAGE, 'Employee__r.Name');
			
			try
			{
				//contactCoverage = Database.query( queryStr );
				contactCoverage = [select c.Role__c, c.Id, c.Employee__r.Name, c.Contact__r.Id, c.Contact__r.Name From Contact_Coverage__c c where c.Contact__r.AccountId =:this.accountId];
			}
			catch(Exception e)
			{
				System.Debug('************* exception: ' + e);
				contactCoverage = new List<Contact_Coverage__c>();
			}
			
			return contactCoverage;
		}
		set;}
		
	
	/**
	*	Action method called externally
	*/
	public void processDates() {
		
		startDate = this.getDate(b_startDate);
		endDate = this.getDate(b_endDate);
	}
	
	
	/**
	*	Utility function to parse date
	*/
	private String getDate ( String dateStr ) {	
		String[] dateParts = dateStr.split ( '/' );
		if ( dateParts.size () != 3 ) {
			return '';
		}
		return ( dateParts[ 2 ] + '-' + dateParts[ 1 ] + '-' + dateParts[ 0 ] );
	}

}