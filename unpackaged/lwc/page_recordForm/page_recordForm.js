import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import exequteSoql from '@salesforce/apex/flowContactController.executeSoql';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class Page_recordForm extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track record;
    @track childrecordId = '';
    @api sObjectName;
    @track error;
    @api title;
    @api icon;
    @api variant='base';
    @api fields='[""]';
    @api requiredfields ='[""]';
    @api columns;
    @api mode='view';
    @api fieldApiName = '';
    @api queryField = '';
    @api queryObject = '';
    @track _fields = [];
    @track _editFields = [];
    @track _requiredFields =[];
    @track _fieldApiName;
    @track fieldLayoutStr;
    @track _fieldLayoutStr = [];
    @track isEditMode = false;
    @track isLoading = false;
    @track queryString;    

    wiredRecordsResult;

    connectedCallback() {
        this._fields = JSON.parse(this.fields);
        this._requiredFields = JSON.parse(this.requiredfields);

        //Create Set for all required fields
        let requiredSet = new Set();
        var reqLen = this._requiredFields.length;
        for(var j=0;j<reqLen;j++){
            requiredSet.add(this._requiredFields[j]);
        }

        //Go through each field to add, and check if it should be required
        var fieldLen = this._fields.length;
        for(var i=0;i<fieldLen;i++){
            var field = {};
            field.fieldName = this._fields[i];
            if(requiredSet.has(field.fieldName)){
                field.required = true;
            }else{
                field.required = false;
            }           
            this._editFields.push(field);
        }

        //Format input for getRecord and getFieldValue methods
        this.fieldLayoutStr = '{"fieldApiName":"' + this.fieldApiName + '", "objectApiName":"' + this.sObjectName +'"}';
        this._fieldLayoutStr = JSON.parse(this.fieldLayoutStr);
        this._fieldApiName = JSON.parse('["'+ this.objectApiName + '.' + this.fieldApiName + '"]');

        //Check form factor and adjust columns accordingly
        if(FORM_FACTOR == 'Large'){
            this.columns = 2;
        }
        else{
            this.columns = 1;
        }
        
        this.queryString = 'SELECT ' + this.queryField + ' FROM ' + this.objectApiName;

        //this.handleLoad();
        
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$_fieldApiName'})
    record(result){
        console.log('Record: ', result.data);
        this.record = result.data;
    };

    handleLoad(){
        console.log("Loading apex");
        getRecord({ recordId: this.recordId, fields: this.fieldApiName})
            .then(result => {
                console.log('Record: ', result.data);
                this.record = result.data;
            })
            .catch(error => {
                this.error = error;
            });

    }

    @wire(exequteSoql, { fieldName: '$queryField', childObject: '$queryObject', objectName: '$objectApiName', recordId: '$recordId'})
    soqlResult(result){
        var res = result.data;

        if(res){      
        var record = res[0];
        var childRecord = record[this.queryObject][0];    
        this.childrecordId = childRecord[this.queryField];
        console.log('Child record Id: ', this.childrecordId);
        }

    };

    get fieldId() {
        var fieldVal = '';
        if(this.childrecordId == ''){
            fieldVal = getFieldValue(this.record, this._fieldLayoutStr);       
        }
        else{
            fieldVal = this.childrecordId;
        }

        console.log('Field value: ' + fieldVal);
        return fieldVal;
    }

    editMode(){
        if(this.isEditMode == false){
            this.isEditMode = true;
        }else{
            this.isEditMode = false;
        }    
    }

    submitChange(event){
        event.preventDefault();
        //Find hidden Submit button in lightnin-record-edit-form, and press it
        var buttons = this.template.querySelectorAll('lightning-button');
        buttons[0].click();        
    }

    submitHandler(){
        console.log("Submitted");
        //this.isLoading = true;
    }
    successHandler(){
        this.isEditMode = false;
        //this.isLoading = false;
    }

}