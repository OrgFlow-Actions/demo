public class ServiceCloud_FlowLookupController_ver2 {
    
    @AuraEnabled 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText, String fld_API_Rel ){
        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';

        
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+' ,' + fld_API_Rel + 
                        ' FROM '+objectName+
                            ' WHERE '+fld_API_Search+' LIKE '+searchText+
                         +' ORDER BY ' + fld_API_Rel + ' ASC '+
                        ' LIMIT '+lim;
        
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            obj.val = String.valueOf(s.get(fld_API_Val))  ;
            obj.related = String.valueOf(s.get(fld_API_Rel));
            lstRet.add(obj);
        } 
         return JSON.serialize(lstRet);
    }
    
    @AuraEnabled 
    public static String searchDBexact(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim,String fld_API_Search,String searchText, String fld_API_Rel ){
        
         searchText='\'' + searchText + '\'';

        
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+' ,' + fld_API_Rel + 
                        ' FROM '+objectName+
                            ' WHERE '+fld_API_Search+'='+searchText+
                         +' ORDER BY ' + fld_API_Rel + ' ASC '+
                        ' LIMIT '+lim;
        
        List<sObject> sobjList = Database.query(query);
         return JSON.serialize(sobjList) ;
    }
    
    
    
    @AuraEnabled
    public static Case getCaseInfo(String recordId){
    Case res = [SELECT Id, Subject, ContactId, AccountId FROM Case WHERE Id =: recordId];     
    return res;
        
    }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        public String related{get;set;}
    }   
    
}