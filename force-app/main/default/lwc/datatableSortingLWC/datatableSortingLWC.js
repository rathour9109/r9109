import { LightningElement, wire } from 'lwc';
import getContact from '@salesforce/apex/DataTableController.getContact';
import { loadStyle } from 'lightning/platformResourceLoader';
import MY_CUSTOM_STYLES from '@salesforce/resourceUrl/myCustomStyles';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: "true" },
    { label: 'Last Name', fieldName: 'LastName', type: 'text', sortable: "true" },
    { label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: "true" },
    { label: 'Email', fieldName: 'Email', type: 'email', sortable: "true" }
];
export default class DatatableSortingLWC extends LightningElement {
    columns = columns;

    data;
    error;
    sortBy;
    sortDirection;
    sortdata;

    connectedCallback() {
        loadStyle(this, MY_CUSTOM_STYLES)
            .then(() => {
                console.log('Custom CSS loaded successfully');
            })
            .catch(error => {
                console.error('Error loading custom CSS:', error);
            });
    }

    @wire(getContact)
    contacts(results) {
        if (results.data) {
            this.data = results.data;
            this.error = undefined;
        } else if (results.error) {
            this.data = undefined;
            this.error = results.error;
        }
    }



    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));

        let keyValue = a => a[fieldname];

        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

}