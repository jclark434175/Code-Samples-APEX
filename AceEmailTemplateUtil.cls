/* 
 * Name: AceEmailTemplateUtil 
 * Description: Provides methods for manipulating email template
 *				functions that operate in system context
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */
global class AceEmailTemplateUtil {

//  ============================================================================
//  Method: createEmailTemplate   
//  Desc:   Creates the specified template
//  Args:   template - The template to create
//  Return:	Result of the create operation
//  ============================================================================
	public static AceWSResultList createEmailTemplate( EmailTemplate template )
	{
		//create the template
		Database.SaveResult sr = Database.Insert(template, false);
    	
    	//process the results of the operation	
    	AceWSResultList resultList = new AceWSResultList ( 1 , False );

        Boolean bStatus = True;
        String msg = '';
        
        if ( !sr.isSuccess () ) {
            bStatus = False;
            msg = aceUtil.concatList( sr.getErrors(), ';' );
        }   
        else
        {
        	msg = sr.getId();
        }
        resultList.setResult ( 0 , bStatus , msg );
    	    		
    		
		return resultList;
	}
	

//  ============================================================================
//  Method: cloneEmailTemplateAttachments   
//  Desc:   Clones attachments from one template to another
//  Args:   templateId - The souce template id
//			baseTemplateId - The template that has associated attachments to be cloned
//  Return:	Result of each attachment cloned     	    
//  Case No: 
//  ============================================================================
	public static AceWSResultList cloneEmailTemplateAttachments( Id templateId, Id baseTemplateId )
	{
		//prepare attachments
    	List<Attachment> attachments = new List<Attachment>();
    	for( Attachment a : [select a.Name, a.Body From Attachment a where ParentId=:baseTemplateId] )
    	{
    		Attachment nA = new Attachment();
    		nA.Name = a.Name;
    		nA.Body = a.Body;
    		nA.ParentId = templateId;
    		
    		attachments.add(nA);
    	} 
    	
    	//System.Debug( Logginglevel.DEBUG, '----------------------------------------------------------------------' );
		//System.Debug( Logginglevel.DEBUG,  '???? attachments: '+attachments );
		//System.Debug( Logginglevel.DEBUG, '----------------------------------------------------------------------' );
    	
    	
    	//create the attachments
    	Database.SaveResult[] opResult = Database.Insert(attachments, false);
    	
    	//System.Debug( Logginglevel.DEBUG, '----------------------------------------------------------------------' );
		//System.Debug( Logginglevel.DEBUG,  '???? attachment save result: '+opResult );
		//System.Debug( Logginglevel.DEBUG, '----------------------------------------------------------------------' );
    	
    	
    	//process the results of the operation	
    	AceWSResultList resultList = new AceWSResultList ( opResult.size() , False );

		for( Integer i=0; i<opResult.size(); i++)
		{
			Database.SaveResult aResult = opResult[i];
			
	        Boolean bStatus = true;
	        String msg = '';
	        
	        if ( !aResult.isSuccess () ) {
	            bStatus = false;
	            msg = aceUtil.concatList( aResult.getErrors(), ';' );
	        }   
	        else
	        {
	        	msg = aResult.getId();
	        }
	        resultList.setResult ( i , bStatus , msg );
		}	
    		
		return resultList;
    	
	}
	
	

	
	
//  ============================================================================
//  Method: deleteEmailTemplate   
//  Desc: Deletes a template from the specified folder
//  Args:	templateId		Target template
//			targetFolderId	The id of the folder where the template resides
//  Return: Result of template deletion     
//  ============================================================================
	public static AceWSResultList deleteEmailTemplate( Id templateId, Id folderId )
	{
		//try to retireve the template
		EmailTemplate template;
		try
		{
			template = [select Id from EmailTemplate where Id=:templateId and FolderId=:folderId];
		}
		catch(System.QueryException e)
		{
			template=null;
		}
    	
    	//specified template not found in specified folder
    	String msg;
    	Boolean bStatus = true;
		if(template==null)
		{
			bStatus = false;
			msg = 'Template '+templateId+' was not found in folder '+folderId;
		}
		//template found in specified folder
		else
		{
			Database.DeleteResult dr = Database.Delete( template );
			if( dr.isSuccess()==true)
			{
				bStatus = true;
				msg = template.Id;
			}
			else
			{
				bStatus = false;
				msg = aceUtil.concatList( dr.getErrors(), ';' );
			}
		}
		
		//prepare the results of the operation	
    	AceWSResultList resultList = new AceWSResultList ( 1 , False );
		resultList.setResult ( 0 , bStatus , msg );
		
		return resultList;
	}
    	  	
}