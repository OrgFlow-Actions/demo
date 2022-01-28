public class LightningAccountController {    
    @AuraEnabled
    public static List<Contact> getContacts(Id recordId) {
        return [Select Id, FirstName, LastName, Email, Phone From Contact Where AccountId =: recordId];       
    }
    
    @AuraEnabled
    public static Account getAccountInfo(Id recordId) {
        Account acc = [Select Id, Name, CFEs_Implants_CM__c, 
                Account_Strategy_Implants__c, Implants_Potential_Year__c, ATL_ISUS_Potential_Year__c, share_of_potential_implants__c 
                FROM Account Where Id =: recordId];
        return acc;        
    }           
    
    @AuraEnabled
    public static String saveAccount(Id recordId, String Implants_potential) {
        system.debug(Implants_potential);
        String accId ='-';
        Integer ImplPot = Integer.valueOf(Implants_potential);
        Account acc = [SELECT Id, Implants_Potential_Year__c, ATL_ISUS_Potential_Year__c FROM Account WHERE Id=: recordId ];
        
        If(acc.Implants_Potential_Year__c != ImplPot){
        acc.Implants_potential_year__c = ImplPot;
        }

        
          try{              
          update acc;
          }
            catch (Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + ' ' + e.getStackTraceString();
            system.debug(errorMessage);                
            } 
        
        return accId;
    }
    
    @AuraEnabled
    public static Boolean getUserAccess(String ComponentName) {
    String userId = userinfo.getUserId();
    User activeUser = [SELECT Id, Username, Team_Setup_ID__c, User_Country_Text__c, SBU_Ratio_IMPL__c, SBU_Ratio_PREV__c FROM User Where Id =:userId];
        
    List<Country_metadata__mdt> activeCountry = [SELECT Component__c, Team_setup__r.Label, SBU__c, Country__c, Visible__c FROM Country_metadata__mdt WHERE (Team_setup__r.Label =: activeUser.Team_Setup_ID__c AND LightningComponent__r.Label =: ComponentName)];
        
    Boolean isVisible = false;   
        
        For (Country_metadata__mdt c: activeCountry){
          If (c.Visible__c){ 
                isVisible = true;
          }}
             
    return isVisible;
    }
    
    @AuraEnabled
    public static User getUserSBUAccess(String ComponentName) {
    String userId = userinfo.getUserId();
    User activeUser = [SELECT Id, Team_Setup_ID__c, SBU_Ratio_IMPL__c, SBU_Ratio_CERE__c, SBU_Ratio_ENDO__c, SBU_Ratio_IMAG__c, SBU_Ratio_INST__c, SBU_Ratio_ORTH__c, SBU_Ratio_PREV__c, 
                       SBU_Ratio_PROS__c, SBU_Ratio_REST__c, SBU_Ratio_TRCE__c FROM User Where Id =:userId];
    return activeUser;
    }
    
    @AuraEnabled
    public static User getUserInfo(Id recordId) {
    User activeUser = [SELECT Id, Username, FirstName, LastName, Team_Setup_ID__c FROM User Where Id =:recordId];
    return activeUser;
    }
    
    @AuraEnabled
    public static List<Team_setup__mdt> getTeamSetup() {
    String userId = userinfo.getUserId();
    User activeUser = [SELECT Id, Team_Setup_ID__c, User_Country_Text__c FROM User Where Id =:userId];
        
    List<Team_setup__mdt> activeSetup = [SELECT Label FROM Team_setup__mdt ORDER BY Label ASC NULLS LAST];
        
    return activeSetup;
    }
    
   @AuraEnabled
    public static String saveUser(User ThisUser) {
        system.debug(ThisUser);
        String accId ='-';
        
          try{              
          update ThisUser;
          accId = ThisUser.Id;
          }
            catch (Exception e){
            String errorMessage = 'Error: ' + e.getMessage() + ' ' + e.getStackTraceString();
            system.debug(errorMessage);                
            } 
        
        return accId;
    }
    
    
    
}