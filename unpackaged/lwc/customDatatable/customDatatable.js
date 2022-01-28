import richText from './richText.html';
import colors from './colors.html';
import customEditor from './customEditor.html';
import LightningDatatable from 'lightning/datatable';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        richText: {
            template: richText,
            editTemplate: customEditor,
            standardCellLayout: true,
            typeAttributes: ['iseditable']
        },
        colors:{
            template: colors,
            standardCellLayout: true,
            typeAttributes: ['ispicklisteditable','iconName']
        }
    }

}