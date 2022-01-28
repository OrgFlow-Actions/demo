import { LightningElement, track, api, wire } from 'lwc';
import { showToast, goToRecord } from 'c/utils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// OBJECT
import ORDER_DISTRIBUTOR_FIELD from '@salesforce/schema/Order.Distributor__c';
//Apex Controllers
import saveDealers from '@salesforce/apex/OrderDealer_CC.saveDealers';
import getDealers from '@salesforce/apex/OrderDealer_CC.getDealers';
import updateDealerInfo from '@salesforce/apex/OrderDealer_CC.updateDealerInfo';
import uIThemeDisplayed from '@salesforce/apex/OrderManagement_CC.uIThemeDisplayed';
import apexSearch from '@salesforce/apex/OrderDealer_CC.search';
// Custom Labels
import title from '@salesforce/label/c.OD_Title';
import subTitle from '@salesforce/label/c.OD_SubTitle';
import search from '@salesforce/label/c.OD_Search';
import searchPlaceHolder from '@salesforce/label/c.OD_Search_Placeholder';
import noDistributorsFound from '@salesforce/label/c.OD_No_Distributors_Found';
import accountCol from '@salesforce/label/c.OD_Account_Col'; 
import typeCol from '@salesforce/label/c.OD_Type_Col';
import cityCol from '@salesforce/label/c.OD_City_Col';
import addDealer from '@salesforce/label/c.OD_Add_Dealer';
import selectDealer from '@salesforce/label/c.OD_Select_Dealer';
import cancel from '@salesforce/label/c.OD_Cancel';
import selectedItems from '@salesforce/label/c.OD_Selected_Items';

export default class OrderDealerLwc extends LightningElement {
    @api recordId;
    @track loading = true;
    @track keyword = '';
    @track distributors = [];
    @track selectedDistributors = [];
    @track dealers = [];
    @track selectedDealer = -1;
    @track noDistributorsFound = false;
    @track userUiTheme;
    @track labels = {
        title,
        subTitle,
        search,
        searchPlaceHolder,
        noDistributorsFound,
        accountCol,
        typeCol,
        cityCol,
        selectDealer,
        addDealer,
        cancel,
        selectedItems
    };

    // Lookup properties
    @track lookupRecentlyViewed = [];
    addDealerDisabled = true;

    @track order;
    @wire(getRecord, { recordId: '$recordId', fields: [ORDER_DISTRIBUTOR_FIELD]})
    wiredRecord({ error, data }) {
        if (error) {
            showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
        } else if (data) {
            this.order = data;
            this.getDealers();
        }
    };

    get orderDistributor() {
        return getFieldValue(this.order, ORDER_DISTRIBUTOR_FIELD);
    }

    connectedCallback() {
        this.uIThemeDisplayed();
        // this.getDealers();
    }

    uIThemeDisplayed() {
        uIThemeDisplayed()
            .then(result => {
                this.userUiTheme = result;
            })
            .catch(error => {
                showToast(this, this.userUiTheme, 'Error', JSON.stringify(error), 'error');
            });
    }

    getDealers() {
        getDealers({ orderId: this.recordId })
            .then(result => {
                const data = result.filter(dealer => dealer.hasOwnProperty('Dealer__r'));
                this.dealers = data.map((dealer, index) => {
                    if (dealer.Dealer__c === this.orderDistributor) {
                        dealer.isSelected = true;
                        dealer.isDisabled = true;
                        this.selectedDealer = index;
                    }
                    return dealer;
                });
                this.loading = false;
            })
            .catch(error => {
                this.loading = false;
                showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
            });
    }

    addDealerHandler() {
        const lookup = this.template.querySelector('c-lookup');
        this.selectedDistributors = lookup.getSelection().map(dealer => dealer.id);
        this.saveDealers();
    }

    saveDealers() {
        this.loading = true;
        const lookup = this.template.querySelector('c-lookup');
        saveDealers({
                distributors: this.selectedDistributors,
                orderId: this.recordId
            })
            .then(result => {
                this.selectedDistributors = [];
                this.dealers = result.map((dealer, index) => {
                    if (dealer.Dealer__c === this.orderDistributor) {
                        dealer.isSelected = true;
                        dealer.isDisabled = true;
                        this.selectedDealer = index;
                    }
                    return dealer;
                });
                lookup.selection = [];
                this.showAddNewDealer = false;
                this.loading = false;
            }).catch(error => {
                showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
                this.loading = false;
            });
    }

    updateDealerInfo() {
        this.loading = true;
        updateDealerInfo({
                orderId: this.recordId,
                dealerId: this.dealers[this.selectedDealer].Id
            })
            .then(result => {
                this.loading = false;
                this.closeQuickAction();
                this.refreshPage();
            }).catch(error => {
                this.loading = false;
                showToast(this, '', 'ERROR', error.body.message + error.body.stackTrace, 'error');
            });
    }

    handleSelectDealer(event) {
        const selectedIndex = event.currentTarget.dataset.index;
        if (!this.dealers[selectedIndex].isSelected) {
            if (selectedIndex !== this.selectedDealer) {
                this.dealers[selectedIndex].isSelected = true;
                if (this.selectedDealer > -1) {
                    this.dealers[this.selectedDealer].isSelected = false;
                }
                this.selectedDealer = selectedIndex;
            }
        } else {
            this.dealers[selectedIndex].isSelected = false;
            this.selectedDealer = -1;
        }
    }

    initSearch() {
        this.distributors = null;
        this.keyword = '';
    }

    get enableSelectDealerButton() {
        return this.selectedDealer < 0;
    }

    refreshPage() {
        if (this.userUiTheme.includes('Theme3')) {
            goToRecord(this.userUiTheme, this.recordId, this);
        } else {
            const refreshQA = new CustomEvent('refresh', {
                detail: ''
            });
            this.dispatchEvent(refreshQA);
        }
    }

    closeQuickAction() {
        if (this.userUiTheme.includes('Theme3')) {
            goToRecord(this.userUiTheme, this.recordId, this);
        } else {
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
        }
    }

    get hasDistributors() {
        return this.distributors ? this.distributors.length > 0 : false;
    }

    get hasSelectedDistributors() {
        return this.selectedDistributors ? this.selectedDistributors.length > 0 : false;
    }

    get isMobile() {
        return this.userUiTheme === 'Theme4t';
    }

    get bodyClass() {
        return this.isMobile ? 'body-mobile-height' : 'body-desktop-height';
    }
    
    // Lookup Component
    async handleSearch(event) {
        const target = event.target,
        detail = event.detail,
        selectedIds = this.dealers.map(dealer => dealer.Dealer__c);
        detail.selectedIds = [...detail.selectedIds, ...selectedIds];
        try {
            const results = await apexSearch(detail);
            target.setSearchResults(results);
        } catch (error) {
            // TODO: handle error
        }
    }

    handleLookupSelectionChange(event) {
        const selection = event.detail;
        this.addDealerDisabled = selection ? selection.length < 1 : true;
    }

    showAddNewDealer = false;
    handleShowAddDealer(event) {
        this.showAddNewDealer = !this.showAddNewDealer;
    }

    renderedCallback() {
        const radioButtons = this.template.querySelectorAll('input[name=distributor-radio]');
        if (radioButtons) {
            for (const radioButton of radioButtons) {
                if (radioButton.checked) {
                    radioButton.closest('tr').classList.add('slds-is-selected');
                } else if (radioButton.closest('tr.slds-is-selected')) {
                    radioButton.closest('tr.slds-is-selected').classList.remove('slds-is-selected');
                }
            }
        }
    }
}