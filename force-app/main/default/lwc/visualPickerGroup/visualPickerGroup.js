import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class VisualPickerGroup extends LightningElement {

    legend = "Confirmation Methods:";

    @api
    selectedOption ="KBA";

    @api
    pickerGroupName = "authOptionPicker";

    @api
    options=[
        {
            "mainText":"KBA",
            "id" : "a0256000001F1b3AAC",
            "subText" : "5 questions",
            "pickerGroupName" : "authOptionPicker"
        },
        {   
            "mainText": "SMS",
            "id" : "a0256000001F1arAAC",
            "subText" : "9980756355",
            "pickerGroupName" : "authOptionPicker"
        },
        {
            "mainText" : "CC",
            "id" : "a0256000001F1b6AAC",
            "subText" : "**** **** **** 4648",
            "pickerGroupName" : "authOptionPicker"
        }
        ];

        handleOptionSelect(event){
            console.log("test");
            this.selectedOption = event.detail;
            // console.log("test"+event.detail);
            const attributeChangeEvent = new FlowAttributeChangeEvent('selectedOption', this.selectedOption);
            this.dispatchEvent(attributeChangeEvent);
        }
}