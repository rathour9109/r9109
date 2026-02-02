import { LightningElement, api, track } from 'lwc';
import linkFiles from '@salesforce/apex/FileUploadController.linkFiles';
import deleteFiles from '@salesforce/apex/FileUploadController.deleteFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploader extends LightningElement {

    @api recordId;

    @track uploadedDocumentIds = [];
    @track uploadedFiles = [];
    @track showProgress = false;
    @track currentStep = '1';
    @track statusMessage = '';

    CHUNK_SIZE = 100;

    get isSubmitDisabled() {
        return this.uploadedDocumentIds.length === 0;
    }

    chunkArray(array, chunkSize) {
        const chunks = [];
        for (let i = 0; i < array.length; i += chunkSize) {
            chunks.push(array.slice(i, i + chunkSize));
        }
        return chunks;
    }

    handleUploadFinished(event) {
        event.detail.files.forEach(file => {
            if (!this.uploadedDocumentIds.includes(file.documentId)) {
                this.uploadedDocumentIds.push(file.documentId);
                this.uploadedFiles.push(file);
            }
        });

        this.showProgress = true;
        this.currentStep = '3';
        this.statusMessage = 'Files uploaded. You can add more or click Submit.';
    }

    async handleSubmit() {
        if (this.uploadedDocumentIds.length === 0) return;

        try {
            this.showProgress = true;
            this.currentStep = '2';
            this.statusMessage = 'Submitting files...';

            const chunkedIds = this.chunkArray(this.uploadedDocumentIds, this.CHUNK_SIZE);

            for (let i = 0; i < chunkedIds.length; i++) {
                this.statusMessage = `Submitting chunk ${i + 1} of ${chunkedIds.length}...`;

                await linkFiles({
                    documentIds: chunkedIds[i],
                    recordId: this.recordId
                });
            }

            this.currentStep = '3';
            this.statusMessage = 'All files submitted successfully.';

            this.uploadedDocumentIds = [];
            this.uploadedFiles = [];

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All files attached successfully',
                    variant: 'success'
                })
            );

        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Submit failed',
                    variant: 'error'
                })
            );
        }
    }

    async handleClear() {
        if (this.uploadedDocumentIds.length > 0) {
            const chunkedIds = this.chunkArray(this.uploadedDocumentIds, this.CHUNK_SIZE);

            for (let i = 0; i < chunkedIds.length; i++) {
                this.statusMessage = `Deleting chunk ${i + 1} of ${chunkedIds.length}...`;
                await deleteFiles({ documentIds: chunkedIds[i] });
            }
        }

        this.uploadedDocumentIds = [];
        this.uploadedFiles = [];
        this.showProgress = false;
        this.currentStep = '1';
        this.statusMessage = '';
    }
}