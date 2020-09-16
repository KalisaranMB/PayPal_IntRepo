import { LightningElement, track, api} from 'lwc'
import getLinkedAccounts from '@salesforce/apex/LinkedAccountsController.getLinkedAccounts'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import CustomerName from '@salesforce/label/c.CustomerName'
import AccountCreated from '@salesforce/label/c.AccountCreationDate'
import AccountStatus from '@salesforce/label/c.AccountStatus'
import AccountType from '@salesforce/label/c.AccountType'
import Emails from '@salesforce/label/c.Emails'
import Phone from '@salesforce/label/c.Phones'
import AccountNumber from '@salesforce/label/c.AccountNumber'
import PrimaryAddress from '@salesforce/label/c.Address'
import StronglyLinked from '@salesforce/label/c.StronglyLinked'
import LinkedBy from '@salesforce/label/c.LinkedBy'
import Wallet from '@salesforce/label/c.Wallet'
export default class LinkedAccounts extends LightningElement {

    @api recordId
    @api objectApiName

    @track
    linkedAccounts = []

    label = {
      CustomerName,
      AccountCreated,
      AccountStatus,
      AccountType,
      Emails,
      Phone,
      AccountNumber,
      PrimaryAddress,
      StronglyLinked,
      LinkedBy,
      Wallet,
    }

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

    mapLinkedAccountsForUI = (account) => {
        let mappedAccount = {...account.linkedAccount, }
        let linkedByAttributes = {emails:[], phones:[], cards:[], banks:[], addresses:[],name}
        let {attributes} = account
        attributes.forEach( data => {
            if(data.attribute.Name ==='Name'){
              linkedByAttributes.linkedByName = data.attribute.Attribute_Value__c
            }
            else if(data.attribute.Name === 'Phone'){
              linkedByAttributes.phones.push(data.attribute.Attribute_Value__c)
            }
            else if(data.attribute.Name === 'Email'){
              linkedByAttributes.emails.push(data.attribute.Attribute_Value__c)
            }
            else if(data.attribute.Name === 'CARD'){
              linkedByAttributes.cards.push(data.financialInstrument)
            }
            else if(data.attribute.Name === 'Address'){
              linkedByAttributes.addresses.push(data.address)
            }

        })
        console.log("Mapped Account", mappedAccount, linkedByAttributes)
      return {...mappedAccount, ...linkedByAttributes, has_emails:linkedByAttributes.emails.length>0, has_name:linkedByAttributes.linkedByName?true:false, has_cards:linkedByAttributes.cards.length>0, has_addresses:linkedByAttributes.addresses.length>0, has_phones:linkedByAttributes.phones.length>0}
    }

    connectedCallback () {
      console.log(this.label)
        getLinkedAccounts(this.getControllerParams()).then(data => {
            this.loading=false
            console.log("Linked Accounts", data)
            console.log("objectApiName", this.objectApiName)
            if(data.result.status!=="SUCCESS"){
              const toastEvent = new ShowToastEvent({
                title: "Unable to fetch Linked Accounts for current Case",
                message: "Record ID: " + this.recordId,
                variant: "error",
                mode:"sticky"
            })
            this.dispatchEvent(toastEvent);
            //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
            }
            else {
                let linkedAccounts = data.linkedAccounts
                this.linkedAccounts = linkedAccounts.map( this.mapLinkedAccountsForUI)
                console.log("After Mapping", this.linkedAccounts)
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