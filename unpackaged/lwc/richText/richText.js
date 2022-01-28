import { api, track, LightningElement } from 'lwc';

export default class RichText extends LightningElement {
    @track validity;
    @api set value(value) {
        this._value = value;
    };
    get value() {
        return this._value;
    }

    _value;
    

    connectedCallback() {
        this._value = this.value;
        // if(this._value.length > 300){
        //     this.validity = false;
        //     this.errorMessage = "You have exceeded the max length";
        // }
    }

    
}