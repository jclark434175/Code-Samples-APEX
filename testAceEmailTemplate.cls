public class testAceEmailTemplate {
/*
Requirements:
	- folder named 'test1';
	- folder named 'test2';
	- email template named test1
	- email template named test2
*/


	//--------------------------- AceEmailTemplate
	
	public static testMethod void test_getEmailTemplates()
	{
		//TEST 
		String[] folderNames = new String[]{'test1', 'test2'};
		
		List<EmailTemplate> e = ALMWebServices.getEmailTemplates( folderNames );
	}
	
	
	public static testMethod void test_sendBulkEmail()
	{
		
		Folder f = [select Id, Name from Folder where Name = 'test1' limit 1];
		
		/*
		EmailTemplate et = new EmailTemplate();
		et.Body = 'body';
		et.Description = 'description';
		et.FolderId = f.Id;
		et.HtmlValue = '<b>body</b>';
		et.IsActive = true;
		et.Subject = 'subject';
		et.TemplateType = 'text';
		et.TemplateStyle = 'none';
		et.Name = 'test1_tempalte';
		Insert et;
		System.assert( et.Id!=null );
		*/
		
		Contact c1 = new Contact();
		c1.FirstName = 'fname1';
		c1.LastName = 'lname1';
		c1.Email = 'email@test111.com';
		Insert c1;
		System.assert( c1.Id!=null );
		
		Contact c2 = new Contact();
		c2.FirstName = 'fname2';
		c2.LastName = 'lname2';
		c2.Email = 'email@test222.com';
		Insert c2;
		System.assert( c2.Id!=null );
		
		Contact c3 = new Contact();
		c3.FirstName = 'fname2';
		c3.LastName = 'lname2';
		c3.Email = ''; //no email to generate error
		Insert c3;
		System.assert( c3.Id!=null );
		
		Contact c4 = new Contact();
		c4.FirstName = 'fname2';
		c4.LastName = 'lname2';
		c4.Email = ''; //no email to generate error
		Insert c4;
		System.assert( c4.Id!=null );
		
		Id[] contactIds = new Id[4];
		contactIds[0] = c1.Id;
		contactIds[1] = c2.Id;
		contactIds[2] = c3.Id;
		contactIds[3] = c4.Id;
		
		
		//send the 4 emails
		AceWSResultList rs =  ALMWebServices.sendBulkEmail( true, null, null, contactIds, null );
		System.assertEquals ( 4 , rs.getResultList().size() );
		
	}
	
	public static testMethod void test_sendPlainTextBulkEmail()
	{
	
		Contact c1 = new Contact();
		c1.FirstName = 'fname11';
		c1.LastName = 'lname11';
		c1.Email = 'email@test11.com';
		Insert c1;
		System.assert( c1.Id!=null );
		
		Contact c2 = new Contact();
		c2.FirstName = 'fname22';
		c2.LastName = 'lname22';
		c2.Email = 'email@test22.com';
		Insert c2;
		System.assert( c2.Id!=null );
		
		Contact c3 = new Contact();
		c3.FirstName = 'fname33';
		c3.LastName = 'lname33';
		c3.Email = ''; //no email to generate error
		Insert c3;
		System.assert( c3.Id!=null );
		
		Contact c4 = new Contact();
		c4.FirstName = 'fname44';
		c4.LastName = 'lname44';
		c4.Email = ''; //no email to generate error
		Insert c4;
		System.assert( c4.Id!=null );
		
		Id[] contactIds = new Id[4];
		contactIds[0] = c1.Id;
		contactIds[1] = c2.Id;
		contactIds[2] = c3.Id;
		contactIds[3] = c4.Id;
	
		AceWSResultList rs;
		Boolean saveActivity = true;
		String	emailSubject = 'test email subject';
		String emailBody = 'test email body';
		Id[] documentIds = null;
		rs = ALMWebServices.sendPlainTextBulkEmail( saveActivity, emailSubject, emailBody, contactIds, documentIds );
		System.assertEquals ( 4 , rs.getResultList().size() );
	
	}
	
	
	
	//--------------------------- AceEmailTemplateUtil
	
	
	public static testMethod void test_createTemplate()
	{
		Folder f = [select Id, Name from Folder where Name = 'test1' limit 1];
		System.assert ( f!=null );
		
		EmailTemplate et = new EmailTemplate();
		et.Body = 'body';
		et.Description = 'description';
		et.FolderId = f.Id;
		et.HtmlValue = '<b>body</b>';
		et.IsActive = true;
		et.Subject = 'subject';
		et.TemplateType = 'text';
		et.TemplateStyle = 'none';
		et.Name = 'test tempalte';
		Insert et;
		System.assert ( et.Id!=null );
		
		//create the template
		AceWSResultList rs = ALMWebServices.createEmailTemplate( et );	
		System.assertEquals ( 1 , rs.getResultList().size() );
		
	}
	
	
	public static testMethod void test_cloneEmailTemplateAttachments()
	{
		Folder f = [select Id, Name from Folder where Name = 'test1' limit 1];
		System.assert ( f!=null );
		
		EmailTemplate baseTemplate = [select Id from EmailTemplate where Name='test1' limit 1];
		System.assert ( baseTemplate.Id!=null );
		
		EmailTemplate targetTemplate = [select Id from EmailTemplate where Name='test2' limit 1];
		System.assert ( targetTemplate.Id!=null );
				
		Attachment at1 = new Attachment();
		at1.Body = Blob.valueOf('body data');
		at1.ContentType = 'text/plain';
		at1.Name = 'testAttachment';
		at1.ParentId = baseTemplate.Id;
		Insert at1;
		System.assert ( at1.Id!=null );
		
		Attachment at2 = new Attachment();
		at2.Body = Blob.valueOf('body data');
		at2.ContentType = 'text/plain';
		at2.Name = 'testAttachment';
		at2.ParentId = baseTemplate.Id;
		Insert at2;
		System.assert ( at2.Id!=null );
		
		//clone attachments between templates
		AceWSResultList rs = ALMWebServices.cloneEmailTemplateAttachments(targetTemplate.Id, baseTemplate.Id);
		System.assertEquals ( 2 , rs.getResultList().size() );
	}
	
	
	public static testMethod void test_deleteEmailTemplate()
	{
		
		Folder f = [select Id, Name from Folder where Name='test1' limit 1];
		System.assert ( f!=null );
		
		EmailTemplate et = new EmailTemplate();
		et.Body = 'body';
		et.Description = 'description';
		et.FolderId = f.Id;
		et.HtmlValue = '<b>body</b>';
		et.IsActive = true;
		et.Subject = 'subject';
		et.TemplateType = 'text';
		et.TemplateStyle = 'none';
		et.Name = 'test tempalte';
		Insert et;
		System.assert ( et.Id!=null );
		
		AceWSResultList rs;
		
		//delete the one template
		rs = ALMWebServices.deleteEmailTemplate( et.Id, f.Id );
		System.assertEquals ( 1 , rs.getResultList().size() );
		
		//delete invalid template
		rs = ALMWebServices.deleteEmailTemplate( null, f.Id );
		System.assertEquals ( 1 , rs.getResultList().size() );
	}
	
	
	
	
}