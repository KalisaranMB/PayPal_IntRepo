import { LightningElement, track } from 'lwc';
import ProfilePicturePath from '@salesforce/resourceUrl/Profile'

export default class MerchantTags extends LightningElement {
    @track profilePicture = ProfilePicturePath+'/Profile.jpg'
    tabClick(e){
      e.currentTarget.classList.add('slds-is-active')
  }
}