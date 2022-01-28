public  class EinsteinAPIService {


    public static FINAL STRING OAUTH_END_POINT = 'https://api.einstein.ai/v2/oauth/token';

    public static String imageOCR(String endPoint, String sample, String model, boolean isBase64, boolean isCard){
        String result = einsteinAPICall(endPoint, sample, model, isBase64, isCard);
        return result;
    }
    public static String predictImage(String endPoint, String sample, String model, boolean isBase64, boolean isCard){
        String result = einsteinAPICall(endPoint, sample, model, isBase64, isCard);
        return result;
    }

    private static String einsteinAPICall(String endPoint, String sample, String model, boolean isBase64, boolean isCard) {
        string contentType = HttpFormBuilder.GetContentType();
        String access_token = EinsteinAPIAuthenticationHandler.getAccessToken('richard_trum');
        
        //  Compose the form
        string form64 = '';
		
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        if(isCard){
            form64 += HttpFormBuilder.WriteBodyParameter('task', EncodingUtil.urlEncode('contact', 'UTF-8'));
            form64 += HttpFormBuilder.WriteBoundary();
        }
        if(isBase64) {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', sample);
        } else {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', sample);
        }
        
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(endPoint);

        Http http = new Http();

        if(!Test.isRunningTest()){
            try {
                HTTPResponse res = http.send(httpRequest);
                System.debug(System.LoggingLevel.DEBUG, ' Response From Einstein Platform API '+res.getBody());
                if (res.getStatusCode() == 200) {
                    return res.getBody();
                }
            } catch(System.CalloutException e) {
                System.debug('ERROR:' + e);
                return e.getStackTraceString();
            }
        }
        else{

            String fakeResponse = '{"object":"predictresponse","probabilities":[{"probability":0.78376186,"label":"TOOLS","boundingBox":{"minX":72,"minY":130,"maxX":134,"maxY":146},"attributes":{"tag":"ORG","pageNumber":"1"}},{"probability":0.78376186,"label":"Firstname Lastname","boundingBox":{"minX":72,"minY":130,"maxX":134,"maxY":146},"attributes":{"tag":"PERSON","pageNumber":"1"}},{"probability":0.78376186,"label":"invalid@dentsplysirona.com","boundingBox":{"minX":72,"minY":130,"maxX":134,"maxY":146},"attributes":{"tag":"EMAIL","pageNumber":"1"}},{"probability":0.78376186,"label":"031-2342352","boundingBox":{"minX":72,"minY":130,"maxX":134,"maxY":146},"attributes":{"tag":"PHONE","pageNumber":"1"}}]}';
            return fakeResponse; 

        }
        return null;
    }
}