import { LightningElement, api, track} from 'lwc';
import cloneOrderItems from '@salesforce/apex/OrderManagement_CC.cloneOrderItems';
import getPriceCall from '@salesforce/apex/OrderManagement_CC.ProdPricingERPCallOut';
// Labels
import editTitle from '@salesforce/label/c.OM_Update_Order_Item_Edit_Title';
import cloneTitle from '@salesforce/label/c.OM_Update_Order_Item_Clone_Title';
import cancel from '@salesforce/label/c.OM_Update_Order_Item_Cancel';
import save from '@salesforce/label/c.OM_Update_Order_Item_Save';

export default class UpdateOrderItemOmLwc extends LightningElement {
    @api order;
    @api itemToUpdate;
    @api tileAction;
    @track loading = false;
    @track unitPrice;
    @track AXRetail;
    @track prodRequest;
    @track labels = {
        editTitle,
        cloneTitle,
        cancel,
        save,
    };

    connectedCallback() {
        this.loading = true;
    }

    goToOrderItems() {
        const selectEvent = new CustomEvent('orderitemupdated', {});
        this.dispatchEvent(selectEvent);
    }

    handleLoadUpdateOrderItem() {
        this.loading = false;
    }

    handleSubmit(event) {        
        this.loading = true;
             
        if (this.tileAction === 'edit' && this.order.Pricebook2.ShowPricingfromMicroServiceOM__c && this.itemToUpdate.Quantity != event.detail.fields.Quantity){
            let priceRequest = { productId : this.itemToUpdate.Article__c, quantity : event.detail.fields.Quantity}
            event.preventDefault();
            this.prodRequest = [];
            this.prodRequest.push(priceRequest);
            this.getPriceCall(event);
        }
                  
        if (this.tileAction === 'clone') {
            event.preventDefault();
            this.cloneOrderItems(event);
        }
        
    }

    getPriceCall(event){
        this.loading = true;
        getPriceCall({parentId : this.order.Id,
                prodPriceRequests : this.prodRequest })
                .then(result => {
                    let Prices = result;
                    event.preventDefault();
                    event.detail.fields.UnitPrice = Prices.entries[0].basePrice ;
                    event.detail.fields.AXRetailPrice__c = Prices.entries[0].retailPrice ;
                    this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
                })
                .catch(error => {
                    this.loading = false;
                    showToast(this, this.userUiTheme, 'ERROR',  error.body.message + error.body.stackTrace, 'error');
                });
    }

    async cloneOrderItems(event) {
        try {
            const fields = event.detail.fields;
            const clonedOrderItem = await cloneOrderItems({
                orderItemId: this.itemToUpdate.Id
            })
            fields.Id = clonedOrderItem.Id;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } catch (error) {
            this.handleErrorUpdateOrderItem();
        }
    }

    handleSuccessUpdateOrderItem() {
        this.loading = false;
        this.goToOrderItems();
    }

    handleErrorUpdateOrderItem() {
        this.loading = false;
    }

    get isEditMode() {
        return this.tileAction === 'edit';
    }

    get isCloneMode() {
        return this.tileAction === 'clone';
    }
}