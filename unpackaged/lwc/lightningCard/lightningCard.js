import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class LightningCard extends LightningElement {
    /** External properties */
    @api cardTitle;
    @api cardIconName;
    @api enableEditMode;
    @api spinnerVariant;
    @api isLoading;
    @api error;
    @api isEditMode;
    @api handleState; // If true, this component will handle switching between view and edit mode
    @api customDesktopEditActions;
    /** Internal properties */
    isDesktopFormFactor = FORM_FACTOR == 'Large';

    handleCardAction() {
        if (this.handleState) this.isEditMode = !this.isEditMode;
        const modeChange = new CustomEvent('modechange', { detail: this.isEditMode });
        this.dispatchEvent(modeChange);
    }

    handleSubmit() {
        const submit = new CustomEvent('mysubmit');
        this.dispatchEvent(submit);
    }

    get customCardClass() {
        return this.isEditMode === true && this.isDesktopFormFactor === true ? 'card-shadow slds-card' : '';
    }
}