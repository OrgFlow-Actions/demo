import { LightningElement, track, api, wire} from 'lwc';
import { showToast } from 'c/utils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_ITEM_OBJECT from '@salesforce/schema/OrderItem';
//Form Factor
import FORM_FACTOR from '@salesforce/client/formFactor';
//Apex Controllers
import getOrderItemsCounter from '@salesforce/apex/OrderManagement_CC.getOrderItemsCounter';
import getOrderItems from '@salesforce/apex/OrderManagement_CC.getOrderItems';
import updateOrderItems from '@salesforce/apex/OrderManagement_CC.insertOrderItems';
import deleteOrderItem from '@salesforce/apex/OrderManagement_CC.deleteOrderItem';
//Custom Labels
import selectAll from '@salesforce/label/c.OM_Select_All';
import applyDiscount from '@salesforce/label/c.OM_Apply_Discount';
import enterDiscount from '@salesforce/label/c.OM_Enter_Discount';
import previous from '@salesforce/label/c.OM_Previous';
import next from '@salesforce/label/c.OM_Next';
import discountInstructions from '@salesforce/label/c.OM_Discount_Instructions';
import updateOrderItemsSuccessMessage from '@salesforce/label/c.OM_Update_Order_Items_Success_Message';
import isGreater from '@salesforce/label/c.OM_Discount_Greater_Message';
import addOneOrderItemAtLeast from '@salesforce/label/c.OM_Select_Order_Item_Validation';
import orderItemDeletedMessage from '@salesforce/label/c.OM_Order_Item_Deleted_Message';
import deleteConfirmMessage from '@salesforce/label/c.OM_Delete_Confirmation_Message';
import applyContractDiscount from '@salesforce/label/c.OM_Apply_Contract_Discount';
import applyCustomDiscount from '@salesforce/label/c.OM_Apply_Custom_Discount';
import orderItemsFound from '@salesforce/label/c.OM_Order_Items_Found';
import orderItemsSelected from '@salesforce/label/c.OM_Order_Items_Selected';
import orderItemClone from '@salesforce/label/c.OM_Order_Item_Clone';
import orderItemDelete from '@salesforce/label/c.OM_Order_Item_Delete';
import orderItemEdit from '@salesforce/label/c.OM_Order_Item_Edit';
export default class OrderItemsOmLwc extends LightningElement {
    @api userUiTheme;
    @api order;
    @track maxDiscount = 100;
    @track itemToUpdate = '';
    @track totalOrderItems = 0;
    @track orderItems = [];
    @track pageSize = 200;
    @track pageNumber = 1;
    @track defaultValue = '';
    @track discountInput = this.isMobile ? 0 : '';
    @track loading = true;
    @track selectAll = false;
    @track labels = {
        selectAll,
        applyDiscount,
        enterDiscount,
        previous,
        next,
        discountInstructions,
        updateOrderItemsSuccessMessage,
        isGreater,
        addOneOrderItemAtLeast,
        orderItemDeletedMessage,
        deleteConfirmMessage,
        applyContractDiscount,
        applyCustomDiscount,
        orderItemsFound,
        orderItemsSelected,
        orderItemClone,
        orderItemDelete,
        orderItemEdit,
    };
    // new
    @track orderItemTileActions = [
        {
            label: this.labels.orderItemEdit,
            value: 'edit',
            iconName: 'utility:edit'
        },
        {
            label: this.labels.orderItemClone,
            value: 'clone',
            iconName: 'utility:copy'
        },
        {
            label: this.labels.orderItemDelete,
            value: 'delete',
            iconName: 'utility:delete'
        }
    ];
    currentTileAction;
    @track orderItemObjectInfo;
    // end new
    
    connectedCallback() {
        
        this.getOrderItemsCounter();
    }

    @wire(getObjectInfo, { objectApiName: ORDER_ITEM_OBJECT })
    orderItemObjectInfo;

    get orderItemDiscountLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.Discount_Percent__c.label : '';
    }
    get orderItemQuantityLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.Quantity.label : '';
    }
    get orderItemUnitPriceLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.UnitPrice.label : '';
    }
    get orderItemRetailPriceLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.AXRetailPrice__c.label : '';
    }
    get orderItemTotalLineItemPriceLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.Total_Line_Item_Price__c.label : '';
    }
    get orderItemFOCLabel() {
        return this.orderItemObjectInfo ? this.orderItemObjectInfo.data.fields.Free_of_Charge_Delivery__c.label : '';
    }

    getOrderItemsCounter() {
        getOrderItemsCounter({orderId : this.order.Id}).then(result => {
            this.totalOrderItems = result;
            this.loading = false;
            this.getOrderItems();
        })
        .catch(error => {
            this.loading = false;
            showToast(this, this.userUiTheme, 'ERROR', error.body.message + error.body.stackTrace, 'error');
        });
    }
    // test
    getOrderItems() {
        this.loading = true;
        getOrderItems({orderId : this.order.Id,
                     pageNumber : this.pageNumber,
                     pageSize : this.pageSize})
			.then(result => {
                if(result.length > 0) {
                    this.orderItems = [];
                    for(let i = 0; i < result.length; i++) {
                        let orderItem = { Id : result[i].Id,
                                        Quantity : result[i].Quantity, 
                                        Product2Id : result[i].Id,
                                        Currency : result[i].Order.CurrencyIsoCode,
                                        Article__c : result[i].Product2.Article__c,
                                        Name : result[i].Product2.Name,
                                        Free_of_Charge_Delivery__c : result[i].Free_of_Charge_Delivery__c,
                                        Discount_Percent__c : result[i].Discount_Percent__c,
                                        Total_Line_Item_Price__c : result[i].Total_Line_Item_Price__c,
                                        //UnitPrice : parseFloat(result[i].UnitPrice).toFixed(2),
                                        //AXRetailPrice__c : parseFloat(result[i].AXRetailPrice__c).toFixed(2),
                                        UnitPrice : result[i].UnitPrice,
                                        AXRetailPrice__c : result[i].AXRetailPrice__c,
                                        AXDiscount__c : result[i].AXDiscount__c,
                                        DiscountedAmount : result[i].DiscountedAmount__c,
                                        LocalProductDescription__c : result[i].PricebookEntry.LocalProductDescription__c,
                                        Url : `/${result[i].Id}`,
                                        isSelected : false};                
                        this.orderItems.push(orderItem);
                    } 
                }
                this.loading = false;
			})
			.catch(error => {
                this.loading = false;
				showToast(this, this.userUiTheme, 'ERROR', error.body.message + error.body.stackTrace, 'error');
			});
    }
    setCustomDiscount() {
        if(this.discountInput <= this.maxDiscount) {
            let orderItems = this.applyDiscount(this.discountInput);
            if(orderItems.length > 0) {
                this.updateOrderItems(orderItems);
            } else {
                showToast(this, this.userUiTheme, 'WARNING', this.labels.addOneOrderItemAtLeast , 'warning');
            }
        } else {
            showToast(this, this.userUiTheme, 'WARNING', this.discountInput + ' ' + this.labels.isGreater + this.maxDiscount + ' %', 'warning');
        }
    }
    setContractDiscount() {
        let orderItems = this.applyDiscount(this.order.Contract.Discount__c);
        if(orderItems.length > 0) {
            this.updateOrderItems(orderItems);
        } else {
            showToast(this, this.userUiTheme, 'WARNING', this.labels.addOneOrderItemAtLeast , 'warning');
        }
    }
    updateOrderItems(orderItems) {
        this.loading = true;
        updateOrderItems({ orderItems : orderItems })
        .then(result => {
            if(result === 'SUCCESS') {
                showToast(this, this.userUiTheme, 'Success', orderItems.length + ' ' + this.labels.updateOrderItemsSuccessMessage, 'success');
                this.getOrderItemsCounter();
                this.discountInput = this.isMobile ? 0 : '';
            } else {
                showToast(this, this.userUiTheme, 'ERROR', result, 'error');
            }
            this.loading = false;
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'ERROR', error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        });
    }
    deleteOrderItem(index) {
        this.loading = true;
        let orderItem = this.orderItems[index];
        deleteOrderItem({orderItemId : orderItem.Id})
        .then(result => {
            this.getOrderItemsCounter();
            showToast(this, this.userUiTheme,'Success', this.labels.orderItemDeletedMessage,'success');
            this.loading = false;
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error',  error.body.message + error.body.stackTrace,'error');
            this.loading = false;
        });
    }
    handleNext() {
        if((this.pageNumber * this.pageSize) < this.totalOrderItems) {
            this.pageNumber++;
            this.getOrderItems();
        }
    }
    handlePrevious() {
        if(this.pageNumber > 1) {
            this.pageNumber--;
            this.getOrderItems();
        }
    }
    handleSelectChange(event) {
        var index = event.target.dataset.index;
        this.orderItems[index].isSelected = event.target.checked;
        this.selectAll = this.orderItems.every(orderItem => orderItem.isSelected);
    }
    applyDiscount(discount) {
        var orderItemsToInsert = [];
        for(let i = 0; i < this.orderItems.length; i++) {
            if(this.orderItems[i].isSelected) {
                this.orderItems[i].isSelected = false;
                this.orderItems[i].Discount_Percent__c = discount;
                let item = {};
                Object.assign(item, this.orderItems[i]);
                delete item.Article__c;
                delete item.Name;
                delete item.Currency;
                delete item.isSelected;
                orderItemsToInsert.push(item);

            }
        }
        this.selectAll = false;
        return orderItemsToInsert;
    }
    get isOrderItemsSelected() {
        return !this.orderItems.some(orderItem => orderItem.isSelected);
    }
    get isDiscountSelected() {
        return !(this.discountInput && !this.isOrderItemsSelected) || this.discountInput > this.maxDiscount;
    }
    get isContractSelected() {
        return !this.order.Contract;
    }
    get enableSelection() {
        return false;//this.isDiscountSelected && this.isContractSelected;
    }
    get orderItemsCounter() {
        const selectedOrderItems = this.orderItems ? this.orderItems.filter(orderItem => orderItem.isSelected).length : 0;
        return selectedOrderItems === 0 ? `${this.totalOrderItems} ${this.labels.orderItemsFound}` : `${selectedOrderItems} ${this.labels.orderItemsSelected}`;
    }
    handleSelectAllChange() {
        this.selectAll = !this.selectAll;
        for(let i = 0; i < this.orderItems.length; i++) {
            this.orderItems[i].isSelected = this.selectAll;
        }
    }
    handleChangeDiscountInput(event) {
        this.discountInput = event.target.value;
    }
    updateOrderItem() {
        this.loading = true;
    }
    openUpdateOrderItemForm(event) {
        this.itemToUpdate = this.orderItems[event.target.dataset.index];
    }
    handleOrderItemUpdated() {
        this.itemToUpdate = '';
        this.getOrderItemsCounter();
        this.getOrderItems();
    }
    handleDeleteOrderItem(event) {
        if (confirm(this.labels.deleteConfirmMessage)) {
            let index = event.target.dataset.index;
            this.deleteOrderItem(index);
        }
    }
    // goToOrderItem(event) {
    //     window.open('/' + this.orderItems[event.target.dataset.index].Id);
    // }

    get getTotalPages() {
        let total = Math.ceil(this.totalOrderItems / this.pageSize);
        return total > 0 ? total : 1;
    }
    // new stuff 201005
    get isMobile() {
        return this.userUiTheme === 'Theme4t';
    }
    handleOrderItemTileAction(event) {
        // Get the value of the selected action
        const tileAction = event.detail.action.value;
        this.currentTileAction = tileAction;

        if (tileAction === 'edit' || tileAction === 'clone') {
            this.openUpdateOrderItemForm(event);
        } else if (tileAction === 'delete') {
            this.handleDeleteOrderItem(event);
        }
    }
    get pagination() {
        return this.totalOrderItems > this.pageSize;
    }
    get orderItemsBoxClass() {
        const defaultClasses = 'slds-grid slds-wrap slds-theme_shade';
        return this.isMobile ? `${defaultClasses}` : `${defaultClasses} slds-box`;
    }
    get orderItemsInnerBoxClass() {
        const defaultClasses = 'slds-text-align_center slds-theme_shade';
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
        return this.isMobile ? `${defaultClasses}` : `${defaultClasses} slds-m-left_x-small`;
    }
    get isSmallScreen() {
        return window.innerWidth < 768;
    }
    get marginTopNegativeClass() {
        return this.isMobile ? `m-top-negative` : ``;
    }
    get paginationTablet() {
        return this.pagination && this.isMobile && !this.isSmallScreen;
    }
    get contractDiscountLabel() {
        return `${this.labels.applyContractDiscount} (${this.order.Contract.Discount__c}%)`
    }
    get contractDiscountLabelCompact() {
        return `(${this.order.Contract.Discount__c}%)`
    }
}