import { LightningElement } from 'lwc';

export default class ComponentX extends LightningElement {
    inputValue = '';
    submittedValue = '';

    handleInputChange(event) {
        this.inputValue = event.target.value;
    }

    handleSubmit() {
        this.submittedValue = this.inputValue;
    }
}