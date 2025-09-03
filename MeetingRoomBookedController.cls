public class MeetingRoomBookedController
{
	
	public static final String DEFAULT_MEETING_ROOM_TEXT = 'Select a meeting room';
	
	//id of the currently selected room
	public String selectedRoomId {get;set;}
	
 	//search text entered by the user
    public String searchText {get;set;}
    
    //flags to control visibility of messages
    public Boolean showRoomSelectionMessage {get;set;}
    public Boolean showNoRoomsFoundMessage {get;set;}
     
     
     
    //reference to the meeting room
    private Meeting_Room_Booked__c mrb;
    
    //indicates the operation should be an insert or update
    private Boolean bUpdate;
    
    //the currently selected room
    private Hotel_Meeting_Room__c userSelectedRoom {get;set;}
    
   
    
    
         
	/*
	*	Constructor
	*/
    public MeetingRoomBookedController(ApexPages.StandardController stdController) 
    {

    	//get and save context from the standard controller
        this.mrb= (Meeting_Room_Booked__c)stdController.getRecord();
        
        //initially hide messages
        showNoRoomsFoundMessage = false;
        showRoomSelectionMessage = false;
       
       
        //insert operation
        if(mrb.id==null)
        {
        	bUpdate=false;
        	
        	//look for a parent conference object and set the reference
        	//if a parent is found, the editable conference lookup will appear pre-populated in the UI
        	//note: retURL is expected to be in the form: "/xxxxxxxxxxxxxx"
        	try 
        	{
        		String tmpStr = System.currentPageReference().getParameters().get('retURL');
	        	System.debug(logginglevel.DEBUG, '???? retURL param: '+tmpStr );
	        	Id conferenceId = tmpStr.substring(1);
	        	Conference__c conferenceObj = getConferenceById( conferenceId );
	        	this.mrb.Conference__c = conferenceObj.Id;
	        } 
        	catch (Exception e) 
        	{
	        	System.debug(logginglevel.DEBUG, '???? conference id not found: '+e );
        	}
        
        }
        //update operation
        else
        {
        	bUpdate=true;
        	
        	//get information about currently selected meeting room
        	userSelectedRoom = getMeetingRoom( this.mrb.Hotel_Meeting_Room__c );
        	selectedRoomId = userSelectedRoom.Id;
        }
        
    }
    
    
    /*
 	*	The selected room displayed in the UI
 	*/
 	public String selectedRoomValue
 	{
 		get
 		{
 			System.debug(logginglevel.DEBUG, '???? The conference obj: '+userSelectedRoom );
 			
	 		if(userSelectedRoom==null)
	 		{
	 			return DEFAULT_MEETING_ROOM_TEXT;
	 		}
	 		else
	 		{
	 			String str = userSelectedRoom.Name+' ('+userSelectedRoom.Hotel__r.Name+')';
	 			return str;
	 		}
	 		
 		}
 		set;
 	}
 	
   
    
    /*
    *	Event handler for change in meeting room
    */
    public PageReference changeSelectedRoom() 
    {
    	//if the room selection has changed, or one never existed
    	if(userSelectedRoom==null || userSelectedRoom.Id!=selectedRoomId)
	    {
	    	userSelectedRoom = getMeetingRoom( selectedRoomId );
	    }
    	
        return null;
    }
    
    
    /*
    *	Event handler for change in conference
    */
    
    public PageReference changeSelectedConference()
    {
    	userSelectedRoom = null;
    	selectedRoomId = null;
    	
    	doSearchAll();
    	
    	return null;
    }
    
       
    
    /*
    *	The search results to display
    */ 
    public List<Hotel_Meeting_Room__c> searchResults 
    {
    	get
    	{
    		//if this is the first request, return an un-filtered list of results
    		if (searchResults==null) 
    		{
                clearSearchText();
                doSearch();
                
            }//end if
                        
            return searchResults;
    	}
    	set;
    }
    
    
    
    
    /*
 	* Perform a search
 	*/
 	public PageReference doSearch()
    {
    	searchResults = new List<Hotel_Meeting_Room__c>();
    	
    	String hotelNameStr;
    	String roomNameStr;
    	
       	//hotels associated with the conference
		Set<Id> hotelIdSet = getConferenceHotels( this.mrb.Conference__c );
		//rooms already booked for the conference
		Set<Id> bookedRoomIdSet = getConferenceBookedRooms( this.mrb.Conference__c );
		
		//parse search terms
		//no search term entered
		if( this.searchText==null || this.searchText.trim().length()== 0 )
		{
			hotelNameStr='';
			roomNameStr='';
		}
		else
		{
			List<String> searchTerms = this.searchText.trim().split(',',2);
			//one search term
			if( searchTerms.size()==1 )
			{
				hotelNameStr=searchTerms[0].trim();
				roomNameStr='';
			}
			//two search terms
			else
			{
				hotelNameStr=searchTerms[0].trim();
				roomNameStr=searchTerms[1].trim();
			}
		}
		
		
		System.debug(logginglevel.DEBUG, '???? hotelNameStr: '+hotelNameStr );
		System.debug(logginglevel.DEBUG, '???? roomNameStr: '+roomNameStr );
		
		//find the rooms in hotels that are associated with the conference and not already booked
	    for ( Hotel_Meeting_Room__c rb : [select n.Name, n.Id, n.Hotel__r.Name, n.Type__c 
	    									from Hotel_Meeting_Room__c n 
	    									where n.Hotel__r.Id in :hotelIdSet and ( n.Hotel__r.Name like :hotelNameStr+'%' and n.Name like :roomNameStr+'%' ) 
	    									order by n.Hotel__r.Name, n.Name] ) 
	    {
	    	
	    	if( bookedRoomIdSet.contains(rb.Id)==false || ( userSelectedRoom!=null && rb.Id==userSelectedRoom.Id ) )
	    	{
	       		searchResults.add ( rb );
	    	}
	    }
	    
	    //if no results were found, tell the user
        if(searchResults.size()==0)
        {
        	System.debug(logginglevel.DEBUG, '???? no available meeting rooms were found ' );
        	showNoRoomsFoundMessage = true;
		}
		else
		{
			showNoRoomsFoundMessage = false;
		}
	    
        return null;
    }
    
    
    
    
    /*
 	* Perform a search for all available items
 	*/
    public PageReference doSearchAll()
    {
    	clearSearchText();
    	doSearch();
    	
    	return null;
    }
    
    
    /*
    *	Clear the search text variable
    */
    private void clearSearchText()
    {
    	searchText = '';
    }
    
    
    /*
    *	Handler for save & new operation
    */
    public PageReference doCommitSaveAndNew()
    {
    	//perform save/update operation
    	PageReference pageRef = doCommit();
    	
    	//save was successful if pageRef is not null
    	if(pageRef!=null)
	    {
	    	pageRef = Page.MeetingRoomBooked;
        	pageRef.setRedirect(true);
	    	pageRef.getParameters().put('retURL', '/'+this.mrb.Conference__c);
	    }
	    
    	return pageRef;
    }
    
    
    /*
    *	Perform the save or update operation
    */
    public PageReference doCommit() 
    {
    	//used to store
    	String url;
    	PageReference page;
    	
    	//clear any previous meeting room message
    	showRoomSelectionMessage=false;
    			    			
    	//update operation
    	if (bUpdate == true) 
    	{
    		System.debug(logginglevel.DEBUG, '???? UPDATE');
    		this.mrb.Hotel_Meeting_Room__c = userSelectedRoom.Id;
    		update this.mrb;
    		
    		url = '/'+this.mrb.id;
        	page = new PageReference(url);    			
    	}
    	//insert operation
    	else
    	{
    		System.debug(logginglevel.DEBUG, '???? INSERT1');
    		if(userSelectedRoom!=null)
    		{
    			System.debug(logginglevel.DEBUG, '???? INSERT2');
    			this.mrb.Hotel_Meeting_Room__c = userSelectedRoom.Id;
    			insert this.mrb;
    			
    			url = '/'+this.mrb.id;
        		page = new PageReference(url);
    		}
    		else
    		{
    			showRoomSelectionMessage = true;
    			page=null;
    		}
    	}
    	
    	return page;   
    }
    
    
    
    
    
    /*
    *	Retrieve information about a conference
    */
    private Conference__c getConferenceById(String id)
    {
    	Conference__c con = [select Name, Id from Conference__c where Id=:id];
    	
    	System.debug(logginglevel.DEBUG, con);
    	
    	return con;
    }
    
        
    /*
 	*	Retrieve the details about a specific meeting room
 	*/
 	private Hotel_Meeting_Room__c getMeetingRoom(Id meetingRoomId)
 	{
 		Hotel_Meeting_Room__c room = [select hr.Name, hr.Capacity__c, hr.Description__c, hr.Hotel__c, hr.Type__c, Hotel__r.Name 
								 		from Hotel_Meeting_Room__c hr 
								 		where hr.Id=:meetingRoomId];
 	
 		System.debug(logginglevel.DEBUG, room);
 		
 		return room;
 	}
    
    /*
    * Returns the id of each meeting room associated with a conference
    */
    private Set<Id> getConferenceBookedRooms(Id conferenceId)
    {
    	Set<Id> bookedHotelIdSet = new Set<Id>();
    	for ( Meeting_Room_Booked__c rb : [select Id, Hotel_Meeting_Room__c
    										from Meeting_Room_Booked__c	 
    										where Conference__c =:conferenceId and Conference__c != null] ) 
        {
           	bookedHotelIdSet.add ( rb.Hotel_Meeting_Room__c );
        }
        System.debug(logginglevel.DEBUG, bookedHotelIdSet);
        
        return bookedHotelIdSet;
    }
    
    
    
    /*
    * Returns the id of each hotel associated with a conference
    */
    private Set<Id> getConferenceHotels(Id conferenceId)
    {
    	Set<Id> hotelIdSet = new Set<Id>();
    	for ( Hotel_Booking__c hb : [select Id, Hotel__r.Id 
    									from Hotel_Booking__c 
    									where Conference__c =:conferenceId and Conference__c != null] ) 
        {
           	hotelIdSet.add ( hb.Hotel__r.Id );
        }
        System.debug(logginglevel.DEBUG, hotelIdSet);
        
        return hotelIdSet;
    }
    
   
}