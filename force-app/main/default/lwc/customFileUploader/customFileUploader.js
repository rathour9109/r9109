import { LightningElement, api, track } from 'lwc';
import uploadChunk from '@salesforce/apex/ChunkCustomFileUploaderController.uploadChunk';
import cancelUpload from '@salesforce/apex/ChunkCustomFileUploaderController.cancelUpload';

const CHUNK_SIZE = 3 * 1024 * 1024;

export default class customFileUploader extends LightningElement {
    @api recordId;
    @track fileItems = [];

    handleFileChange(event) {
        const files = [...event.target.files];
        this.fileItems = files.map(file => ({
            file,
            uploadId: crypto.randomUUID(),
            progress: 0,
            status: 'READY',
            isUploading: false,
            isError: false,
            isReady: true,
            isDone: false,
            previewUrl: file.type.startsWith('image/') ? URL.createObjectURL(file) : null
        }));
    }

    async startUpload() {
        for (const item of this.fileItems) {
            if (item.isReady) {
                await this.uploadFile(item);
            }
        }
    }

    async uploadFile(item) {
        item.status = 'UPLOADING';
        item.isUploading = true;
        item.isError = false;
        item.isReady = false;
        item.isDone = false;
        this.updateItem(item);

        let start = 0;
        let chunkIndex = 0;

        try {
            while (start < item.file.size) {
                if (item.status === 'CANCELLED') return;

                const end = Math.min(start + CHUNK_SIZE, item.file.size);
                const blob = item.file.slice(start, end);
                const base64 = await this.readBlob(blob);

                await uploadChunk({
                    uploadId: item.uploadId,
                    fileName: item.file.name,
                    chunkData: base64,
                    chunkIndex,
                    isLastChunk: end === item.file.size,
                    recordId: this.recordId
                });

                start = end;
                chunkIndex++;
                item.progress = Math.floor((start / item.file.size) * 100);
                this.updateItem(item);
            }

            item.status = 'DONE';
            item.isUploading = false;
            item.isError = false;
            item.isReady = false;
            item.isDone = true;
            this.updateItem(item);
        } catch (e) {
            item.status = 'ERROR';
            item.isUploading = false;
            item.isError = true;
            item.isReady = false;
            item.isDone = false;
            this.updateItem(item);
        }
    }

    cancelFile(event) {
        const uploadId = event.target.dataset.id;
        const item = this.fileItems.find(f => f.uploadId === uploadId);
        item.status = 'CANCELLED';
        item.isUploading = false;
        this.updateItem(item);
        cancelUpload({ uploadId });
    }

    retryFile(event) {
        const uploadId = event.target.dataset.id;
        const item = this.fileItems.find(f => f.uploadId === uploadId);

        item.status = 'READY';
        item.progress = 0;
        item.isError = false;
        item.isReady = true;
        item.isDone = false;
        this.updateItem(item);

        this.uploadFile(item);
    }

    clearAllFiles() {
        this.fileItems = [];
    }

    readBlob(blob) {
        return new Promise(resolve => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.readAsDataURL(blob);
        });
    }

    updateItem(item) {
        this.fileItems = this.fileItems.map(f => f.uploadId === item.uploadId ? { ...item } : f);
    }
}