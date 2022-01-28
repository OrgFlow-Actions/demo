/*-------------------------------------------------------------------------------------------------------
Author:         Roberto Narbona 20210716
Description:    Mockup class for ProductPricingERPCallOutResponse calluts.

History:	Updated By:	Update Description:

----------------------------------------------------------------------------------------*/

@isTest
global class ProductPricingERPCallOutMock implements HttpCalloutMock {
  // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().endsWith('https://login.microsoftonline.com/bc74e59c-5fa3-4157-9c37-6e5063d11a62/oauth2/v2.0/token')) {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"token_type": "Bearer","expires_in": 3599,"ext_expires_in": 3599,"access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiJhcGk6Ly81N2NjNTQwNS1lZTlmLTQyZGEtYmE4ZC0zZGMyOWRlOTIyZTUiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9iYzc0ZTU5Yy01ZmEzLTQxNTctOWMzNy02ZTUwNjNkMTFhNjIvIiwiaWF0IjoxNjM0ODU1OTYxLCJuYmYiOjE2MzQ4NTU5NjEsImV4cCI6MTYzNDg1OTg2MSwiYWlvIjoiRTJaZ1lHaHVDWGwydHVIRWdSL1BPamkzL1Rza0FRQT0iLCJhcHBpZCI6IjU3Y2M1NDA1LWVlOWYtNDJkYS1iYThkLTNkYzI5ZGU5MjJlNSIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L2JjNzRlNTljLTVmYTMtNDE1Ny05YzM3LTZlNTA2M2QxMWE2Mi8iLCJvaWQiOiI1ZjNiNmE3My1lM2FhLTRjNmUtYTMxYS1mNGE2ZGU0OTQwMTAiLCJyaCI6IjAuQVE0QW5PVjB2S05mVjBHY04yNVFZOUVhWWdWVXpGZWY3dHBDdW8wOXdwM3BJdVVPQUFBLiIsInN1YiI6IjVmM2I2YTczLWUzYWEtNGM2ZS1hMzFhLWY0YTZkZTQ5NDAxMCIsInRpZCI6ImJjNzRlNTljLTVmYTMtNDE1Ny05YzM3LTZlNTA2M2QxMWE2MiIsInV0aSI6ImpxZUlrNXU1dDBhRjE0SDF6Q0ZaQUEiLCJ2ZXIiOiIxLjAifQ.YvG6eanyC09s3ysVo7Gn41S1HbrBKQQoFwnudM2zDA-ROqmK5W-UmAtb90Y9mkmREGb9b6lo5zNVtwtOqxf72pTrNwEU7MmNNdtGgC42MX22CDDPN26y7UIysB0zZS7RlJmmaq0rVIhmxBmdC5HnylpUrYv02KgbIBaabcmkuLZmgCR7aF3zZL5McoaqtHKWXxZV_09u48yzx8uHYQsH5f8e0zxEyBA2DLqj62kOhFhl06R3k9xqonWWJFud1RuWtm1YspYBiY3ALqrCaUlxsZzT2vRCkLcZDbtg3R4EgRSjb1dnOnKpoBp2ZGplmBPdhuim9HqlRNWu6FhZlWU9fA"}');
            response.setStatusCode(200);
            return response; 
        }else if (request.getEndpoint().endsWith('https://prod-22.southcentralus.logic.azure.com:443/workflows/b5c43fa071f8419a813802a22f157fb2/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0')) {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"entries": [{"productEntry": {"productId": "0520055","quantity": 1},"basePrice": 4.77,"retailPrice": 4.77}]}');
            response.setStatusCode(200);
            return response; 
            } else {
                return null;
            }
    }
}