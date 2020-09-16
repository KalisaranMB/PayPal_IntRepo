import { LightningElement, track, api } from 'lwc';

//import ProfilePicturePath from "@salesforce/resourceUrl/Profile";

//import SecondaryUsers from "@salesforce/label/c.QC_SecondaryUsers";  
import getMerchantProfile from "@salesforce/apex/MerchantProfileController.getMerchantProfile";
import getAllSecondaryUsers from "@salesforce/apex/SecondaryUsersController.getAllSecondaryUsers";
import getFinancialInstruments from '@salesforce/apex/FinancialInstrumentsController.getFinancialInstruments';
import getProducts from "@salesforce/apex/ProductsController.getProducts";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import Confirmed from '@salesforce/label/c.CustomerQuickGlance_Confirmed'
import Inactive from '@salesforce/label/c.CustomerQuickGlance_Inactive'
import Primary from '@salesforce/label/c.CustomerQuickGlance_Primary'
import Trusted from '@salesforce/label/c.CustomerQuickGlance_Trusted'
import Unconfirmed from '@salesforce/label/c.CustomerQuickGlance_Unconfirmed'

import Payments from '@salesforce/label/c.Payments'
import PayPalCredit from '@salesforce/label/c.PayPalCredit'
import BanksAndCards from '@salesforce/label/c.BanksAndCards'
import PayPalDebitCards from '@salesforce/label/c.PayPalDebitCards'
import Rewards from '@salesforce/label/c.Rewards'
import NotAvailable from '@salesforce/label/c.NotAvailable'
import ExpirationDate from '@salesforce/label/c.ExpirationDate'

export default class MerchantProfile extends LightningElement {
  @api recordId;
  //@track profilePicture = ProfilePicturePath + '/Profile.jpg'

  @track alternateEmails = [];
  @track alternatePhones = [];
  @track secondaryUsers = [];
  @track hasSecondaryUsers = false;
  @track paypalDebitCards = [];
  @track hasPaypalDebitCards = false;
  @track paypalCredit = [];
  @track hasPaypalCredit = false;
  @track banksAndCards = [];
  @track hasBanksAndCards = false;
  @track rewards = [];
  @track hasRewards = false;
  @track paypalHere = [];
  @track hasPaypalHere = false;
  @track unbrandedCreditCards = [];
  @track hasUnbrandedCreditCards = false;
  @track virtualTerminal = [];
  @track hasVirtualTerminal = false;

  label = {
    //SecondaryUsers,
    Confirmed,
    Inactive,
    Primary,
    Trusted,
    Unconfirmed,
    Payments,
    PayPalCredit,
    PayPalDebitCards,
    BanksAndCards,
    Rewards,
    NotAvailable,
    ExpirationDate
  }

  tabClick(e) {
    e.currentTarget.classList.add('slds-is-active')
  }

  /* Keeping this in case permissions require the other table type
  @track secondaryUsersX = [{
     permissions: [{
       label: "Permissions", expanded: false, items: [
         { label: "send money" }, { label: "add users" }, { label: "update account" }]
     }], Full_Name__c: "Louise Belcher", Email_Address__c: "Louise@bobsburgers.com", primaryPhone: " +1 410-555-8675"
   }];
 */

  @track isModalOpen = false;
  @track sortBy = "name";
  @track sortDirection = "asc";
  @track secondaryUsersColumns = [
    {
      label: 'Name',
      fieldName: 'name',
      type: 'text',
      sortable: true
    },
    {
      label: 'User ID',
      fieldName: 'userId',
      type: 'text',
      sortable: true
    },
    {
      label: 'Email Address',
      fieldName: 'email',
      type: 'text',
      sortable: true
    },
    {
      label: 'Phone Number',
      fieldName: 'phone',
      type: 'text',
      sortable: true
    }
    /*,
    {
      label: 'Permissions',
      fieldName: 'permissions'
    }
    */
  ];

  openSUModal() {
    this.isModalOpen = true;
  }
  closeSUModal() {
    this.isModalOpen = false;
  }

  //custom sorting from https://jungleeforce.com/2019/08/17/lwc-lightning-datatable-sorting/
  updateColumnSorting(event) {
    let fieldName = event.detail.fieldName;
    let sortDirection = event.detail.sortDirection;
    //assign the values
    this.sortBy = fieldName;
    this.sortDirection = sortDirection;
    //call the custom sort method.
    this.sortData(fieldName, sortDirection);
  }

  //This sorting logic here is very simple. This will be useful only for text or number field.
  // You will need to implement custom logic for handling different types of field.
  sortData(fieldName, sortDirection) {
    let sortResult = Object.assign([], this.secondaryUsers);
    this.secondaryUsers = sortResult.sort(function (a, b) {
      if (a[fieldName] < b[fieldName])
        return sortDirection === 'asc' ? -1 : 1;
      else if (a[fieldName] > b[fieldName])
        return sortDirection === 'asc' ? 1 : -1;
      else
        return 0;
    })
  }


  connectedCallback() {
    console.log("RECORD ID x", this.recordId);
    //console.log("Labels", this.label);
    getMerchantProfile({ caseId: this.recordId })
      .then((data) => {
        //console.log("getMerchantProfile data ", data);
        if (data.result.status !== "SUCCESS") {
          const toastEvent = new ShowToastEvent({
            title: "Unable to fetch data for current Case",
            message: "Record ID: " + this.recordId,
            variant: "error",
            mode: "sticky"
          });
          this.dispatchEvent(toastEvent);
          //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
        } else {
          this.alternateEmails = data.emails;
          this.alternatePhones = data.phones;
          this.hasSecondaryUsers = data.hasSecondaryUsers;
        }

      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error Calling Apex Controller",
          message: "Record ID: " + this.recordId + " Error: " + error,
          variant: "error",
          mode: "sticky"
        });
        this.dispatchEvent(toastEvent);
      });

    getFinancialInstruments({ caseId: this.recordId })
      .then(data => {
        if (data.result.status !== "SUCCESS") {
          const toastEvent = new ShowToastEvent({
            title: "Unable to fetch data for current Case",
            message: "Record ID: " + this.recordId,
            variant: "error",
            mode: "sticky"
          });
          this.dispatchEvent(toastEvent);
          //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
        } else {
          //console.log("FinancialInstrumentController", data)
          //TODO check result Status

          let { financialInstruments } = data
          let ppCredit = financialInstruments.filter(ppCredit => ppCredit.Financial_Instrument_Type__c === 'PAYPAL_CREDIT')
          let ppDebitCards = financialInstruments.filter(ppDebit => ppDebit.Issuer_Name__c === 'PayPal' && ppDebit.Financial_Instrument_Subtype__c === 'DEBIT')
          let banksAndCards = financialInstruments.filter(instrument => (instrument.Financial_Instrument_Type__c === 'CARD' || instrument.Financial_Instrument_Type__c === 'BANK') && instrument.Issuer_Name__c !== 'PayPal')

          ppCredit.forEach((data) => {
            this.paypalCredit.push(
              {
                ...data,
                info: `${data.Financial_Instrument_Subtype__c}(X-${data.Last_4_digits__c})`,
                hasExpiry: data.Expiry_Date__c ? true : false,
                icon: 'custom:custom40',
              })
          })
          ppDebitCards.forEach((data) => this.paypalDebitCards.push(
            {
              ...data,
              info: `${data.Issuer_Name__c} - ${data.Financial_Instrument_Type__c} - ${data.Financial_Instrument_Subtype__c} (X-${data.Last_4_digits__c})`,
              hasExpiry: data.Expiry_Date__c ? true : false,
              icon: 'custom:custom40',
            }))
          banksAndCards.forEach((data) => this.banksAndCards.push(
            {
              ...data,
              info: `${data.Issuer_Name__c} - ${data.Financial_Instrument_Type__c} - ${data.Financial_Instrument_Subtype__c} (X-${data.Last_4_digits__c})`,
              hasExpiry: data.Expiry_Date__c ? true : false,
              icon: data.Financial_Instrument_Type__c === 'BANK' ? 'custom:custom16' : 'custom:custom40',
            }))
          this.hasBanksAndCards = this.banksAndCards.length > 0
          this.hasPaypalCredit = this.paypalCredit.length > 0
          this.hasPaypalDebitCards = this.paypalDebitCards > 0
          this.hasRewards = this.rewards ? true : false //TODO add corresponding flags
        }
      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error Calling Apex Controller",
          message: "Record ID: " + this.recordId + " Error: " + error,
          variant: "error",
          mode: "sticky"
        });
        this.dispatchEvent(toastEvent);
      });

    getProducts({ caseId: this.recordId })
      .then(data => {
        console.log("getProducts ", data)
        //TODO check result Status
        if (data.result.status !== "SUCCESS") {
          const toastEvent = new ShowToastEvent({
            title: "Unable to fetch data for current Case",
            message: "Record ID: " + this.recordId,
            variant: "error",
            mode: "sticky"
          });
          this.dispatchEvent(toastEvent);
          //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
        } else {

          let { products } = data
          let ppHere = products.filter(ppHere => ppHere.Product_Code__c === 'PAYPAL_HERE');
          let unbrandedCnC = products.filter(unbrandedCnC => unbrandedCnC.Product_Code__c === 'UCC');
          let virtTerm = products.filter(virtTerm => virtTerm.Product_Code__c === 'VT');

          ppHere.forEach((data) => {
            this.paypalHere.push(
              {
                ...data,
                deviceID: data.Id.substr(-5),
                hasActivated: data.Time_Activated__c ? true : false,
                hasDeactivated: data.Time_Deactivated__c ? true : false,
                icon: 'custom:custom40',
              })
          })
          unbrandedCnC.forEach((data) => {
            this.unbrandedCreditCards.push(
              {
                ...data,
                info: `Credit Card (xxxx-${data.Id.substr(-4)})`,
                hasExpiry: data.Expiry_Date__c ? true : false,
                icon: 'custom:custom40',
              })
          })
          virtTerm.forEach((data) => {
            this.virtualTerminal.push(
              {
                ...data,
                hasActivated: data.Time_Activated__c ? true : false,
                hasDeactivated: data.Time_Deactivated__c ? true : false,
                icon: 'custom:custom40',
              })
          })


          this.hasPaypalHere = this.paypalHere.length > 0;
          this.hasUnbrandedCreditCards = this.unbrandedCreditCards.length > 0;
          this.hasVirtualTerminal = this.virtualTerminal.length > 0;

        }

      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error Calling Apex Controller",
          message: "Record ID: " + this.recordId + " Error: " + error,
          variant: "error",
          mode: "sticky"
        });
        this.dispatchEvent(toastEvent);
      });

    //Not yet available
    getAllSecondaryUsers({ caseId: this.recordId })
      .then((data) => {
        console.log("getAllSecondaryUsers data ", data);
        if (data.result.status !== "SUCCESS") {
          const toastEvent = new ShowToastEvent({
            title: "Unable to fetch data for current Case",
            message: "Record ID: " + this.recordId,
            variant: "error",
            mode: "sticky"
          });
          this.dispatchEvent(toastEvent);
          //TODO Send an FPTI Event to log as failure with Service with the Result and Correlation ID
        } else {

          let rawSecondaryUsers = data.secondaryUsers;
          // Need names, userIds, primary emails, primary phones, and eventually permissions
          rawSecondaryUsers.forEach((data) => {
            let emails = data.emails;
            let emailData = emails.filter(emailData => emailData.Is_Primary__c == true);
            let phones = data.phones;
            let phoneData = phones.filter(phoneData => phoneData.Is_Primary__c == true);
            var email, phone;

            if (emailData.length > 0) {
              email = emailData[0].Email_Address__c;
            } else {
              email = this.label.NotAvailable;
            }

            if (phoneData.length > 0) {
              phone = phoneData[0].Phone_Number__c;
            } else {
              phone = this.label.NotAvailable;
            }


            console.log(" email ", email);
            console.log(" phone ", phone);

            this.secondaryUsers.push(
              {
                name: data.user.Full_Name__c,
                userId: data.secondaryUserAttrbutes.loginId,
                email: email,
                phone: phone,
              })

          })

          console.log("this.secondaryUsers ", JSON.stringify(this.secondaryUsers));

        }

      })
      .catch((error) => {
        const toastEvent = new ShowToastEvent({
          title: "Error Calling Apex Controller",
          message: "Record ID: " + this.recordId + " Error: " + error,
          variant: "error",
          mode: "sticky"
        });
        this.dispatchEvent(toastEvent);
      });


  }
}