public class EncoreConfiguration {
    
    public static String getWebApiEndpoint()
    {

        Encore_Configuration__mdt[] encoreConfiguration = 
            [SELECT Encore_configuration_value__c FROM Encore_Configuration__mdt WHERE DeveloperName = 'WebAPI_Endpoint'];
       
        if ( encoreConfiguration.size() > 0 )
        {
            System.debug('WebAPI_EndPoint=' + encoreConfiguration[0].Encore_configuration_value__c );

            return encoreConfiguration[0].Encore_configuration_value__c;
        }
        else
        {
            System.debug('getWebApiEndpoint() was unable to get the WebAPI_EndPoint');
            throw new RequiredInfoException();
        }
               
    }
    
}