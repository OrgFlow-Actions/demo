/*-------------------------------------------------------------------------------------------------------
Author:         Roberto Narbona 20210716
Description:    This is a class created to be used for ERP call out

History:	Updated By:	Update Description:

----------------------------------------------------------------------------------------*/

public with sharing class ProductPricingERPCallOutResponse {
    public static ProductPricingERPCallOutWrapper.productPricingResponse  ProductPricingERPCallOutResponse(string accERPId, string currencyCode, string companyCode, List<ProductPricingERPCallOutWrapper.ProductEntry> productsForPricing) {
        String strJson = '';
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField('accountId', accERPId); //query in source records to get AX ID
        jsGen.writeStringField('currency', currencyCode);
        jsGen.writeStringField('dataAreaId', companyCode); //AX company that only is expose so it could be hard coded but also we should be able to get it from products company code field
        jsGen.writeFieldName('entries');
        jsGen.writeStartArray();

        for(ProductPricingERPCallOutWrapper.ProductEntry prod :productsForPricing){ //loop of products that we need to get
            jsGen.writeStartObject();
            jsGen.writeStringField('productId', prod.productId); //Article__c in products
            if(prod.quantity > 1){
                jsGen.writeNumberField('quantity', prod.quantity ); //Quanty of produts to get price
            } else{
                jsGen.writeNumberField('quantity', 1); //Quanty of produts to get price
            }            
            jsGen.writeEndObject();
        }
        jsGen.writeEndArray();
        jsGen.writeEndObject();
        strJson = jsGen.getAsString();
        
        //MicroServiceCallOut__c calloutDetail = [SELECT Client_ID__c, Logic_Apps_URL__c, Scope__c, Secret_Id__c, TokenURL__c FROM MicroServiceCallOut__c];
        PricingMicroServiceCallOut__mdt calloutDetail = [SELECT Client_ID__c, Logic_Apps_URL__c, Scope__c, Secret_Id__c, TokenURL__c FROM PricingMicroServiceCallOut__mdt Limit 1];
        //Callout to get token ID   
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(calloutDetail.TokenURL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        req.setBody('grant_type=client_credentials&response_type=token&scope=' + calloutDetail.Scope__c +'&client_id=' + calloutDetail.Client_ID__c +'&client_secret=' + calloutDetail.Secret_Id__c);
        HttpResponse res = h.send(req);
        ProductPricingERPCallOutWrapper.DeserializeTokenResponse resp1 = (ProductPricingERPCallOutWrapper.DeserializeTokenResponse)JSON.deserialize(res.getbody(),ProductPricingERPCallOutWrapper.DeserializeTokenResponse.class);
        //Real callout to Logic Apps
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(calloutDetail.Logic_Apps_URL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader( 'Authorization', 'Bearer ' +resp1.access_token );
            // Set the body as a JSON object
        request.setBody(strJson);
        HttpResponse response = http.send(request);

        
        ProductPricingERPCallOutWrapper.ProductPricingResponse prodResponse = (ProductPricingERPCallOutWrapper.ProductPricingResponse)JSON.deserialize(response.getBody(), ProductPricingERPCallOutWrapper.ProductPricingResponse.class);
        return(prodResponse);
    }
}