import { LightningElement, wire, track } from 'lwc';
import getAccList from '@salesforce/apex/accountFilteredList.getAccList';

export default class AccountTable extends LightningElement {
    @track error;
    @track accList = [];

    @wire(getAccList) 
    wiredAccounts({ error, data }) {
        if (data) {
            this.accList = data;
        } else if (error) {
            this.error = error;
        }
    }
}