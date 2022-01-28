import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class Flow_progressIndicator extends LightningElement {
    @api currentStage;
    @api stages;
    @api type = "base";
    @api variant = "base";
    _hasError;

    // Used for navigation control
    @api availableActions = [];
    @api selectedStage;

    connectedCallback() {
        this.selectedStage = null;
    }

    handleClick(event) {
        const stepIndex = event.target.value;
        this.selectedStage = event.target.value;
        // dispatch that selectedStage has changed
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedStage', this.selectedStage);
        this.dispatchEvent(attributeChangeEvent);
        console.log(`stepIndex::${stepIndex} selectedStage::${this.selectedStage}`);

        // Navigate to next
        if (this.availableActions.find(action => action === 'NEXT') && this.currentStage !== this.selectedStage) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}