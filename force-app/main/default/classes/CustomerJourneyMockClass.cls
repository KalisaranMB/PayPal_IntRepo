public with sharing class CustomerJourneyMockClass {
    
    @AuraEnabled
    public static list<channeldetails> getCustomerJourneyDetails(string accountNumber){

        if(accountNumber =='test1234'){
            return getcustomerDetails();
        }
        else{
            return null;
        }
    }
    
    private static list<channeldetails> getcustomerDetails(){
        list<channeldetails> channeldetailsR = new list<channeldetails>();

        Integer interactionId=0;
        Integer dateRange=3;
        for(Integer i=0;i<30;i++)
        {

            /*Chat bot example 1*/
            channeldetails chatBot = new channeldetails();
            chatBot.interactionId=String.valueOf(interactionId++);
            chatBot.channeltype='chatbot';
            chatBot.timeStamp= string.valueof(dateTime.now()-(dateRange=dateRange+3));
            list<channelSummary> chatBotChannelSummary = new  list<channelSummary>();
            channelSummary channelSummary1 = new channelSummary();
            channelSummary1.name='Jennifer';
            channelSummary1.timeStamp='9:55 am';
            channelSummary1.notes='Test conversation 1';
            chatBotChannelSummary.add(channelSummary1);
            chatBot.channelSummaryDetails = chatBotChannelSummary;
            list<stepUpInfo> chatBotStepUpDetails = new list<stepUpInfo>();

            stepUpInfo stepUpInfo1 = new stepUpInfo();
            stepUpInfo1.type='SMS';
            stepUpInfo1.status='Success';
            chatBotStepUpDetails.add(stepUpInfo1);
            stepUpInfo stepUpInfo2 = new stepUpInfo();
            stepUpInfo2.type='Email';
            stepUpInfo2.status='Success';
            chatBotStepUpDetails.add(stepUpInfo2);
            chatBot.stepUpDetails = chatBotStepUpDetails;
            
            channeldetailsR.add(chatBot);
            /*Chat bot example 1*/

            /*helpCenter example 1*/
            channeldetails helpCenter = new channeldetails();
            helpCenter.interactionId=''+interactionId++;
            helpCenter.channeltype='help_center';
            helpCenter.timeStamp=  string.valueof(dateTime.now()-(dateRange=dateRange+3));
            list<channelSummary> helpCenterChannelSummary = new  list<channelSummary>();

            channelSummary channelSummary5 = new channelSummary();
            channelSummary5.notes='https://www.paypal.com/in/smarthelp/article/paypal%E2%80%99s-response-to-the-coronavirus-(covid-19)-pandemic-&-faqs-faq4003';
            channelSummary5.name='PayPal’s response to the coronavirus (COVID-19) pandemic & FAQs';
            helpCenterChannelSummary.add(channelSummary5);
            channelSummary channelSummary8 = new channelSummary();
            channelSummary8.notes='https://www.paypal.com/in/smarthelp/article/what-is-gst-and-how-does-it-apply-to-paypal-services-in-india-what-if-i%E2%80%99m-in-a-special-economy-zone-faq3744';
            channelSummary8.name='What is GST and how does it apply to PayPal services in India? What if I’m in a Special Economy Zone?';
            helpCenterChannelSummary.add(channelSummary8);

            helpCenter.channelSummaryDetails = helpCenterChannelSummary;
            list<stepUpInfo> helpCenterStepUpDetails = new list<stepUpInfo>();
            stepUpInfo stepUpInfo3 = new stepUpInfo();
            stepUpInfo3.type='SMS';
            stepUpInfo3.status='Success';
            helpCenterStepUpDetails.add(stepUpInfo3);
            helpCenter.stepUpDetails = helpCenterStepUpDetails;
            
            channeldetailsR.add(helpCenter);
            /*helpCenter example 1*/
            
             /*IVR example 1*/
            channeldetails ivr = new channeldetails();
            ivr.interactionId=String.valueOf(interactionId++);
            ivr.channeltype='IVR';
            ivr.timeStamp=  string.valueof(dateTime.now()-(dateRange=dateRange+3));
            list<channelSummary> ivrChannelSummary = new  list<channelSummary>();
            channelSummary channelSummary9 = new channelSummary();
            channelSummary9.notes='https://www.paypal.com/in/smarthelp/article/paypal%E2%80%99s-response-to-the-coronavirus-(covid-19)-pandemic-&-faqs-faq4003';
            channelSummary9.name='What is GST and how does it apply to PayPal services in India? What if I’m in a Special Economy Zone?';
            ivrChannelSummary.add(channelSummary9);

            channelSummary channelSummary10 = new channelSummary();
            channelSummary10.notes='https://www.paypal.com/in/smarthelp/article/how-do-i-link-an-india-bank-account-to-my-paypal-account-faq686';
            channelSummary10.name='How do I link an India bank account to my PayPal account?';
            ivrChannelSummary.add(channelSummary10); 
            ivr.channelSummaryDetails = ivrChannelSummary;

            channeldetailsR.add(ivr);
            /*IVR example 1*/

            /* Other Teammate */
            channeldetails otherTeammateCompass = new channeldetails();
            otherTeammateCompass.interactionId=String.valueOf(interactionId++);
            otherTeammateCompass.channeltype='compass';
            otherTeammateCompass.timeStamp=  string.valueof(dateTime.now()-(dateRange=dateRange+3));
            list<channelSummary> compassChannelSummary = new  list<channelSummary>();
            channelSummary channelSummary11 = new channelSummary();
            channelSummary11.name='Payment Decline';
            channelSummary11.notes='test notes';
            channelSummary11.workflowDetails='completed';
            compassChannelSummary.add(channelSummary11);
            otherTeammateCompass.channelSummaryDetails = compassChannelSummary;

            channeldetailsR.add(otherTeammateCompass);
             /* Other Teammate */


        }

       

        return channeldetailsR;
    }

    private static list<channeldetails> getcustomerDetails1(){
        list<channeldetails> channeldetailsR = new list<channeldetails>();

        return channeldetailsR;
    }

    public class channeldetails{
        @AuraEnabled
        public string interactionId{get;set;}
        @AuraEnabled
        public string channeltype{get;set;}
        @AuraEnabled
        public string timeStamp{get;set;}
        @AuraEnabled
        public list<channelSummary> channelSummaryDetails{get;set;}
        @AuraEnabled
        public list<stepUpInfo> stepUpDetails{get;set;}
        public channeldetails(){
            this.interactionId='';
            this.channeltype='';
            this.timeStamp='';
            this.channelSummaryDetails = new list<channelSummary>();
            this.stepUpDetails= new list<stepUpInfo>();
        }
    }
    public class channelSummary{
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string notes{get;set;}
        @AuraEnabled
        public string timeStamp{get;set;}
        @AuraEnabled
        public string workflowDetails{get;set;}  
        @AuraEnabled
        public boolean isAgent{get;set;}          
        public channelSummary(){
            this.name='';
            this.notes='';
            this.timeStamp='';
            this.workflowDetails='';
            this.isAgent=false;
        }
    }
    public class stepUpInfo{
        @AuraEnabled
        public string type{get;set;}
        @AuraEnabled
        public string status{get;set;} 
        public stepUpInfo(){
            this.type='';
            this.status='';
        }
    }

    /*public class stepUpActivity{
        public string activityName{get;set;}
        public string status{get;set;}
    }
    public class chatDetails{
        public 
    }
    public class FAQDetails{
        public string fqaId{get;set;}
    }
    public class otherTeammate{
        public string systemName{get;set;}
        public string notes{get;set;}
        public string workflowDetails{get;set;}
    }*/
}