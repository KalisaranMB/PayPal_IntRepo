/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import getCustomerTags from '@salesforce/apex/CustomerTagsController.getCustomerTags'
import Limitations from '@salesforce/label/c.CustomerTags_Limitation'
import ManagedAccount from '@salesforce/label/c.CustomerTags_ManagedAccount'
import UnRegistered from '@salesforce/label/c.CustomerTags_UnRegistered'



export default class CustomerTags extends LightningElement {
    @track profilePicture = ""
    @track accountInfo = {}
    @track userInfo = {}
    @track hasLimitations = false
    @track isManagedAccount = false
    @api recordId

    labels = {
        Limitations,
        ManagedAccount,
        UnRegistered
    }
    connectedCallback(){

        getCustomerTags({caseId:this.recordId}).then( data =>{
            console.log("Customer TAGS", data)
            this.userInfo = data.userInfo
            this.accountInfo = data.accountInfo
            this.customerInitials = data.userInfo.FirstName.charAt(0).toUpperCase()+data.userInfo.LastName.charAt(0).toUpperCase()
            this.hasLimitations = data.hasOpenLimitations
            this.isManagedAccount = data.isManagedAccount
            this.profilePicture = data.userInfo.Profile_Picture__c


        }).catch( error =>{
            console.log("Unable to call Apex for Customer Tags", error)
            //TODO Handle Errors
        })
    }
  
}