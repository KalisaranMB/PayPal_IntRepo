import {LightningElement, track} from 'lwc';
import getCustomerJourneyDetails from '@salesforce/apex/CustomerJourneyMockClass.getCustomerJourneyDetails';
import CHATBOT_ICON from '@salesforce/resourceUrl/chatbotIcon';
import HELPCENTRE_ICON from '@salesforce/resourceUrl/helpCentreIcon';
import IVR_ICON from '@salesforce/resourceUrl/ivrIcon';
import TEAMMATE_ICON from '@salesforce/resourceUrl/teammateIcon';

const iconMap= type =>{
    switch(type){
        case 'chatbot': return `${CHATBOT_ICON}#chatBot`
        case 'IVR': return `${IVR_ICON}#ivr`
        case 'compass': return `${TEAMMATE_ICON}#teammate`
        case 'help_center': return `${HELPCENTRE_ICON}#helpCentre`
    }
}
const monthNames= ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

export default class CustomerJourneyTimeline extends LightningElement {
    channelName = "chatbot";
    interactionData=[];
    summaryData=[];
     clickHandler(e){

        let {month,interaction} = e.target.dataset;
        console.log('called with ', e.target.dataset.interaction);
       // this.summaryData = this.interactionData[month].interaction[interaction]
        this.channelName = this.summaryData.channeltype
        console.log('interaction',interaction);
        let el = this.template.querySelector(`[data-id="${interaction}"]`);
        el.classList.contains("slds-is-open") ?
            el.classList.remove("slds-is-open"):
            el.classList.add("slds-is-open");
        
    };
    monthToggle(e){
        console.log('called');
        let month = e.target.dataset.month;
        let el = this.template.querySelector(`[data-id="${month}"]`);
        el.classList.contains("hide") ?
            el.classList.remove("hide"):
            el.classList.add("hide");
    };
    connectedCallback(){
             getCustomerJourneyDetails({accountNumber:'test1234'}).then(response => {
              
                 let dateSet =  new Set();
                 response.forEach(res => {
                     dateSet.add(new Date(res.timeStamp).getMonth());
                     res['iconUrl'] = iconMap(res.channeltype);
                     //res.timeStamp = new Date(res.timeStamp).toLocaleDateString();
                 });
                 let newRes= []
                 dateSet.forEach(d=>{
                    let obj = {};
                    obj['month'] = monthNames[d];
                    obj['year'] = '2020';
                    obj['timeElapsed'] = `${new Date().getMonth()-d} month ago`
                    obj['interaction']= response.filter(r=> new Date(r.timeStamp).getMonth() == d);
                    newRes.push(obj);
                })
                this.interactionData =newRes;
                this.summaryData = response;

           }).catch(console.log);

        }
}