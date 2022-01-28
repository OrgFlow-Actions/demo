import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export function showToast(cmp, userTheme, title, message, variant) {
    if (userTheme.includes('Theme3')) {
        if (variant.toUpperCase() === 'ERROR' || variant.toUpperCase() === 'WARNING') {
            alert(title + ' : ' + message);
        }
    } else {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        cmp.dispatchEvent(event);
    }
}
export function goToRecord(userTheme, recordId, cmpClass, lightningOut = false) {
    if (userTheme.includes('Theme3') || lightningOut) {
        window.open('/' + recordId, '_self');
    } else {
        cmpClass[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
}

export function handleApexError({ error, message = 'An error occurred' }) {
    const errorDetail = error.body.message.match(/(?:[A-Z]*, )(.*?)(?=:)/);
    return {
        message: message,
        detail: errorDetail ? errorDetail[1] : error.body.message
    };
}