import { LightningElement, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import STAGE from '@salesforce/schema/Opportunity.StageName';

import createOpportunity from '@salesforce/apex/NewOpportunity.createOpportunity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class NewOpportunityLWC extends LightningElement {

    @api recordId;

    contactName = '';
    contactId = '';
    opportunityName = '';
    stage = '';
    closeDate = '';

    connectedCallback(){
        console.log('connectedCallback', this.recordId);
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    opportunityInfo;

    @wire (getRecord, { recordId: '$recordId', fields: [CONTACT_NAME] })
    wiredContact({ data, error }){
        if (data) {
            this.contactName = data.fields.Name.value;
            this.contactId = this.recordId;
        } else if (error) {
            console.error('Error fetching contact', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$opportunityInfo.data.defaultRecordTypeId',
        fieldApiName: STAGE
    })
    wiredStageValues({ data, error }) {
        if(data) {
            this.stageOptions = data.values.map(value => ({
                label: value.label,
                value: value.value
            }));
        } else if (error) {
            console.error('Error fetching stage values', error);
        }
    }
    handleChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;   
    }

    async handleSubmit() {
        if(!this.contactId || !this.opportunityName || !this.stage || !this.closeDate) {
            this.showToast('Error','Please fill all required fields.', 'error');
            return;
        } 
        try {
            await createOpportunity({
                contactId: this.contactId,
                name: this.opportunityName,
                stage: this.stage,
                closeDate: this.closeDate
            });

            this.showToast('Success','New Opportunity created successfully.', 'success');
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            console.error('Error creating new Opportunity', error);
            this.showToast('Error', error.body.message, 'error');
        }
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}