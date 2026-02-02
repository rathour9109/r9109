import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import RATING_FIELD from '@salesforce/schema/Account.Rating';
import SLA_FIELD from '@salesforce/schema/Account.SLA__c';

import searchAccounts from '@salesforce/apex/AccountFormController.searchAccounts';
import createAccount from '@salesforce/apex/AccountFormController.createAccount';
import updateAccount from '@salesforce/apex/AccountFormController.updateAccount';
import deleteAccount from '@salesforce/apex/AccountFormController.deleteAccount';

export default class AccountForm extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track searchKey = '';
    @track accounts;
    @track selectedAccountId;
    @track originalAccountData;
    @track name = '';
    @track rating = '';
    @track phone = '';
    @track sla = '';
    @track ratingOptions = [];
    @track slaOptions = [];

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: RATING_FIELD })
    wiredRating({ data, error }) {
        if (data) this.ratingOptions = data.values;
        else if (error) console.error('Rating picklist error:', error);
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SLA_FIELD })
    wiredSLA({ data, error }) {
        if (data) this.slaOptions = data.values;
        else if (error) console.error('SLA picklist error:', error);
    }

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Rating', fieldName: 'Rating' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'SLA', fieldName: 'SLA__c' }
    ];

    get hasSelection() { return !!this.selectedAccountId; }
    get noSelection() { return !this.selectedAccountId; }

    openModal() { this.isModalOpen = true; }
    closeModal() { 
        this.isModalOpen = false; this.resetState();
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length < 2) {
            this.accounts = undefined;
            return;
        }
        searchAccounts({ searchKey: this.searchKey })
            .then(result => this.accounts = result)
            .catch(error => console.error(error));
    }

    handleRowSelection(event) {
        const rows = event.detail.selectedRows;
        if (rows.length === 0) {
            this.resetState();
            return;
        }
        const acc = rows[0];
        this.selectedAccountId = acc.Id;
        this.name = acc.Name;
        this.rating = acc.Rating;
        this.phone = acc.Phone;
        this.sla = acc.SLA__c;
        this.originalAccountData = { ...acc };
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field.toLowerCase()] = event.target.value;
    }

    handleCreate() {
        createAccount({ fields: this.collectFields() })
            .then(id => { this.toRecordPage(id); this.closeModal(); })
            .catch(error => console.error(error));
    }

    handleUpdate() {
        updateAccount({ fields: { Id: this.selectedAccountId, ...this.collectFields() } })
            .then(() => { this.toRecordPage(this.selectedAccountId); this.closeModal(); })
            .catch(error => console.error(error));
    }

    handleDelete() {
        deleteAccount({ accId: this.selectedAccountId })
            .then(() => this.closeModal())
            .catch(error => console.error(error));
    }

    handleReset() {
        this.resetState();
    }

    collectFields() {
        return {
            Name: this.name,
            Rating: this.rating,
            Phone: this.phone,
            SLA__c: this.sla
        };
    }

    toRecordPage(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    resetState() {
        this.searchKey = '';
        this.accounts = undefined;
        this.selectedAccountId = undefined;
        this.originalAccountData = undefined;
        this.name = '';
        this.rating = '';
        this.phone = '';
        this.sla = '';
    }
}