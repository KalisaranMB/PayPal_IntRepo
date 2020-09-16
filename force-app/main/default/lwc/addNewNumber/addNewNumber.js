import { LightningElement, api } from 'lwc';

export default class AddNewNumber extends LightningElement {
    @api
    numberToAdd;

    closeClick(){
        event = new CustomEvent('closeclick',{
        });
        this.dispatchEvent(event);
    }
    onAddNumber(event){
        this.numberToAdd = event.target.value;
        console.log(this.numberToAdd);
    }
    verifyClick(){
        console.log("inside verifyclick : numberToAdd is : "+ this.numberToAdd);
        const event = new CustomEvent('verifyclick',{
            detail : this.numberToAdd
        });
        this.dispatchEvent(event);

    }
}