/*-------------------------------------------------------------------------------------------------------
Author:         Ahmed loudrassi (Salesforce) 20200215
Description:    OrderManagementCmp Controller Class
Test Class:     Test_OrderManagement_CC
History:
210716          modified to support ERP callouts new methods added -> prodPricingERPCallOut, getSourceRecords
210426          modified getProducts() to return list ordered on Article__c
201015          Added readAccess check on getPriceBooks()
----------------------------------------------------------------------------------------*/
public with sharing class OrderManagement_CC {
    /*------------------------------------------------------------  
    Description:    Method to select the current User uITheme.
    Inputs:         
    ------------------------------------------------------------*/
    @AuraEnabled
    public static string uIThemeDisplayed(){
        try {
            return UserInfo.getUIThemeDisplayed();
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.uIThemeDisplayed');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to select the List of the active currencies related to a pricebook.
    Inputs:          @param ID pricebookId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<AggregateResult> getPriceBooksEntriesCurrencies(ID pricebookId) {
        try {
            return [SELECT CurrencyIsoCode FROM PricebookEntry
            WHERE Pricebook2Id = : pricebookId
            AND IsActive = true
            AND Product2.IsActive = true 
            GROUP BY CurrencyIsoCode];
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getPriceBooksEntriesCurrencies');
            throw new AuraHandledException(e.getMessage());    
        }
    }
     /*------------------------------------------------------------  
    Description:    Method to select the List of the active pricebooks except the Standard Pricebook.
    Inputs:         
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static List<PriceBook2> getPriceBooks() {
        try {
            Map<Id, Pricebook2> pricebookMap = new Map<Id, Pricebook2>([
                SELECT Id, Name, ShowPricingfromMicroServiceOM__c  
                FROM Pricebook2 
                WHERE IsActive = true AND Name != 'Standard Price Book' AND Name != 'Sirona Products' AND ObjectTypeUseOM__c != 'Opportunity'
                ORDER BY Name ASC
            ]);

            List<Pricebook2> pbWithReadAccessList = new List<Pricebook2>();
            for (UserRecordAccess recordAccess : [
                SELECT RecordId 
                FROM UserRecordAccess 
                WHERE UserId= :UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :pricebookMap.keySet() 
                LIMIT 200
            ]) {
                pbWithReadAccessList.add(pricebookMap.get(recordAccess.RecordId));
            }
            pbWithReadAccessList.sort();

            return pbWithReadAccessList;
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getPriceBooks');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to select the  total of the Order Items related to an order.
    Inputs:          @param orderId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static Integer getOrderItemsCounter(ID orderId) {
        try {
             return (Integer)((AggregateResult) Database.query('SELECT Count(Id) total FROM OrderItem WHERE OrderId =:orderId')).get('total');
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getOrderItemsCounter');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to select the Order Items List related to an order with server side pagination.
    Inputs:          @param orderId, @param pageNumber, @param pageSize
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<OrderItem> getOrderItems(ID orderId, Integer pageNumber, Integer pageSize) {
        try {
            return [SELECT Id, Quantity, AXRetailPrice__c, AXDiscount__c, TotalPrice, UnitPrice, Total_Line_Item_Price__c, DiscountedAmount__c, Free_Of_Charge__c,Free_of_Charge_Delivery__c,
            Product2.Name, Product2.Article__c, PricebookEntry.LocalProductDescription__c,
            Order.CurrencyIsoCode, Discount_Percent__c FROM OrderItem
            WHERE OrderId =:orderId 
            ORDER BY CreatedDate DESC
            LIMIT :pageSize OFFSET :(pageNumber-1)* pageSize];
       }
       catch (Exception e) {
        DebugLog.addException(e, 'OrderManagement_CC.');
           throw new AuraHandledException(e.getMessage());    
       }
    }
    /*------------------------------------------------------------  
    Description:    Method to delete an  Order Item by ID.
    Inputs:          @param orderItemId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static String deleteOrderItem(String orderItemId) {
        try {
            OrderItem orderItem = [SELECT Id FROM OrderItem WHERE ID =:orderItemId];
            delete orderItem;
            return 'SUCCESS';
        } catch(Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.deleteOrderItem');
            throw new AuraHandledException(e.getMessage());
            //return e.getMessage();
        }

    }
    /*------------------------------------------------------------  
    Description:    Method to select an  Order by ID.
    Inputs:          @param orderItemId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static Order getOrder(ID orderId) {
        try {
            return [
                SELECT 
                    Id
                    , AccountId
                    , CurrencyIsoCode
                    , ContractId
                    , Contract.Discount__c
               		, Distributor_email__c
                    , Contract.EndDate
                    , OrderNumber
                    , Pricebook2Id
                    , Pricebook2.ShowPricingfromMicroServiceOM__c
                    , Pricebook2.isActive
                    , Pricebook2.Show_Discount_OM__c
                    , Pricebook2.Show_FOC_OM__c
                    , Pricebook2.Show_OfferCode_OM__c
                    , Pricebook2.Show_Description_OM__c
                    , Pricebook2.Show_Price_OM__c
                    , Pricebook2.Pricebook_General_Discount__c
                    , Pricebook2.Automatically_Apply_Discount_OM__c
                    , Pricebook2.CompanyCode__c
                FROM Order 
                WHERE Id =: orderId
            ];
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getOrder');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    @AuraEnabled
    public static Order cloneOrder(ID orderId, String contractId) {
        try {
            Order order = [
                SELECT Id
                    , Contact__c
                    , Country__c
                    , Dealer__c
                    , Distributor__c
                    , Distributor_email__c
                    , RecordTypeId
                    , CurrencyIsoCode
                    , Pricebook2Id
                    , Pricebook2.ShowPricingfromMicroServiceOM__c
                    , AccountId
                    , OpportunityId
                    , ContractId
                    , Status
                    , ShippingCity
                    , ShippingCountry
                    , ShippingPostalCode
                    , ShippingState
                    , ShippingStreet
                    , Contract.EndDate
                    , Order_Type__c
                    , Order_subtype__c
                    , SourceRecord__c
                    , (
                        SELECT 
                            Id
                            , Quantity
                            , PricebookEntryId
                            , UnitPrice
                            , Free_Of_Charge__c
                            , Free_of_Charge_Delivery__c
                            , Product2.Name
                            , Product2.Article__c
                            , PricebookEntry.IsActive
                            , Order.CurrencyIsoCode
                            , Discount_Percent__c 
                        FROM OrderItems
                    ) 
                FROM Order
                WHERE Id =: orderId
            ];
            Order clonedOrder = order.clone();
            clonedOrder.EffectiveDate = Date.today();
            clonedOrder.Status = 'Created';
            if(String.isNotBlank(contractId)) {
                clonedOrder.ContractId = contractId;
            } else if(clonedOrder.Contract.EndDate < Date.today()) {
                clonedOrder.ContractId = null;
            }
            List<OrderItem> clonedOrderItems = order.OrderItems.deepClone();
            
            Set<ID> pricebookEntriesIds = new Set<ID>();
            List<OrderItem> clonedOrderItemsToInsert = new List<OrderItem> ();
            List <ProductPricingERPCallOutWrapper.ProductEntry> pricingProdsRequest = new List<ProductPricingERPCallOutWrapper.ProductEntry>();
            List <ProductPricingERPCallOutWrapper.ProductEntry> dupPricingProdsRequest = new List<ProductPricingERPCallOutWrapper.ProductEntry>();



            set<String> uniqueProds = new set<string>();
            set<String> dupProds = new set<string>();
            for(OrderItem orderItem : clonedOrderItems) {
                if(orderItem.PricebookEntry.IsActive && order.Pricebook2.ShowPricingfromMicroServiceOM__c == false) {
                    pricebookEntriesIds.add(orderItem.PricebookEntryId);
                } 
                
                if(orderItem.PricebookEntry.IsActive && order.Pricebook2.ShowPricingfromMicroServiceOM__c == true) {
                    ProductPricingERPCallOutWrapper.ProductEntry prodRequest = new ProductPricingERPCallOutWrapper.ProductEntry();
                    prodRequest.productId = orderItem.Product2.Article__c;
                    prodRequest.quantity = orderItem.Quantity.intValue();
                    if(uniqueProds.isEmpty() || ! uniqueProds.contains(orderItem.Product2.Article__c)){
                        uniqueProds.add(orderItem.Product2.Article__c);
                        pricingProdsRequest.add(prodRequest);
                    } else {
                        if(dupProds.isEmpty() || ! dupProds.contains(orderItem.Product2.Article__c)){
                            dupProds.add(orderItem.Product2.Article__c);
                            dupPricingProdsRequest.add(prodRequest);
                        }
                        /*
                        if (uniqueProds.contains(orderItem.Product2.Article__c)){
                            if(dupProds.isEmpty()){
                                dupProds.add(orderItem.Product2.Article__c);
                                dupPricingProdsRequest.add(prodRequest);
                            } else {
                                if (! dupProds.contains(orderItem.Product2.Article__c)){
                                    dupPricingProdsRequest.add(prodRequest);
                                    dupProds.add(orderItem.Product2.Article__c);
                                }
                            }
                        } else {
                            pricingProdsRequest.add(prodRequest);
                            uniqueProds.add(orderItem.Product2.Article__c);
                        }*/
                    }
                }
            }
            Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
            if(! pricebookEntriesIds.isEmpty()){
                for(PricebookEntry priceEntry : [SELECT Id,Product2Id, UnitPrice FROM PricebookEntry WHERE Id IN :pricebookEntriesIds]){
                    pricebookEntries.put(priceEntry.Id,priceEntry);
                }
            }
            ProductPricingERPCallOutWrapper.ProductPricingResponse prices = new ProductPricingERPCallOutWrapper.ProductPricingResponse();
            if(! pricingProdsRequest.isEmpty()){
                prices = ProdPricingERPCallOut(Order.Id, pricingProdsRequest );
                Integer i = 0;
                for(ProductPricingERPCallOutWrapper.Entries priceBack: prices.entries){
                    for(ProductPricingERPCallOutWrapper.ProductEntry prod: pricingProdsRequest){
                        if(priceBack.productEntry.productId == prod.productId ){
                            prices.Entries[i].productEntry.quantity = prod.Quantity;
                            continue;
                        }
                    }
                }
            }
            ProductPricingERPCallOutWrapper.ProductPricingResponse dupPrices = new ProductPricingERPCallOutWrapper.ProductPricingResponse();
            if(! dupPricingProdsRequest.isEmpty()){
                dupPrices = ProdPricingERPCallOut(Order.Id, dupPricingProdsRequest );
                Integer i = 0;
                for(ProductPricingERPCallOutWrapper.Entries priceBack: dupPrices.entries){
                    for(ProductPricingERPCallOutWrapper.ProductEntry prod: dupPricingProdsRequest){
                        if(priceBack.productEntry.productId == prod.productId ){
                            dupPrices.Entries[i].productEntry.quantity = prod.Quantity;
                            continue;
                        }
                    }
                }
                prices.entries.addAll(dupPrices.entries);
            }
            insert clonedOrder;
            for(OrderItem orderItem : clonedOrderItems) {
                
                if(orderItem.PricebookEntry.IsActive && order.Pricebook2.ShowPricingfromMicroServiceOM__c == false){
                    orderItem.OrderId = clonedOrder.Id;
                    PricebookEntry pricebookEntry = pricebookEntries.get(orderItem.PricebookEntryId);
                    orderItem.UnitPrice = pricebookEntry.UnitPrice;
                }
                if(orderItem.PricebookEntry.IsActive && order.Pricebook2.ShowPricingfromMicroServiceOM__c == true){
                    integer j=0;
                    for(ProductPricingERPCallOutWrapper.Entries price: prices.entries){
                        if(orderItem.Product2.Article__c == prices.Entries[j].productEntry.productId && orderItem.Quantity == prices.Entries[j].productEntry.quantity) {
                            orderItem.OrderId = clonedOrder.Id;
                            orderItem.UnitPrice = prices.Entries[j].basePrice;
                            orderItem.AXRetailPrice__c = prices.Entries[j].retailPrice;
                        }
                        j++;
                    }
                }
               /* } else{
                    orderItem.UnitPrice = prices.Entries[j].basePrice;
                    orderItem.AXRetailPrice__c = prices.Entries[j].retailPrice;
                }*/
                if(orderItem.OrderId == clonedOrder.Id){
                    clonedOrderItemsToInsert.add(orderItem);

                }
                
            }

            /*
            if(order.Pricebook2.ShowPricingfromMicroServiceOM__c == false){
                insert clonedOrder;
                for(OrderItem orderItem : clonedOrderItems) {
                    if(orderItem.PricebookEntry.IsActive ) {
                        orderItem.OrderId = clonedOrder.Id;
                        pricebookEntriesIds.add(orderItem.PricebookEntryId);
                        clonedOrderItemsToInsert.add(orderItem);
                    }
                }
                Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>
                    ([SELECT Id,Product2Id, UnitPrice FROM PricebookEntry WHERE Id IN :pricebookEntriesIds]);
                for(OrderItem orderItem : clonedOrderItemsToInsert) {
                    PricebookEntry pricebookEntry = pricebookEntries.get(orderItem.PricebookEntryId);
                    orderItem.UnitPrice = pricebookEntry.UnitPrice;
                }
            }
            //When ERP pricing callout is needed
            else{
                List <ProductPricingERPCallOutWrapper.ProductEntry> pricingProdsRequest = new List<ProductPricingERPCallOutWrapper.ProductEntry>();
                for(OrderItem orderItem : clonedOrderItems) {
                    if(orderItem.PricebookEntry.IsActive ) {
                        ProductPricingERPCallOutWrapper.ProductEntry prodRequest = new ProductPricingERPCallOutWrapper.ProductEntry();
                        prodRequest.productId = orderItem.Product2.Article__c;
                        prodRequest.quantity = orderItem.Quantity.intValue();
                        pricingProdsRequest.add(prodRequest);
                    }
                }
                If(!pricingProdsRequest.isEmpty()){
                    ProductPricingERPCallOutWrapper.ProductPricingResponse prices = ProdPricingERPCallOut(Order.Id, pricingProdsRequest );
                    insert clonedOrder;
                    for(OrderItem orderItem : clonedOrderItems) {
                        integer j=0;
                        for(ProductPricingERPCallOutWrapper.Entries price: prices.entries){
                            if(orderItem.PricebookEntry.IsActive  && (orderItem.Product2.Article__c == prices.Entries[j].productEntry.productId)) {
                                orderItem.OrderId = clonedOrder.Id;
                                orderItem.UnitPrice = prices.Entries[j].basePrice;
                                orderItem.AXRetailPrice__c = prices.Entries[j].retailPrice;
                                clonedOrderItemsToInsert.add(orderItem);
                            }
                            j++;
                        }
                        
                    }
                }
            }*/
            insert clonedOrderItemsToInsert;
            return  getOrder(clonedOrder.Id);
        }
        catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.cloneOrder');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to insert the Order Items List related to an order.
    Inputs:          @param orderItems
    ------------------------------------------------------------*/
    @AuraEnabled
    public static string insertOrderItems(List<OrderItem>  orderItems){
        try {
            upsert orderItems;
            return 'SUCCESS';
        }catch(Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.insertOrderItems');
            throw new AuraHandledException(e.getMessage());
            //return e.getMessage();
        }
    }
    @AuraEnabled
    public static OrderItem cloneOrderItems(Id orderItemId){
        try {
            List<OrderItem> orderItemToCloneList = [
                SELECT Id, Quantity, PricebookEntryId, UnitPrice, Free_Of_Charge__c, Product2.Name, Product2.Article__c, OrderId,
                PricebookEntry.IsActive, Order.CurrencyIsoCode, Discount_Percent__c, Order.Pricebook2.ShowPricingfromMicroServiceOM__c
                FROM OrderItem
                WHERE Id = :orderItemId
            ];
            List<OrderItem> clonedOrderItemList = orderItemToCloneList.deepClone();
            //microservice call out

            If(orderItemToCloneList[0].Order.Pricebook2.ShowPricingfromMicroServiceOM__c == true){
                List <ProductPricingERPCallOutWrapper.ProductEntry> pricingProdsRequest = new List<ProductPricingERPCallOutWrapper.ProductEntry>();
                ProductPricingERPCallOutWrapper.ProductEntry prodRequest = new ProductPricingERPCallOutWrapper.ProductEntry();
                prodRequest.productId = orderItemToCloneList[0].Product2.Article__c;
                prodRequest.quantity = orderItemToCloneList[0].Quantity.intValue();
                pricingProdsRequest.add(prodRequest);
                ProductPricingERPCallOutWrapper.ProductPricingResponse prices = new ProductPricingERPCallOutWrapper.ProductPricingResponse();
                prices = ProdPricingERPCallOut(orderItemToCloneList[0].OrderId, pricingProdsRequest);
                orderItemToCloneList[0].UnitPrice = prices.Entries[0].basePrice;
                orderItemToCloneList[0].AXRetailPrice__c = prices.Entries[0].retailPrice;

            }
            insert clonedOrderItemList;
            return clonedOrderItemList[0];
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.cloneOrderItems');
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to select a contracts List related to the parent(Account,Opportunity, Event, Lead)
                    filtred by currencyIsoCode and pricebook discount type.
    Inputs:          @param pricebookId, @param parentId, @param currencyIsoCode
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Contract> getContracts(String pricebookId, ID parentId, String currencyIsoCode) {
        try {
            Pricebook2 pricebook = [SELECT Id, Contract_Discount_types__c FROM Pricebook2 WHERE Id =: pricebookId];
            if(String.isNotEmpty(pricebook.Contract_Discount_types__c)) {
                String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
                String query = 'SELECT Id, Name, Discount__c, Discount_Type__c FROM Contract WHERE RecordType.DeveloperName=\'Contract\' AND Type_of_Contract__c = \'Contract\' AND Discount_Type__c = \'' + pricebook.Contract_Discount_types__c + '\'';
                Date todayDate = Date.today();
                query+= ' AND StartDate <= :todayDate AND EndDate >= :todayDate';
                if(String.isNotEmpty(currencyIsoCode)) {
                    query += ' AND CurrencyIsoCode =\'' + currencyIsoCode + '\''; 
                }
                if('Account'.equals(parentSObjectName)) {
                    query += ' AND AccountId =:parentId';                 
                } else if ('Opportunity'.equals(parentSObjectName)) {
                    Opportunity parent = [SELECT Id, AccountId FROM Opportunity WHERE Id=:parentId];
                    query += ' AND AccountId =\'' + parent.AccountId + '\'';
                }
                else if ('Field_Sales_Project_Members__c'.equals(parentSObjectName)) {
                    Field_Sales_Project_Members__c parent = [SELECT Id, Account__c FROM Field_Sales_Project_Members__c WHERE Id=:parentId];
                    query += ' AND AccountId =\'' + parent.Account__c + '\'';
                }
                else if ('Event'.equals(parentSObjectName)) {
                    Event parent = [SELECT Id, AccountId FROM Event WHERE Id=:parentId];
                    query += ' AND AccountId =\'' + parent.AccountId + '\'';
                }
                return Database.query(query);
            }
            return null;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getContracts');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to insert a related order to the parent(Opportunity, Event, Lead) related Account
    Inputs:          @param pricebookId, @param parentId, @param currencyIsoCode,  @param contractId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static Order createOrder(String pricebookId, ID parentId, String currencyIsoCode, String contractId, String sourceRecordId, string accountId) {
        try {
            Pricebook2 pricebook = [SELECT Id, PriceBook_Type__c, Pricebook_Subtype__c, Pricebook_Channel__c FROM Pricebook2 WHERE Id =:pricebookId];
            Order order = new Order();
            order.Pricebook2Id = pricebookId;
            order.Order_Type__c = pricebook.PriceBook_Type__c;
            order.Order_subtype__c = pricebook.Pricebook_Subtype__c;
            order.Status = 'Created';
            if ('Direct'.equals(pricebook.Pricebook_Channel__c)) {
                order.RecordTypeId = GlobalUtils.getRecordTypeId('Order', 'Direct_global_order');
            } else if ('Indirect'.equals(pricebook.Pricebook_Channel__c)) {
                order.RecordTypeId = GlobalUtils.getRecordTypeId('Order', 'Indirect_global_order');
            } else if ('Free Good Order'.equals(pricebook.Pricebook_Channel__c)) {
                order.RecordTypeId = GlobalUtils.getRecordTypeId('Order', 'Free_Good_Order');
            }
            order.CurrencyIsoCode = currencyIsoCode;
            order.EffectiveDate = Date.today();
            if (String.isNotEmpty(contractId)) {
                order.contractId = contractId;
            }
            String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
            if ('Account'.equals(parentSObjectName)) {
                order.AccountId = parentId;
            } else if ('Contact'.equals(parentSObjectName)) {
                Contact parent = [SELECT Id, AccountId FROM Contact WHERE Id=:parentId LIMIT 1];
                order.Contact__c = parent.Id;
                if(accountId != null ){
                    order.AccountId = accountId;
                } else {
                    order.AccountId = parent.AccountId;
                }
                
            } else if ('Opportunity'.equals(parentSObjectName)) {
                Opportunity parent = [SELECT Id, AccountId FROM Opportunity WHERE Id=:parentId LIMIT 1];
                order.OpportunityId = parent.Id;
                order.AccountId = parent.AccountId;
            } else if ('Field_Sales_Project_Members__c'.equals(parentSObjectName)) {
                Field_Sales_Project_Members__c parent = [SELECT Id, Account__c FROM Field_Sales_Project_Members__c WHERE Id=:parentId LIMIT 1];
                order.AccountId = parent.Account__c;
                order.SalesLead__c = parent.Id;
            } else if ('Event'.equals(parentSObjectName)) {
                Event parent = [SELECT Id, AccountId, Contact_Id__c, Orders_Related_to_CFE__c, Subject FROM Event WHERE Id=:parentId LIMIT 1];
                order.AccountId = accountId != null && accountId != '' ? accountId : parent.AccountId;
                
                order.Contact__c = parent?.Contact_Id__c != null ? parent?.Contact_Id__c : null;
                if (String.isNotBlank(parent.Orders_Related_to_CFE__c)) {
                    order.Orders_Related_to_CFE__c = parent.Orders_Related_to_CFE__c;
                } else {
                    Orders_Related_to_CFE__c orderRelatedToCFE = new Orders_Related_to_CFE__c(
                        Name = parent.Subject.length() > 80 ? parent.Subject.subString(0,80) : parent.Subject
                    );
                    insert orderRelatedToCFE;
                    parent.Orders_Related_to_CFE__c = orderRelatedToCFE.Id;
                    update parent;
                    order.Orders_Related_to_CFE__c = orderRelatedToCFE.Id;
                }
            }
            Account orderAccount = [SELECT Id, RecordType.DeveloperName, Country__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account WHERE Id = :order.AccountId LIMIT 1];
            order.ShippingCity = orderAccount?.BillingCity;
            order.ShippingCountry = orderAccount?.BillingCountry;
            order.ShippingPostalCode = orderAccount?.BillingPostalCode;
            order.ShippingState = orderAccount?.BillingState;
            order.ShippingStreet = orderAccount?.BillingStreet;
            order.Country__c = orderAccount?.Country__c;
            
            if(sourceRecordId != null && sourceRecordId.length() > 0 && orderAccount.RecordType.DeveloperName == 'CIM_Account'){ 
                order.SourceRecord__c=sourceRecordId;
            }
            insert order;
            return getOrder(order.Id);
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.createOrder');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    @AuraEnabled
    public static Integer getProductsCounter(ID pricebookId,ID parentId, String keywordSearch, String currencyIsoCode,
                                            String valueDesc1,  String valueDesc2,
                                             String valueDesc3,  String valueDesc4, Boolean superProducts) {
        try { 
            Set<ID> productsIds = new Set<ID>();                                         
            Set<Id> filteredProductsIds = new Set<Id>();
            if(superProducts) {
                productsIds = getSuperProducts(pricebookId, parentId, currencyIsoCode);
            } else {
                productsIds = getProductsIdsFromPriceBooksEntries(pricebookId, currencyIsoCode);  
            }
            String queryCounter = 'SELECT COUNT(Id) total  FROM Product2 WHERE Id IN  :productsIds';
            queryCounter += queryBuilder(pricebookId, parentId, keywordSearch,
            currencyIsoCode, valueDesc1, valueDesc2, valueDesc3, valueDesc4);
            if (String.isNotEmpty(keywordSearch)) {
                filteredProductsIds = getProductsIdsFromPriceBooksEntries(pricebookId, currencyIsoCode, keywordSearch);
            }
            String singleQuote = '\'';
            String filteredProducts = filteredProductsIds.isEmpty() ? '' : 'OR Id IN :filteredProductsIds';
            queryCounter = String.format(queryCounter, new List<Object>{singleQuote, filteredProducts});
            return (Integer)((AggregateResult) Database.query(queryCounter)).get('total');
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getProductsCounter');
            throw new AuraHandledException(e.getMessage());    
        }
    }

    public static Set<ID> getSuperProducts(ID pricebookId,ID parentId, String currencyIsoCode) {
        try {
            String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
            String accountId = '';
            if('Order'.equals(parentSObjectName)) {
                Order parent = [SELECT Id, AccountId FROM Order WHERE Id=:parentId];
                accountId = parent.AccountId;
            } else if('Account'.equals(parentSObjectName)) {
                accountId = parentId;
            } else if ('Opportunity'.equals(parentSObjectName)) {
                Opportunity parent = [SELECT Id, AccountId FROM Opportunity WHERE Id=:parentId];
                accountId = parent.AccountId;
            } else if ('Field_Sales_Project_Members__c'.equals(parentSObjectName)) {
                Field_Sales_Project_Members__c parent = [SELECT Id, Account__c FROM Field_Sales_Project_Members__c WHERE Id=:parentId];
                accountId = parent.Account__c;
            } else if ('Event'.equals(parentSObjectName)) {
                Event parent = [SELECT Id, AccountId FROM Event WHERE Id=:parentId];
                accountId = parent.AccountId;
            }
            List<AggregateResult> orderItemsProducts = [Select count(Id) orderItemNumber, PricebookEntry.Product2Id productId FROM OrderItem 
                                        WHERE PricebookEntry.Pricebook2Id = :pricebookId
                                        AND PricebookEntry.CurrencyIsoCode = :currencyIsoCode
                                        AND Order.AccountId = :accountId
                                        GROUP BY PricebookEntry.Product2Id];
            Set<ID> productsIds = new Set<ID>();
            for(AggregateResult orderItemProduct : orderItemsProducts) {
                productsIds.add((ID)orderItemProduct.get('productId'));
            }
            return productsIds;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getSuperProducts');
            throw new AuraHandledException(e.getMessage());    
        }                                                            
    }
    @AuraEnabled
    public static List<Product2> getProducts(ID pricebookId,ID parentId, String keywordSearch, String currencyIsoCode,
                                            String valueDesc1,  String valueDesc2,
                                             String valueDesc3,  String valueDesc4,
                                             Integer pageNumber, Integer pageSize, boolean superProducts) {
        try {
            Set<ID> productsIds = new Set<ID>();
            if(superProducts) {
                productsIds = getSuperProducts(pricebookId, parentId, currencyIsoCode);
            } else {
                productsIds = getProductsIdsFromPriceBooksEntries(pricebookId, currencyIsoCode);  
            }
            Set<Id> filteredProductsIds = new Set<Id>();                              
            String query = 'Select Id, Name, Article__c, GlobalSKUMapping__c,'
                            + ' (Select Id, UnitPrice, CurrencyIsoCode, LocalProductDescription__c, Product2.Article__c FROM PricebookEntries where Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode)';
            query += ' FROM Product2 WHERE Id IN  :productsIds';
            query += queryBuilder(pricebookId, parentId, keywordSearch, currencyIsoCode, 
            valueDesc1, valueDesc2, valueDesc3, valueDesc4);
            // if(superProducts) {
            //     query += ' ORDER BY Name DESC';
            // }
            query += ' ORDER BY Article__c';
            Integer offset = (pageNumber-1)*pageSize;
            query += ' LIMIT :pageSize OFFSET :offset';
            if (String.isNotEmpty(keywordSearch)) {
                filteredProductsIds = getProductsIdsFromPriceBooksEntries(pricebookId, currencyIsoCode, keywordSearch);
            }
            String singleQuote = '\'';
            String filteredProducts = filteredProductsIds.isEmpty() ? '' : ' OR Id IN :filteredProductsIds';
            query = String.format(query, new List<Object>{singleQuote, filteredProducts});
            return Database.query(query);
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getProducts');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    public static String queryBuilder(ID pricebookId,ID parentId, String keywordSearch, String currencyIsoCode,
                                String valueDesc1,  String valueDesc2,
                                String valueDesc3,  String valueDesc4) {                      
        try { 
            String queryFilter = ' AND isActive = true';
            if(String.isNotEmpty(keywordSearch)) {  
                keywordSearch = String.escapeSingleQuotes(keywordSearch);
                String regExp = '([^,]*){1}(,[^,]*)+';
                if(Pattern.matches(regExp, keywordSearch)) {
                    List<String> keywordsArticles = keywordSearch.replaceAll('\\s', '').split('\\,');
                    Boolean isFirst = true;
                    queryFilter += ' AND (';
                    for(String word : keywordsArticles) {
                        // word = '%' + word + '%'; // TFUS-000002897: Removed wild card matching
                        if(isFirst) {
                            isFirst = false;
                        } else {
                            queryFilter += ' OR';
                        }
                        queryFilter += ' Article__c LIKE {0}' + word+ '{0}';
                    }
                    queryFilter += ')';
                } else {
                    List<String> keywordsSplitted = keywordSearch.split('(\\+|\\s)');
                    for(String word : keywordsSplitted) {
                        word = '%' + word + '%';
                        queryFilter += ' AND (Name LIKE {0}'+ word + '{0} OR Article__c LIKE {0}' + word+ '{0}{1})';
                    }
                }
            }
            if (String.isNotEmpty(valueDesc1)) queryFilter += ' AND GlobalSKUMapping__r.PG1_Desc__c =:valueDesc1';
            if (String.isNotEmpty(valueDesc2)) queryFilter += ' AND GlobalSKUMapping__r.PG2_Desc__c =:valueDesc2';
            if (String.isNotEmpty(valueDesc3)) queryFilter += ' AND GlobalSKUMapping__r.PG3_Desc__c =:valueDesc3';
            if (String.isNotEmpty(valueDesc4)) queryFilter += ' AND GlobalSKUMapping__r.PG4_Desc__c =:valueDesc4';
            return  queryFilter;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.queryBuilder');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    @AuraEnabled
    public static String getSBUDescriptions(String pricebookId, ID parentId, String currencyIsoCode, Boolean superProducts){
        try {
                Set<ID> productsIds = new Set<ID> ();
            if(superProducts) {
                productsIds = getSuperProducts(pricebookId, parentId, currencyIsoCode);
            } else {
                productsIds = getProductsIdsFromPriceBooksEntries(pricebookId, currencyIsoCode);  
            }  
            List<Product2> products = [SELECT GlobalSKUMapping__c, GlobalSKUMapping__r.PG1_Desc__c, GlobalSKUMapping__r.PG2_Desc__c,GlobalSKUMapping__r.PG3_Desc__c,GlobalSKUMapping__r.PG4_Desc__c 
            FROM Product2 
            WHERE Id IN :productsIds];
            Description globalDescription = new Description();

            for(Product2 product : products) {
                if(String.isNotBlank(product.GlobalSKUMapping__r.PG1_Desc__c)) {
                    globalDescription.addRelatedDescription(product.GlobalSKUMapping__r.PG1_Desc__c, null);
                    if(String.isNotBlank(product.GlobalSKUMapping__r.PG2_Desc__c)) {
                        Description level1 = globalDescription.relatedDescriptions.get(product.GlobalSKUMapping__r.PG1_Desc__c);
                        level1.addRelatedDescription(product.GlobalSKUMapping__r.PG2_Desc__c, product.GlobalSKUMapping__r.PG1_Desc__c);
                        if(String.isNotBlank(product.GlobalSKUMapping__r.PG3_Desc__c)) {
                            Description level2 = level1.relatedDescriptions.get(product.GlobalSKUMapping__r.PG2_Desc__c);
                            level2.addRelatedDescription(product.GlobalSKUMapping__r.PG3_Desc__c, product.GlobalSKUMapping__r.PG2_Desc__c);
                            if(String.isNotBlank(product.GlobalSKUMapping__r.PG4_Desc__c)) {
                                Description level3 = level2.relatedDescriptions.get(product.GlobalSKUMapping__r.PG3_Desc__c);
                                level3.addRelatedDescription(product.GlobalSKUMapping__r.PG4_Desc__c, product.GlobalSKUMapping__r.PG3_Desc__c);
                            }
                        }
                    }
                }
            }
            return JSON.serialize(globalDescription);
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getSBUDescriptions');
            throw new AuraHandledException(e.getMessage());    
        }
    }
    /*------------------------------------------------------------  
    Description:    Method to select a pricebook related products IDs
    filtered by currencyIsoCode
    Inputs:          @param pricebookId  @param currencyIsoCode
    ------------------------------------------------------------*/
    private static Set<ID> getProductsIdsFromPriceBooksEntries(String pricebookId, String currencyIsoCode) {
        try {
            Set<ID> productsIds = new Set<ID> ();
            for(PriceBookEntry pricebookEntry : [SELECT Id, Product2Id FROM PriceBookEntry WHERE Pricebook2Id =: pricebookId AND CurrencyIsoCode =:currencyIsoCode AND isActive = true]) {
                productsIds.add(pricebookEntry.Product2Id);
            }
            return productsIds;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.');
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<ID> getProductsIdsFromPriceBooksEntries(String pricebookId, String currencyIsoCode, String keywordSearch) {
        try {
            String query = 'SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode AND LocalProductDescription__c != null';
            keywordSearch = String.escapeSingleQuotes(keywordSearch);
            String regExp = '([^,]*){1}(,[^,]*)+';
            if (!Pattern.matches(regExp, keywordSearch)) {
                List<String> keywordsSplitted = keywordSearch.split('(\\+|\\s)');
                for(String word : keywordsSplitted) {
                    word = '%' + word + '%';
                    query += ' AND LocalProductDescription__c LIKE \''+ word + '\'';
                }
                Set<ID> productsIds = new Set<ID> ();
                for (PricebookEntry pricebookEntry : (List<PricebookEntry>)Database.query(query)) {
                    productsIds.add(pricebookEntry.Product2Id);
                }
                return productsIds;
            } else {
                return new Set<Id>();
            }
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getProductsIdsFromPriceBooksEntries');
            throw new AuraHandledException(e.getMessage());    
        }
    }

    public class Description {
        Map<String, Description> relatedDescriptions;
        String parent;
        public void addRelatedDescription(String value, String parent) {
            if(this.relatedDescriptions == null) {
                this.relatedDescriptions = new Map<String, Description> ();
                this.parent = parent;
            }
            if(!this.relatedDescriptions.containsKey(value)) {
                this.relatedDescriptions.put(value, new Description());
            }
        }
    }



    /*------------------------------------------------------------  
    Description:    Method to select a Source Records List related to the parent(Account,Opportunity, Event, Lead)
                    filtred by accountID.
    Inputs:          @param parentId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<Source_Record__c> getSourceRecords(ID parentId, String pricebookId, String accountId) {
        try {
            List<Source_Record__c> sourceRecords = new List<Source_Record__c>();
            List<Pricebook2> pricebook = [SELECT Id, CompanyCode__c, SourceId__c, Pricebook_Channel__c FROM Pricebook2 WHERE SourceId__c = '2' AND Pricebook_Channel__c = 'Direct' AND Id =:pricebookId  LIMIT 1];
            if(pricebook.size() > 0 ){

                String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
                if('Account'.equals(parentSObjectName)) {
                    sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: parentId AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                } else if ('Opportunity'.equals(parentSObjectName)) {
                    Opportunity parentOpp = [SELECT Id, AccountId FROM Opportunity WHERE Id=:parentId];
                    sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: parentOpp.AccountId AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                } else if ('Field_Sales_Project_Members__c'.equals(parentSObjectName)) {
                    Field_Sales_Project_Members__c parentSalesLead = [SELECT Id, Account__c FROM Field_Sales_Project_Members__c WHERE Id=:parentId];
                    sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: parentSalesLead.Account__c AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                } else if ('Event'.equals(parentSObjectName)) {
                    Event parentEvent = [SELECT Id, WhatId FROM Event WHERE Id=:parentId];
                    sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: accountId AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                } else if ('Contact'.equals(parentSObjectName)) {
                    if(accountID != null){
                        sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: accountId AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                    }
                }
                /*
                sourceRecords = [SELECT Id, Combined_Fields__c FROM Source_Record__c WHERE CIM_Account__c =: parentId AND Source_Id__c = '2' AND Company_Code__c =: pricebook[0].CompanyCode__c];
                */
                //if(! sourceRecords.isEmpty() ){
                    return sourceRecords;
                //}
            }
            return null;
            
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getSourceRecords');
            throw new AuraHandledException(e.getMessage());    
        }
    }



    /*------------------------------------------------------------  
    Description:    Method to select a Source Records List related to the parent(Account,Opportunity, Event, Lead)
                    filtred by accountID.
    Inputs:          @param parentId
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<AccountContactRelation > getRelatedAccountsWithContact(ID parentId) {
        try {
            List<AccountContactRelation> relatedAccountsWithContact = new List<AccountContactRelation>();
            String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
            if('Contact'.equals(parentSObjectName)) {
                relatedAccountsWithContact = [SELECT AccountId,Account.Name, ContactId FROM AccountContactRelation WHERE ContactId =: parentId ];
                return relatedAccountsWithContact;
            } else {
                if('Event'.equals(parentSObjectName)) {
                    Event parentEvent = [SELECT Id, WhoId FROM Event WHERE Id =: parentId LIMIT 1];
                    String whoIdSObjectName = parentEvent.WhoId != null ? parentEvent.WhoId.getSObjectType().getDescribe().getName() :  null;
                    if(whoIdSObjectName != null && 'Contact'.equals(whoIdSObjectName)) {
                        relatedAccountsWithContact = [SELECT AccountId,Account.Name, ContactId FROM AccountContactRelation WHERE ContactId =: parentEvent.WhoId ];
                        return relatedAccountsWithContact;
                    }
                    
                }
                
            } 
            return null;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.getSourceRecords');
            throw new AuraHandledException(e.getMessage());    
        }
    }



    /* ERP pricing Callout method*/
    @AuraEnabled
    public static ProductPricingERPCallOutWrapper.ProductPricingResponse ProdPricingERPCallOut(ID parentId, list<ProductPricingERPCallOutWrapper.ProductEntry> prodPriceRequests ) {
        try {
            string codeERPId = '';
            order orderDetail = [SELECT Id, Account.GDWUniqueKey_CustomerMaster__c, Account.RecordTypeId, Account.RecordType.DeveloperName, SourceRecord__r.Customer_Id__c , CurrencyIsoCode , 	Pricebook2.CompanyCode__c FROM order WHERE Id =: parentId LIMIT 1];
            If(Schema.SObjectType.Account.getRecordTypeInfosById().get(orderDetail.Account.RecordTypeId).getDeveloperName() == 'CIM_Account'){
            //If(orderDetail.Account.RecordType.DeveloperName == 'CIM_Account'){
                
                codeERPId = orderDetail.SourceRecord__r.Customer_Id__c;
            }
            If(Schema.SObjectType.Account.getRecordTypeInfosById().get(orderDetail.Account.RecordTypeId).getDeveloperName() == 'ERP_Account'){
            //If(orderDetail.Account.RecordType.DeveloperName == 'ERP_Account'){
                List<string> codeERPSplit = orderDetail.Account.GDWUniqueKey_CustomerMaster__c.split('_');
                If(codeERPSplit[0] == '2'){
                    codeERPId = codeERPSplit[2];
                }                
            }
            ProductPricingERPCallOutWrapper.ProductPricingResponse priceResponse = ProductPricingERPCallOutResponse.ProductPricingERPCallOutResponse(codeERPId, orderDetail.CurrencyIsoCode, orderDetail.Pricebook2.CompanyCode__c , prodPriceRequests);
            return priceResponse;
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.ProdPricingERPCallOut');
            throw new AuraHandledException(e.getMessage());
        }
    }


    /* Get account record type */
    @AuraEnabled
    public static String getAccountRecordType( ID parentId) {
        try {
			String accountRecordTypeName = null;
            String parentSObjectName = parentId.getSObjectType().getDescribe().getName();
            if ('Account'.equals(parentSObjectName)) {
                Account accountDetails = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id=:parentId LIMIT 1];
                accountRecordTypeName = accountDetails.RecordType.DeveloperName;
            } else if ('Contact'.equals(parentSObjectName)) {
                Contact con = [SELECT Id, Account.RecordType.DeveloperName FROM Contact WHERE Id=:parentId LIMIT 1];
                accountRecordTypeName = con.Account.RecordType.DeveloperName;
                
            } else if ('Opportunity'.equals(parentSObjectName)) {
                Opportunity opp = [SELECT Id, Account.RecordType.DeveloperName FROM Opportunity WHERE Id=:parentId LIMIT 1];
                accountRecordTypeName = opp.Account.RecordType.DeveloperName;
            } else if ('Field_Sales_Project_Members__c'.equals(parentSObjectName)) {
                Field_Sales_Project_Members__c salesLead = [SELECT Id, Account__r.RecordType.DeveloperName FROM Field_Sales_Project_Members__c WHERE Id=:parentId LIMIT 1];
                accountRecordTypeName = salesLead.Account__r.RecordType.DeveloperName;
            } else if ('Event'.equals(parentSObjectName)) {
                Event ev = [SELECT Id, Account.RecordType.DeveloperName FROM Event WHERE Id=:parentId LIMIT 1];
                accountRecordTypeName = ev.Account.RecordType.DeveloperName;
            }
            return accountRecordTypeName;
        
        } catch (Exception e) {
            DebugLog.addException(e, 'OrderManagement_CC.ProdPricingERPCallOut');
            throw new AuraHandledException(e.getMessage());
        
        }
    }


    
}