public abstract class WebApi {
    
    protected String ipPort;
    protected String computerLogin;
    protected String userId;
    
    public WebApi()
    {
        this.computerLogin = '';
    }

    public abstract void getRequiredInfo();
    
    public abstract String buildLogEventJson();
    
    // parses the LogEvent Response JSON
    public static Map<String, String> parseLogEventPayload( String response )
    {
        Map<String, String> res = new Map<String, String>();
        JSONParser parser = JSON.createParser( response );
        
        while( parser.nextToken() != null )
        {
            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) 
            {
                String fieldName = parser.getText();
                parser.nextToken();
                
                if ( fieldName == 'responseCode' )
                {
                    String responseCode = String.valueOf( parser.getIntegerValue() );
                    res.put( 'responseCode', responseCode );
                }
            }
        }
        
        return res;
    }

  	@future (callout=true)
  	public static void doLogEventCalloutFromFuture(String jsonPayload) 
    {
        System.debug('Starting future callout with payload ' + jsonPayload);
		try 
        {
            System.debug( 'Salesforce WebApi Integration started... doLogEventCalloutFromFuture() called' );
            
            Http http = new Http();
            String url = EncoreConfiguration.getWebApiEndpoint();
            String endpoint = url + '/WebAPI/EcapiJson.svc/LogEvent/';
            
            System.debug('endpoint = ' + endpoint);
            HttpRequest req = new HttpRequest();
            req.setHeader( 'Content-Type', 'application/json' ); 
            req.setEndpoint( endpoint );
            req.setMethod( 'POST' );
            req.setBody( jsonPayload );
            req.setCompressed( false );
            
            HttpResponse response = http.send( req );
            
            System.debug('HttpResponse = ' + response);        
            Map<String, String> result = parseLogEventPayload(response.getBody());
            
            System.debug('result.responseCode = ' + result.get('responseCode'));
            
            if ( result.get('responseCode') != null && Integer.valueOf( result.get('responseCode') ) == 100 )
            {
                System.debug( 'LogEvent was successful' );
            }
            else
            {
                System.debug('RESULT = ' + result);
                System.debug( 'An error occured while processing an LogEvent request responseCode = ' + 
                             result.get('responseCode') + ' responseStatus = ' + response.getStatus() );
            }
        } 
        catch (Exception ex)
        {
            System.debug( 'Validation Error: We did not send the request because we are missing required Data' );
        }
    }
    
    public Object doLogEventCallout() 
    {
     	try 
        {
            getRequiredInfo();
            String json = buildLogEventJson();
            WebApi.doLogEventCalloutFromFuture(json);
        }
        catch (Exception ex)
        {
            System.debug( 'Validation Error: We did not send the request because we are missing required Data' );
            return null;
        }
        
        return null;
    }
    
}