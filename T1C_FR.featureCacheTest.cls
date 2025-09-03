/* 
 * Name:		featureCacheTest.cls
 *
 * Description: Test methods, plus support methods, for exercising the Feature/
 *				Attribute infrastructure. 
 *
 * Notes: 
 *
 * Confidential & Proprietary, 2008 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole or in part
 * without written permission from Tier1CRM.
 */

public class featureCacheTest {

	public class TestException extends Exception {}

//  ================================================================================
//  Package variables - so we don't have to pass them around in gigantic argument
//  lists
//  ================================================================================
	
//  Object record names.
//  --------------------	
	private static Feature_UGPR_Link__c UGPRLink0 , UGPRLink1;  // Entitlement records
	private static Feature_UGPR__c UGPR0 , UGPR1;  // Entitled_User records
	private static User user0 , user1;				// Users
	private static Group grp0 , grp1;			 	// Groups
	private static GroupMember grpMem0 , grpMem1;   // GroupMembers
	private static UserRole role0;					// Roles
	private static Profile prof0;					// Profiles
	private static Feature__c npf , npsf;		 	// Non-permissionable Feature records
	private static Feature__c ypf , ypsf;		 	// Permissionable Feature records
	private static Feature__c ef , esf;		 		// Entitled Feature records
	private static Feature__c uf , usf;		 		// User Feature records
	private static Feature__c usf_orphan;		 	// Orphaned User Feature record
	private static Attribute__c npa , npsa;			// Attributes on npf and npsf
	private static Attribute__c ypa , ypsa;	 		// Attributes on ypf and ypsf
	private static Attribute__c ea , esa;			// Attributes on ef and esf
	private static Attribute__c ua , usa;			// Attributes on uf and usf
	private static Attribute__c usa_orphan;			// Attribute on usf_orphan
	
	private static Id nullId = Null;
	private static Feature__c badFeature;   // for use by our various failure tests

	private static String TEST_USER_0 = 'Test User 0';
	private static String TEST_USER_1 = 'Test User 1';
	private static String TEST_USERNAME_0 = 'test@user0.com';
	private static String TEST_USERNAME_1 = 'test@user1.com';
	private static String TEST_USER_ALIAS_0 = 'user0';
	private static String TEST_USER_ALIAS_1 = 'user1';
	
	private static String NP_FEATURE_NAME = 'Non-permissionable Feature';
	private static String YP_FEATURE_NAME = 'Permissionable Feature';
	private static String SUBFEATURE_FRAG = 'Subfeature';
	private static String NP_SUBFEATURE_NAME = NP_FEATURE_NAME + '.' + SUBFEATURE_FRAG;
	private static String YP_SUBFEATURE_NAME = YP_FEATURE_NAME + '.' + SUBFEATURE_FRAG;
	
	private static String NP_ATTR_NAME = 'NP Attr Name';
	private static String YP_ATTR_NAME = 'YP Attr Name';
	private static String NP_SUBATTR_NAME = 'NP SubAttr Name';
	private static String YP_SUBATTR_NAME = 'YP SubAttr Name';
	private static String NP_ATTR_VALUE = 'NP Attr Value';
	private static String YP_ATTR_VALUE = 'YP Attr Value';
	private static String NP_SUBATTR_VALUE = 'NP SubAttr Value';
	private static String YP_SUBATTR_VALUE = 'YP SubAttr Value';

//  ================================================================================
//  The test methods
//  ================================================================================


	TestMethod static void test_GUIFeatures () {
		setupFeatures ( False );
		testFailures ( False );
	}

	TestMethod static void test_DLFeatures () {
		setupFeatures ( True );
		testFailures ( True );
	}

	TestMethod static void test_UGPRFailures () {
		setupFeatures ( True );
		testUGPRFailures ();
	}

	TestMethod static void test_DLUpdates () {
		setupFeatures ( True );
		setupAttributes ();
		testUpdates ( True );
	}

	TestMethod static void test_GUIUpdates () {
		setupFeatures ( False );
		setupAttributes ();
		testUpdates ( False );
	}

	TestMethod static void test_DLFeatureBulk () {
		testBulkFeatures ( True );
	}
	
	TestMethod static void test_GUIFeatureBulk () {
		testBulkFeatures ( False );
	}
	
	TestMethod static void test_AttrBulk () {
		setupFeatures ( False );
		Test.startTest ();
		testBulkAttributes ();
		Test.stopTest ();
	}

	TestMethod static void test_FeaturePermChanges () {
		setupFeatures ( False );
		setupAttributes ();
		testPermChanges ();
	}

	TestMethod static void test_FeatureDeletions () {
		setupFeatures ( False );
		setupAttributes ();
		testDeletions ();
	}   

	TestMethod static void test_AceWSResultList () {
		AceWSResult ar = new AceWSResult ( True , 'TEST MSG' );
		AceWSResultList arl = new AceWSResultList ();
		arl.ResultList.add ( ar );
		
		arl.setResult ( True , 'TEST MSG' );
		arl.setResult ( 0 , True , 'TEST MSG' );
		arl.setResult ( 1 , True , 'TEST MSG' );
		
		arl.getResultList ();
		arl.getResult ( 0 );
		arl.getResult ( 1 );
	}

	TestMethod static void test_YPWebSvcs () {
		setupUsers ();
		AceWSResultList arl;
		
//		Create features.
//		----------------		
		arl = featureCacheWebSvc.createFeatures ( new String[] { YP_FEATURE_NAME , YP_SUBFEATURE_NAME } , true );
		System.debug ( 'CREATE FEATURES:\n' + arl );

//		Permission a feature several different ways.
//		--------------------------------------------
		arl = featureCacheWebSvc.permissionFeature ( YP_FEATURE_NAME ,
														user0.Id ,
														featureCacheUtil.USER_STRING ,
														False );
		System.debug ( 'PERMISSION FEATURE FOR USER:\n' + arl );

		arl = featureCacheWebSvc.permissionFeature ( YP_FEATURE_NAME ,
														grp0.Id ,
														featureCacheUtil.GROUP_STRING ,
														False );
		System.debug ( 'PERMISSION FEATURE FOR GROUP:\n' + arl );

		arl = featureCacheWebSvc.permissionFeature ( YP_FEATURE_NAME ,
														user0.ProfileId ,
														featureCacheUtil.PROFILE_STRING ,
														False );
		System.debug ( 'PERMISSION FEATURE FOR PROFILE:\n' + arl );

		arl = featureCacheWebSvc.permissionFeature ( YP_FEATURE_NAME ,
														user0.UserRoleId ,
														featureCacheUtil.ROLE_STRING ,
														True );
		System.debug ( 'PERMISSION FEATURE FOR ROLE:\n' + arl );

//		Set attributes for the various permissions.
//		-------------------------------------------
		Test.startTest ();
		Attribute attr = new Attribute ( YP_ATTR_NAME , YP_ATTR_VALUE );
		arl = featureCacheWebSvc.setAttributes ( YP_FEATURE_NAME ,
													new Attribute[] { attr } );
		System.debug ( 'SET CORE ATTRIBUTE:\n' + arl );

		attr = new Attribute ( YP_ATTR_NAME , YP_ATTR_VALUE + ' USER OVERRIDE' );
		arl = featureCacheWebSvc.overrideAttributes ( user0.Id , featureCacheUtil.USER_STRING ,
														YP_FEATURE_NAME , new Attribute[] { attr } );
		System.debug ( 'OVERRIDE ATTRIB FOR USER:\n' + arl );

		attr = new Attribute ( YP_ATTR_NAME , YP_ATTR_VALUE + ' GROUP OVERRIDE' );
		arl = featureCacheWebSvc.overrideAttributes ( grp0.Id , featureCacheUtil.GROUP_STRING ,
														YP_FEATURE_NAME , new Attribute[] { attr } );
		System.debug ( 'OVERRIDE ATTRIB FOR USER:\n' + arl );

		attr = new Attribute ( YP_ATTR_NAME , YP_ATTR_VALUE + ' PROFILE OVERRIDE' );
		arl = featureCacheWebSvc.overrideAttributes ( user0.ProfileId , featureCacheUtil.PROFILE_STRING ,
														YP_FEATURE_NAME , new Attribute[] { attr } );
		System.debug ( 'OVERRIDE ATTRIB FOR USER:\n' + arl );

		attr = new Attribute ( YP_ATTR_NAME , YP_ATTR_VALUE + ' ROLE OVERRIDE' );
		arl = featureCacheWebSvc.overrideAttributes ( user0.UserRoleId , featureCacheUtil.ROLE_STRING ,
														YP_FEATURE_NAME , new Attribute[] { attr } );
		System.debug ( 'OVERRIDE ATTRIB FOR USER:\n' + arl );

		Map<String , Map<String , Map<String , FeatureCache>>> fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
//		Now grab the Attribute and see what value we get back.
//		(Should be the 'USER OVERRIDE' one.)
//		------------------------------------------------------
		String attrVal = featureCacheWebSvc.getAttribute ( user0.Id , YP_FEATURE_NAME , 
															YP_ATTR_NAME );
		System.debug ( 'ATTR VAL [' + attrVal + ']' );

		
//		Un-permission the feature.
//		--------------------------														
		arl = featureCacheWebSvc.unPermissionFeature ( YP_FEATURE_NAME ,
														user0.Id ,
														'USER' );
		System.debug ( 'UN-PERMISSION FEATURE:\n' + arl );

//		Grab the Attribute again and see what value we get back this time.
//		(Should be the 'GROUP OVERRIDE' one.)
//		------------------------------------------------------------------
		attrVal = featureCacheWebSvc.getAttribute ( user0.Id , YP_FEATURE_NAME , 
															YP_ATTR_NAME );
		System.debug ( 'ATTR VAL [' + attrVal + ']' );

		
//		Re-permission it, for a Group this time.
//		----------------------------------------				
		arl = featureCacheWebSvc.permissionFeature ( YP_FEATURE_NAME ,
														grp0.Id ,
														'GROUP' ,
														False );
		System.debug ( 'PERMISSION FEATURE:\n' + arl );

		Feature[] featList = featureCacheWebSvc.getAttributeTree ( Null , YP_FEATURE_NAME );
		System.debug ( 'GET ATTRIBUTE TREE:\n' + featList );

		Test.stopTest ();
	}

	TestMethod static void test_WebSvcs () {

		setupUsers ();
		AceWSResultList arl;
		
//		Create features.
//		----------------		
		arl = featureCacheWebSvc.createFeatures ( new String[] { NP_FEATURE_NAME , NP_SUBFEATURE_NAME } , false );
		System.debug ( 'CREATE FEATURES:\n' + arl );
		arl = featureCacheWebSvc.createFeature ( NP_FEATURE_NAME , true );
		System.debug ( 'CREATE DUPE FEATURES:\n' + arl );

//		Create attributes.
//		------------------		 
		Attribute attr = new Attribute ( NP_ATTR_NAME , NP_ATTR_VALUE );
		arl = featureCacheWebSvc.setAttributes ( NP_FEATURE_NAME ,
													new Attribute[] { attr } );
		System.debug ( 'CREATE ATTRS:\n' + arl );
		arl = featureCacheWebSvc.setAttribute ( NP_SUBFEATURE_NAME ,
													NP_ATTR_NAME , NP_ATTR_VALUE , False );
		System.debug ( 'CREATE ATTRS ON BAD FEATURE:\n' + arl );
		
//		Override an attribute.
//		----------------------		
		arl = featureCacheWebSvc.setUserAttribute ( user0.Id ,
														NP_FEATURE_NAME ,
														NP_ATTR_NAME , NP_ATTR_VALUE );
		System.debug ( 'SET USER ATTR:\n' + arl );

		arl = featureCacheWebSvc.overrideAttribute ( user0.Id ,
														'USER' ,
														NP_FEATURE_NAME ,
														NP_ATTR_NAME , 
														NP_ATTR_VALUE + ':' + user0.Id );
		System.debug ( 'OVERRIDE ATTR:\n' + arl );

//		Rebuild the feature cache.
//		--------------------------
		featureCacheWebSvc.rebuildFeatureCache ( new String[] { NP_FEATURE_NAME , YP_FEATURE_NAME } );
																
//		Un-override the attribute.
//		--------------------------														
		arl = featureCacheWebSvc.deleteUserAttribute ( user0.Id ,
														NP_FEATURE_NAME ,
														 attr.Name );
		System.debug ( 'DELETE USER ATTRS:\n' + arl );

		arl = featureCacheWebSvc.unOverrideAttribute ( user0.Id ,
														'USER' ,
														NP_FEATURE_NAME ,
														attr.Name );
		System.debug ( 'UNOVERRIDE ATTR:\n' + arl );

//		Get attribute/attributes/attribute tree.
//		----------------------------------------
		String attrVal = featureCacheWebSvc.getAttribute ( user0.Id ,
														NP_FEATURE_NAME ,
														attr.Name );
		System.debug ( 'GET ATTRIBUTE:\n' + attrVal );

		attrVal = featureCacheWebSvc.getAttribute ( user0.Id ,
														NP_FEATURE_NAME ,
														attr.Name + 'bogus' );
		System.debug ( 'GET ATTRIBUTE:\n' + attrVal );
		
		Attribute[] attrList = featureCacheWebSvc.getAttributes ( user0.Id ,
																	NP_FEATURE_NAME );
		System.debug ( 'GET ATTRIBUTES:\n' + attrList );
		
		Feature[] featList = featureCacheWebSvc.getAttributeTree ( user0.Id ,
																	NP_FEATURE_NAME );
		System.debug ( 'GET ATTRIBUTE TREE:\n' + featList );

//		Delete attribute.
//		-----------------
		arl = featureCacheWebSvc.deleteAttribute ( NP_FEATURE_NAME , NP_ATTR_NAME ); 
		System.debug ( 'DELETE ATTRIBUTE:\n' + arl );

//		Delete feature.
//		---------------		 
		arl = featureCacheWebSvc.deleteFeature ( NP_FEATURE_NAME );
		System.debug ( 'DELETE FEATURE:\n' + arl );		
	}

	TestMethod static void test_WebSvcs2 () {

		setupUsers ();
		AceWSResult ar;

//		Create some seed Feature Cache records.
//		---------------------------------------
		Feature_Cache__c[] fcl = new Feature_Cache__c[] { 
				new Feature_Cache__c ( Name = NP_FEATURE_NAME ,
										UGPR_Id__c = 'FALSE' ,
										Feature_Name__c = NP_FEATURE_NAME ,
										Attribute_Name__c = featureCacheUtil.FEATURE_NAME_STRING ,
										Attribute_Value__c = NP_FEATURE_NAME
									) ,
				new Feature_Cache__c ( Name = NP_FEATURE_NAME ,
										UGPR_Id__c = 'FALSE' ,
										Feature_Name__c = NP_FEATURE_NAME ,
										Attribute_Name__c = NP_ATTR_NAME ,
										Attribute_Value__c = NP_ATTR_VALUE
									) ,
				new Feature_Cache__c ( Name = NP_FEATURE_NAME ,
										UGPR_Id__c = 'FALSE' ,
										Feature_Name__c = NP_SUBFEATURE_NAME ,
										Attribute_Name__c = featureCacheUtil.FEATURE_NAME_STRING ,
										Attribute_Value__c = NP_SUBFEATURE_NAME
									) ,
				new Feature_Cache__c ( Name = NP_FEATURE_NAME ,
										UGPR_Id__c = 'FALSE' ,
										Feature_Name__c = NP_SUBFEATURE_NAME ,
										Attribute_Name__c = NP_ATTR_NAME ,
										Attribute_Value__c = NP_SUBATTR_VALUE
									)
		};
		insert fcl;
		
//		Create the Feature tree based on these records.
//		-----------------------------------------------
		ar = featureCacheWebSvc.mkFeatureTreeFromCache ( NP_FEATURE_NAME );
		System.debug ( 'mkFeatureTreeFromCache:\n' + ar );
		
//		Re-root the Feature tree.
//		-------------------------
		ar = featureCacheWebSvc.mvFeatureTree ( NP_FEATURE_NAME , YP_FEATURE_NAME );
		System.debug ( 'mvFeatureTree:\n' + ar );
		
//		Delete the underlying Feature Cache records.
//		--------------------------------------------
		Set<Id> nullUserSet;
		Integer iResult = featureCacheUtil.deleteFeatureCache ( nullUserSet , new Set<String> { YP_FEATURE_NAME } );
		System.debug ( 'deleteFeatureCache : [' + iResult + ']' );
	}
	

//  ========================================================================
//  Method: getTestFeatureCache
//
//  Args:   None.
//
//  Desc:   Skunky little utility to grab our test Feature Cache entries, 
//			and map them by UGPRId, and return the resulting map. 
//  ========================================================================
	static Map<String , Map<String , Map<String , FeatureCache>>> getTestFeatureCache () {
		
		Map<String , Map<String , Map<String , FeatureCache>>> fcMap 
						= new Map<String , Map<String , Map<String , FeatureCache>>> {};
		
		for ( Feature_Cache__c dbFC : [ select 
										UGPR_Id__c , 
										UGPR_Type__c ,
										UGPR_Name__c ,
										Roll_Up_Role_Hierarchy__c ,
										Feature_Name__c , 
										Attribute_Name__c , 
										Attribute_Value__c
									from 
										Feature_Cache__c
									where 
										Feature_Name__c like :NP_FEATURE_NAME + '%' or
										Feature_Name__c like :YP_FEATURE_NAME + '%'
									order by
										UGPR_Name__c , 
										Feature_Name__c , 
										Attribute_Name__c
										]
							) {
			if ( !fcMap.containsKey ( dbFC.UGPR_Id__c ) ) {
				fcMap.put ( dbFC.UGPR_Id__c , new Map<String , Map<String , FeatureCache>> {} );
			}
			if ( !fcMap.get ( dbFC.UGPR_Id__c ).containsKey ( dbFC.Feature_Name__c ) ) {
				fcMap.get ( dbFC.UGPR_Id__c ).put ( dbFC.Feature_Name__c , new Map<String , FeatureCache> {} );
			}
			
			fcMap.get ( dbFC.UGPR_Id__c ).get ( dbFC.Feature_Name__c )
										.put ( dbFC.Attribute_Name__c , new FeatureCache ( dbFC ) );
		}						 
		
		return ( fcMap );
	}

//  ========================================================================
//  Method: summTestFeatureCache
//
//  Args:   fcMap - the output of getTestFeatureCache ()
//
//  Desc:   Skunky little utility to summarize the Feature Cache data 
//			structure retrieved by getTestFeatureCache, and produce a 
//			UGPRId -> numFCEntries map. 
//  ========================================================================
	static Map<String , Integer> summTestFeatureCache (
								Map<String , Map<String , Map<String , FeatureCache>>> fcMap ) {
		
		Map<String , Integer> fcSummMap = new Map<String , Integer> {};
		
		for ( String UGPRId : fcMap.keySet() ) {
			Integer iSumm = 0;
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				iSumm += fcMap.get ( UGPRId ).get ( fName ).size ();
			}
			fcSummMap.put ( UGPRId , iSumm );
		}
		
		return fcSummMap;
	}
											
//  ========================================================================
//  Method: getTestFeatures
//
//  Args:   None.
//
//  Desc:   Skunky little utility to grab our test Feature entries, 
//			and map them by Name, and return the resulting map. 
//  ========================================================================
	static Map<String , Feature__c[]> getTestFeatures () {
		
		Map<String , Feature__c[]> fMap = new Map<String , Feature__c[]> {};
		
		for ( Feature__c f : [select Name__c , Feature_UGPR_Link__c ,
								Core_Feature__c , External_Id__c ,
								Parent_Feature__c , Permission_Required__c ,
								UGPR_Override__c
								from Feature__c
								where Name__c like :NP_FEATURE_NAME + '%'
								or Name__c like :YP_FEATURE_NAME + '%']
							) {
			if ( !fMap.containsKey ( f.Name__c ) ) {
				fMap.put ( f.Name__c , new Feature__c[] {} );
			}
			fMap.get ( f.Name__c ).add ( f );
		}						 
		
		return ( fMap );
	}
	
//  ============================================================================
//  Method: mkFeature
//
//  Desc:   Utility to create a Feature record from the specified components.
//			Works in either DataLoader mode (leaves inter-Feature references
//			blank and builds the External Id), or non-DataLoader mode (adds
//			inter-Feature references and leaves the External Id blank).
//
//  Return: The newly-created Feature.  
//  ============================================================================	
	static Feature__c mkFeature ( String featureName ,
									Boolean bPermReqd ,
									Id UGPRLinkRef ,
									Boolean bOverride ,
									Id parentFeatureRef ,
									Id coreFeatureRef ,
									Boolean bDL
								) {
		Feature__c feature = new Feature__c (
									Name__c = featureName ,
									Permission_Required__c = bPermReqd ,
									Feature_UGPR_Link__c = UGPRLinkRef ,
									UGPR_Override__c = bOverride
		);
		if ( bDL ) {
			feature.External_Id__c = featureCacheUtil.mkFeatureExternalId ( featureName , 
															UGPRLinkRef ,
															bOverride );
		}
		else {
			feature.Parent_Feature__c = parentFeatureRef;
			feature.Core_Feature__c = coreFeatureRef;
		}
		
		return feature;
	}								 

//  ========================================================================
//  Function:   setupUsers
//
//  Arguments:  None.
//
//  Identifies a couple of Users to use, and sets up a pair of Groups for
//  the Users.
//
//  None of the actions in this function is expected to fail.
//  ========================================================================	
	static void setupUsers () {

//		Create a couple of Users with defined Roles.		
//		Get Users with defined Roles for our test.  Grab the 9th and 10th
//		User, in a feeble attempt to bypass the administrative user.
//		-----------------------------------------------------------------

		UserRole[] roleList = [ select Id from UserRole limit 1 ];
		if ( roleList.isEmpty () ) {
			throw new TestException ( 'Need at least one Role, to run Feature Registry tests.' );
		}
		role0 = roleList[ 0 ];
		
		Profile[] profList = [ select Id from Profile limit 1 ];
		if ( profList.isEmpty () ) {
			throw new TestException ( 'Need at least one Profile, to run Feature Registry tests.' );
		}
		prof0 = profList[ 0 ];

/*		--- TEMPORARILY COMMENTED OUT - DML ON USERS MAY BE PROBLEMATIC ---
//		Grab the current user, to use as a template for our test users.
//		---------------------------------------------------------------
		User thisUser = [ select
							Username ,
							Email ,
							Alias ,
							CommunityNickname , 
							TimeZoneSidKey , 
							LocaleSidKey , 
							EmailEncodingKey , 
							LanguageLocaleKey ,
							ProfileId ,
							UserRoleId ,
							IsActive ,
							Feature_Administrator__c
						from
							User
						where
							Id = :UserInfo.getUserId ()
						];
		user0 = thisUser.clone ( False , True );
		user1 = thisUser.clone ( False , True );
		
		user0.LastName = TEST_USER_0;
		user0.Username = TEST_USERNAME_0;
		user0.Email = TEST_USERNAME_0;
		user0.Alias = TEST_USER_ALIAS_0;
		user0.CommunityNickname = TEST_USER_ALIAS_0;
		user0.ProfileId = prof0.Id;
		user0.UserRoleId = role0.Id;
		user0.IsActive = False;
		user0.Feature_Administrator__c = NP_FEATURE_NAME + ';' + YP_FEATURE_NAME;
		
		user1.LastName = TEST_USER_1;
		user1.Username = TEST_USERNAME_1;
		user1.Email = TEST_USERNAME_1;
		user1.Alias = TEST_USER_ALIAS_1;
		user1.CommunityNickname = TEST_USER_ALIAS_1;
		user1.ProfileId = prof0.Id;
		user1.UserRoleId = role0.Id;
		user1.IsActive = False;
		
		insert new User[] { user0 , user1 };
		--- END OF TEMPORARILY COMMENTED OUT - DML ON USERS MAY BE PROBLEMATIC --- */

/*		--- ORIGINAL CODE TO BE REPLACED WITH THE ABOVE --- */
		User[] userList = [select Name , UserRoleId , ProfileId ,
							Feature_Administrator__c from User
							where UserRoleId != Null 
							limit 10];
		if ( userList.size () < 2 ) {
			throw new TestException ( 'Need at least two Users with defined Roles, to run Feature Registry tests.' );
		}
		Integer listSize = userList.size ();
		user0 = userList[ listSize - 2 ];
		user1 = userList[ listSize - 1 ];
/*		--- END OF ORIGINAL CODE TO BE REPLACED WITH THE ABOVE --- */
		
		System.debug ( 'USER0:\n' + user0 );
		System.debug ( 'USER1:\n' + user1 );

//		Set the current user as a Feature Admin, so we can test the WebSvc methods.
//		---------------------------------------------------------------------------
/*		--- TEMPORARILY COMMENTED OUT - PER ABOVE ---
		thisUser.Feature_Administrator__c += ';' + NP_FEATURE_NAME + ';' + YP_FEATURE_NAME;
		update thisUser;
		--- END OF TEMPORARILY COMMENTED OUT - PER ABOVE --- */

/*		--- ORIGINAL CODE TO BE REPLACED WITH THE ABOVE --- */
		User thisUser = [select Name , Feature_Administrator__c from User
							where Id = :UserInfo.getUserId ()];
		User[] updUserList = new User[] { userList[ 0 ] };
		if ( userList[ 0 ].Id != thisUser.Id ) {
			updUserList.add ( thisUser );
		}
		for ( User u : updUserList ) {
			u.Feature_Administrator__c += ';' + NP_FEATURE_NAME + ';' + YP_FEATURE_NAME;
		}
		update updUserList;		 
/*		--- END OF ORIGINAL CODE TO BE REPLACED WITH THE ABOVE --- */
		
//		Create Groups for these Users.
//		------------------------------
		grp0 = new Group ( Name = 'Test Group 1' );
		grp1 = new Group ( Name = 'Test Group 2' );
		Insert new Group[] { grp0 , grp1 };
		
		grpMem0 = new GroupMember ( GroupId = grp0.Id , UserOrGroupId = user0.Id );
		grpMem1 = new GroupMember ( GroupId = grp1.Id , UserOrGroupId = user1.Id );
		Insert new GroupMember[] { grpMem0 , grpMem1 };
	}			 
	
//  ========================================================================
//  Function:   setupFeatures
//
//  Arguments:  bDataLoader - flag indicating to emulate DataLoader mode.
//
//  Sets up a bunch of Feature, Entitlement and Entitled_User object 
//  records, which are defined in the static variable block above.
//
//  None of the actions in this function is expected to fail.
//  ========================================================================	
	static void setupFeatures ( Boolean bDataLoader ) {
	
//		First do the User setup.
//		------------------------
		setupUsers ();  

//		Create Entitlements for our Users.
//		----------------------------------
		UGPRLink0 = new Feature_UGPR_Link__c ( Name = 'Test UGPR Link 1' );		
		UGPRLink1 = new Feature_UGPR_Link__c ( Name = 'Test UGPR Link 2' );
		Insert new Feature_UGPR_Link__c[] { UGPRLink0 , UGPRLink1 };
		
		UGPR0 = new Feature_UGPR__c ( 
					Name = 'Test UGPR 1' ,
					UGPR_Id__c = user0.Id ,
					UGPR_Name__c = user0.Name , 
					UGPR_Type__c = featureCacheUtil.USER_STRING ,
					Feature_UGPR_Link__c = UGPRLink0.Id
				);
		UGPR1 = new Feature_UGPR__c ( 
					Name = 'Test UGPR 2' ,
					UGPR_Id__c = user1.Id ,
					UGPR_Name__c = user1.Name ,
					UGPR_Type__c = featureCacheUtil.USER_STRING ,
					Feature_UGPR_Link__c = UGPRLink1.Id
				);
		Insert new Feature_UGPR__c[] { UGPR0 , UGPR1 };
		
//		========================================================================
//		TEST 1  : Add Public Features:
//				- Add a public Feature npf.
//				- Add a public SubFeature npsf.
//		EXPECTED: New FeatureName = npfName and npsfName pseudo-attributes
//				in FeatureCache with wild-carded User fields.
//		========================================================================
		npf = mkFeature ( NP_FEATURE_NAME , False ,
										nullId , False , nullId , nullId , bDataLoader ); 
		npsf = mkFeature ( NP_SUBFEATURE_NAME , False ,
										nullId , False , npf.Id , nullId , bDataLoader );
		System.debug ( 'ABOUT TO ADD PUBLIC CORE FEATURES [' + npf + '] [' + npsf + ']' );
		try {
			Insert new Feature__c[] { npf , npsf };
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE ADDING PUBLIC CORE FEATURES [' + npf + '] [' + npsf + ']' );
		featureCacheUtil.showQueryStats ( 'END OF ADD PUBLIC CORE FEATURES' );  

//		========================================================================
//		TEST 2  : Add Permissionable Features:
//				- Add a permissionable Feature ypf.
//				- Add a permissionable SubFeature ypsf.
//		EXPECTED: Nothing new in FeatureCache.
//		========================================================================
		ypf = mkFeature ( YP_FEATURE_NAME , True ,
										nullId , False , nullId , nullId , bDataLoader );
		ypsf = mkFeature ( YP_SUBFEATURE_NAME , True ,
										nullId , False , nullId , nullId , bDataLoader );

		System.debug ( 'ABOUT TO ADD PERMISSIONABLE CORE FEATURES [' + npf + '] [' + ypf + ']' );
		try {
			Insert new Feature__c[] { ypf , ypsf };
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE ADDING PERMISSIONABLE CORE FEATURES [' + ypf + '] [' + ypsf + ']' );
		featureCacheUtil.showQueryStats ( 'END OF ADD PERMISSIONABLE CORE FEATURES' );  

//		========================================================================
//		TEST 3  : Add Entitled Feature and SubFeature, and Override SubFeature:
//				- Add an Entitled Feature ef, hooked to Core Feature ypf and
//					Entitlement UGPRLink0.
//				- Add an Entitled SubFeature esf, hooked to Core SubFeature
//					ypsf and Entitlement UGPRLink0
//				- Add an Override SubFeature usf_orphan, hooked to Core
//					SubFeature ypsf and Entitlement UGPRLink0
//		EXPECTED: New FeatureName = ypfName and ypsfName pseudo-attributes in
//				FeatureCache for User0 (the one hooked to UGPRLink0).
//		========================================================================
		ef = mkFeature ( YP_FEATURE_NAME , False ,
							UGPRLink0.Id , False , nullId , ypf.Id , bDataLoader );
		esf = mkFeature ( YP_SUBFEATURE_NAME , False ,
							UGPRLink0.Id , False , ef.Id , ypsf.Id , bDataLoader );
		usf_orphan = mkFeature ( YP_SUBFEATURE_NAME , False ,
							UGPRLink0.Id , True , nullId , ypsf.Id , bDataLoader );

		System.debug ( 'ABOUT TO ADD ENTITLED/OVERRIDE FEATURES: ['
						+ ef + '] [' + esf + '] [' + usf_orphan + ']' );
		try {
			Insert new Feature__c[] { ef , esf , usf_orphan };
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE ADDING ENTITLED/OVERRIDE FEATURES: ['
						+ ef + '] [' + esf + '] [' + usf_orphan + ']' );
		featureCacheUtil.showQueryStats ( 'END OF ADD ENTITLED/OVERRIDE FEATURES' );	

//		========================================================================
//		TEST 4  : Add Override Feature and SubFeature:
//				- Add an Override Feature uf, hooked to Core Feature npf and
//					User user1.
//				- Add an Override Feature usf, hooked to Core SubFeature npsf
//					and User user1.
//		EXPECTED: No change to FeatureCache.
//		========================================================================
		uf = mkFeature ( NP_FEATURE_NAME , False ,
							UGPRLink1.Id , True , nullId , npf.Id , bDataLoader );
		usf = mkFeature ( NP_SUBFEATURE_NAME , False ,
							UGPRLink1.Id , True , uf.Id , npsf.Id , bDataLoader );						 

		System.debug ( 'ABOUT TO ADD OVERRIDE FEATURES: ['
						+ uf + '] [' + usf + ']' );
		try {
			Insert new Feature__c[] { uf , usf };
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}

		System.debug ( 'DONE ADDING OVERRIDE FEATURES: ['
						+ uf + '] [' + usf + ']' );
		featureCacheUtil.showQueryStats ( 'END OF ADD OVERRIDE FEATURES' ); 
						
//		Now do the self-consistency assertions.
//		---------------------------------------
		Map<String , Map<String , Map<String , FeatureCache>>> fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
		featureCacheUtil.showQueryStats ( 'END OF GET TFC AFTER OVERRIDE FEATURES' );
		
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_FEATURE_NAME )
															.get ( featureCacheUtil.FEATURE_NAME_STRING )
															.AttributeValue ,
								NP_FEATURE_NAME );
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_SUBFEATURE_NAME )
		 													.get ( featureCacheUtil.FEATURE_NAME_STRING )
															.AttributeValue ,
								NP_SUBFEATURE_NAME );
		System.assertEquals ( fcMap.get ( user0.Id ).get ( YP_FEATURE_NAME )
															.get ( featureCacheUtil.FEATURE_NAME_STRING )
															.AttributeValue ,
								YP_FEATURE_NAME );
		System.assertEquals ( fcMap.get ( user0.Id ).get ( YP_SUBFEATURE_NAME )
		 													.get ( featureCacheUtil.FEATURE_NAME_STRING )
		 													.AttributeValue ,
								YP_SUBFEATURE_NAME );

		System.assertEquals ( fcMap.containsKey ( user1.Id ) , False );	 

//		========================================================================
//		TEST 5  : Delete user0:
//		EXPECTED: FeatureCache entries associated with user0 should disappear.
//		========================================================================
/*		--- MUST COMMENT OUT - NOT ALLOWED TO DELETE USERS - EVEN TEST ONES ---
		System.debug ( 'ABOUT TO DELETE USER [' + user0 + ']' );
		delete user0;
		System.debug ( 'DONE DELETING USER [' + user0 + ']' );
		featureCacheUtil.showQueryStats ( 'END OF DELETE USER' ); 
		
//		Now do the self-consistency assertions.
//		---------------------------------------
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_FEATURE_NAME )
															.get ( featureCacheUtil.FEATURE_NAME_STRING )
															.AttributeValue ,
								NP_FEATURE_NAME );
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_SUBFEATURE_NAME )
		 													.get ( featureCacheUtil.FEATURE_NAME_STRING )
															.AttributeValue ,
								NP_SUBFEATURE_NAME );
								
		System.assertEquals ( fcMap.containsKey ( user0.Id ) , False );	 
		System.assertEquals ( fcMap.containsKey ( user1.Id ) , False );	 
*/
	}
	
//  ========================================================================
//  Function:   setupAttributes
//
//  Arguments:  None.
//
//  Sets up a bunch of Attribute object records, which are defined in the
//  static variable block at the top of this file.  Records are hooked to
//  the appropriate Feature records.
//
//  None of the actions in this function is expected to fail.
//  ========================================================================	
	static void setupAttributes () {
		
//		========================================================================
//		TEST 1  : Add an Attribute to our core Feature npf.
//		EXPECTED: New Feature_Cache entries for the Attribute for all users in
//				the system.
//		========================================================================
		npa = new Attribute__c ( Feature__c = npf.Id , Name = 'NP Attr Name' , 
										Value__c = 'NP Attr Value' );
		npsa = new Attribute__c ( Feature__c = npsf.Id , Name = 'NP SubAttr Name' , 
										Value__c = 'NP SubAttr Value' );

		ypa = new Attribute__c ( Feature__c = ypf.Id , Name = 'YP Attr Name' , 
										Value__c = 'YP Attr Value' );
																			
		ypsa = new Attribute__c ( Feature__c = ypsf.Id , Name = 'YP SubAttr Name' , 
										Value__c = 'YP SubAttr Value' );

		ua = new Attribute__c ( Feature__c = uf.Id , Name = 'NP Attr Name' , 
										Value__c = 'NP Attr Value User Override' );

		usa_orphan = new Attribute__c ( Feature__c = usf_orphan.Id , Name = 'YP SubAttr Name' , 
										Value__c = 'YP SubAttr Value User Override' );

		Attribute__c[] attrList = new Attribute__c[] { npa , npsa ,
																ypa , ypsa ,
																ua , usa_orphan };
															
		System.debug ( 'ABOUT TO ADD ATTRIBUTES' );
		try {
			Insert attrList;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE ADDING ATTRIBUTES' );
		featureCacheUtil.showQueryStats ( 'END OF ADDING ATTRIBUTES' ); 
		
//		Now do the self-consistency assertions.
//		---------------------------------------
		Map<String , Map<String , Map<String , FeatureCache>>> fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_FEATURE_NAME )
																			.get ( 'NP Attr Name' )
																			.AttributeValue ,
								'NP Attr Value' );
		System.assertEquals ( fcMap.get ( user0.Id ).containsKey ( NP_FEATURE_NAME ) ,
								False );
		System.assertEquals ( fcMap.get ( user1.Id ).get ( NP_FEATURE_NAME )
															.get ( 'NP Attr Name' )
		 													.AttributeValue ,
								'NP Attr Value User Override' );
								
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).get ( NP_SUBFEATURE_NAME )
																			.get ( 'NP SubAttr Name' )
																			.AttributeValue ,
								'NP SubAttr Value' );
		System.assertEquals ( fcMap.get ( user0.Id ).containsKey ( NP_SUBFEATURE_NAME ) ,
								False );
		System.assertEquals ( fcMap.get ( user1.Id ).containsKey ( NP_SUBFEATURE_NAME ) ,
								False );

		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).containsKey ( YP_FEATURE_NAME ) ,
								False );								
		System.assertEquals ( fcMap.get ( user0.Id ).get ( YP_FEATURE_NAME )
															.get ( 'YP Attr Name' )
															.AttributeValue ,
								'YP Attr Value' );
		System.assertEquals ( fcMap.get ( user1.Id ).containsKey ( YP_FEATURE_NAME ) ,
								False );
								
		System.assertEquals ( fcMap.get ( featureCacheUtil.WILDCARD_STRING ).containsKey ( YP_SUBFEATURE_NAME ) ,
								False );
		System.assertEquals ( fcMap.get ( user0.Id ).get ( YP_SUBFEATURE_NAME )
															.get ( 'YP SubAttr Name' )
		 													.AttributeValue ,
								'YP SubAttr Value User Override' );
		System.assertEquals ( fcMap.get ( user1.Id ).containsKey ( YP_SUBFEATURE_NAME ) ,
								False );
	}

//  ========================================================================
//  Function:   testFailures
//
//  Arguments:  bDataLoader - flag indicating DataLoader emulation mode.
//
//  Branches off into DataLoader/non-DataLoader specific test cases.
//  ========================================================================			
	static void testFailures ( Boolean bDataLoader ) {
		
		if ( bDataLoader ) {
			testDLFailures ();
		}
		else {
			testGUIFailures ();
		}
	}		 

//  ========================================================================
//  Function:   testDLFailures
//
//  Arguments:  None.
//
//  Runs DataLoader-specific failure test cases (there are only three of
//  these).
//  ========================================================================			
	static void testDLFailures () {
			
//		========================================================================
//		TEST 1FD: Add a non-Core DL Feature with bad Name__c, so we can't find
//				its corresponding Core Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'badStuff' , False ,
									UGPRLink0.Id , False , nullId , nullId , True );
		System.debug ( 'ABOUT TO ADD BAD-NAME DL NON-CORE FEATURE: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_DL_NONCORE_FEATURE_NO_CORE_FEATURE ) );
		}
		System.debug ( 'DONE ADDING BAD-NAME DL NON-CORE FEATURE: [' + badFeature + ']' );
		
//		========================================================================
//		TEST 2FD: Add a DL Sub-Feature with bad Name__c, so we can't find
//				its corresponding Parent Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'badStuff.subFeature' , False ,
									nullId , False , nullId , nullId , True );
		System.debug ( 'ABOUT TO ADD BAD-NAME DL SUBFEATURE: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_DL_SUB_FEATURE_NO_PARENT_FEATURE ) );
		}
		System.debug ( 'DONE ADDING BAD-NAME DL SUBFEATURE: [' + badFeature + ']' );
		
	}
		
//  ========================================================================
//  Function:   testGUIFailures
//
//  Arguments:  None.
//
//  Runs non-DataLoader-specific failure test cases (there are many more
//  of these).
//  ========================================================================			
	static void testGUIFailures () {
		
		Id badId;
		
//		========================================================================
//		PREP	: Add a bogus Feature and then delete it, capturing its ID for
//				use in subsequent failure tests.  Side effect - this tests
//				the Feature Delete After trigger!
//		========================================================================				
		badFeature = mkFeature ( NP_FEATURE_NAME + 'temp' , True ,
									nullId , False , nullId , nullId , False );
		Insert badFeature;
		badId = badFeature.Id;
		Delete badFeature;
			
//		========================================================================
//		TEST 1F : Add a non-Core Feature with no Entitlement reference.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME , False ,
									nullId , False , nullId , npf.Id , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE W/O ENTL REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_NO_UGPR_LINK_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE W/O USER OR ENTL REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 2F : Add a non-Core Feature with an invalid Core reference.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME , False ,
									UGPRLink0.Id , False , nullId , badId , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE WITH BAD CORE REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_BAD_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE WITH BAD CORE REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 3F : Add a non-Core Feature whose Core Feature reference is to 
//				another non-Core Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME , False ,
									UGPRLink0.Id , False , nullId , esf.Id , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE WITH NON-CORE CORE FEATURE REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_BAD_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE WITH NON-CORE CORE FEATURE REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 4F : Add a non-Core Feature whose Core Feature reference is to 
//				a Feature with the wrong name.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'bad' , False ,
									UGPRLink0.Id , False , nullId , npf.Id , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE WITH BAD-NAME CORE FEATURE REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_BAD_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE WITH BAD-NAME CORE FEATURE REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 5F : Add a Core Feature with an Entitlement reference.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'bad' , False ,
									UGPRLink0.Id , False , nullId , nullId , False );

		System.debug ( 'ABOUT TO ADD CORE FEATURE WITH ENTITLEMENT REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_CORE_FEATURE_UGPR_LINK_REF ) );
		}
		System.debug ( 'DONE ADDING CORE FEATURE WITH ENTITLEMENT REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 6F : Add a Sub-Feature with a non-delimited Name.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'bad' , False ,
									nullId , False , ypf.Id , nullId , False );

		System.debug ( 'ABOUT TO ADD SUB-FEATURE WITH NON-DELIMITED NAME: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_NAME_NOT_DELIMITED ) );
		}
		System.debug ( 'DONE ADDING SUB-FEATURE WITH NON-DELIMITED NAME: [' + badFeature + ']' );

//		========================================================================
//		TEST 7F : Add a Sub-Feature with a bad Parent reference.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_SUBFEATURE_NAME + 'bad' , False ,
									nullId , False , badId , nullId , False );

		System.debug ( 'ABOUT TO ADD SUB-FEATURE WITH BAD PARENT REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_BAD_PARENT_REF ) );
		}
		System.debug ( 'DONE ADDING SUB-FEATURE WITH BAD PARENT REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 8F : Add a Sub-Feature with a Parent reference to a Feature of
//				a different Type.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_SUBFEATURE_NAME , False ,
									nullId , False , ef.Id , nullId , False );

		System.debug ( 'ABOUT TO ADD SUB-FEATURE WITH BAD-TYPE PARENT REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_BAD_PARENT_REF ) );
		}
		System.debug ( 'DONE ADDING SUB-FEATURE WITH BAD-TYPE PARENT REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 9F : Add a Sub-Feature with a Parent reference to a Feature with
//				a different name
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_SUBFEATURE_NAME , False ,
									nullId , False , ypf.Id , nullId , False );

		System.debug ( 'ABOUT TO ADD SUB-FEATURE WITH BAD-NAME PARENT REF: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_BAD_PARENT_REF ) );
		}
		System.debug ( 'DONE ADDING SUB-FEATURE WITH BAD-NAME PARENT REF: [' + badFeature + ']' );

//		========================================================================
//		TEST 10F: Add a User Feature with a Core Feature reference to another
//				User (non-Core) Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME , False ,
									UGPRLink0.Id , True , nullId  , uf.Id , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE WITH CORE REF TO NON-CORE FEATURE: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_NONCORE_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE WITH CORE REF TO NON-CORE FEATURE: [' + badFeature + ']' );

//		========================================================================
//		TEST 11F: Add a User Feature with a Core Feature reference to a Feature
//				with a different Name.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_SUBFEATURE_NAME , False ,
									UGPRLink0.Id , True , nullId  , npf.Id , False );

		System.debug ( 'ABOUT TO ADD NON-CORE FEATURE WITH CORE REF TO FEATURE W/DIFF NAME: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_NONCORE_FEATURE_BADNAME_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING NON-CORE FEATURE WITH CORE REF TO FEATURE W/DIFF NAME: [' + badFeature + ']' );

//		========================================================================
//		TEST 12F: Add an Entitled Feature with a Core Feature reference to a 
//				Public Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME , True ,
									UGPRLink0.Id , False , nullId  , npf.Id , False );

		System.debug ( 'ABOUT TO ADD ENTITLED FEATURE WITH CORE REF TO PUBLIC FEATURE: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_ENTITLED_FEATURE_PUBLIC_CORE_REF ) );
		}
		System.debug ( 'DONE ADDING ENTITLED FEATURE WITH CORE REF TO PUBLIC FEATURE: [' + badFeature + ']' );

//		========================================================================
//		TEST 13F: Add a Core Sub-Feature with a Parent Feature reference to an 
//				Entitled (non-Core) Feature.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( YP_SUBFEATURE_NAME , True ,
									nullId , False , ef.Id  , nullId , False );

		System.debug ( 'ABOUT TO ADD CORE SUBFEATURE WITH PARENT REF TO NON-CORE FEATURE: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_BADTYPE_PARENT_REF ) );
		}
		System.debug ( 'DONE ADDING CORE SUBFEATURE WITH PARENT REF TO NON-CORE FEATURE: [' + badFeature + ']' );

//		========================================================================
//		TEST 14F: Add a Core Sub-Feature with a Parent Feature reference to a 
//				Core Feature with the wrong name.
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_SUBFEATURE_NAME , False ,
									nullId , False , npsf.Id  , nullId , False );

		System.debug ( 'ABOUT TO ADD CORE SUBFEATURE WITH PARENT REF TO FEATURE W/BAD NAME: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_SUB_FEATURE_BADNAME_PARENT_REF ) );
		}
		System.debug ( 'DONE ADDING CORE SUBFEATURE WITH PARENT REF TO FEATURE W/BAD NAME: [' + badFeature + ']' );

//		========================================================================
//		TEST 15F: Add a Core Sub-Feature with no Parent Feature reference, and
//				a name not corresponding to any Feature. 
//		EXPECTED: Exception thrown.
//		========================================================================
		badFeature = mkFeature ( NP_FEATURE_NAME + 'Bogus.' + SUBFEATURE_FRAG , False ,
									nullId , False , nullId  , nullId , False );

		System.debug ( 'ABOUT TO ADD CORE SUBFEATURE WITH UNKNOWN PARENT COMPONENT: [' + badFeature + ']' );
		try {
			Insert badFeature;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_FEATURE_NAME_DELIMITED ) );
		}
		System.debug ( 'DONE ADDING CORE SUBFEATURE WITH UNKNOWN PARENT COMPONENT: [' + badFeature + ']' );
	}

//  ========================================================================
//  Function:   testBulkFeatures
//
//  Arguments:  bDataLoader - flag indicating to emulate DataLoader mode.
//
//  Creates a large number of non-permissionable Features.
//  ========================================================================	
	static void testBulkFeatures ( Boolean bDataLoader ) {
		Integer idx = 0;
		Feature__c[] featureList = new Feature__c[] {};
		
		while ( idx++ < 100 ) {
			featureList.add ( mkFeature ( 'bulkFeature ' + idx , False ,
												nullId , False , nullId , nullId , bDataLoader )
							);
		}
		
		Insert featureList;
	}   

//  ========================================================================
//  Function:   testBulkAttributes
//
//  Arguments:  None.
//
//  Creates a large number of Attributes, hooked to non-permissionable
//  Feature npf.
//  ========================================================================	
	static void testBulkAttributes () {
		Integer idx = 0;
		Attribute__c[] attrList = new Attribute__c[] {};
		
		while ( idx++ < 100 ) {
			attrList.add ( new Attribute__c ( Name = 'attrName ' + idx , 
												Value__c = 'attrVal ' + idx ,
												Feature__c = npf.Id
											)
							);
		}
		
		Insert attrList;
	}
		
//  ========================================================================
//  Function:   testUpdates
//
//  Arguments:  bDataLoader - flag indicating to emulate DataLoader mode.
//
//  Updates Features and Attributes and checks the resulting record set
//  for self-consistency.
//  ========================================================================	
	static void testUpdates ( Boolean bDataLoader ) {
		
		npf.Name__c += 'UPDATED';
		npsf.Name__c  = npf.Name__c + '.' + SUBFEATURE_FRAG;
		
		if ( bDataLoader ) {
			npf.External_Id__c = featureCacheUtil.mkFeatureExternalId ( npf.Name__c ,
															npf.Feature_UGPR_Link__c ,
															npf.UGPR_Override__c );
			npsf.External_Id__c = featureCacheUtil.mkFeatureExternalId ( npsf.Name__c ,
															npsf.Feature_UGPR_Link__c ,
															npsf.UGPR_Override__c );
		}
		Update new Feature__c[] { npf , npsf };
		featureCacheUtil.showQueryStats ( 'END OF FEATURE UPDATE' ); 
		
		npa.Value__c += 'UPDATED';
		Update npa;

		Map<String , Map<String , Map<String , FeatureCache>>> fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
	}		 

//  ========================================================================
//  Method: testUGPRFailures
//
//  Args:   None.
//
//  Desc:   Tests the various Entitled_User failure cases.  
//  ========================================================================	
	static void testUGPRFailures () {
		
//		========================================================================
//		TEST 1 : Give an UGPR an invalid UGPR Type. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Type__c = 'abcdef';
		
		System.debug ( 'ABOUT TO SET INVALID UGPR TYPE ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_UGPR_TYPE ) );
		}
		System.debug ( 'DONE SETTING INVALID UGPR TYPE ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 2 : Give the UGPR a non-User reference but a User Type. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = user0.UserRoleId;
		UGPR0.UGPR_Type__c = featureCacheUtil.USER_STRING;
		
		System.debug ( 'ABOUT TO SET NON-USER REF BUT USER TYPE ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_USER ) );
		}
		System.debug ( 'DONE SETTING NON-USER REF BUT USER TYPE ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 3  : Give the UGPR a really bogus User-type UGPR reference. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = 'abcdef';

		System.debug ( 'ABOUT TO SET BOGUS USER REF ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_USER ) );
		}
		System.debug ( 'DONE SETTING BOGUS USER REF ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 4 : Give the UGPR a non-Group reference but a Group Type. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = user0.Id;
		UGPR0.UGPR_Type__c = featureCacheUtil.GROUP_STRING;
		
		System.debug ( 'ABOUT TO SET NON-GROUP REF BUT GROUP TYPE ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_GROUP ) );
		}
		System.debug ( 'DONE SETTING NON-GROUP REF BUT GROUP TYPE ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 5  : Give the UGPR a really bogus Group-type UGPR reference. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = 'abcdef';

		System.debug ( 'ABOUT TO SET BOGUS GROUP REF ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_GROUP ) );
		}
		System.debug ( 'DONE SETTING BOGUS GROUP REF ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 6  : Hook the UGPR to a non-Regular Group. 
//		EXPECTED: Exception thrown.
//		========================================================================
		Group[] nonRegGrps = [ select Id from Group where Type != 'Regular' limit 1 ];
		if ( !nonRegGrps.isEmpty () ) { 
			UGPR0.UGPR_Id__c = nonRegGrps[ 0 ].Id;
	
			System.debug ( 'ABOUT TO SET NON-REGULAR GROUP REF ON ENTITLED USER [' + UGPR0 + ']' );
			try {
				Update UGPR0;
				System.assert ( False );
			}
			catch ( DMLException e ) {
				System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
				System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_NOT_REGULAR_GROUP ) );
			}
			System.debug ( 'DONE SETTING NON-REGULAR GROUP GROUP REF ON ENTITLED USER [' + UGPR0 + ']' );
		}
		
//		========================================================================
//		TEST 7 : Give the UGPR a non-Profile reference but a Profile Type. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = user0.UserRoleId;
		UGPR0.UGPR_Type__c = featureCacheUtil.PROFILE_STRING;
		
		System.debug ( 'ABOUT TO SET NON-PROFILE REF BUT PROFILE TYPE ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_PROFILE ) );
		}
		System.debug ( 'DONE SETTING NON-PROFILE REF BUT PROFILE TYPE ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 8  : Give the UGPR a really bogus Profile-type UGPR reference. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = 'abcdef';

		System.debug ( 'ABOUT TO SET BOGUS PROFILE REF ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_PROFILE ) );
		}
		System.debug ( 'DONE SETTING BOGUS PROFILE REF ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 9 : Give the UGPR a non-Role reference but a Role Type. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = user0.Id;
		UGPR0.UGPR_Type__c = featureCacheUtil.ROLE_STRING;
		
		System.debug ( 'ABOUT TO SET NON-ROLE REF BUT ROLE TYPE ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_ROLE ) );
		}
		System.debug ( 'DONE SETTING NON-ROLE REF BUT ROLE TYPE ON UGPR [' + UGPR0 + ']' );

//		========================================================================
//		TEST 10 : Give the UGPR a really bogus Role-type UGPR reference. 
//		EXPECTED: Exception thrown.
//		========================================================================
		UGPR0.UGPR_Id__c = 'abcdef';

		System.debug ( 'ABOUT TO SET BOGUS ROLE REF ON UGPR [' + UGPR0 + ']' );
		try {
			Update UGPR0;
			System.assert ( False );
		}
		catch ( DMLException e ) {
			System.debug ( 'EXCEPTION [' + e.getDMLMessage ( 0 ) + ']' );
			System.assert ( e.getDMLMessage( 0 ).contains ( featureCacheUtil.ERR_UGPR_INVALID_ROLE ) );
		}
		System.debug ( 'DONE SETTING BOGUS ROLE REF ON UGPR [' + UGPR0 + ']' );

//		Restore the Entitled_User object to a state of normalcy.
//		--------------------------------------------------------		
		UGPR0.UGPR_Id__c = user0.Id;
		UGPR0.UGPR_Type__c = featureCacheUtil.USER_STRING;
	}
	
//  ========================================================================
//  Method: testPermChanges
//
//  Args:   None.
//
//  Desc:   Changes Feature permissions, and checks the resulting Feature
//			Cache for self-consistency.
//  ========================================================================
	static void testPermChanges () {

		Map<String , Map<String , Map<String , FeatureCache>>> fcMap;
		Map<String , Integer> fcSummMap;
		Map<String , Feature__c[]> fMap;
		
//		========================================================================
//		TEST 1  : Change npf from Public to Permissionable.
//		EXPECTED: All npf-related and npsf-related Feature Cache entries
//				should disappear (being now Permissionable but not Entitled).
//		========================================================================
		npf.Permission_Required__c = True;
		
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
		System.debug ( 'ABOUT TO CHANGE npf TO PERMISSIONABLE' );
		try {
			Update npf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE CHANGING npf TO PERMISSIONABLE' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		fcSummMap = summTestFeatureCache ( fcMap );
		
		System.assertEquals ( fcSummMap.containsKey ( featureCacheUtil.WILDCARD_STRING ) , False );
		System.assertEquals ( 4 , fcSummMap.get ( user0.Id ) );
		System.assertEquals ( fcSummMap.containsKey ( user1.Id ) , False );

//		========================================================================
//		TEST 2  : Change npf back from Permissionable to Public.
//		EXPECTED: All npf-related Feature Cache entries should re-appear, and
//					the npsf-related entries should NOT re-appear.
//		========================================================================
		npf.Permission_Required__c = False;
		
		System.debug ( 'ABOUT TO CHANGE npf BACK TO PUBLIC' );
		try {
			Update npf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE CHANGING npf BACK TO PUBLIC' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		fcSummMap = summTestFeatureCache ( fcMap );
		
		System.assertEquals ( 2 , fcSummMap.get( featureCacheUtil.WILDCARD_STRING ) );
		System.assertEquals ( 4 , fcSummMap.get ( user0.Id ) );
		System.assertEquals ( 1 , fcSummMap.get ( user1.Id ) );

//		========================================================================
//		TEST 3  : Change ypf from Permissionable to Public.
//		EXPECTED: All ypf-related Feature Cache entries should change from user0
//					to '*'.  The ypsf-related entries should remain unchanged.
//					The ef Feature should disappear.
//		========================================================================
		ypf.Permission_Required__c = False;
		
		System.debug ( 'ABOUT TO CHANGE ypf TO PUBLIC' );
		try {
			Update ypf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE CHANGING ypf TO PUBLIC' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		fcSummMap = summTestFeatureCache ( fcMap );
		
		System.assertEquals ( 4 , fcSummMap.get ( featureCacheUtil.WILDCARD_STRING ) );
		System.assertEquals ( 2 , fcSummMap.get ( user0.Id ) );
		System.assertEquals ( 1 , fcSummMap.get ( user1.Id ) );

		fMap = getTestFeatures ();
		for ( String fName : fMap.keySet () ) {
			System.debug ( 'FEATURE MAP BY NAME [' + fName + '] :' );
			featureCacheUtil.dumpFeature ( fMap.get ( fName ) );
		}
		System.assertEquals ( 1 , fMap.get ( YP_FEATURE_NAME ).size () );

//		========================================================================
//		TEST 4  : Change ypf from Public back to Permissionable.
//		EXPECTED: All ypf-related Feature Cache entries should disappear, as ypf
//					is now Permissionable but not entitled.  The ypsf-related
//					entries should remain unchanged.
//		========================================================================
		ypf.Permission_Required__c = True;
		
		System.debug ( 'ABOUT TO CHANGE ypf BACK TO PERMISSIONABLE' );
		try {
			Update ypf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE CHANGING ypf BACK TO PERMISSIONABLE' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		fcSummMap = summTestFeatureCache ( fcMap );
		
		System.assertEquals ( 2 , fcSummMap.get ( featureCacheUtil.WILDCARD_STRING ) );
		System.assertEquals ( 2 , fcSummMap.get ( user0.Id ) );
		System.assertEquals ( 1 , fcSummMap.get ( user1.Id ) );

	}

//  ========================================================================
//  Method: testDeletions
//
//  Args:   None.
//
//  Desc:   Deletes Features, and checks the resulting Feature Cache for
//			self-consistency.
//  ========================================================================
	static void testDeletions () {

		Map<String , Map<String , Map<String , FeatureCache>>> fcMap;
		Map<String , Integer> fcSummMap;
		Map<String , Feature__c[]> fMap;
		
//		========================================================================
//		TEST 1  : Delete npf.
//		EXPECTED: All npf-related and npsf-related Feature Cache entries
//				should disappear.  The Features npsf, uf and usf should also
//				disappear.
//		========================================================================
		System.debug ( 'ABOUT TO DELETE npf' );
		try {
			Delete npf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE DELETING npf' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		fcSummMap = summTestFeatureCache ( fcMap );
		
		System.assertEquals ( fcSummMap.containsKey ( featureCacheUtil.WILDCARD_STRING ) , False );
		System.assertEquals ( 4 , fcSummMap.get ( user0.Id ) );
		System.assertEquals ( fcSummMap.containsKey ( user1.Id ) , False );

		fMap = getTestFeatures ();
		for ( String fName : fMap.keySet () ) {
			System.debug ( 'FEATURE MAP BY NAME [' + fName + '] :' );
			featureCacheUtil.dumpFeature ( fMap.get ( fName ) );
		}
		System.assertEquals ( fMap.containsKey ( NP_FEATURE_NAME ) , False );
		System.assertEquals ( fMap.containsKey ( NP_SUBFEATURE_NAME ) , False );
	
//		========================================================================
//		TEST 2  : Delete ypsf.
//		EXPECTED: All ypsf-related Feature Cache entries should disappear. 
//				The features esf and usf_orphan should also disappear.
//		========================================================================
		System.debug ( 'ABOUT TO DELETE ypsf' );
		try {
			Delete ypsf;
		}
		catch ( Exception e ) {
			System.debug ( 'UNEXPECTED EXCEPTION [' + e + ']' );
			System.assert ( False );
		}
		System.debug ( 'DONE DELETING ypsf' );
		fcMap = getTestFeatureCache ();
		for ( String UGPRId : fcMap.keySet () ) {
			for ( String fName : fcMap.get ( UGPRId ).keySet () ) {
				for ( String aName : fcMap.get ( UGPRId ).get ( fName ).keyset () ) {
					fcMap.get ( UGPRId ).get ( fName ).get ( aName ).dump ();
				}
			}
		}
		
		System.assertEquals ( fcMap.containsKey ( featureCacheUtil.WILDCARD_STRING ) , False );
		System.assertEquals ( 2 , fcMap.get ( user0.Id ).size () );
		System.assertEquals ( fcMap.containsKey ( user1.Id ) , False );

		fMap = getTestFeatures ();
		for ( String fName : fMap.keySet () ) {
			System.debug ( 'FEATURE MAP BY NAME [' + fName + '] :' );
			featureCacheUtil.dumpFeature ( fMap.get ( fName ) );
		}
		System.assertEquals ( fMap.containsKey ( YP_SUBFEATURE_NAME ) , False );
	}
}