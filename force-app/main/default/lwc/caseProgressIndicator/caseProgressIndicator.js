import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, wire, api } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_ID from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import { getFieldValue, getRecord, updateRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseProgressIndicator extends LightningElement {
    statusOptions;
    @api recordId;
    caseStatusvalue;
    channelName = '/event/Case_Details__e';
    subscription ={};
    //1.get the picklist values

    @wire(getObjectInfo,{
        objectApiName: CASE_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues,{
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: STATUS_FIELD
    })
    picklistFunction({ data, error }) {
        if(data) {
            console.log("data", data);
            this.statusOptions = data.values;
        } else if (error) {
            console.log("Error while fetching picklist", error);
        }
    }

    //2.get the current value of the case status

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [STATUS_FIELD]
    })
    getRecordOutput({ data, error }) {
        if(data) {
            console.log("data", data);  
            this.caseStatusvalue = getFieldValue(data, STATUS_FIELD);
        } else if (error) {
            console.log("Error while fetching data", error);
        }
    }

    // Initializes the component
    connectedCallback() {
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) =>{
            console.log('New message received: ', JSON.stringify(response));
            this.handleEventResponse(response);
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    disconnectedCallback() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });

    }

    async handleEventResponse(response){
        console.log("response from postman", JSON.parse(JSON.stringify(response )));
        if(response.hasOwnProperty("data")) {
            let jsonObj = response.data;
            if(jsonObj.hasOwnProperty("payload")) {
                let responseCaseId = response.data.payload.Case_Id__c;
                let responseCaseStatus = response.data.payload.Case_Status__c;

                let fields ={};
                fields[CASE_ID.fieldApiName] = responseCaseId;
                fields[STATUS_FIELD.fieldApiName] = responseCaseStatus;
                let recordInput = {fields};
                await updateRecord(recordInput)
                await notifyRecordUpdateAvailable([{recordId: this.recordId}]);

                const event = new ShowToastEvent({
                    title: "Success",
                    message:
                        `Case Status is set to ${responseCaseStatus}`                   
                });
                this.dispatchEvent(event);
            }
        }
    }
    
}