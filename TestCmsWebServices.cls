/**  
 * Name: TestCmsWebServices 
 * Description: Tests methods & webservices in cmsWebServices.cls
 *
 * Confidential & Proprietary, ©2007 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM Inc.
 */
 
public class TestCmsWebServices {
    
    private static Conference__c mConference = new Conference__c();
    private static List<Registrant__c> mSpeakerRegistrants = new List<Registrant__c>();
    private static List<Registrant__c> mAttendeeRegistrants = new List<Registrant__c>();
    private static List<Contact> mSpeakerContacts = new List<Contact>();
    private static List<Contact> mAttendeeContacts = new List<Contact>();

    public static testmethod void testInsertRegistrants()
    {
        //create account
        Account a1 = new Account();
        a1.Name = 'test account 1';
        Insert a1;
        
        //create contacts
        Contact cc1 = new Contact();
        cc1.LastName = 'test contact 1';
        cc1.Account = a1;
        Insert cc1;
        
        Contact cc2 = new Contact();
        cc2.LastName = 'test contact 1';
        cc2.Account = a1;
        Insert cc2;
        
        //create conferences
        Conference__c c1 = testDataConference.insertRecord('test conf 1');
        Conference__c c2 = testDataConference.insertRecord('test conf 2');
        
        //create registrants
        Registrant__c r1 = testDataRegistrant.createRecord(cc1.Id, c1.Id);
        Registrant__c r2 = testDataRegistrant.createRecord(cc2.Id, c2.Id); 

        Registrant__c[] registrants = new Registrant__c[2];
        registrants[0] = r1;
        registrants[1] = r2;
        
        //insert registrants
        AceWSResultList result = cmsWebServices.insertRegistrants( registrants );
        System.assertEquals(2, result.getResultList().Size());  
    }

    public static testmethod void testSearchAllConferences() 
    {
        //create conferences
        Conference__c c1 = testDataConference.insertRecord('test conf 1');
        Conference__c c2 = testDataConference.insertRecord('test conf 2');
        
        //find conferences
        list<Conference> result = cmsWebServices.searchAllConferences('test');
        System.assertEquals(2, result.Size());
    }
    
    public static testmethod void testSearchOpenConferences() 
    {
        //create conferences
        Conference__c c1 = testDataConference.insertRecord('test conf 1');
        Conference__c c2 = testDataConference.insertRecord('test conf 2');
        
        //find conferences
        list<Conference> result = cmsWebServices.searchOpenConferences('test');
        System.assertEquals(2, result.Size());
    }
    
    public static testmethod void testInsertMeetingRoomsBooked() {
//      Create conferences      
        Conference__c aConference = testDataConference.insertRecord('aConference');
        Hotel__c aHotel = testDataHotel.insertRecord('aHotelName');
        
        Hotel_Meeting_Room__c aMeetingRoom = testDataHotelMeetingRoom.insertRecord(aHotel.Id, 'Room 1');
        Hotel_Meeting_Room__c bMeetingRoom = testDataHotelMeetingRoom.insertRecord(aHotel.Id, 'Room 2');
        
        list<Meeting_Room_Booked__c> meetingRoomsBooked = new list<Meeting_Room_Booked__c>();
        
        meetingRoomsBooked.add(new Meeting_Room_Booked__c(Conference__c = aConference.Id, Hotel_Meeting_Room__c = aMeetingRoom.Id));
        meetingRoomsBooked.add(new Meeting_Room_Booked__c(Conference__c = aConference.Id, Hotel_Meeting_Room__c = bMeetingRoom.Id));
        
        AceWSResultList result = cmsWebServices.insertMeetingRoomsBooked(meetingRoomsBooked);       
        result = cmsWebServices.updateMeetingRoomsBooked([select Id from Meeting_Room_Booked__c where Conference__c = :aConference.Id]);        
    }
    
    public static testmethod void testAceWSResultList() {
        AceWSResultList wsList = new AceWSResultList();
        wsList.setResult(-1, true, 'Some message');
        AceWSResult someResult = wsList.getResult(-1);      

//      to cover aceUtil.deleteRecords      
        Conference__c aConference = testDataConference.insertRecord('aConference');
        Conference__c bConference = testDataConference.insertRecord('bConference');     
        //list<id> ids = new list<id> { aConference.Id, bConference.Id, aConference.Id };
        Id[] ids = new Id[3];
        AceWSResultList result = aceUtil.deleteRecords(ids);
        
        ids[0] = aConference.Id;
        ids[1] = aConference.Id;
        ids[2] = bConference.Id;        
        
        result = aceUtil.deleteRecords(ids);

        Id[] ids2 = new Id[2];
        ids2[0] = aConference.Id;
        ids2[1] = bConference.Id;
            
        result = aceUtil.deleteRecords(ids2);
        result = aceUtil.deleteRecords(ids2);
    }
        
//  ============================================================================
//  Method: getConferenceInfo
//  Detail: Tests getConferenceInfo
//  Case No: 3725 
//  Task Id: TA381
//  ============================================================================    
    public static testmethod void getConferenceInfo() {
//      Create conferences      
        Conference__c aConference = testDataConference.insertRecord('aConference');
        Conference__c bConference = testDataConference.insertRecord('bConference');

//      call to web service; this should return 2 records       
        List<Conference> conferences = cmsWebServices.getConferenceInfo(new String[] {aConference.Id, bConference.id});
        System.assertEquals(2, conferences.Size());
    }
        
//  ============================================================================
//  Method: getTimeslots
//  Detail: Tests getTimeslots
//  Case No: 3703
//  Task Id: TA239
//  ============================================================================    
    public static testmethod void getTimeslots() {      
        //Create a template
        Timeslot_Template__c template = TestCmsWebServices.insertTimeslotTemplate('TemplateName');
        
        //Create a timeslot 
        Timeslot__c timeSlot = new Timeslot__c();
        timeSlot.Timeslot_template__c = template.Id;
        timeSlot.Start_Hr__c = 8;
        timeSlot.Start_Mins__c = 0;
        timeSlot.Start_Meridiem__c = 'AM';
        timeSlot.End_Hr__c = 8;
        timeSlot.End_Mins__c = 30;
        timeSlot.End_Meridiem__c = 'AM';
        insert timeSlot;
        
        //Creating a conference
        Conference__c conference = testDataConference.insertRecord('MyConference');
        
        //Updating the conference with template id
        conference.Timeslot_Template__c = template.Id;
        update conference;
        
        //This call is to cover the exception part
        List<Timeslot> ts = cmsWebServices.getTimeslots(new String[] {'conferenceId'});
        
        //Call to getTimeslotByConference
        List<Timeslot> timeslots = cmsWebServices.getTimeslots(new String[] {conference.Timeslot_template__c});
        
        //This method should return one time slot       
        System.assertEquals(1, timeslots.Size());
    }
    
//  ============================================================================
//  Method: testGetRegistrantSpeakerMeetings
//  Detail: Tests testGetRegistrantSpeakerMeetings  
//  Case No: 3704
//  Task Id: TA241
//  ============================================================================
    public static testmethod void testGetRegistrantSpeakerMeetings() {      
//      create 1 speaker and 2 attendees        
        createRegistrants(1, 2);        
        Contact aSpeakerContact = mSpeakerContacts[0];      
        Contact aAttendeeContact = mAttendeeContacts[0];
        Contact bAttendeeContact = mAttendeeContacts[1];        
        Registrant__c aSpeakerRegistrant = mSpeakerRegistrants[0];
        Registrant__c aAttendeeRegistrant = mAttendeeRegistrants[0];
        Registrant__c bAttendeeRegistrant = mAttendeeRegistrants[1];        
        
//      Create a meeting, Date: Conference date, time: 8:30 AM - 9:00 AM
        Meeting__c aMeeting = testDataMeeting.insertRecord(
                                                    mConference.Id, 
                                                    System.Today(), 
                                                    8.0, 30.0, 'AM', 
                                                    9.0, 0.0, 'AM');
                                                                                                                                    
        Meeting_Participation__c aParticipation = testDataMeetingParticipation.insertRecord(
                                                            aMeeting.Id,
                                                            aSpeakerRegistrant.Id,
                                                            aSpeakerContact.Id,
                                                            'Accepted',
                                                            aceCMSCommon.Type_Speaker_Public);                                                              
                                                                                                                                                    
        Meeting_Participation__c bParticipation = testDataMeetingParticipation.insertRecord(
                                                            aMeeting.Id,
                                                            aAttendeeRegistrant.Id,
                                                            aAttendeeContact.Id,
                                                            'Accepted',
                                                            'Attendee');

        Meeting_Participation__c cParticipation = testDataMeetingParticipation.insertRecord(
                                                            aMeeting.Id,
                                                            bAttendeeRegistrant.Id,
                                                            bAttendeeContact.Id,
                                                            'Accepted',
                                                            'Attendee');                                                            
        Set<Id> participants = new Set<Id>();       
        participants.Add(aParticipation.Id);
        participants.Add(bParticipation.Id);
        participants.Add(cParticipation.Id);
        
        System.assertEquals(3, [Select Count() From Meeting_Participation__c where Id In :participants]);       
        List<Meeting> customMeetings = cmsWebServices.getRegistrantSpeakerMeetings(aSpeakerRegistrant.Id);      
        System.assertEquals(customMeetings.Size(), 1);

//      Exercise the WebSvc record create method.
//      -----------------------------------------
        aParticipation = testDataMeetingParticipation.createRecord ( 
                                                            aMeeting.Id ,
                                                            aSpeakerRegistrant.Id ,
                                                            aSpeakerContact.Id ,
                                                            'Accepted' ,
                                                            aceCMSCommon.Type_Speaker_Public );
        cmsWebServices.insertMeetingParticipations ( 
                                new Meeting_Participation__c[] { aParticipation }
                            ); 
    }
    
//  =====================================================================================
//  Method: getRegistrantsAvailability
//  Detail: Tests getRegistrantsAvailability
//  Return: Array of all registrants of the conference, if registrantIds is null/empty
//          Array of registrants, if registrantIds is not null/empty
//  Case No: 3713 
//  Task Id: TA240
//  ====================================================================================     
    public static testmethod void testGetRegistrantsAvailability() {

//      create 5 speakers and 5 attendees       
        createRegistrants(5, 5);
        
        String[] registrantIds = new String[5];
                
        for( Registrant__c reg : mSpeakerRegistrants ) {
            registrantIds.Add(reg.Id);  
        }

//      pass registrants and conference     
        List<List<Registrant>> registrant_conference = cmsWebServices.getRegistrantsAvailability(registrantIds, mConference.Id);
        
//      pass only the conference
        List<List<Registrant>> null_conference = cmsWebServices.getRegistrantsAvailability(null, mConference.Id);
        
    }
    
    public static testmethod void testAceUtil() {
//      Updating participating account name     
        Conference__c conferenceABC = testDataConference.insertRecord('Conference ABC');
        Account anAccount = ST_ACE.testDataAccount.insertRecord('anAccount', 'AA');
        
        Presenting_Company__c aPCompany = new Presenting_Company__c();      
        aPCompany.Conference__c = conferenceABC.Id;
        aPCompany.Account__c = anAccount.Id;
        
        Presenting_Company__c bPCompany = new Presenting_Company__c();      
        bPCompany.Conference__c = conferenceABC.Id;
        bPCompany.Account__c = anAccount.Id;
        
        List<Presenting_Company__c> listPresentingCompany = new List<Presenting_Company__c>();
        listPresentingCompany.Add(aPCompany);
        listPresentingCompany.Add(bPCompany);
        AceWSResultList resultList = new AceWSResultList();
        
//      this should PASS/FAIL
        resultList = aceUtil.upsertRecords(listPresentingCompany, False);
        System.assertEquals(true, resultList.getResult(0).bSuccess);
        System.assertEquals(false, resultList.getResult(1).bSuccess);
    }
    
    public static testmethod void testInsertMeetings() {
//      create 1 speakers and 2 attendees       
        createRegistrants(1, 2);
        
        Contact aSpeakerContact = mSpeakerContacts[0];      
        Contact aAttendeeContact = mAttendeeContacts[0];
        Contact bAttendeeContact = mAttendeeContacts[1];        
        Registrant__c aSpeakerRegistrant = mSpeakerRegistrants[0];
        Registrant__c aAttendeeRegistrant = mAttendeeRegistrants[0];
        Registrant__c bAttendeeRegistrant = mAttendeeRegistrants[1];                
        
        Meeting__c aMeeting = new Meeting__c();
        
        aMeeting.Conference__c = mConference.Id; 
        aMeeting.Start_Hr__c = 9.00; 
        aMeeting.Start_Mins__c = 0.00;
        aMeeting.Start_Meridiem__c = 'AM';
        aMeeting.Date__c = mConference.Start_Date__c;
        aMeeting.End_Hr__c = 10.00;     
        aMeeting.End_Mins__c = 0.00;
        aMeeting.End_Meridiem__c = 'AM';
        aMeeting.Status__c = 'Scheduled';
        
        List<Meeting__c> meetingsToInsert = new List<Meeting__c>();
        meetingsToInsert.Add(aMeeting);
        
        AceWSResultList resultList = new AceWSResultList();
        resultList = cmsWebServices.insertMeetings(meetingsToInsert);
        resultList = cmsWebServices.insertMeetings(meetingsToInsert);               
    }
    
    public static testmethod void testUpdateMeetings() {
//      create 1 speakers and 2 attendees       
        createRegistrants(1, 2);
        
        Contact aSpeakerContact = mSpeakerContacts[0];      
        Contact aAttendeeContact = mAttendeeContacts[0];
        Contact bAttendeeContact = mAttendeeContacts[1];        
        Registrant__c aSpeakerRegistrant = mSpeakerRegistrants[0];
        Registrant__c aAttendeeRegistrant = mAttendeeRegistrants[0];
        Registrant__c bAttendeeRegistrant = mAttendeeRegistrants[1];
        
        Meeting__c aMeeting = new Meeting__c();
        
        aMeeting.Conference__c = mConference.Id; 
        aMeeting.Start_Hr__c = 9.00; 
        aMeeting.Start_Mins__c = 0.00;
        aMeeting.Start_Meridiem__c = 'AM';
        aMeeting.Date__c = mConference.Start_Date__c;
        aMeeting.End_Hr__c = 10.00;
        aMeeting.End_Mins__c = 0.00;
        aMeeting.End_Meridiem__c = 'AM';
        aMeeting.Status__c = 'Scheduled';
        
        List<Meeting__c> meetingsToInsert = new List<Meeting__c>();
        meetingsToInsert.Add(aMeeting);
        
        AceWSResultList resultList = new AceWSResultList();
        resultList = cmsWebServices.insertMeetings(meetingsToInsert);

//      ids to delete       
        Id[] deleteIds = new Id[] {resultList.getResultList()[0].statusMsg};
        
        resultList = cmsWebServices.insertMeetings(meetingsToInsert);
        
        Meeting__c[] meetingsToUpdate = [Select Id, Conference__c From Meeting__c Where Id = :resultList.getResultList()[0].statusMsg];
        resultList = cmsWebServices.updateMeetings(meetingsToUpdate);
        
        Meeting__c[] duplicateMeetings = new Meeting__c[] {meetingsToUpdate[0], meetingsToUpdate[0]};
        resultList = cmsWebServices.updateMeetings(duplicateMeetings);      
        resultList = cmsWebServices.deleteRecords(deleteIds);       
    }
    
    private static Timeslot_Template__c insertTimeslotTemplate(String timeSlotName) {
        Timeslot_Template__c template = new Timeslot_Template__c(Name = timeSlotName);
        insert template;
        return template;
    }
    
    private static void createRegistrants(Integer speakerCount, Integer attendeeCount) {        
        List<Account> speakerAccounts = new List<Account>();
        List<Account> attendeeAccounts = new List<Account>();
        List<Contact> speakerContacts = new List<Contact>();
        List<Contact> attendeeContacts = new List<Contact>();
        List<Registrant__c> speakerRegistrants = new List<Registrant__c>();
        List<Registrant__c> attendeeRegistrants = new List<Registrant__c>();
        
        Conference__c conference = testDataConference.insertRecord('MyConference');
        
        if (speakerCount > 0) {         
            speakerAccounts = ST_ACE.testDataAccount.insertRecords(speakerCount);
            speakerContacts = ST_ACE.testDataContact.insertRecords(speakerAccounts);
            speakerRegistrants = testDataRegistrant.insertRecords(
                                        conference, 
                                        speakerContacts, 
                                        'Pre-Registrant',                   //registrantType, 
                                        aceCMSCommon.Type_Speaker_Public,   //role 
                                        'Pending',                          //registration_Status, 
                                        conference.Start_Date__c,           //attendance_Start_Date, 
                                        conference.End_Date__c);            //attendance_End_Date
        }
        
        if (attendeeCount > 0) {
            attendeeAccounts = ST_ACE.testDataAccount.insertRecords(attendeeCount);
            attendeeContacts = ST_ACE.testDataContact.insertRecords(attendeeAccounts);
            attendeeRegistrants = testDataRegistrant.insertRecords(
                                        conference, 
                                        attendeeContacts, 
                                        'Pre-Registrant',                   //registrantType, 
                                        'Attendee',                         //role 
                                        'Pending',                          //registration_Status, 
                                        conference.Start_Date__c,           //attendance_Start_Date, 
                                        conference.End_Date__c);            //attendance_End_Date
        }
        
        mConference = conference;
        mSpeakerContacts = speakerContacts;
        mAttendeeContacts = attendeeContacts;
        mSpeakerRegistrants = speakerRegistrants;
        mAttendeeRegistrants = attendeeRegistrants;             
    }       
}