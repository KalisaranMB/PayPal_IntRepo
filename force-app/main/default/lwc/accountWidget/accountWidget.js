/* eslint-disable no-console */
import { LightningElement, track, api, } from 'lwc'
import ProfilePicturePath from '@salesforce/resourceUrl/Profile'
// import getHeaderInfo from '@salesforce/apex/HeaderController.getHeaderInfo'
// import getNextStepInfo from '@salesforce/apex/NextStepsController.getNextStepInfo'
export default class AccountWidget extends LightningElement {

  @track profilePicture = ProfilePicturePath+'/Profile.jpg'
    tabClick(e){
      e.currentTarget.classList.add('slds-is-active')
  }
  //TODO recordId is showing up only few times when using in console
  @track currentRecordId
  @track currentObjectId
  @api recordId
  @api objectApiName
  @track headerInfo
  @track wallets = []
  @track limitations = []
  @track charities = []
  @track acct = {}
  @track accountManagers = []
  @track emails = []

  //@wire(getHeaderInfo, { caseId:"$caseId" })
  setHeaderInfo({err, data}){
    //console.log("Response", JSON.stringify(data), JSON.stringify(err))
    this.headerInfo = data
    return {
      err,
      data
    }
  }

  connectedCallback(){
    this.currentRecordId = this.recordId
    this.currentObjectId  =this.objectApiName
    // getHeaderInfo({caseId:this.currentRecordId}).then(data => {
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
    // getNextStepInfo({caseId:this.currentRecordId}).then(data => {
    //   console.log("NEXT STEPS",data)
    // }).catch(err => {
    //   console.log("NEXT STEPS ERRRRR",err)
    // })
    //console.log("Response", JSON.parse(JSON.stringify(this.headerInfo)))
  }



}