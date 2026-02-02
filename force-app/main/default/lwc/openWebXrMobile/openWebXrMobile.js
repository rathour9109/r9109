import { LightningElement } from 'lwc';

export default class OpenWebXrMobile extends LightningElement {
    showViewer = false;

    toggle() {
        this.showViewer = true;
    }
}