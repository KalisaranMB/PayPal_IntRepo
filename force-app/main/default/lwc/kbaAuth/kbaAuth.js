import { LightningElement, api } from 'lwc';

export default class KBAAuth extends LightningElement {

   json = {
      "Questions": [
         {
            "id": "q1",
            "question": "What is your mother's maiden name",
            "options": [
               {
                  "label": "Jones",
                  "value": "Jones"
               },
               {
                  "label": "Peter",
                  "value": "Peter"
               },
               {
                  "label": "Raghav",
                  "value": "Raghav"
               },
               {
                  "label": "Ghosh",
                  "value": "Ghosh"
               }
            ]
         },
         {
            "id": "q2",
            "question": "What is the name of your first pet",
            "options": [
               {
                  "label": "Simba",
                  "value": "Simba"
               },
               {
                  "label": "Moti",
                  "value": "Moti"
               },
               {
                  "label": "Sheru",
                  "value": "Sheru"
               },
               {
                  "label": "Kuku",
                  "value": "Kuku"
               }
            ]
         },
         {
            "id": "q3",
            "question": "What is the name of your first school",
            "options": [
               {
                  "label": "DPS",
                  "value": "DPS"
               },
               {
                  "label": "SSRVM",
                  "value": "SSRVM"
               },
               {
                  "label": "RBM",
                  "value": "RBM"
               },
               {
                  "label": "NPS",
                  "value": "NPS"
               }
            ]
         }
      ]
   };

   selectedValue = '';

   map = new Map();

   @api
   finalAnswers = '';

   handleChange(event) {
      console.log(event.target.dataset.id);
      console.log(this.selectedValue);
      this.map[event.target.dataset.id] = event.detail.value;
      // const myString = "string value"
      // const myJson = {};
      // myJson.myMap = mapToObj(map);
      // myJson.myString = myString;
      const jsonStr = JSON.stringify(this.map);
      console.log(jsonStr);
      this.finalAnswers=jsonStr;
      const attributeChangeEvent = new FlowAttributeChangeEvent('finalAnswers', this.finalAnswers);
      this.dispatchEvent(attributeChangeEvent);
   }

}