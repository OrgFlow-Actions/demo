import { LightningElement, track ,api} from 'lwc';
import { showToast, goToRecord} from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';
//Apex Controllers
import uIThemeDisplayed from '@salesforce/apex/OrderManagement_CC.uIThemeDisplayed';
import cloneOrder from '@salesforce/apex/OrderManagement_CC.cloneOrder';
import getOrder from '@salesforce/apex/OrderManagement_CC.getOrder';
import getContracts from '@salesforce/apex/OrderManagement_CC.getContracts';

// Custom Labels
import cloneOrderLabel from '@salesforce/label/c.OM_Clone_Order';
import cloneOrderPricebookDeactivated from '@salesforce/label/c.OM_Clone_Order_Deactivated_Price_Book';
import cloneOrderContractExpired from '@salesforce/label/c.OM_Clone_Order_Expired_Contract';
import orderCloneSuccess from '@salesforce/label/c.OM_Clone_Order_Success_Message';
import selectContract from '@salesforce/label/c.OM_Select_Contract';
import cancelLabel from '@salesforce/label/c.OM_Cancel';

export default class CloneOrderOmLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    @track order;
    @track labels = {cloneOrderLabel, orderCloneSuccess, selectContract, cancelLabel,
        cloneOrderPricebookDeactivated, cloneOrderContractExpired};
    @track userUiTheme;
    @track loading;
    @track contracts;
    @track selectedContractId = '';
    @track displayContractsCombo = false;
    @track noneLabel = '--None--';
    connectedCallback() {
        this.loading = true;
        this.uIThemeDisplayed();
    }
    uIThemeDisplayed() {
        uIThemeDisplayed()
        .then(result => {
            this.userUiTheme = result;
            this.getOrder();
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace , 'error');
        });
    }
    cloneOrder() {
        this.loading = true;
        cloneOrder({orderId : this.order.Id, contractId : this.selectedContractId})
        .then(result => {
            showToast(this, this.userUiTheme, 'Success', result.OrderNumber + ' : ' + this.labels.orderCloneSuccess , 'success');
            goToRecord(this.userUiTheme, result.Id, this);
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace , 'error');
            this.loading = false;
        });
    }
    getOrder() {
		getOrder({orderId : this.recordId})
			.then(result => {
                this.order = result;
                let todayDate = '';
                if(this.order.ContractId) {
                    todayDate = new Date().toISOString().substring(0,this.order.Contract.EndDate.length);
                }
                if(!this.order.Pricebook2.IsActive) {
                    showToast(this, this.userUiTheme, 'Error', this.labels.cloneOrderPricebookDeactivated, 'error');
                    this.closeQuickAction();
                } else if(!this.order.ContractId || todayDate > this.order.Contract.EndDate) {
                    this.getContracts();
                } else {
                    this.cloneOrder();
                }
			})
			.catch(error => {
                this.loading = false;
				this.error = error;
			});
    }
    getContracts() {
        getContracts({pricebookId: this.order.Pricebook2Id,
                        parentId : this.order.AccountId,
                        currencyIsoCode : this.order.CurrencyIsoCode})
        .then(result => {
            if(result && result.length > 0) {
                showToast(this, this.userUiTheme, 'Warning', this.labels.cloneOrderContractExpired, 'warning');
                this.contracts = result;
                this.displayContractsCombo = true;
                this.loading = false;
            } else {
                this.cloneOrder();
            }
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        });
    }
    handleContractChange(event) {
        this.selectedContractId = event.detail.value;
    }
    get contractsOptions() {
        var options = [];
        options.push({ label: this.noneLabel, value: null});
        if(this.contracts) {
            for(let i = 0; i < this.contracts.length; i++) {
                options.push({ label: this.contracts[i].Name + '(' +  this.contracts[i].Discount__c + '%)', value: this.contracts[i].Id});
            }
        }
        return options;
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
    
    // TODO delete?
    cancel() {
        const selectEvent = new CustomEvent('cancel', {
        });
        this.dispatchEvent(selectEvent);
    }
}