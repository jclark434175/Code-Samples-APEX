/* 
 * Name: AVGContactGrid 
 * Description: Contains the details of a specialized AVG Contact grid, which 
 *              extends the AVG SOQL grid by folding in a 'Covered Flag' whose
 *              value modifies the SOQL query in a fairly non-trivial way.
 *
 * Confidential & Proprietary, 2009 Tier1CRM Inc.
 * Property of Tier1CRM Inc.
 * This document shall not be duplicated, transmitted or used in whole
 * or in part without written permission from Tier1CRM.
 */ 
public virtual class AVGContactGrid extends AVGSoqlGrid {

//  ==========================================
//  Instance variables (not bound to VF page).
//  ==========================================
    private String baseSObjType;
    private String baseWhereClause;
    private String sFilter='none';
    
//  ==========================================
//  Instance properties (bindable to VF page).
//  ==========================================

    public Boolean coveredFlag { 
        get;
        
        set {
            
//          Short-circuit if no change.
//          ---------------------------         
            if ( value == this.coveredFlag ) {
                return;
            }
            
            if ( value && ( this.coveredFlag == Null || this.coveredFlag == False ) ) {
                
//              Turning Coverage flag ON:  convert SOQL query to a relationship query
//              thru Contact_Coverage__c.
//              ---------------------------------------------------------------------               
                this.sobjType = 'Contact_Coverage__c';
                this.whereClause = this.whereClause.replace ( 'AccountId' , 'Contact__r.AccountId' )
                									.replace ( 'ST_Inactive__c' , 'Contact__r.ST_Inactive__c' )
                                    + ' and Employee__r.User__c = \'' + UserInfo.getUserId () + '\'';
                                        
                for ( AVGGridColumn col : this.cols ) {
                    String[] sfdcFlds = col.getSFDCFlds ();         
                    for ( Integer i = 0 ; i < sfdcFlds.size () ; i++ ) {
                        sfdcFlds[ i ] = 'Contact__r.' + sfdcFlds[ i ];
                    }
                    col.setSFDCFlds ( sfdcFlds );
                        
                    String sortFldName = col.getSortFld ();
                    if ( sortFldName != Null ) {
                        sortFldName = 'Contact__r.' + sortFldName;
                        col.setSortFld ( sortFldName );
                    }
                }
            }
            else if (!value && this.coveredFlag != Null && this.coveredFlag == True ) {

//              Turning Coverage flag OFF:  convert SOQL query back to a straight
//              query thru Contact.
//              -----------------------------------------------------------------               
                this.sobjType = this.baseSObjType;
                this.whereClause = this.baseWhereClause;
                    
                for ( AVGGridColumn col : this.cols ) {
                    String[] sfdcFlds = col.getSFDCFlds ();         
                    for ( Integer i = 0 ; i < sfdcFlds.size () ; i++ ) {
                        sfdcFlds[ i ] = sfdcFlds[ i ].replace ( 'Contact__r.' , '' );
                    }
                    col.setSFDCFlds ( sfdcFlds );

                    String sortFldName = col.getSortFld ();
                    if ( sortFldName != Null ) {
                        sortFldName = sortFldName.replace ( 'Contact__r.' , '' );
                        col.setSortFld ( sortFldName );
                    }
                }
            }
            
//          Save our state and refresh the instance's data payload.
//          -------------------------------------------------------
            coveredFlag = Value;
            this.refreshDataPayload ();
        }
    }
    //CIBC - Contact page
    public String Filter
    {
        get;
        set{sFilter=value;}
    }
    
    public PageReference filterContacts()
    {
                
        if(sFilter != 'none')
            this.whereClause = this.baseWhereClause + ' AND Decision_Maker_For__c includes (\''+ sFilter+ '\')';
        else
            this.whereClause = this.baseWhereClause;
        
        this.refreshDataPayload();      
        
        return null;
    } 
    //CIBC end
//  ============================================================================
//  Method: <constructor>
//
//  Desc:   Constructors.
//
//  Args:   title       - the grid title.
//          sobjType    - the SObject supplying the grid contents.
//          whereClause - the query clause of the underlying SOQL query.
//          cols        - List of AVGGridColumn objects defining the grid 
//                        columns.
//  ============================================================================                        
    public AVGContactGrid ( String title , String sobjType , String whereClause , AVGGridColumn[] cols ) {

        this.init ( title , sobjType , whereClause , cols );            
        this.refreshDataPayload ();
    }
    
    public AVGContactGrid () {
    }
    
//  ============================================================================
//  Method: init
//
//  Desc:   Initializes the grid object's instance variables.
//
//  Args:   title       - the grid title.
//          sobjType    - the SObject supplying the grid contents.
//          whereClause - the query clause of the underlying SOQL query.
//          cols        - List of AVGGridColumn objects defining the grid 
//                        columns.
//  ============================================================================                        
    public virtual override void init ( String title , String sobjType , String whereClause , AVGGridColumn[] cols ) {
        super.init ( title , sobjType , whereClause , cols );
            
        this.baseSObjType = sobjType;
        this.baseWhereClause = whereClause;
        this.coveredFlag = False;           
    }
    
}