@isTest
global class OpportunitySynchHttpCalloutMock implements HttpCalloutMock {
  // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{}');
        response.setStatusCode(204);
        return response; 
    }
}