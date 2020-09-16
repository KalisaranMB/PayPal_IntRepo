/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import getQuickGlanceInfo from "@salesforce/apex/QuickGlanceBizController.getQuickGlanceInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CustomerName from "@salesforce/label/c.MerchantQuickGlance_CustomerName";
import AccountCountry from "@salesforce/label/c.MerchantQuickGlance_AccountCountry";
import AccountCreated from "@salesforce/label/c.MerchantQuickGlance_AccountCreated";
import AccountFlags from "@salesforce/label/c.MerchantQuickGlance_AccountFlags";
import AccountStatus from "@salesforce/label/c.MerchantQuickGlance_AccountStatus";
import AccountType from "@salesforce/label/c.MerchantQuickGlance_AccountType";
import AccountComplianceStatus from "@salesforce/label/c.MerchantQuickGlance_AccountComplianceStatus";
import Restrictions from "@salesforce/label/c.MerchantQuickGlance_Restrictions";
import AccountNumber from "@salesforce/label/c.MerchantQuickGlance_AccountNumber";
import PrimaryAddress from "@salesforce/label/c.MerchantQuickGlance_PrimaryAddress";
import PrimaryUser from "@salesforce/label/c.MerchantQuickGlance_PrimaryUser";
import PrimaryPhone from "@salesforce/label/c.MerchantQuickGlance_PrimaryPhone";
import PrimaryEmail from "@salesforce/label/c.MerchantQuickGlance_PrimaryEmail";
import Role from "@salesforce/label/c.MerchantQuickGlance_Role";
import BusinessName from "@salesforce/label/c.MerchantQuickGlance_BusinessName";
import BusinessAddress from "@salesforce/label/c.MerchantQuickGlance_BusinessAddress";
import Industry from "@salesforce/label/c.MerchantQuickGlance_Industry";
import MCCCode from "@salesforce/label/c.MerchantQuickGlance_MCCCode";
import UserComplianceStatus from "@salesforce/label/c.MerchantQuickGlance_UserComplianceStatus";
import CustomerServiceEmail from "@salesforce/label/c.MerchantQuickGlance_CustomerServiceEmail";
import CustomerServicePhone from "@salesforce/label/c.MerchantQuickGlance_CustomerServicePhone";
import AccountDetails from "@salesforce/label/c.MerchantQuickGlance_AccountDetails";
import ContactInfo from "@salesforce/label/c.MerchantQuickGlance_ContactInfo";
import BusinessDetails from "@salesforce/label/c.MerchantQuickGlance_BusinessDetails";
import NotAvailable from '@salesforce/label/c.NotAvailable'

// import getQuickGlanceInfoWithoutCache from '@salesforce/apex/QuickGlanceController.getQuickGlanceInfoWithoutCache'


export default class CustomerQuickGlance extends LightningElement {
  @api recordId;
  @track quickGlanceData = {};
  @track accountInfo = {};
  @track accountRestrictionsList = [];
  @track limitations = [];
  @track accountFlags = {};  
  @track emails = [];
  @track addresses = [];    
  @track phones = {};
  @track primaryParty = {};
  @track primaryAddress = {};
  @track isPrimaryAddressAvailable = false
  @track accountCreated = "";
  @track accountFlagsList = [];  
  @track accountEmailsList = [];
  @track businessAddress = [];
  @track contactedParty = [];
  @track accountStatusLocked = false;
  @track primaryPhone = "";
  @track primaryEmail = "";
  @track accountComplianceStatusClass = "slds-p-bottom_xx-small";
  @track isContactedPartyAvailable = true;
  @track isContactedPartyNotPrimary = false;
  @track isContactAddressAvailable = false;
  @track contactAddresses = [];
  @track contactAddress = {};
  @track contactPartyRole = "";
  @track userComplianceStatusClass = "slds-p-bottom_xx-small";


  label = {
    AccountCountry,
    AccountCreated,
    AccountFlags,
    AccountStatus,
    AccountType,
    AccountComplianceStatus,
    CustomerName,
    Restrictions,
    AccountNumber,
    PrimaryAddress,
    PrimaryUser,
    PrimaryPhone,
    PrimaryEmail,
    Role,
    BusinessName,
    BusinessAddress,
    Industry,
    MCCCode,
    UserComplianceStatus,
    CustomerServiceEmail,
    CustomerServicePhone,
    AccountDetails,
    ContactInfo,
    BusinessDetails,
    NotAvailable
  };


  connectedCallback() {
    getQuickGlanceInfo({ caseId: this.recordId })
      .then((data) => {
        console.log("DATA", data);
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

          this.accountInfo = data.accountInfo;
          this.primaryParty = data.primaryParty.user;
          this.emails = data.primaryParty.emails;
          this.accountFlags = data.accountFlags;          
          this.addresses =  data.primaryParty.addresses;
          this.limitations = data.limitations;
          this.phones = data.primaryParty.phones; 
          this.businessAddress = data.businessAddress;
          this.contactedParty = data.contactedParty.user; 
          this.isContactedPartyAvailable = data.isContactedPartyAvailable;
          this.isContactedPartyNotPrimary = data.isContactedPartyNotPrimary;
          this.contactAddresses =  data.contactedParty.addresses;

          if(this.isContactedPartyNotPrimary){
            this.contactPartyRole = "Secondary User";
          }else{
            this.contactPartyRole = "Primary User";
          }

          //check account status to see if lock icon is needed
          if (this.accountInfo.Account_Status__c == "Locked") {
            this.accountStatusLocked = true;
          }

          //set Compliance Status class based on the value to adjust the color
          switch (this.accountInfo.CIP_Status__c.toLowerCase()) {
            case "completed":
              //turn it green
              this.accountComplianceStatusClass = "slds-p-bottom_xx-small slds-text-color_success";
              break;
            case "denied":
              //turn it red?
              this.accountComplianceStatusClass = "slds-p-bottom_xx-small slds-text-color_error";
              break;
            case "in progress":
              //turn it yellow <-color not available
              this.accountComplianceStatusClass = "slds-p-bottom_xx-small";
              break;
            case "not started":
              //also yellow? <-color not available
              this.accountComplianceStatusClass = "slds-p-bottom_xx-small";
              break;
            default:
              //set the basic class
              this.accountComplianceStatusClass = "slds-p-bottom_xx-small";
          }

          // set userComplianceStatusClass
          switch (this.contactedParty.CIP_Status__c.toLowerCase()) {
            case "completed":
              //turn it green
              this.userComplianceStatusClass = "slds-p-bottom_xx-small slds-text-color_success";
              break;
            case "denied":
              //turn it red?
              this.userComplianceStatusClass = "slds-p-bottom_xx-small slds-text-color_error";
              break;
            case "in progress":
              //turn it yellow <-color not available
              this.userComplianceStatusClass = "slds-p-bottom_xx-small";
              break;
            case "not started":
              //also yellow? <-color not available
              this.userComplianceStatusClass = "slds-p-bottom_xx-small";
              break;
            default:
              //set the basic class
              this.userComplianceStatusClass = "slds-p-bottom_xx-small";
          }

          //get the primary address since there are multiple primaries in this mock response validate if that can really happen either way check if there is atleast one primary address
          let primaryAddressList = this.addresses.filter(
            (address) => address.Is_Primary__c
          );
          if (primaryAddressList.length > 0) {
            this.primaryAddress = primaryAddressList[0];
            this.isPrimaryAddressAvailable = true;
          } else {
            this.isPrimaryAddressAvailable = false;
          }

          let contactAddressList = this.contactAddresses.filter(
            (address) => address.Is_Primary__c
          );
          if (contactAddressList.length > 0) {
            this.isContactAddressAvailable = true;
            this.contactAddress = contactAddressList[0];
          } else {
            this.isContactAddressAvailable = false;
          }
          
          //iterate over limitations, create array for lightning template
          if (this.limitations.length > 0) {
            var i;
            for (i = 0; i < this.limitations.length; i++) {
              this.accountRestrictionsList.push({
                key: i,
                value: this.limitations[i].Name
              });
            }
          }
          
          //iterate over accountFlags, create array for lightning template
          if (this.accountFlags.length > 0) {
            var i;
            for (i = 0; i < this.accountFlags.length; i++) {
              this.accountFlagsList.push({
                key: i,
                value: this.accountFlags[i].Name
              });
            }
          }

          //get primary phone number from available phone numbers
          if (this.phones.length > 0) {
            var i;
            this.primaryPhone = "";
            for (i = 0; i < this.phones.length; i++) {
              if (this.phones[i].Is_Primary__c) {
                this.primaryPhone = this.phones[i].Phone_Number__c;
              }
            }
          }

          //get primary email from available emails
          if (this.emails.length > 0) {
            var i;
            this.primaryEmail = "";
            for (i = 0; i < this.emails.length; i++) {
              if (this.emails[i].Is_Primary__c) {
                this.primaryEmail = this.emails[i].Email_Address__c;
              }
            }
          }

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