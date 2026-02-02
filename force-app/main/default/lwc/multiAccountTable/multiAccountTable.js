import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNewAccount from '@salesforce/apex/AccountController.createAccList';
import { loadStyle } from 'lightning/platformResourceLoader';
import MY_CUSTOM_STYLES from '@salesforce/resourceUrl/myCustomStyles';

export default class MultiAccountTable extends LightningElement {
    @track accounts = [{ no: 1, name: '', website: '', phone: '' }];
    counter = 2;

    connectedCallback() {
        loadStyle(this, MY_CUSTOM_STYLES)
            .then(() => {
                console.log('Custom CSS loaded successfully');
            })
            .catch(error => {
                console.error('Error loading custom CSS:', error);
            });
    }

    get numberedAccounts() {
        return this.accounts.map((acc, index) => ({ ...acc, rowNumber: index + 1 }));
    }


    addRow() {
        this.accounts = [...this.accounts, { no: this.counter++, id: this.counter, name: '', website: '', phone: '' }];
    }


    deleteRow(event) {
        const delRow = event.target.dataset.id;
        this.accounts = this.accounts.filter(acc => acc.no != delRow);
    }


    deleteAllRows() {
        this.accounts = [];
    }


    handleInputChange(event) {
        const { id, field } = event.target.dataset;
        this.accounts = this.accounts.map(acc =>
            acc.id == id ? { ...acc, [field]: event.target.value } : acc
        );
    }


    checkValidity() {

        console.log('-----3-----');
        if (this.accounts.length === 0) {
            this.showToast('Error', 'There are no accounts to create.', 'error');
            return false;
        }

        const invalidAccounts = this.accounts.filter(acc => !acc.name);
        if (invalidAccounts.length > 0) {
            this.showToast('Error', 'Each account must have a name.', 'error');
            return false;
        }
        return true;
    }


    handleCreateAccount() {

        console.log('-----1-----');
        if (!this.checkValidity()) {
            return;
        }
        console.log('-----2-----');

        const accountsToCreate = this.accounts.map(acc => ({
            Name: acc.name,
            Website: acc.website ? acc.website : null,
            Phone: acc.phone ? acc.phone : null
        }));

        createNewAccount({ accList: accountsToCreate })
            .then(() => {
                this.showToast('Success', 'Accounts created successfully.', 'success');
                this.accounts = [{ id: 1, name: '', website: '', phone: '' }];
                this.counter = 2;
            })
            .catch((error) => {
                console.error('Error creating accounts:', error);
                this.showToast(
                    'Error',
                    'Failed to create accounts. ' + (error.body?.message || 'Unknown error'),
                    'error'
                );
            });
    }


    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

}