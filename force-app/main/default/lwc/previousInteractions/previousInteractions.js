import { LightningElement, api } from 'lwc';
import {
    EXAMPLES_COLUMNS_DEFINITION_BASIC,
    EXAMPLES_DATA_BASIC,
} from './sampleData';

import getPreviousInteractions from '@salesforce/apex/PreviousInteractionsController.getPreviousInteractions'

export default class PreviousInteractions extends LightningElement {

    @api recordId
    @api objectApiName

    getControllerParams = () => {
        if (this.objectApiName === 'Case'){
          return {
            caseId : this.recordId
          }
        }
        if (this.objectApiName === 'Account'){
          return {
            accountId : this.recordId
          }
        }
        throw new Error("This component will only work when you pass caseId or accountId, pass the recordId and objectApiName information")
    }


        // definition of columns for the tree grid
        gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;

        // data provided to the tree grid
        gridData = EXAMPLES_DATA_BASIC;


        connectedCallback(){
            console.log("RECORD ID", this.recordId)
            console.log("Labels", this.label)
            
            /*I'm not wiring the controller because I want to be able to use these component in the account pages as well as in case record pages.
              To load the controller we either need the caseId or the accountId and we always have the reference to them from the recordId.
              We can know whether a record Id is a caseId or a accountId using the objectApiName, we can later extend this to other types of pages too depending on the need and just switching the function
            */
            getPreviousInteractions(this.getControllerParams()).then(data => {
              console.log("Previous Interactions", data)
              this.loading=false
              if(data.result.status!=="SUCCESS"){
                const toastEvent = new ShowToastEvent({
                  title: "Unable to fetch data for current Case",
                  message: "Record ID: " + this.recordId,
                  variant: "error",
                  mode:"sticky"
              })
              this.dispatchEvent(toastEvent);
              //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
              //TODO Retry
              }
              else {

      
              }
            })
            .catch(error => {
              this.loading=false
              const toastEvent = new ShowToastEvent({
                title: "Error Calling Apex Controller",
                message: "Record ID: " + this.recordId+" Error: "+error,
                variant: "error",
                mode:"sticky"
            });
            this.dispatchEvent(toastEvent);
            })
          }

}