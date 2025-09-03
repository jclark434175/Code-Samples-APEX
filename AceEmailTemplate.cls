/* 
 * Name: EmailTemplate 
 * Description: Contains static Email Template related methods.
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */


//note: 'with sharing' is used here because 
//1) templates retrieved are those contained within folders that are visible to the running user
//2) emails sent should appear as from the running user
global with sharing class AceEmailTemplate 
{
        
    
//  ============================================================================
//  Method: getEmailTemplates   
//  Desc:   Retrieves the active email templates that reside in the specified
//			folder(s)
//  Args:   folderNames
//  Return: One or more Email Templates                    
//  ============================================================================
    public static List<EmailTemplate> getEmailTemplates ( String[] folderNames ) 
    {    	
    	//find the ids of the email template folders matching the input folder names
    	List<Id> folderIds = new List<Id>();
    	for ( Folder f : [ select Id from Folder where Type='Email' AND Name IN :folderNames ] )
    	{
    		folderIds.add(f.Id);
    	}
    	
    	//retrieve the active templates from the target folders
    	List<EmailTemplate> templates = [ select Body, BrandTemplateId, Description, Encoding, FolderId, Folder.Name, Folder.Type, HtmlValue, IsActive, Name, OwnerId, Subject, TemplateStyle, TemplateType from EmailTemplate where IsActive=true and FolderId IN :folderIds ];
    	
    	
    	return templates;
    	
    }
    
    
//  ============================================================================
//  Method: sendBulkEmail   
//  Desc: Sends an email to each contact using the specified email template
//  Args:	saveActivity	whether or not to save an activity for each email sent
//			templateId		Source template to use
//			contactIds		Who should receive emails
//			attachments		List of document ids that will be attached to the 

//  Return: Result of sending email to each contact                
//  ============================================================================
	public static AceWSResultList sendBulkEmail( Boolean saveActivity, Id templateId, Id whatId, Id[] contactIds, Id[] documentIds )
	{
		//container for emails to be sent
    	Messaging.Email[] mails = new Messaging.Email[contactIds.size()];
    	//position into the array storing emails to be sent
	    Integer pos = 0;
	    	
	    //process each target contact specified
    	for(Id cid : contactIds)
    	{	
    		//new email message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId( cid ); // the target contact 
			mail.setTemplateId( templateId  ); //template to be used
			mail.setBccSender(false); 
			mail.setSaveAsActivity( saveActivity );
			mail.setUseSignature(false);
			mail.setDocumentAttachments( documentIds );
			mail.setWhatId(whatId); //what id
			
    		//save the mail message
			mails[pos] = mail;
			
			//get ready to process the next email message	
			pos++;
    	}
    	
    	//send the email messages (all or none = false)
		Messaging.SendEmailResult[] opResult = Messaging.sendEmail( mails , false);
	
		//process the results of the operation		
    	AceWSResultList resultList = new AceWSResultList ( opResult.size () , False );
    	//process each SendEmailResult returned
    	for ( Integer i = 0 ; i < opResult.Size () ; i++ ) 
    	{
            Messaging.SendEmailResult meResult = opResult[ i ];
            Boolean bStatus = true;
            String msg = '';
            
            if ( !meResult.isSuccess () ) 
            {
                bStatus = false;
                msg = AceEmailTemplate.parseSendEmailErrors( meResult.getErrors(), ';' );
            }   
            resultList.setResult ( i , bStatus , msg );
        }
	
    	return resultList;
		
	}
    
    
    //  ============================================================================
	//  Method: sendPlainTextBulkEmail   
	//  Desc: Sends an custom plain text email to each contact
	//  Args:	saveActivity	Whether or not to save an activity for each email sent
	//			contactIds		Who should receive emails
	//			documentIds		List of document ids that will be attached to the 
	//			subject			Email subject
	//			body			Email body
	//
	//  Return: Result of sending email to each contact                
	//  ============================================================================
    public static AceWSResultList sendPlainTextBulkEmail( Boolean saveActivity, String subject, String body, Id[] contactIds, Id[] documentIds )
	{
		//container for emails to be sent
    	Messaging.Email[] mails = new Messaging.Email[contactIds.size()];
    	//position into the array storing emails to be sent
	    Integer pos = 0;
	    	
	    //process each target contact specified
    	for(Id cid : contactIds)
    	{	
    		//new email message
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId( cid ); // the target contact 
			mail.setBccSender(false); 
			mail.setSaveAsActivity( saveActivity );
			mail.setUseSignature(false);
			mail.setDocumentAttachments( documentIds );
			mail.setPlainTextBody( body );
			mail.setSubject( subject );
			
    		//save the mail message
			mails[pos] = mail;
			
			//get ready to process the next email message	
			pos++;
    	}
    	
    	//send the email messages (all or none = false)
		Messaging.SendEmailResult[] opResult = Messaging.sendEmail( mails , false);
		    		
		//process the results of the operation		
    	AceWSResultList resultList = new AceWSResultList ( opResult.size () , False );
    	//process each SendEmailResult returned
    	for ( Integer i = 0 ; i < opResult.Size () ; i++ ) 
    	{
            Messaging.SendEmailResult meResult = opResult[ i ];
            Boolean bStatus = true;
            String msg = '';
            
            if ( !meResult.isSuccess () ) 
            {
                bStatus = false;
                msg = AceEmailTemplate.parseSendEmailErrors( meResult.getErrors(), ';' );
            }   
            resultList.setResult ( i , bStatus , msg );
        }
    	   	
    	return resultList;
	}
	
	
    
//  ============================================================================
//  Method: parseSendEmailErrors   
//  Desc: Parses errors returned from the sendEmail call
//  Args:	errList		Error list
//			delim		Delimiter used to seperate multiple errors
//  Return: String of parsed errors       
//  ============================================================================
    public static String parseSendEmailErrors( List<Database.Error> errList , String delim ) {
        
        String concatStr = '';
        
        //process all errors
        for ( Integer i = 0 ; i < errList.size () ; i++ ) 
        {
        	//specific status code encountered
        	if( errList[i].getStatusCode()== System.StatusCode.MASS_MAIL_LIMIT_EXCEEDED )
        	{
        		concatStr += ( i == 0 ? '' : delim ) + 'Mass email limit exceeded';
        	}
        	//general error message
        	else
        	{
            	concatStr += ( i == 0 ? '' : delim ) + errList[ i ].getMessage ();
        	}
        }
        return concatStr;
    }
    
}