import { LightningElement, api,track} from 'lwc';
import { showToast, goToRecord} from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';

//Apex Controllers
import uIThemeDisplayed from '@salesforce/apex/OrderManagement_CC.uIThemeDisplayed';
import getOrder from '@salesforce/apex/OrderManagement_CC.getOrder';
import createOrder from '@salesforce/apex/OrderManagement_CC.createOrder';
// Custom Labels
import orderCreatedSuccess from '@salesforce/label/c.Om_Order_Created_Success';
import showOrderItems from '@salesforce/label/c.OM_Show_Order_Items';
import goToOrder from '@salesforce/label/c.OM_Go_to_Order';
import addMoreProducts from '@salesforce/label/c.OM_Add_More_Products';

const ORDER_SOBJECT_API_NAME = 'Order';
export default class OrderManagementLwc  extends NavigationMixin(LightningElement) {
    @track userUiTheme = '';
    @api recordId;
    @api sobjectName;
    @api lightningOut;
    @track seletedPricebookId = '';
    @track selectContractId = '';
    @track selectedCurrency = '';
    @track selectedAccountsWithContactId = '';
    @track selectedSourceRecordId = '';
    @track order;
    @track showSelectProducts = false;
    @track showOrderItems = false;
    @track loading = true;
    @track orderCreationSkip = true;
    @track labels = {
        orderCreatedSuccess,
        showOrderItems,
        addMoreProducts,
        goToOrder,
    };
    connectedCallback() {
        this.uIThemeDisplayed();
    }
    uIThemeDisplayed() {
        uIThemeDisplayed()
        .then(result => {
            this.userUiTheme = result;
            if(this.isOrder) {
                this.getOrder();
            } else {
                this.orderCreationSkip = false;
                this.loading = false;
            }
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', JSON.stringify(error) , 'error');
        });
    }
    handleSelectedPriceBook(event) {
        this.seletedPricebookId = event.detail;
    }
    handleSelectedContract(event) {
        this.selectContractId = event.detail;
        this.insertOrder();
    }
    handleOrderCreation(event) {
        this.selectContractId = event.detail.contractId;
        this.seletedPricebookId = event.detail.pricebookId;
        this.selectedrelatedAccountsWithContactId = event.detail.accountId; 
        this.selectedSourceRecordId = event.detail.sourceRecordId; 
        this.selectedCurrency = event.detail.currency;
        this.insertOrder();
    }
    insertOrder() {
        createOrder({pricebookId: this.seletedPricebookId,
                    parentId : this.recordId,
                    contractId : this.selectContractId,
                    currencyIsoCode : this.selectedCurrency,
                    sourceRecordId : this.selectedSourceRecordId,
                    accountId : this.selectedrelatedAccountsWithContactId })
        .then(result => {
            this.order = result;
            this.showSelectProducts = true;
            showToast(this, this.userUiTheme, 'Success', this.order.OrderNumber + ' : ' + this.labels.orderCreatedSuccess, 'success');
        })
        .catch(error => {
            console.log( JSON.stringify(error));
            showToast(this, this.userUiTheme, 'Error', JSON.stringify(error) , 'error');
        });
    }
    getOrder() {
		getOrder({orderId : this.recordId})
			.then(result => {
                this.order = result;
                this.selectContractId = this.order.contractId;
                this.seletedPricebookId = this.order.Pricebook2Id;
                this.showSelectProducts = true;
                this.loading = false;
			})
			.catch(error => {
                this.loading = false;
				this.error = error;
			});
    }
    get displayContractForm() {
        return this.seletedPricebookId && !this.order;
    }
    switchDisplay() {
        this.showOrderItems = !this.showOrderItems;
        this.showSelectProducts = !this.showSelectProducts; 
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
    goToOrder() {
        goToRecord(this.userUiTheme,this.order.Id, this, /*this.lightningOut*/ false);
    }
    
    get isOrder() {
        return this.sobjectName === ORDER_SOBJECT_API_NAME;
    }

    get displayOrderCreation() {
        return !this.order && !this.orderCreationSkip;
    }

    get orderNumber() {
        return this.order.OrderNumber;
    }

    get isMobile() {
        return this.userUiTheme === 'Theme4t';
    }

    get containerClass() {
        const defaultClasses = 'slds-modal-container';
        if (this.isMobile) {
            return `${defaultClasses} slds-p-vertical_medium`;
        } else if (this.lightningOut && this.userUiTheme !== 'Theme3') {
            return `${defaultClasses} modal-container_vf-desktop-height-max slds-is-relative slds-p-around_medium modal_container_vh-vertical_padding`;
        } else if (this.lightningOut && this.userUiTheme === 'Theme3') {
            return `${defaultClasses} modal-container_vf-desktop-height slds-is-relative slds-p-around_medium modal_container_vh-vertical_padding`;
        } else {
            return `${defaultClasses} modal-container_desktop-height slds-is-relative slds-p-around_medium`;
        }
    }

    get navigationButtonGroupClass() {
        const defaultClasses = 'slds-p-around_xxx-small';
        return this.isMobile ? `${defaultClasses} slds-size_8-of-8` : `${defaultClasses} slds-size_3-of-8`;
    }
}