import { LightningElement, wire } from 'lwc';
import { publish, MessageContext, subscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import FILTER from '@salesforce/messageChannel/widgetFilter__c';
import { context } from 'c/widgetFilterContextCache';

export default class WidgetFilters extends LightningElement {
    @wire(MessageContext)
    messageContext;

    currentDateFilterType;
    keywordSearch;
    showStartDateInput;
    showEndDateInput;
    startDate;
    endDate;

    subscription = null;

    connectedCallback(){
        this.subscribeMC();
        if(!context.dateFilterType){
            this.changeDateFilter('7days');
        } else {
            this.changeDateFilter(context.dateFilterType, true);
            this.startDate = context.startDate;
            this.endDate = context.endDate;
        }
    }

    get dateFilters() {
        return [
            { label: 'Last 7 Days', value: '7days'},
            { label: 'From Date', value: 'from'},
            { label: 'Specific Range', value: 'range'},
            { label: 'Any', value: 'any'}
        ];
    }

    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            FILTER, (message) => {
                this.handleMessage(message);
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    handleMessage(message) {
        this.startDate = message.startDate;
        this.endDate = message.endDate;
        this.changeDateFilter(context.dateFilterType, true);
    }    

    changeDateFilter(dateFilterType, maintainDates){
        const today = new Date();
        let changedValue = false;
        let d = new Date();
        this.currentDateFilterType = dateFilterType;
        context.dateFilterType = dateFilterType;
        let defaultStartDate;
        let defaultEndDate = today.toISOString();
        switch(dateFilterType){
            case '7days':
                d.setDate(new Date().getDate() - 7);
                defaultStartDate = d.toISOString();
                defaultEndDate = today.toISOString();
                this.showStartDateInput = false;
                this.showEndDateInput = false;
                changedValue = true;
                break;
            case 'from':
                defaultStartDate = this.startDate;
                defaultEndDate = today.toISOString();
                this.showStartDateInput = true;
                this.showEndDateInput = false;
                changedValue = true;
                break;
            case 'range':
                this.showStartDateInput = true;
                this.showEndDateInput = true;
                break;
            case 'any':
                defaultStartDate = new Date(2000, 1).toISOString();
                this.showStartDateInput = false;
                this.showEndDateInput = false;
                changedValue = true;
                break;
            default:
                this.showStartDateInput = false;
                this.showEndDateInput = false;
        }
        if(changedValue && !maintainDates){
            this.startDate = defaultStartDate;
            this.endDate = defaultEndDate;
            context.startDate = this.startDate;
            context.endDate = this.endDate;
        }
        return changedValue;
    }

    handleFilterChange(event){
        switch(event.target.name){
            case 'keyword-search':
                this.keywordSearch = event.target.value;
                break;
            case 'date-filter-type':
                const changedValue = this.changeDateFilter(event.detail.value);
                if(!changedValue) return;
                break;
            case 'start-date':
                this.startDate = event.target.value;
                context.startDate = this.startDate;
                break;
            case 'end-date':
                this.endDate = event.target.value;
                context.endDate = this.endDate;
                break;
        }
        const message = {
            keyword: this.keywordSearch,
            startDate: this.startDate,
            endDate: this.endDate
        };
        console.log("Sending message", message);
        publish(this.messageContext, FILTER, message);
    }
}