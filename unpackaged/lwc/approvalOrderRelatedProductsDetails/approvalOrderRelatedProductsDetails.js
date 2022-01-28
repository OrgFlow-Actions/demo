import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';

import getOrderItems from '@salesforce/apex/getApprovalProcessRecordDetailController.getOrderItems';
import showAllRecordsLabel from '@salesforce/label/c.LWCApprovalOrderItemsShowAll';
import orderProductsLabel from '@salesforce/label/c.LWCApprovalOrderItemsOrderProducts';

import orderItemObject from '@salesforce/schema/OrderItem';
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';

export default class ShowApprovalRecordDetails extends LightningElement {
    @api recordId;
    @api prop1;

    @track allOrderItems;
    @track orderItemsToShow;
    @track errorOI;
    @track showButton;
    @track showComponent;

    @track orderItemInfo;


    /*get our custom label*/
    customLabel = {
        showAllRecordsLabel,
        orderProductsLabel,
    };

    /*get our field labels*/
    @wire(getObjectInfo, {
        objectApiName: orderItemObject
    })
    detailsOrderItem({
        data,
        error
    }) {
        if (data) {
            this.orderItemInfo = data;

        }
    }

    @wire(getOrderItems, {
        recordId: '$recordId'
    })
    getOrderItems({
        data,
        error
    }) {
        if (data) {
            /*at the begining only we need to show maximun 10 order items*/
            const initialNumberOfItems = 10;
            this.allOrderItems = data;
            this.showComponent = data.length > 0;
            this.orderItemsToShow = data.slice(0, initialNumberOfItems);
            this.showButton = data.length > initialNumberOfItems;
            this.error = undefined;

        }
        else if (error) {
            this.errorOI = error;
            this.data  = undefined;
        }
    }
    
    /*show all records*/
    showAllRecords() {
        this.orderItemsToShow = this.allOrderItems;
        this.showButton = false;
    }
}