import { LightningElement, api, track } from 'lwc';
import readBusinessCardBase64 from '@salesforce/apex/EinsteinOCRService.readBusinessCardBase64';
import logTask from '@salesforce/apex/EinsteinOCRService.logActivity';
import readTextFromImageByBase64 from '@salesforce/apex/EinsteinOCRService.readTextFromImageByBase64';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class EinsteinOCR extends NavigationMixin(LightningElement) {
    @api recordId;
    @track contact;
    @track duplicates;
    @track duplicatesExist;
    @track dupCount;
    @track dupObject;
    @track dupObjectIsContact;
    @track objectName;
    @track objectIsContact;
    @track scanningComplete;
    @track recordSelected;
    @track recordSuccess;
    @track updatedRecord;
    @track selectedAccountId;
    @track logActivity;
    @track marketingConsent;
    resultCard;
    fileReader;
    fileContents;
    content;
    file;
    errors;
    MAX_FILE_SIZE = 10000000; //1500000;
    sizeLongMessage;
    isLoading = false;
    fileLabel = 'Upload Image'
    fileName = 'file not selected'
    isBusinessCarrd = true;
    value = 'Contact';

    get options() {
        return [
            { label: 'Contact', value: 'Contact' },
            { label: 'Lead', value: 'Lead' }
        ];
    }

    connectedCallback(){
        this.duplicatesExist = false;
        this.objectName = 'Contact';
        this.dupCount =0;
        this.recordSelected = false;
        this.recordSuccess = false;
        this.logActivity = true;
        this.scanningComplete = false;
    }

    handleChangePick(event){
        this.value = event.target.value;
    }

    handleChange(event){
        this.isBusinessCarrd = event.target.checked;
    }

    handleFilesChange(event){
        this.file = event.target.files[0];
        this.fileName = event.target.files[0]['name'];
        this.dupCount = 0;
        this.dupObject = null;
        this.duplicatesExist = false;
        this.startPrediction();
    }

    objectIsContact(){
        if(this.objectName == "Contact"){
            this.objectIsContact = true;
        }
        else{
            this.objectIsContact = false;
        }
    }

    handleActivity(event){
        console.log('Log activity?: ' + event.target.checked);
        this.logActivity = event.target.checked;
    }

    handleSuccess(event){

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!',
                message: 'A record has been created/updated with the id ' + event.detail.id,
                variant: 'info'
            })
        );

        if(this.logActivity == true){
            logTask({
                recordId : event.detail.id,
                accountId:  this.accountId
            })
            .then(result => {
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            })
        };

        this.updatedRecord = event.detail.id;
        //this.contact = null;
        this.dupCount = 0;
        this.dupObject = null;
        this.selectedAccountId = null;
        this.recordSuccess = true;
        this.isLoading = false;
        return ;
    }

    handleDupSelected(event){
        console.log('Dup selected!');
        console.log(event.target.id);
        this.selectedAccountId = event.target.id.substring(0,18);
        this.recordSelected = true;
    }

    collectMarketingConsent(event){
        console.log(event.target.id);
        console.log(event.target.value);
        this.marketingConsent = true;
    }

    createSalesLead(){
        console.log('Creating sales lead');

        let flowUrl = '/flow/Lead_Create_lead_from_account?';
        flowUrl = flowUrl + 'recordId=' + this.updatedRecord;
            
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: flowUrl
                }
            },
            true // Replaces the current page in your browser history with the URL
          );

    }

    showSpinner(){
        this.isLoading = true;
    }

    goToRecord(){
        console.log('Navigate to record ' + this.updatedRecord);
        let recId = this.updatedRecord;
                // Generate a URL to a User record page
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recId,
                        objectApiName: 'Contact',
                        actionName: 'view',
                    },
                });
    }

    scanAgain(){
        this.scanningComplete = false;
        this.recordSuccess = false;
        this.recordSelected = false;
        this.updatedRecord = null;
        this.duplicates = null;
        this.duplicatesExist = false;
        this.dupCount =0;
        this.selectedAccountId = null;
        this.contact = null;
        this.isLoading = false;
    }

    startPrediction(){


        if (this.file.size > this.MAX_FILE_SIZE) {
            this.sizeLongMessage = this.file.size+' File Size is to long';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File size too large',
                    message: 'File size too large',
                    variant: 'info'
                })
            );
            return ;
        }

        this.isLoading = true;
        this.recordSuccess = false;
        this.scanningComplete = true;
        this.fileReader= new FileReader();

        this.fileReader.onloadend = (() => {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scanning business card',
                    message: 'Scanning business card',
                    variant: 'info'
                })
            );

            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            if(this.isBusinessCarrd){
                this.readBinaryFile(this.fileContents);
            }else{
                this.readImageFROMOCR(this.fileContents);
            }
        });
        this.fileReader.readAsDataURL(this.file);
    }

    readImageFROMOCR(binaryData){
        readTextFromImageByBase64({
            sample : binaryData
        })
        .then(result => {
            let returnedData = JSON.parse(result);
            this.resultCard = result? JSON.stringify(returnedData, undefined, 4): "no prediction found";
            let textArea = this.template.querySelector('textarea');
            textArea.innerHTML = this.resultCard;
            this.errors = undefined;
            console.log({
                message : 'Response From Einstein Platform API',
                data : result
            });
        })
        .catch(error => {
            this.errors = error;
            this.resultCard = undefined;
            console.error({
                message : 'Error occured while making callout to Einstein API',
                data : error
            })
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error occurred during scanning',
                    message: 'The business card could not be scanned properly',
                    variant: 'info'
                })
            );
        })
        .finally(()=>{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scanning complete',
                    message: 'Scanning complete',
                    variant: 'info'
                })
            );
        })
    }

    readBinaryFile(binaryData){
        readBusinessCardBase64({
            sampleBusinessCard : binaryData,
            objectName : this.value,
            recordId : this.recordId
        })
        .then(result => {
            let returnedData = JSON.parse(result.response);
            //let returnedDataRecord = JSON.parse(result.record);
            let resultCard1 = result? JSON.stringify(returnedData, undefined, 4): "no prediction found";
            this.resultRecord = result? JSON.stringify(result.record, undefined, 4): "no prediction found";
            let duplicateString = result? JSON.stringify(result.duplicates, undefined, 4): "no duplicate found";
            let objectNameString = result? JSON.stringify(result.objecttype, undefined, 4): "no object name found";
            console.log(result.duplicates);

            if(duplicateString != '[]'){
                console.log('Assigning duplicates');
                this.duplicates = JSON.parse(duplicateString);

                let dups = this.duplicates;

                for(var j in dups){
                    console.log('Dup id: ' + dups[j].Id);
                    let idPrefix = dups[j].Id.substring(0,3);
                    if(idPrefix == '001'){
                        dups[j].ObjectType = 'Account';
                        if(this.dupObject != 'Contact'){
                            this.dupObject = 'Account';
                            this.dupObjectIsContact = false;
                        }
                    }
                    if(idPrefix == '003'){
                        dups[j].ObjectType = 'Contact';
                        this.dupObject = 'Contact';
                        this.dupObjectIsContact = true;
                    }
                    if(idPrefix == '00Q'){
                        dups[j].ObjectType = 'Lead';
                        this.dupObjectIsContact = false;
                    }
                     
                }

                this.duplicates = dups;

                this.duplicatesExist = true;
                this.dupCount = this.duplicates.length;
                if(this.dupCount > 1){
                    this.recordSelected = false;
                    for(var n = 0; n < this.duplicates.length; n++){
                        if(this.duplicates[n].ObjectType != this.dupObject){
                            this.duplicates.splice(n, 1);
                            n--;
                        }
                    }
                }
                else{
                    this.recordSelected = true;
                    this.selectedAccountId = this.duplicates[0].Id;
                }
            }
            this.contact = JSON.parse(this.resultRecord);

            console.log('Object name: ' + objectNameString);
            this.objectName = objectNameString;

            console.log({
                message: 'Record',
                data: JSON.stringify(this.contact)
            });

            console.log({
                message: 'Duplicates',
                data: this.duplicates
            });
            //console.log(result.response.data.record);
            
            /*let textArea = this.template.querySelector('textarea');
            textArea.innerHTML = resultCard1;*/

            /*let txtArea = this.template.querySelector('.recordDetailsClass');
            txtArea.innerHTML = this.resultRecord;*/
            this.errors = undefined;

            console.log({
                message : 'Response From Einstein Platform API',
                data : result
            });
        })
        .catch(error => {
            this.errors = error;
            this.resultCard = undefined;
            console.error({
                message : 'Error Occured While making callout to Einstein API',
                data : error
            })
        })
        .finally(()=>{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Scanning complete',
                    message: 'Scanning complete',
                    variant: 'info'
                })
            );
            console.log(this.objectName);
            console.log(this.template.querySelector('lightning-record-edit-form'));

        })
    }
}