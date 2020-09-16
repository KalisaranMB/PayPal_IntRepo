import { LightningElement, api, track } from 'lwc';

export default class CustomerJourneySummary extends LightningElement {
    
    @api channelName=""; 
    @api res=[];
    @api interactionId='';
    @track interactionDetails=[];

    get isSummaryAvailable() {
        return this.channelSummary !== 0;
    }

    get isHC() {
        return (this.channelName === "help_center") || (this.channelName === "IVR");
    }
    get isIVR() {
        return this.channelName === "IVR";
    }
    get isChatbot() {
        return this.channelName === "chatbot";
    }
    get isTeammateTools() {
        return this.channelName === "compass";
    }
    get isEmail() {
        return this.channelName === "email";
    }
    get channelSummary(){
        this.res.forEach(item => {
            if(this.interactionId === item.interactionId){
                this.interactionDetails= item;
            }  
         })
         
        return this.interactionDetails;
    }

    //Added for Chatbot infinite scroll
    columns = [
        { label: 'Name', fieldName: 'name', type:"text" },
        { label: 'time', fieldName: 'time', type:"text" },
        { label: 'Message', fieldName: 'msg', type:"text" }
    ];
    i=0;
    val = [];
    newval;
    loadMoreData(event){
        console.log('called');
        if(event){
            event.target.isLoading = true;
        }
        this.newval=[]
        for(this.i=0;this.i<10;this.i++)
       this.newval.push({
                name:'jennifer',
                id: Math.random(this.i*100),
                time: `${Math.floor(Math.random()*12)}:${Math.floor(Math.random()*60)}`,
                msg: "my question regarding my last transaction "
        },
        {
            name:'TM',
            id: Math.random(this.i*100),
            time: `${Math.floor(Math.random()*12)}:${Math.floor(Math.random()*60)}`,
            msg: "I can assit you with that, let me take a look "
        })
        this.val = this.val.concat(this.newval);
        console.log(this.val.length);
        if(event){
            event.target.isLoading = false;
        }
    }
    
    connectedCallback(){
        console.log('Child CN:',this.channelName);
        console.log('Child res:',this.res);
       //this.loadMoreData();
      
    }
}