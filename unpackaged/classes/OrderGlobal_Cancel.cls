//Author: Richard Trum (2017-06-19)

public without sharing class OrderGlobal_Cancel
{    
    public Order CurRec {get; set;}
    public String CurRecId {get; set;}
    
    public OrderGlobal_Cancel(ApexPages.StandardController stdController)
    {        
        CurRecId = ApexPages.CurrentPage().getParameters().get('id');
        CurRec = [SELECT Id, Status, Note_for_canceled_orders__c FROM Order WHERE Id =: CurRecId];        
    }
        
    public pageReference save() {
       
    CurRec.Status = 'Rejected';
        
    try{
    upsert CurRec;
    }
        catch(Exception ex){
        ApexPages.addMessages(ex);
        }
        
    pagereference p = new pagereference('/' + CurRec.Id);
    return p;

    }
    
       
    }