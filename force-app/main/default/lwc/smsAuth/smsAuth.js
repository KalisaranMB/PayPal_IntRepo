import { LightningElement,track,api } from 'lwc';

export default class SmsAuth extends LightningElement {

    @track
    selectedPhone;

    @track
    agreements = [];

    @track
    codeSent = false;

    @api
    code ="empty";

    @track
    smsauthDetails = {
        "phones":[
            {
                "value" : "408-567-2223",
                "label":"Primary Phone: 408-567-2223"
            },
            {
                "value" : "408-806-2238",
                "label":"Secondary Phone : 408-806-2238"
            }
        ],
        "addNewNumberAllowed": false,
        "agreements":[
            {
                "label" : "Acknowledgment that you have read the guidance to the customer",
                "value" : "1234"
            },
            {
                "label" : "Click here if the customer agrees to receiving SMS and Auto-Dial contacts from Paypal",
                "value" : "1236"
            }
        ]
    };

    phoneSelected(event){
        this.selectedPhone=event.detail.value;
        console.log("Phone Selection changed"+this.selectedValue);
    }

    agreementChecked(event){
        this.agreements=event.detail.value;
        console.log("Agreement selction changed"+this.agreements);
    }

    sendCode(event){
        console.log("Send code.");
        this.codeSent=true;
    }

    setCode(event){
        this.code = event.detail.value;
    }

    verify(event){
        console.log("verify"+this.code);
        const attributeChangeEvent = new FlowAttributeChangeEvent('code', this.code);
        this.dispatchEvent(attributeChangeEvent);
    }

    @track show = false;
    openAddNumberScreen(){
        this.show = !this.show;
    }
    handleCloseClick(evt){
        this.show = !this.show;
    }
    handleAddNumber(evt){
        this.show = !this.show;
        this.smsauthDetails.phones.push({
            "value" : evt.detail,
            "label":"New Phone: " + evt.detail
        });
    }

}