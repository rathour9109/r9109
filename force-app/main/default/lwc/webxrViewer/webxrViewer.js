import { LightningElement } from 'lwc';
import htmlFile from '@salesforce/resourceUrl/index';
import glbFile from '@salesforce/resourceUrl/mouseGLB';
import usdzFile from '@salesforce/resourceUrl/mouseUSDZ';

export default class WebxrViewer extends LightningElement {
    htmlUrl = htmlFile;
    glbUrl = glbFile;
    usdzUrl = usdzFile; 

    get finalUrl() {
        const params = new URLSearchParams({
            glb: this.glbUrl,
            usdz: this.usdzUrl
        });
        return `${this.htmlUrl}?${params.toString()}`;
    }
}