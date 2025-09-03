public with sharing class PageNavigate {

	public enum objectType {ACCOUNT, CONTACT} 
	private objectType objType;
	private Id objID;
    
	public PageNavigate(ApexPages.StandardController controller)
	{
	    this.objID = ApexPages.currentPage().getParameters().get('id');
	    SObject obj = controller.getRecord();
	    Schema.SObjectType sObjType = obj.getSObjectType();
	    objType = (sObjType + '' == 'Account' ? objectType.ACCOUNT : objectType.CONTACT);
	
	}
    /**********************************************************/ 
	public PageReference ViewPageByProfile ()
    /**********************************************************/
	{	
		// get user profile info
		String profileId = UserInfo.getProfileId();
		String profileName =[Select p.Name From Profile p where p.Id=:profileId].Name;
		// get the page
		return (objType == objectType.ACCOUNT ? 
				ViewAccountByProfile(objId, profileName)
				: ViewContactByProfile(objId, profileName));
		
	}
	
    /**********************************************************/ 
	private PageReference ViewAccountByProfile (Id objID, String profileName)	
    /**********************************************************/
	{	
		// get the account record type info
		String[] arrReturnFields = new String[] {'Name','RecordType.Name', 'RecordTypeId'};
		Account obj = (Account)AceSObject.getSObjectInfoById(objID + '', 'Account', arrReturnFields );
		Id rtId = obj.RecordTypeId;
		String rtName = obj.RecordType.Name;
		// determine the page to be viewed
		string pageName = '';
		// get user info // FIC configuration
		//arrReturnFields = new String[] {'Name','Business_Group__c'};
		//User usr = (User)AceSObject.getSObjectInfoById(UserInfo.getUserId(), 'User', arrReturnFields );
		//if (usr.Business_Group__c == 'FIC & Derivative Groups') pageName = '/apex/FIC_Client_View';
		pageName = '/apex/PageNavigateAccount'; // Displays Std page 
		//return the page
		return ViewPageByName(pageName);
		
	}
	/**********************************************************/ 
	private PageReference ViewContactByProfile (Id objID, String profileName)	
	//Store xref profile/object recordType -> page name in AFR.
    /**********************************************************/
	{	string pageName = '';		
		pageName = '/apex/PageNavigateContact'; // Displays Std page 
		//return the page
		return ViewPageByName(pageName);
		
	}
	/**********************************************************/ 
	public PageReference ViewPageByName (String pageName)
    /**********************************************************/
	{
		PageReference redirectPage ;
		if (pageName == null || pageName.trim() == '') {
			pageName = '/' + objID; //standard SF page 
			redirectPage = new PageReference(pageName);  
			redirectPage.getParameters().put('nooverride', '1'); 
		} else { //verify VF page name
			if (!pageName.startsWith('/')) pageName = '/' + pageName;
			if (!pageName.startsWith('/apex')) pageName = '/apex' + pageName;
			redirectPage = new PageReference(pageName);
		}		
		redirectPage.getParameters().put('id', objID);  
		return redirectPage.setRedirect(true);		
	}
	
	/**********************************************************/ 
	public PageReference ViewStdPage()
    /**********************************************************/
	{
		return ViewPageByName ('');
	}
	
	
	//---------------------------------------------------------------
	public static testMethod void testPageNavigateAccount() 
	//---------------------------------------------------------------
    {
    	
        // create an Account       
        Account acct = new Account(Name='Acct PageNavigate');
        try
        {
           insert acct;
        } catch (DmlException e) {
            System.debug('**************Error: Account could not be created -- ' + e.getMessage()); return;
        }
        // Initiate the page
        PageReference pageRef = Page.AccountDetails;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
		ApexPages.currentPage().getParameters().put('id',acct.id);
		ApexPages.StandardController stdControl = new ApexPages.StandardController(acct);
        PageNavigate controller = new PageNavigate(stdControl);    
        //Test page views
        controller.ViewPageByProfile();
        controller.ViewStdPage();
              
    }
    //---------------------------------------------------------------
	public static testMethod void testPageNavigateContact() 
	//---------------------------------------------------------------
    {
    	 // create an Account       
        Account acct = new Account(Name='Acct PageNavigate2');
        try
        {
           insert acct;
        } catch (DmlException e) {
            System.debug('**************Error: Account could not be created -- ' + e.getMessage()); return;
        }
        // create a Contact         
        Contact cont = new Contact(FirstName='John', LastName='PageNavigate', AccountID=acct.Id);
        try
        {
           insert cont;
        } catch (DmlException e) {
            System.debug('**************Error: Contact could not be created -- ' + e.getMessage()); return;
        }
        // Initiate the page
        PageReference pageRef = Page.ContactDetails;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
		ApexPages.currentPage().getParameters().put('id',cont.id);
		ApexPages.StandardController stdControl = new ApexPages.StandardController(cont);
        PageNavigate controller = new PageNavigate(stdControl);    
        //Test page views
        controller.ViewPageByProfile();
        controller.ViewStdPage();
              
    }
}