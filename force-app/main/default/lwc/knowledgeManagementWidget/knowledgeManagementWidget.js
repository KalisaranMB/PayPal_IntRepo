/* eslint-disable no-console */
import { LightningElement, track, wire, api } from "lwc";
import Id from "@salesforce/user/Id";
import fetchAllWidgets from "@salesforce/apex/WidgetController.fetchAllWidgets";
import { context } from 'c/widgetFilterContextCache';
import { NavigationMixin } from 'lightning/navigation';

export default class KnowledgeManagementWidget extends NavigationMixin(LightningElement) {
  @api recordId;

  userId = Id;

  @track localWidgets = []
  @track allWidgets = [];
  @track errors;
  @track intent

  @wire(fetchAllWidgets, { User: "$userId" })
  widgets({ error, data }) {
    if (data) {
      this.allWidgets = data;
      console.log("beforesetting local widgets")
      this.setLocalWidgets();
      this.errors = undefined;
    } else if (error) {
      this.errors = error;
      this.localWidgets = undefined;
    }
  }

  setLocalWidgets() {
    let pinnedWidgets = this.allWidgets.filter(w => w.Pins__r)
    let intentBasedWidgets = this.filterLocalWidgets(this.intent)
    let localWidgetsSet = new Set()
    console.log(pinnedWidgets, intentBasedWidgets)
    //TODO Because @track obbjects are returning proxies spread operator is throwing error
    pinnedWidgets.map( w => localWidgetsSet.add(w))
    intentBasedWidgets.map(w => localWidgetsSet.add(w))
    this.localWidgets = [...localWidgetsSet]
    console.log("setLocalWidgets",this.intent, this.search, JSON.stringify(this.localWidgets))
  }

  @track search = ""; //
  handleChange(evt) {
    if (evt.target.value) {
      this.search = evt.target.value;
      this.filterWidgets();
    } else {
      this.search = "";
      this.filterWidgets();
    }
  }

  filterWidgets() {
    if (!this.search) {
      this.setLocalWidgets();
    } else {
      this.localWidgets = this.filterLocalWidgets(this.search)
      console.log(this.intent, this.search)
    }
  }

  filterLocalWidgets(searchCriteria){
    return searchCriteria?this.allWidgets.filter(
      w =>
        w.Name.toLowerCase().indexOf(searchCriteria.toLowerCase()) > -1 ||
        (w.Tags__c &&
          w.Tags__c.toLowerCase().indexOf(searchCriteria.toLowerCase()) >
            -1)
    )
    :[];
  }

  //Pin and Unpin called from child widgetCard
  handlePinWidget(event) {
    let newPins = event.detail.pinned ? "True" : "";
    this.allWidgets = this.allWidgets.map(w => {
      return w.Id === event.detail.id ? { ...w, Pins__r: newPins } : w;
    });
    this.setLocalWidgets();
    this.filterWidgets();
  }

  updateWidgets(data){
    console.log("New Intent REceived",data)
    this.intent = data.workflow.Flow_API_Name__c
    if(this.localWidgets){
      this.setLocalWidgets()
    }
  }

  handleWidgetClick(event) {
    context.id = this.recordId;
    this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
        apiName: event.detail.widget.ObjectName__c,
      }
    });
  }
}