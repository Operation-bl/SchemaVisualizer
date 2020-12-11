import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getSObjectOptions from '@salesforce/apex/SchemaVisualizerController.getSObjectOptions';
import getWrappedSObjectDescribe from '@salesforce/apex/SchemaVisualizerController.getWrappedSObjectDescribe';

const ERROR_TOAST_TITLE = 'ERROR!',
    DEFAULT_ICON_PATH = '/img/icon/t4v35/utility/ban_120.png',
    DEFAULT_ICON_COLOR = 'transparent',
    DEFAULT_FIELDS_DATA_COLUMNS_DESCRIBE = [
        { label: 'Field Label' , fieldName: 'label' , type: 'text' },
        { label: 'Field Name' , fieldName: 'name' , type: 'text' },
        { label: 'Is Custom' , fieldName: 'isCustom' , type: 'boolean' },
        { label: 'Is Reference' , fieldName: 'isReference' , type: 'boolean' },
        { label: 'Is Accessible' , fieldName: 'isAccessible' , type: 'boolean' },
    ];

export default class SchemaVisualizer extends LightningElement {

    isBusy = true;
    sObjectOptions = [];
    sObjectApiName;
    fieldsDataColumnsDescribe = DEFAULT_FIELDS_DATA_COLUMNS_DESCRIBE;
    fieldsData = [];
    sObjectDescribe = {};

    @wire(getSObjectOptions)
    wiredOptions({data, error}) {
        if (data) {
            this.sObjectOptions = data;
        } else if (error) {
            this.showError(error.body.message);
        }
        this.toggleSpinner(false);
    }

    /**
     * Used to get correct image url, because Schema.DescribeIconResult can return inappropriate results and
     * UI API is preferable for such a use cases
     */
    @wire(getObjectInfo, {objectApiName: '$sObjectApiName'})
    wiredObjectInfo({data, error}) {
        if (data) {
            this.buildDataForUI(this.convertDataFromUIApi(data));
            this.toggleSpinner(false);
        } else if (error) {
            // It is needed in order to take sObject that is not accessible(e.g. non-queryable) within the UI API
            this.getSObjectDescribe(this.sObjectApiName);
        }
    }

    getSObjectDescribe(sObjectApiName) {
        getWrappedSObjectDescribe({sObjectApiName})
            .then(result => this.buildDataForUI(this.convertDataFromSchema(result)))
            .catch(error => this.showError(typeof error === 'string' ? error : error.body.message))
            .finally(() => this.toggleSpinner(false));
    }

    handleSObjectChange(event) {
        this.sObjectApiName = event.target.value;
        this.toggleSpinner(true);
    }

    buildDataForUI(data) {
        const {
            label,
            color,
            apiName,
            iconUrl,
            isCustom,
            keyPrefix,
            isQueryable,
            isUpdateable,
            isAccessible,
            fieldDescribes,
        } = data,
            iconStyle = `background-color: ${color}; background-image: url(${iconUrl});`;
        this.sObjectDescribe = {
            label,
            apiName,
            isCustom,
            keyPrefix,
            iconStyle,
            isQueryable,
            isUpdateable,
            isAccessible,
        };
        this.fieldsData = [...fieldDescribes];
    }

    convertDataFromUIApi(rawData) {
        const {
            label,
            apiName,
            custom : isCustom,
            keyPrefix,
            queryable : isQueryable,
            updateable : isUpdateable,
            fields : rawFields,
            themeInfo : {
                color,
                iconUrl,
            },
        } = rawData,
            isAccessible = true, //Because UI API would return error for inaccessible sObjects
            fieldDescribes = Object.values(rawFields).map(rawField => {
                const {
                    label,
                    apiName : name,
                    custom : isCustom,
                    reference : isReference,
                } = rawField;
                return {
                    name,
                    label,
                    isCustom,
                    isReference,
                    isAccessible : true, //Same as for sObject Accessibility
                }
            }).sort((a, b) => {
                let result = 0;
                if (a.label > b.label) {
                    result = 1;
                } else if (a.label < b.label) {
                    result = -1;
                }
                return result;
            });

        return {
            label,
            apiName,
            iconUrl,
            isCustom,
            keyPrefix,
            isQueryable,
            isUpdateable,
            isAccessible,
            fieldDescribes,
            color : `#${color}`,
        };
    }
    convertDataFromSchema(rawData) {
        return {
            ...rawData,
            iconUrl: DEFAULT_ICON_PATH,
            color: DEFAULT_ICON_COLOR,
        }
    }

    toggleSpinner(isBusy) {
        this.isBusy = isBusy;
    }

    showError(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                message,
                variant: 'error',
                title: ERROR_TOAST_TITLE,
            })
        );
    }
}