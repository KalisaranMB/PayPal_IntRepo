/* eslint-disable no-alert */
import { LightningElement, api, wire } from "lwc";
import Id from "@salesforce/user/Id";
import pinWidget from "@salesforce/apex/WidgetController.pinWidget";
import unpinWidget from "@salesforce/apex/WidgetController.unpinWidget";

export default class WidgetCard extends LightningElement {
  @api widget;
  @api index;
  @api intent;
  userId = Id;

  widgetClick() {
    this.dispatchEvent(new CustomEvent('widgetclick', { detail: {widget: this.widget } }));
  }

  get getGridStyle() {
    if (this.index % 2 === 0) {
      return "slds-col slds-size_1-of-2";
    }
    return "slds-col slds-size_1-of-2";
  }

  handleUnpinClick(evt) {
    //Call Apex
    unpinWidget({
          WidgetId: evt.target.value,
          UserId: this.userId
        });
    this.dispatchEvent(new CustomEvent('togglepin', { detail: {pinned: false, id: this.widget.Id} }));
  }

  handlePinClick(evt) {
    //Call Apex
    pinWidget({
          WidgetId: evt.target.value,
          UserId: this.userId
        });
    this.dispatchEvent(new CustomEvent('togglepin', { detail: {pinned: true, id: this.widget.Id} }));
  }
}