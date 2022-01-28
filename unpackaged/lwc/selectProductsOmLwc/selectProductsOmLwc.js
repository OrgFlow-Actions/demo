import { LightningElement, track, api, wire} from 'lwc';
import { showToast } from 'c/utils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRICE_BOOK_ENTRY_OBJECT from '@salesforce/schema/OrderItem';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import ORDER_ITEM_OBJECT from '@salesforce/schema/OrderItem';

//Apex Controllers
import getProducts from '@salesforce/apex/OrderManagement_CC.getProducts';
import getProductsCounter from '@salesforce/apex/OrderManagement_CC.getProductsCounter';
import getSBUDescriptions from '@salesforce/apex/OrderManagement_CC.getSBUDescriptions';
import insertOrderItems from '@salesforce/apex/OrderManagement_CC.insertOrderItems';
import getPriceCall from '@salesforce/apex/OrderManagement_CC.ProdPricingERPCallOut';

//Custom Labels
import OMNotERPPriceFound from '@salesforce/label/c.OMNotERPPriceFound';
import OMNotERPProductFound from '@salesforce/label/c.OMNotERPProductFound';
import previous from '@salesforce/label/c.OM_Previous';
import next from '@salesforce/label/c.OM_Next';
import searchProductsInstruction from '@salesforce/label/c.OM_Search_Products_Instruction';
import productSearchPlaceHolder from '@salesforce/label/c.OM_Product_Search_Placeholder';
import showMoreOrdredProducts from '@salesforce/label/c.OM_Show_Frequently_Ordered_Products';
import productsFound from '@salesforce/label/c.OM_Products_Found';
import productsSelected from '@salesforce/label/c.OM_Products_Selected';
import addProducts from '@salesforce/label/c.OM_Add_Products';
import selectProductMessage from '@salesforce/label/c.OM_Select_Product_Message';
import orderItemsCreatedSuccessfully from '@salesforce/label/c.OM_Order_Item_Created_Success';
import productGroupOneDescription from '@salesforce/label/c.OM_Product_Group_1_Description';
import productGroupTwoDescription from '@salesforce/label/c.OM_Product_Group_2_Description';
import productGroupThreeDescription from '@salesforce/label/c.OM_Product_Group_3_Description';
import productGroupFourDescription from '@salesforce/label/c.OM_Product_Group_4_Description';
import quantity from '@salesforce/label/c.OM_Quantity';
import uIThemeDisplayed from '@salesforce/apex/OrderManagement_CC.uIThemeDisplayed';
export default class SelectProductsOmLwc extends LightningElement {
    @api userUiTheme;
    @api order;
    @api parentId;
    @track orderItems;
    @track prodPriceRequests;//used for pricing callout
    @track AXPrices;
    @track totalProducts = 0;
    @track columns;
    @track keywordSearch;
    @track pageSize = 25;
    @track defaultPage = 1;
    @track pageNumber = 1;
    @track defaultValue = '';
    @track globalDescription;
    @track noneLabel = '—None—';
    @track hideFilter = true;
    @track valueDesc1 = this.defaultValue;
    @track valueDesc2 = this.defaultValue;
    @track valueDesc3 = this.defaultValue;
    @track valueDesc4 = this.defaultValue;
    @track descriptions = [[], [], [], []];
    @track loading = true;
    @track labels = {
        OMNotERPPriceFound,
        OMNotERPProductFound,
        previous, 
        next, 
        searchProductsInstruction, 
        addProducts, 
        selectProductMessage,
        productSearchPlaceHolder, 
        showMoreOrdredProducts, 
        productsFound,
        productsSelected,
        orderItemsCreatedSuccessfully,
        productGroupOneDescription,
        productGroupTwoDescription,
        productGroupThreeDescription,
        productGroupFourDescription,
        quantity,
    };
    @track superProducts = false;
    // new
    @track searchThrottlingTimeout;
    @track mouseOverTimeOut;
    @track popOverFields = ['SBU_Description__c', 'GPP_Desc__c', 'PG1_Desc__c', 'PG2_Desc__c', 'PG3_Desc__c', 'PG4_Desc__c'];
    @track priceBookEntryObjectInfo;
    @track productObjectInfo;
    @track orderItemObjectInfo;
    @track selectAll = false;

    connectedCallback() {
        this.getProductsCounter();
        this.getSBUDescriptions();
    }

    @wire(getObjectInfo, { objectApiName: PRICE_BOOK_ENTRY_OBJECT })
    priceBookEntryObjectInfo;

    get priceBookEntryUnitPriceLabel() {
        const data = this.priceBookEntryObjectInfo.data;
        return data ? data.fields.UnitPrice.label : '';
    }
    
    // get priceBookEntryLocalProductDescriptionLabel() {
    //     return this.priceBookEntryObjectInfo ? this.priceBookEntryObjectInfo.data.fields.LocalProductDescription__c.label : '';
    // }

    @wire(getObjectInfo, { objectApiName: ORDER_ITEM_OBJECT })
    orderItemObjectInfo;
    get orderItemRetailPriceLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.AXRetailPrice__c.label : '';
    }
    
    get orderItemUnitPriceLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.UnitPrice.label : '';
    }

    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productObjectInfo;

    

    get productArticleNumberLabel() {
        const data = this.productObjectInfo.data;
        return data ? data.fields.Article__c.label : '';
    }

    handleSuperProductsChange() {
        this.pageNumber = this.defaultPage;
        this.superProducts = !this.superProducts;
        this.getProductsCounter();
        this.getSBUDescriptions();
    }
    async getProducts() {
        try{
            const result= await getProducts({pricebookId : this.order.Pricebook2Id,
                parentId : this.parentId,
                currencyIsoCode : this.order.CurrencyIsoCode,
                keywordSearch : this.keywordSearch,
                valueDesc1 : this.valueDesc1,
                valueDesc2 : this.valueDesc2,
                valueDesc3 : this.valueDesc3,
                valueDesc4 : this.valueDesc4,
                pageNumber : this.pageNumber,
                pageSize : this.pageSize,
                superProducts : this.superProducts});
                let products = result;
                this.orderItems = [];
                this.prodPriceRequests = [];
                //microservice prices callout
                if(products.length > 0 && this.order.Pricebook2.ShowPricingfromMicroServiceOM__c) {
                    for(let i = 0; i < products.length; i++) {
                        let prodPriceRequest = { productId : products[i].Article__c,
                            quantity : 1}
                        this.prodPriceRequests.push(prodPriceRequest);
                    }
                    this.AXPrices = await this.getPriceCall2(this.prodPriceRequests);
                }

                if(products.length > 0) {
                    for(let i = 0; i < products.length; i++) {
                        let foundInAX;
                        if(this.AXPrices){
                            foundInAX = this.AXPrices.find(element => products[i].Article__c === element.productEntry.productId);
                            if( foundInAX === undefined ){ //When product is not found in ERP side
                                foundInAX = {retailPrice : this.labels.OMNotERPProductFound,
                                             basePrice: this.labels.OMNotERPProductFound,
                                             disableSelectedAndQuantityBox: true
                                             }
                            }
                            if( foundInAX.basePrice === 0 ){ //When product is found but price does not exist in ERP side
                                foundInAX = {retailPrice : this.labels.OMNotERPPriceFound,
                                             basePrice: this.labels.OMNotERPPriceFound,
                                             disableSelectedAndQuantityBox: true
                                             }
                            }
                            
                        }
                        if (this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && ! this.AXPrices) {
                            foundInAX = {retailPrice : this.labels.OMNotERPProductFound,
                                basePrice: this.labels.OMNotERPProductFound,
                                disableSelectedAndQuantityBox: true
                                }
                        }
                        let orderItem = {OrderId : this.order.Id,
                                        PricebookEntryId : products[i].PricebookEntries[0].Id,
                                        Product2Id : products[i].Id,
                                        Quantity : this.isMobile ? 0 : this.defaultValue,
                                        Free_Of_Charge__c :false,
                                        Article__c : products[i].Article__c,
                                        Name : products[i].Name,
                                        //UnitPrice : this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && foundInAX ? foundInAX.basePrice : products[i].PricebookEntries[0].UnitPrice,
                                        UnitPrice : this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && foundInAX ? foundInAX.basePrice : products[i].PricebookEntries[0].UnitPrice,
                                        
                                        AXRetailPrice__c : this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && foundInAX ? foundInAX.retailPrice : null,
                                        AXDiscount__c : this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && foundInAX.basePrice > 0 ? 100 * (1 - ( foundInAX.basePrice / foundInAX.retailPrice )) : 0,
                                        Currency : products[i].PricebookEntries[0].CurrencyIsoCode,
                                        LocalProductDescription__c : products[i].PricebookEntries[0].LocalProductDescription__c,
                                        Description : this.defaultValue,
                                        Offer_Code_dna__c : null,
                                        isMouseOver: false,
                                        isSelected : false,
                                        GlobalSKUMapping__c: products[i].GlobalSKUMapping__c ? products[i].GlobalSKUMapping__c : products[i].Id,
                                        disabledFields : true,
                                        disableSelectedAndQuantityBox : foundInAX && foundInAX.disableSelectedAndQuantityBox  ? foundInAX.disableSelectedAndQuantityBox : false

                                    };
                        
                        if(this.order.Pricebook2.Automatically_Apply_Discount_OM__c) {
                            orderItem.Discount_Percent__c = this.order.Contract ? this.order.Contract.Discount__c : this.order.Pricebook2.Pricebook_General_Discount__c;
                        }        
                        this.orderItems.push(orderItem);
                    }
                }
                this.loading = false;

        } catch (error){
            this.loading = false;
                showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
        }
    }


    async getPriceCall2(prodsAXRequest){
        try{
            const prices = await getPriceCall({parentId : this.order.Id,
                prodPriceRequests : prodsAXRequest});
                //this.loading = false;
            return prices.entries;
        } catch (error){
            this.loading = false;
            showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
        }
    }
 
    getProductsCounter() {
        this.loading = true;
        getProductsCounter({pricebookId : this.order.Pricebook2Id,
                     parentId : this.parentId,
                     currencyIsoCode : this.order.CurrencyIsoCode,
                     keywordSearch : this.keywordSearch,
                     valueDesc1 : this.valueDesc1,
                     valueDesc2 : this.valueDesc2,
                     valueDesc3 : this.valueDesc3,
                     valueDesc4 : this.valueDesc4,
                     superProducts : this.superProducts})
			.then(result => {
                this.totalProducts = result;
                this.getProducts();
			})
			.catch(error => {
                this.loading = false;
				showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
			});
    }


    async insertOrderItems() {
        try{
            this.loading = true;
            let orderItems = await this.getOrderItems();
            if(orderItems.length > 0) {
                const result = await insertOrderItems({orderItems : orderItems});
                if(result === 'SUCCESS') {
                    this.goToOrderItems();
                    showToast(this, this.userUiTheme, 'Success', orderItems.length + ' ' + this.labels.orderItemsCreatedSuccessfully, 'success');
                } else {
                    showToast(this, this.userUiTheme, 'ERROR', result, 'error');
                }
                this.loading = false;
            }
            console.log('hola 22' +this.loading);
        }
        catch (error){
            showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        }
    }



    getSBUDescriptions() {
        getSBUDescriptions({pricebookId : this.order.Pricebook2Id,
                            currencyIsoCode : this.order.CurrencyIsoCode,
                            parentId : this.parentId,
                            superProducts : this.superProducts})
        .then(result => {
            this.globalDescription = JSON.parse(result);
            let level1 = this.globalDescription.relatedDescriptions;
            this.getDescriptions(level1, this.descriptions, 3);
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
        });
    }
    getDescriptions(level, arr, deep){
        this.fillDescriptions(level, arr, deep);
        for(let i = 0; i < this.descriptions.length; i++) {
            this.descriptions[i].sort(function (a, b) {
                return a.toLowerCase().localeCompare(b.toLowerCase());
            });
            this.descriptions[i] = [...new Set(this.descriptions[i])];
        }
    }
    fillDescriptions(level, arr, deep) {
        if(deep >= 0) {
            for(let key in level) {
                if (level.hasOwnProperty(key)) {
                    arr[deep].push(key)
                    if(level[key].relatedDescriptions) {
                        this.fillDescriptions(level[key].relatedDescriptions, arr, deep - 1);
                    }
                }
            }
        }
    }
    handleSearchTermChange(event) {
        this.keywordSearch = event.target.value;
        if (this.keywordSearch.length !== 1) {
            this.pageNumber = this.defaultPage;
            if (this.searchThrottlingTimeout) clearTimeout(this.searchThrottlingTimeout);
            this.searchThrottlingTimeout = setTimeout(() => {
                this.getProductsCounter();
                this.searchThrottlingTimeout = null;
            }, 300);
        }
    }
    handleSave() {
        this.insertOrderItems();
    }
    handleSelectChange(event) {
        const index = event.target.dataset.index;
        const isSelected = event.target.checked;
        this.selectChangeHelper(index, isSelected);
        this.selectAll = this.orderItems.every(orderItem => orderItem.isSelected);
    }
    handleSelectAllChange() {
        this.selectAll = !this.selectAll;
        for (let i = 0; i < this.orderItems.length; i++) {
            if(! this.orderItems[i].disableSelectedAndQuantityBox){
                this.selectChangeHelper(i, this.selectAll);
            }            
        }
    }
    selectChangeHelper(index, isSelected) {
        this.orderItems[index].isSelected = isSelected;
        this.orderItems[index].disabledFields = !this.orderItems[index].isSelected;
        this.orderItems[index].Quantity = isSelected ? 1 : this.defaultQuantityValue;
        this.orderItems[index].Description = this.defaultValue;
        this.orderItems[index].Offer_Code_dna__c = null;
        this.orderItems[index].Free_Of_Charge__c =false;
    }
    get productsCounter() {
        const selectedProducts = this.orderItems ? this.orderItems.filter(orderItem => orderItem.isSelected).length : 0;
        return selectedProducts === 0 ? `${this.totalProducts} ${this.labels.productsFound}` : `${selectedProducts} ${this.labels.productsSelected}`;
    }
    handleDescriptionChange(event) {
        this.orderItems[event.target.dataset.index].Quantity = event.target.value;
    }
    handleFOCChange(event) {
        this.orderItems[event.target.dataset.index].Free_Of_Charge__c = event.target.value;
    }
    handleQuantityChange(event) {
        let quantity = event.target.value;
        let index = event.target.dataset.index;
        if(quantity > 0) {
            this.orderItems[index].Quantity = quantity;
        } else {
            this.orderItems[index].Quantity = this.defaultQuantityValue;
            this.orderItems[index].Description = this.defaultValue;
            this.orderItems[index].Offer_Code_dna__c = null;
        }
        this.orderItems[index].isSelected = (quantity > 0);
        this.orderItems[index].disabledFields = !this.orderItems[index].isSelected;
    }

    async getOrderItems() {
        try{
            var orderItemsToInsert = [];
            this.prodPriceRequests = [];
            if( this.order.Pricebook2.ShowPricingfromMicroServiceOM__c) {
                for(let i = 0; i < this.orderItems.length; i++) {
                    if(this.orderItems[i].Quantity > 0) {
                        let prodPriceRequest = { productId : this.orderItems[i].Article__c,
                                                 quantity : this.orderItems[i].Quantity}
                       this.prodPriceRequests.push(prodPriceRequest);
                    }
                }
                this.AXPrices = await this.getPriceCall2(this.prodPriceRequests);
           }

            for(let i = 0; i < this.orderItems.length; i++) {
                if(this.orderItems[i].Quantity > 0) {
                    if(this.AXPrices){
                        let foundInAX2;
                        foundInAX2 = this.AXPrices.find(element => this.orderItems[i].Article__c === element.productEntry.productId);
                        this.orderItems[i].UnitPrice = foundInAX2.basePrice;
                        this.orderItems[i].AXRetailPrice__c = foundInAX2.retailPrice;
                        //this.orderItems[i].UnitPrice = parseFloat(foundInAX2.basePrice).toFixed(2);
                        //this.orderItems[i].AXRetailPrice__c = parseFloat(foundInAX2.retailPrice).toFixed(2);
                    }
                    
                
                    let item = {};
                    Object.assign(item, this.orderItems[i]);
                    delete item.Article__c;
                    delete item.Name;
                    delete item.Currency;
                    delete item.isSelected;
                    delete item.disabledFields;
                    if(!item.Offer_Code_dna__c) {
                        delete item.Offer_Code_dna__c;
                    }
                    orderItemsToInsert.push(item);
                }
            } 
        
            this.initOrderItems();
            return orderItemsToInsert;

        } catch (error){
            this.loading = false;
            showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
        }

    }
    
    initOrderItems() {
        for(let i = 0; i < this.orderItems.length; i++) {
            if(this.orderItems[i].Quantity > 0) {
                this.orderItems[i].Quantity = this.defaultQuantityValue;
                this.orderItems[i].isSelected = false;
                this.orderItems[i].Free_Of_Charge__c = false;
                this.orderItems[i].disabledFields = !this.orderItems[i].isSelected;
            }
        } 
    }
    handleNext() {
        if((this.pageNumber * this.pageSize) < this.totalProducts) {
            this.pageNumber++;
            this.getProductsCounter();
        }
    }
    handlePrevious() {
        if(this.pageNumber > 1) {
            this.pageNumber--;
            this.getProductsCounter();
        }
    }
    get optionsDesc1() {
        return this.buildDescsOptions(this.descriptions[3]);
    }
    get optionsDesc2() {
        return this.buildDescsOptions(this.descriptions[2]);
    }
    get optionsDesc3() {
        return this.buildDescsOptions(this.descriptions[1]);
    }
    get optionsDesc4() {
        return this.buildDescsOptions(this.descriptions[0]);
    }
    buildDescsOptions(descriptionsArray) {
        var options = [];
        options.push({ label: this.noneLabel, value: null});
        if(descriptionsArray) {
            for(let i = 0; i < descriptionsArray.length; i++) {
                options.push({ label: descriptionsArray[i], value: descriptionsArray[i]});
            }
        }
        return options;
    }
    initFilters() {
        this.valueDesc1 = this.defaultValue;
        this.valueDesc2 = this.defaultValue;
        this.valueDesc3 = this.defaultValue;
        this.valueDesc4 = this.defaultValue;
        this.getDescriptions(this.globalDescription.relatedDescriptions);
        this.pageNumber = this.defaultPage;
        this.getProductsCounter();
    }
    handleChangeDescriptionsCombo1(event) {
        this.valueDesc1 = event.detail.value;
        this.valueDesc2 = this.defaultValue;
        this.valueDesc3 = this.defaultValue;
        this.valueDesc4 = this.defaultValue;
        if(this.valueDesc1) {
            this.descriptions[0] = [];
            this.descriptions[1] = [];
            this.descriptions[2] = [];
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions, this.descriptions, 2);
        }else {
            this.getDescriptions(this.globalDescription.relatedDescriptions, this.descriptions, 3);
        }
        this.pageNumber = this.defaultPage;
        this.getProductsCounter();
    }
    handleChangeDescriptionsCombo2(event) {
        this.valueDesc2 = event.detail.value;
        this.valueDesc3 = this.defaultValue;
        this.valueDesc4 = this.defaultValue;
        if(this.valueDesc2 && this.valueDesc1) {
            this.descriptions[0] = [];
            this.descriptions[1] = [];
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions[this.valueDesc2].relatedDescriptions, this.descriptions, 1);
        } else if(this.valueDesc1) {
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions, this.descriptions, 2);
        } else {
            this.getDescriptions(this.globalDescription.relatedDescriptions, this.descriptions, 3);
        }
        this.pageNumber = this.defaultPage;
        this.getProductsCounter();
    }
    handleChangeDescriptionsCombo3(event) {
        this.valueDesc3 = event.detail.value;
        this.valueDesc4 = this.defaultValue;
        if(this.valueDesc3 && this.valueDesc2 && this.valueDesc1) {
            this.descriptions[0] = [];
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions[this.valueDesc2].relatedDescriptions[this.valueDesc3].relatedDescriptions, this.descriptions, 0);
        } else if(this.valueDesc2 && this.valueDesc1) {
            this.descriptions[0] = [];
            this.descriptions[1] = [];
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions[this.valueDesc2].relatedDescriptions, this.descriptions, 1);
        } else if(this.valueDesc1) {
            this.getDescriptions(this.globalDescription.relatedDescriptions[this.valueDesc1].relatedDescriptions, this.descriptions, 2);
        } else {
            this.getDescriptions(this.globalDescription.relatedDescriptions, this.descriptions, 3);
        }
        this.pageNumber = this.defaultPage;
        this.getProductsCounter();
    }
    handleChangeDescriptionsCombo4(event) {
        this.valueDesc4 = event.detail.value;
        this.pageNumber = this.defaultPage;
        this.getProductsCounter();
    }
    handleShowFilter() {
        this.hideFilter = !this.hideFilter;
    }
    goToProduct(event) {
        window.open('/' + this.orderItems[event.target.dataset.index].Product2Id);
    }
    goToOrderItems() {
        const event = new CustomEvent('gotoorderitems');
        this.dispatchEvent(event);
    }
    get getTotalPages() {
        let total = Math.ceil(this.totalProducts / this.pageSize);
        return total > 0 ? total : 1;
    }
    // new stuff 201005
    get isMobile() {
        return this.userUiTheme === 'Theme4t';
    }
    get filterButtonSelected() {
        return !this.hideFilter;
    }
    get orderItemSelected() {
        return this.orderItems ? this.orderItems.some(orderItem => orderItem.isSelected) : false;
    }
    get pageSizeOptions() {
        return [
            { label: '10', value: '10' },
            { label: '25', value: '25' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
            { label: '200', value: '200' },
        ];
    }
    get pageSizeValue() {
        return this.pageSize.toString();
    }
    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.detail.value, 10);
        this.getProductsCounter();
    }
    handleSliderInput(event) {
        console.log(`slider ${JSON.stringify(event)}`);
    }
    get defaultQuantityValue() {
        return this.isMobile ? 0 : null;
    }
    get orderItemCardClass() {
        return this.isMobile ? 'slds-size_6-of-6 slds-p-around_xx-small' : 'slds-size_6-of-6 slds-p-around_xxx-small';
    }
    get selectProductBoxClass() {
        const defaultClasses = 'slds-grid slds-wrap slds-theme_shade';
        return this.isMobile ? `${defaultClasses} slds-p-top_xx-small` : `${defaultClasses} slds-box`;
    }
    get selectProductInnerBoxClass() {
        const defaultClasses = 'slds-text-align_center slds-theme_shade slds-m-top_x-small';
        if (this.isMobile) {
            return `${defaultClasses}`;
        } else if (this.userUiTheme === 'Theme3') {
            return `${defaultClasses} slds-box custom-box container-vf-height slds-scrollable`;
        } else {
            return `${defaultClasses} slds-box custom-box`;
        }
    }
    get selectAllCheckboxClass() {
        const defaultClasses = 'slds-form-element slds-float_left';
        return this.isMobile ? `${defaultClasses}` : `${defaultClasses} slds-m-left_medium`;
    }
    get pagination() {
        return this.totalProducts > this.pageSize;
    }
    get isSmallScreen() {
        return window.screen.availWidth < 768;
    }
    get paginationTablet() {
        return this.pagination && this.isMobile && !this.isSmallScreen;
    }
    handleOrderItemMouseOver(event) {
        const index = event.target.dataset.index;
        if (this.mouseOverTimeOut) {
            if (this.mouseOverTimeOut.index !== index) {
                this.orderItems[this.mouseOverTimeOut.index].isMouseOver = false;
            } 
            clearTimeout(this.mouseOverTimeOut.timeOut);
        } 
        this.orderItems[index].isMouseOver = true;
    }
    handleOrderItemMouseLeave(event) {
        const index = event.target.dataset.index;
        const timeOut = setTimeout(() => {
            this.orderItems[index].isMouseOver = false;
            this.mouseOverTimeOut = null;
        }, 300);
        this.mouseOverTimeOut = { index, timeOut };
    }
}