import { LightningElement, api,track } from 'lwc';

export default class AuthOption extends LightningElement {
   @api mainText  = "Knowledge Based Authentication";
   @api subText = "";
   @api pickerId = "123";;
   @track pickerValue =  "345";
   @api pickerName="678";

   onClick(){
        const event = new CustomEvent('optionselect', {
            // detail contains only primitives
            detail: this.mainText
        });
        // Fire the event from c-tile
        this.dispatchEvent(event);
        console.log(this.mainText);
    }
    get hasRendered(){
        if(this.mainText.localeCompare("KBA"))
            return true;
        return false;
    }  
}