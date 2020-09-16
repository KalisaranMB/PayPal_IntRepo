import { LightningElement, track, api } from 'lwc';
import getFinancialInstruments from '@salesforce/apex/FinancialInstrumentsController.getFinancialInstruments'
import Payments from '@salesforce/label/c.Payments'
import PayPalCredit from '@salesforce/label/c.PayPalCredit'
import BanksAndCards from '@salesforce/label/c.BanksAndCards'
import PayPalDebitCards from '@salesforce/label/c.PayPalDebitCards'
import Rewards from '@salesforce/label/c.Rewards'
import NotAvailable from '@salesforce/label/c.NotAvailable'
import ExpirationDate from '@salesforce/label/c.ExpirationDate'


export default class CustomerProfile extends LightningElement {

    @api recordId
    @api objectApiName

    analytics={}
    @track
    paypalDebitCards = []
    @track
    hasPaypalDebitCards = false

    @track
    paypalCredit = []
    @track
    hasPaypalCredit = false

    @track
    banksAndCards = []
    @track
    hasBanksAndCards = false

    @track
    rewards = []
    @track
    hasRewards = false

    label = {
      Payments,
      PayPalCredit,
      PayPalDebitCards,
      BanksAndCards,
      Rewards,
      NotAvailable,
      ExpirationDate
    }
    


    tabClick(e){
      e.currentTarget.classList.add('slds-is-active')
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

    connectedCallback(){
      console.log(this.label)
      if (window.PAYPAL && window.PAYPAL.analytics) {
        this.analytics = window.PAYPAL.analytics
        this.analytics.logActivity({
          pgrp:"sf:main:customer360:",
          link:"customer-profile"
        })
      }
      console.log("Customer Profile axxcde", this.recordId, this.objectApiName)
      //TODO log to FPTI on start and end time for controller call and durations
      getFinancialInstruments(this.getControllerParams()).then( data => {
        console.log("FinancialInstrumentController", data)
        //TODO check result Status

        let {financialInstruments} = data
        let ppCredit = financialInstruments.filter( ppCredit => ppCredit.Financial_Instrument_Type__c === 'PAYPAL_CREDIT') 
        let ppDebitCards = financialInstruments.filter(ppDebit => ppDebit.Issuer_Name__c === 'PayPal' && ppDebit.Financial_Instrument_Subtype__c==='DEBIT')
        let banksAndCards = financialInstruments.filter(instrument => (instrument.Financial_Instrument_Type__c === 'CARD' || instrument.Financial_Instrument_Type__c === 'BANK') && instrument.Issuer_Name__c !== 'PayPal')

        ppCredit.forEach((data) => {
          this.paypalCredit.push(
            {...data, 
              info:`${data.Financial_Instrument_Subtype__c}(X-${data.Last_4_digits__c})`,
              hasExpiry:data.Expiry_Date__c?true:false,
              icon:'custom:custom40',
            })
        })
        ppDebitCards.forEach((data) => this.paypalDebitCards.push(
          {...data, 
            info: `${data.Issuer_Name__c} - ${data.Financial_Instrument_Type__c} - ${data.Financial_Instrument_Subtype__c} (X-${data.Last_4_digits__c})`,
            hasExpiry:data.Expiry_Date__c?true:false,
            icon:'custom:custom40',
          }))
        banksAndCards.forEach((data) => this.banksAndCards.push(
          {...data, 
          info:`${data.Issuer_Name__c} - ${data.Financial_Instrument_Type__c} - ${data.Financial_Instrument_Subtype__c} (X-${data.Last_4_digits__c})`,
          hasExpiry:data.Expiry_Date__c?true:false,
          icon:data.Financial_Instrument_Type__c==='BANK'?'custom:custom16':'custom:custom40',
        }))
        this.hasBanksAndCards = this.banksAndCards.length > 0
        this.hasPaypalCredit = this.paypalCredit.length > 0
        this.hasPaypalDebitCards = this.paypalDebitCards > 0
        this.hasRewards = this.rewards?true:false //TODO add corresponding flags
      }).catch( error => {
        console.log("FinancialInstrumentsController Error", error)
      })
    }
}