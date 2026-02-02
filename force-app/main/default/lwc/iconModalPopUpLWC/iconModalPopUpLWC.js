import { LightningElement } from 'lwc';
import IndiaFlag from '@salesforce/resourceUrl/IndiaFlag';
import RussiaFlag from '@salesforce/resourceUrl/RussiaFlag';
import UsFlag from '@salesforce/resourceUrl/UsFlag';
import ChinaFlag from '@salesforce/resourceUrl/ChinaFlag';

export default class IconModalPopUpLWC extends LightningElement {

    IndiaFlag = IndiaFlag;
    RussiaFlag = RussiaFlag;
    UsFlag = UsFlag;
    ChinaFlag = ChinaFlag;

    showModal = false;
    selectedType = '';
    selectedTypeNumber = 0;

    handleImageClick(event) {
        console.log('event', event.currentTarget.dataset.type);
        const type = event.currentTarget.dataset.type;

        let typeNumber = 0;
        if (type === 'india') {
            typeNumber = 1;
        } else if (type === 'russia') {
            typeNumber = 2;
        } else if (type === 'us') {
            typeNumber = 3;
        } else if (type === 'china') {
            typeNumber = 4;
        }

        this.selectedType = type;
        this.selectedTypeNumber = typeNumber;
        this.showModal = true;

    }

    handleCloseModal() {
        this.showModal = false;
        this.selectedType = '';
        this.selectedTypeNumber = 0;
    }

    get modalTitle() {
        return `Flag : ${this.selectedType.toUpperCase()}`;
    }
}