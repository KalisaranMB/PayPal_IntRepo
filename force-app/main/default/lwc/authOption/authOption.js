import { LightningElement, api } from 'lwc';

export default class AuthOption extends LightningElement {
    @api phoneNumber = "408-806-2345";
    @api creditCard = "4378";
    get phoneNumberDetails() {
        //formatting logic goes here
        return this.phoneNumber;
    }

    get crediCardDetails() {
        //formatting logic goes here
        return this.creditCard;
    }


}