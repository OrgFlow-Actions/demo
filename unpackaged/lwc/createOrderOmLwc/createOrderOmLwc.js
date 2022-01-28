import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { showToast } from 'c/utils';
// Current User Id
import currentUserId from '@salesforce/user/Id';
// Schema
import USER_CURRENCY_FIELD from '@salesforce/schema/User.DefaultCurrencyIsoCode';
//Apex Controllers
import getPriceBooksEntriesCurrencies from '@salesforce/apex/OrderManagement_CC.getPriceBooksEntriesCurrencies';
import getPriceBooksList from '@salesforce/apex/OrderManagement_CC.getPriceBooks';
import getContracts from '@salesforce/apex/OrderManagement_CC.getContracts';
import getSourceRecords from '@salesforce/apex/OrderManagement_CC.getSourceRecords';
import getRelatedAccountsWithContact from '@salesforce/apex/OrderManagement_CC.getRelatedAccountsWithContact';
import getAccountRecordType from '@salesforce/apex/OrderManagement_CC.getAccountRecordType';

// Custom Labels
import createOrderLabel from '@salesforce/label/c.OM_Create_Order';
import createOrderInstructionsLabel from '@salesforce/label/c.OM_Create_Order_Instructions';
import cancelLabel from '@salesforce/label/c.OM_Cancel';
import selectCurrency from '@salesforce/label/c.OM_Select_Currency';
import selectPricebook from '@salesforce/label/c.OM_Select_Pricebook';
import selectContract from '@salesforce/label/c.OM_Select_Contract';
import noPricebooksAccess from '@salesforce/label/c.OMNoPricebookAccess';
import noAvailablePricebooks from '@salesforce/label/c.OM_No_Available_Pricebooks';
import noAvailableCurrencies from '@salesforce/label/c.OM_No_Available_Currencies';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class CreateOrderOmLwc extends LightningElement {
    @api userUiTheme;
    @api parentId;
    @track currentUserId = currentUserId;
    @track selectedCurrency = '';
    @track currencies = [];
    @track selectedPricebookId = '';
    @track pricebooks = [];
    @track contracts = [];
    @track selectedContractId = '';
    @track sourceRecords = []; 
    @track selectedSourceRecordId = '';
    @track relatedAccountsWithContact = []; 
    @track selectedAccountsWithContactId = '';
    @track isMicroserviceCallOutPricebook = false;  
    @track loading = true;
    @track noneLabel = '--None--';
    @track labels = {
        createOrderLabel, 
        createOrderInstructionsLabel, 
        cancelLabel,
        selectCurrency, 
        selectPricebook, 
        selectContract,
        noPricebooksAccess,
        noAvailablePricebooks,
        noAvailableCurrencies
    };
    @track optionNull = ({ label: this.noneLabel, value: null});

    @wire(getRecord, { recordId: '$currentUserId', fields: [USER_CURRENCY_FIELD] })
    currentUser;

    get currentUserCurrencyIsoCode() {
        return getFieldValue(this.currentUser.data, USER_CURRENCY_FIELD);
    }
    
    connectedCallback() {
        this.getAccountRecordType();
        this.getPriceBooksList();
    }
    getPriceBooksList() {
		getPriceBooksList()
			.then(result => {
                if(result) {
                    this.pricebooks = result;
                    if (this.pricebooks.length === 1) {
                        this.selectedPricebookId = this.pricebooks[0].Id;
                        this.getPriceBooksEntriesCurrencies();
                    } else {
                        this.loading = false;
                    }
                } else {
                    showToast(this, this.userUiTheme, 'Info', this.labels.noAvailablePricebooks, 'info');
                    this.loading = false;
                }
			})
			.catch(error => {
                showToast(this, this.userUiTheme, 'Info', error.body.message + error.body.stackTrace, 'info');
                this.loading = false;
			});
    }
    getPriceBooksEntriesCurrencies() {
		getPriceBooksEntriesCurrencies({pricebookId : this.selectedPricebookId})
			.then(result => {
                if (result) {
                    this.currencies = result;
                    for(let i = 0; i < this.pricebooks.length; i++){
                        if(this.selectedPricebookId == this.pricebooks[i].Id){
                            this.isMicroserviceCallOutPricebook = this.pricebooks[i].ShowPricingfromMicroServiceOM__c;
                            continue;
                        }
                    }
                    if (this.currencies.length === 1) {
                        this.selectedCurrency = this.currencies[0].CurrencyIsoCode;
                        this.getRelatedAccountsWithContact();
                    } else if (this.currencies.length > 1) {
                        const filteredCurrencies = this.currencies.filter(currency => currency.CurrencyIsoCode === this.currentUserCurrencyIsoCode);
                        if (filteredCurrencies.length === 1) {
                            this.selectedCurrency = filteredCurrencies[0].CurrencyIsoCode;
                            this.getRelatedAccountsWithContact();
                        } else {
                            this.loading = false;
                        }
                    } else {
                        this.loading = false;
                    }
                    this.loading = false;
                } else {
                    showToast(this, this.userUiTheme, 'Info', this.labels.noAvailableCurrencies, 'info');
                    this.loading = false;
                }
			})
			.catch(error => {
                showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace, 'error');
                this.loading = false;
			});
    }

    getRelatedAccountsWithContact() { 
        getRelatedAccountsWithContact({parentId : this.parentId})
        .then(result => {
            if(result) {
                this.relatedAccountsWithContact = result;
                if (this.relatedAccountsWithContact.length === 1) {
                    this.selectedAccountsWithContactId = this.relatedAccountsWithContact[0].AccountId;
                    this.getSourceRecords();
                } else {
                    this.loading = false;
                }
            } else {
                this.getSourceRecords();
            }
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        });
    }

    getSourceRecords() { 
        getSourceRecords({parentId : this.parentId, pricebookId: this.selectedPricebookId, accountId : this.selectedAccountsWithContactId})
        .then(result => {
            if(result) {
                this.sourceRecords = result;
                if (this.sourceRecords.length === 1) {
                    this.selectedSourceRecordId = this.sourceRecords[0].Id;
                    this.getContracts();
                } else 
                    if (this.sourceRecords.length > 1) {
                        this.loading = false;
                    } else {
                        this.getContracts();
                        this.loading = false;
                    }
            } else {
                this.getContracts();
            }
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        });
    }
    getContracts() {
        getContracts({pricebookId: this.selectedPricebookId,
                        parentId : this.parentId,
                        currencyIsoCode : this.selectedCurrency})
        .then(result => {
            if(result) {
                this.contracts = result;
                if (this.contracts.length === 0 && this.pricebooks.length === 1 && this.selectedCurrency) {
                    this.createOrder();
                } else {
                    this.loading = false;
                }
            } else {
                if (this.pricebooks.length === 1 && this.selectedCurrency) {
                    this.createOrder();
                } else {
                    this.loading = false;
                }
            }
        })
        .catch(error => {
            showToast(this, this.userUiTheme, 'Error', error.body.message + error.body.stackTrace, 'error');
            this.loading = false;
        });
    }
    
    get pricebooksOptions() {
        const options = this.pricebooks.map(entry => {
            return ({ label: entry.Name , value: entry.Id })
        });
        return [].concat(this.optionNull, options);
    }
    get currenciesOptions() {
        const options = this.currencies.map(entry => {
            return ({ label: entry.CurrencyIsoCode , value: entry.CurrencyIsoCode })
        });
        return [].concat(this.optionNull, options);
    }

    
    get contractsOptions() {
        const options = this.contracts.map(entry => {
            return ({ label: entry.Name + ' - ' +  entry.Discount_Type__c + ' - ' + entry.Discount__c + '%', value: entry.Id })
        });
        return [].concat(this.optionNull, options);
    }
    get relatedAccountsWithContactOptions() {
        const options = this.relatedAccountsWithContact.map(entry => {
            return ({ label: entry.Account.Name, value: entry.AccountId })
        });
        return [].concat(this.optionNull, options);
    }
    get soruceRecordOptions() { 
        const options = this.sourceRecords.map(entry => {
            return ({ label: entry.Combined_Fields__c , value: entry.Id })
        });
        return [].concat(this.optionNull, options);
    }

    
    handlePricebookChange(event) {
        this.selectedPricebookId = event.detail.value;
        this.loading = true;
        this.currencies = [];
        this.selectedCurrency = '';
        this.contracts = [];
        this.selectedContractId = '';
        this.sourceRecords = []; 
        this.selectedSourceRecordId = '';
        this.relatedAccountsWithContact = [];  
        this.selectedAccountsWithContactId = '';
        this.getPriceBooksEntriesCurrencies();
    }
    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        this.loading = true;
        this.contracts = []; 
        this.selectedContractId = '';
        this.sourceRecords = []; 
        this.selectedSourceRecordId = '';
        this.relatedAccountsWithContact = [];  
        this.selectedAccountsWithContactId = '';
        this.getRelatedAccountsWithContact();
    }
    handlerelatedAccountsWithContactChange(event) { 
        this.selectedAccountsWithContactId = event.detail.value;
        this.loading = true;
        this.contracts = []; 
        this.selectedContractId = '';
        this.sourceRecords = []; 
        this.selectedSourceRecordId = '';
        this.getSourceRecords();
    }
    handleSourceRecordChange(event) { 
        this.selectedSourceRecordId = event.detail.value;
        this.loading = true;
        this.contracts = []; 
        this.selectedContractId = '';
        this.getContracts();
    }
    
    handleContractChange(event) {
        this.selectedContractId = event.detail.value;
    }

    get displayCurrenciesCombo() {
        return this.currencies.length > 1;
    }
    get displayPricebooksCombo() {
        return this.pricebooks.length > 0;
    }
    get displayContractsCombo() {
        return this.contracts.length > 0;
    }

    get displaySourceRecordsCombo() { 
        return this.sourceRecords.length > 1 ;
    }

    get displayRelatedAccountsWithContactCombo() { 
        return this.relatedAccountsWithContact.length > 1;
    }
    
    createOrder() {
        this.loading = true;
        const selectEvent = new CustomEvent('createorder', {
            detail : {'contractId' : this.selectedContractId,
                      'pricebookId' : this.selectedPricebookId,
                      'currency' : this.selectedCurrency,
                      'sourceRecordId' : this.selectedSourceRecordId,
                      'accountId' : this.selectedAccountsWithContactId} 
        });
        this.dispatchEvent(selectEvent);
    }
    
    get enableCreateButton() {
        //return !this.selectedPricebookId || !this.selectedCurrency;
        return !this.selectedPricebookId || !this.selectedCurrency || (this.isMicroserviceCallOutPricebook && !this.selectedSourceRecordId && this.accountRecordType =='CIM_Account');
    }
    
    cancel() {
        const selectEvent = new CustomEvent('cancel', {
        });
        this.dispatchEvent(selectEvent);
    }


    getAccountRecordType() {
		getAccountRecordType({parentId : this.parentId })
			.then(result => {
                if(result) {
                    this.accountRecordType = result;
                } 
			})
			.catch(error => {
                showToast(this, this.userUiTheme, 'Info', error.body.message + error.body.stackTrace, 'info');
                this.loading = false;
			});
    }
}