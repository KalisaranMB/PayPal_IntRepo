import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Customer360 extends LightningElement {

     isConsumer = true
     isMerchant = false
     showNotification = () =>{
        const evt = new ShowToastEvent({
            title: "Some Title",
            message: "Some Message",
            variant: "success",
        });
        this.dispatchEvent(evt);
     }
}