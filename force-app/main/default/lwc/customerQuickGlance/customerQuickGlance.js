/* eslint-disable no-console */
import { LightningElement, track, api, } from 'lwc';
import ProfilePicturePath from '@salesforce/resourceUrl/Profile'
import getQuickGlanceInfo from '@salesforce/apex/QuickGlanceController.getQuickGlanceInfo'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import Title from '@salesforce/label/c.CustomerQuickGlance_Title';
import CustomerName from '@salesforce/label/c.CustomerQuickGlance_CustomerName'
import AccountCountry from '@salesforce/label/c.CustomerQuickGlance_AccountCountry'
import AccountCreated from '@salesforce/label/c.CustomerQuickGlance_AccountCreated'
import AccountFlags from '@salesforce/label/c.CustomerQuickGlance_AccountFlags'
import AccountStatus from '@salesforce/label/c.CustomerQuickGlance_AccountStatus'
import AccountType from '@salesforce/label/c.CustomerQuickGlance_AccountType'
import ComplianceStatus from '@salesforce/label/c.CustomerQuickGlance_ComplianceStatus'
import Confirmed from '@salesforce/label/c.CustomerQuickGlance_Confirmed'
import CustomerSegment from '@salesforce/label/c.CustomerQuickGlance_CustomerSegment'
import Emails from '@salesforce/label/c.CustomerQuickGlance_Emails'
import Home from '@salesforce/label/c.Home'
import Inactive from '@salesforce/label/c.CustomerQuickGlance_Inactive'
import Mobile from '@salesforce/label/c.Mobile'
import Phone from '@salesforce/label/c.CustomerQuickGlance_Phone'
import Primary from '@salesforce/label/c.CustomerQuickGlance_Primary'
import Restrictions from '@salesforce/label/c.CustomerQuickGlance_Restrictions'
import Trusted from '@salesforce/label/c.CustomerQuickGlance_Trusted'
import Unconfirmed from '@salesforce/label/c.CustomerQuickGlance_Unconfirmed'
import Work from '@salesforce/label/c.CustomerQuickGlance_Work'
import AccountNumber from '@salesforce/label/c.CustomerQuickGlance_AccountNumber'
import PrimaryAddress from '@salesforce/label/c.CustomerQuickGlance_PrimaryAddress'
import getQuickGlanceInfoWithoutCache from '@salesforce/apex/QuickGlanceController.getQuickGlanceInfoWithoutCache'

export default class CustomerQuickGlance extends LightningElement {

    @api recordId
    @api objectApiName

    @track profilePicture = ProfilePicturePath+'/Profile.jpg'
    @track quickGlanceData = {}
    @track accountFlags = []
    @track accountInfo = {}
    @track emails = []
    @track addresses = []
    @track limitations = []
    @track phones = []
    @track userInfo = {}
    @track primaryAddress = {}
    @track isPrimaryAddressAvailable = false
    @track loading = false
    @track workPhones = []
    @track mobilePhones = []
    @track homePhones = []

    // @wire(getQuickGlanceInfo, { caseId: '$recordId' })
    // quickGlanceData
    label = {
       AccountCountry,
       AccountCreated,
       AccountFlags,
       AccountStatus,
       AccountType,
       ComplianceStatus,
       Confirmed,
       CustomerName,
       CustomerSegment,
       Emails,
       Inactive,
       Phone,
       Primary,
       Restrictions,
       Title,
       Trusted,
       Unconfirmed,
       Work,
       AccountNumber,
       PrimaryAddress,
       Home,
       Mobile,
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
    handleRefreshData = () => {
      this.loading=true
      console.log("Handle Refresh Data")
      getQuickGlanceInfoWithoutCache(this.getControllerParams()).then(data => {
        this.loading=false
        console.log("DATA", data)
        console.log("objectApiName", this.objectApiName)
        if(data.result.status!=="SUCCESS"){
          const toastEvent = new ShowToastEvent({
            title: "Unable to fetch data for current Case",
            message: "Record ID: " + this.recordId,
            variant: "error",
            mode:"sticky"
        })
        this.dispatchEvent(toastEvent);
        //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
        }
        else {
          this.userInfo = data.userInfo
          this.emails = data.emails
          this.accountFlags = data.accountFlags
          this.accountInfo = data.accountInfo
          this.addresses = data.addresses
          this.limitations = data.limitations
          this.phones = data.phones
          //this.accountInfo.Account_Created_Time__c = new Date(this.accountInfo.Account_Created_Time__c).getTime()

          //get the primary address since there are multiple primaries in this mock response validate if that can really happen either way check if there is atleast one primary address
          let primaryAddressList = this.addresses.filter(address => address.Is_Primary__c)
          if(primaryAddressList.length > 0)
          {
            this.primaryAddress = primaryAddressList[0]
            this.isPrimaryAddressAvailable = true
          }
          else{
            this.isPrimaryAddressAvailable = false
          }

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

    connectedCallback(){
      console.log("RECORD ID", this.recordId)
      console.log("Labels", this.label)
      
      /*I'm not wiring the controller because I want to be able to use these component in the account pages as well as in case record pages.
        To load the controller we either need the caseId or the accountId and we always have the reference to them from the recordId.
        We can know whether a record Id is a caseId or a accountId using the objectApiName, we can later extend this to other types of pages too depending on the need and just switching the function
      */
      getQuickGlanceInfo(this.getControllerParams()).then(data => {
        console.log("DATA", data)
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
          this.userInfo = data.userInfo
          this.emails = data.emails
          this.accountFlags = data.accountFlags
          this.accountInfo = data.accountInfo
          this.addresses = data.addresses
          this.limitations = data.limitations
          this.phones = data.phones
          this.workPhones = this.phones.filter(phone => phone.Type__c==='Work')
          this.mobilePhones = this.phones.filter(phone => phone.Type__c==='Mobile')
          this.homePhones = this.phones.filter(phone => phone.Type__c==='Home')
          //this.accountInfo.Account_Created_Time__c = new Date(this.accountInfo.Account_Created_Time__c).getTime()

          //get the primary address since there are multiple primaries in this mock response validate if that can really happen either way check if there is atleast one primary address
          let primaryAddressList = this.addresses.filter(address => address.Is_Primary__c)
          if(primaryAddressList.length > 0)
          {
            this.primaryAddress = primaryAddressList[0]
            this.isPrimaryAddressAvailable = true
          }
          else{
            this.isPrimaryAddressAvailable = false
          }

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
    //   this.currentRecordId = this.recordId
    //   console.log("DAAAATA",data)
    //   this.headerInfo = data
    //   this.acct = data.acct
    //   this.limitations = data.limitations
    //   this.wallets = data.wallets
    //   this.charities = data.charities
    //   this.accountManagers = data.accountManagers
    //   this.emails = data.emails
    // }).catch(err => {
    //   console.log("ERRRRR",err)
    // })
    // getQuickGlanceInfoWithoutCache({caseId:this.currentRecordId}).then(data => {
    //   console.log("Without Cache",data)
    // }).catch(err => {
    //   console.log("Errors in without Cache",err)
    // })
      //console.log("Response", JSON.parse(JSON.stringify(this.headerInfo)))
    }

}