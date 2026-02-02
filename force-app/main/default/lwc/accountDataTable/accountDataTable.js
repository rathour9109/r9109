import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountPaginationController.getAccounts';

export default class AccountDataTableWithPagination extends LightningElement {
    @track accounts = [];
    @track searchKey = '';
    @track firstRecordId;
    @track lastRecordId;
    @track direction = 'next';
    @track isNextDisabled = false;
    @track isPrevDisabled = true;
    @track pageNumber = 1;
    @track isLoading = false;
    pageSize = 50;

    columns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text' },
        { label: 'Industry', fieldName: 'Industry', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' }
    ];

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        this.isLoading = true;

        try {
            const response = await getAccounts({
                searchKey: this.searchKey || '',
                direction: this.direction,
                lastId: this.direction === 'next' ? this.lastRecordId : this.firstRecordId,
                pageSize: this.pageSize
            });

            this.accounts = response.records || [];

            if (this.accounts.length > 0) {
                this.firstRecordId = this.accounts[0].Id;
                this.lastRecordId = this.accounts[this.accounts.length - 1].Id;
            }

            this.isNextDisabled = this.accounts.length < this.pageSize;
            this.isPrevDisabled = this.pageNumber === 1;

        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.resetPagination();
        this.loadData();
    }

    handleNext() {
        if (this.isNextDisabled) return;
        this.direction = 'next';
        this.pageNumber += 1;
        this.isPrevDisabled = false;
        this.loadData();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.direction = 'previous';
            this.pageNumber -= 1;
            this.loadData();
        }
    }

    resetPagination() {
        this.pageNumber = 1;
        this.firstRecordId = undefined;
        this.lastRecordId = undefined;
        this.isPrevDisabled = true;
        this.isNextDisabled = false;
        this.direction = 'next';
    }

    get disablePrev() {
        return this.isPrevDisabled;
    }

    get disableNext() {
        return this.isNextDisabled;
    }

    get pageLabel() {
        return `Page ${this.pageNumber}`;
    }
}