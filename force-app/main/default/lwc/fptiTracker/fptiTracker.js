/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import FPTI from '@salesforce/resourceUrl/FPTI';
import { loadScript } from 'lightning/platformResourceLoader';
import Id from '@salesforce/user/Id';
export default class FptiTracker extends LightningElement {
    userId = Id;
    // variable will decide whether FPTI script should be loaded or not
    @api donotLoadFPTI = false;
    //case record Id
    @api recordId;
    // page group -FPTI paramater
    @api pageGroup;
    //page -FPTI paramater
    @api page;
    //to store the start time
    @track startTime;
    //to store the start time
    @track startTime1 = 0;
    //to indicate whether timer is started or not
    @track timerStarted = false;
    // to store the total time
    @track totalTime = 0;
    // to store the total click in the page
    @track totalClicks = 0;
    connectedCallback() {
            if (!this.donotLoadFPTI) {
                //loading FPTI script and adding window listeners
                loadScript(this, FPTI).then(() => {
                        if (window.PAYPAL && window.PAYPAL.analytics) {
                            if (document.readyState === "ready" || document.readyState === "complete") {
                                window.addEventListener('focus', this.onfocusEventHandler.bind(this));
                                window.addEventListener('blur', this.onBlurEventHandler.bind(this));
                                window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
                                window.addEventListener('click', this.countClicks.bind(this));
                                this.startTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
                                this.timerStarted = true;
                            } else {
                                document.onreadystatechange = function() {
                                    if (document.readyState === "complete") {
                                        window.addEventListener('focus', this.onfocusEventHandler.bind(this));
                                        window.addEventListener('blur', this.onBlurEventHandler.bind(this));
                                        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
                                        window.addEventListener('click', this.countClicks.bind(this));
                                        this.startTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
                                        this.timerStarted = true;
                                    }
                                }
                            }
                        }
                        //this.template.querySelector('lightning-button');
                    })
                    .catch(e => {
                        console.log("Failed to load FPTI Script", e)
                    })
            }
        }
        //Passing the total time spend on the salesforce page when browser tab is closed
    beforeUnloadHandler() {
            if (this.timerStarted) {
                let endTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
                let seconds = (endTime - this.startTime) / 1000;
                this.totalTime = this.totalTime + seconds;
            }
            // pgrp: "salesforce:cs_customer:console:service124",
            //page: "salesforce:cs_customer:console:service:customerJourney3",
            let data = {
                page: this.page,
                pgrp: this.pageGroup,
                url: window.location.href,
                action: 'page_Spend_Time_' + this.userId,
                internal_user: this.userId, // applicaion_namecs_compass
                view: { "t11": this.totalTime }

            };
            window.PAYPAL.analytics.logPerformance(data);
        }
        //starting the timer when the browser tab is on focus
    onfocusEventHandler() {
            this.startTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
            this.timerStarted = true;
        }
        // pausing the timer when browser tab is out of focus
    onBlurEventHandler() {
            let endTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
            let seconds = (endTime - this.startTime) / 1000;
            this.totalTime = this.totalTime + seconds;
            this.timerStarted = false;
        }
        // tracking clicks in the page level 
    countClicks() {
            this.totalClicks = this.totalClicks + 1;
            //console.log('::event:' + event);
            //console.log('::event:' + event.target);
            //console.log('::totalClicks:' + this.totalClicks);
        }
        // this method will be used in aura component to start the timer
    @api
    startTimer() {
            this.startTime1 = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
        }
        // this method will be used in aura component to end the timer
    @api
    endTimer(componentName, pageName, pageGroup) {
        //console.log(':::startTime1:::' + this.startTime1);
        //console.log(':::componentName:::' + componentName);
        if (this.startTime1 > 0) {
            let endTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
            let seconds = (endTime - this.startTime1) / 1000;
            //console.log(':::seconds:::' + seconds);
            this.startTime1 = 0;
            let pgName = this.page;
            let pgGroup = this.pageGroup;
            if (pageName !== undefined && pageName !== '')
                pgName = pageName;
            if (pageGroup !== undefined && pageGroup !== '')
                pgGroup = pageGroup;
            let data = {
                page: pgName,
                pgrp: pgGroup,
                url: window.location.href,
                action: componentName + 'page_Spend_Time_' + this.userId,
                internal_user: this.userId,
                application_name: 'salesforce',
                caseid: this.recordId,
                view: { "t11": seconds }

            };
            window.PAYPAL.analytics.logPerformance(data);
        }
    }


}
// this function will be used in custom LWC component to track the click events and its details
export function trackOnClickEvents(event) {
    //account_number
    //event_source
    //tm_location
    let dataSetGroup = event.target.dataset;
    //console.log(':::dataset:::' + JSON.stringify(event.target.dataset));
    if (dataSetGroup.fptiName !== undefined && dataSetGroup.fptiPage !== undefined && dataSetGroup.fptiPgrp !== undefined) {
        let options = {
            data: {
                page: dataSetGroup.fptiPage,
                pgrp: dataSetGroup.fptiPgrp,
                url: window.location.href,
                link_name: dataSetGroup.fptiName,
                caseid: this.recordId,
                application_name: 'salesforce',
                internal_user: this.userId
            }
        };

        window.PAYPAL.analytics.Analytics.prototype.recordClick(options);
    }
}
// this function will be used in custom LWC component to start the timer
export function startTimer() {
    this.startTime1 = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
}
// this function will be used in custom LWC component to end the timer
export function endTimer(componentName, pageName, pageGroup) {
    //console.log(':::startTime1:::' + this.startTime1);
    //console.log(':::componentName:::' + componentName);
    if (this.startTime1 > 0) {
        let endTime = window.PAYPAL.analytics.Analytics.prototype.getTimeNow();
        let seconds = (endTime - this.startTime1) / 1000;
        //console.log(':::seconds:::' + seconds);
        this.startTime1 = 0;
        let pgName = this.page;
        let pgGroup = this.pageGroup;
        if (pageName !== undefined && pageName !== '')
            pgName = pageName;
        if (pageGroup !== undefined && pageGroup !== '')
            pgGroup = pageGroup;
        let data = {
            page: pgName,
            pgrp: pgGroup,
            url: window.location.href,
            action: componentName + 'page_Spend_Time_' + this.userId,
            internal_user: this.userId,
            application_name: 'salesforce',
            caseid: this.recordId,
            view: { "t11": seconds }

        };
        window.PAYPAL.analytics.logPerformance(data);
    }
}