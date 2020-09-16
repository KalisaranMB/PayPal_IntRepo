declare module "@salesforce/apex/WidgetController.fetchWidgets" {
  export default function fetchWidgets(param: {User: any, SearchParam: any}): Promise<any>;
}
declare module "@salesforce/apex/WidgetController.pinWidget" {
  export default function pinWidget(param: {WidgetId: any, UserId: any}): Promise<any>;
}
declare module "@salesforce/apex/WidgetController.unpinWidget" {
  export default function unpinWidget(param: {WidgetId: any, UserId: any}): Promise<any>;
}
declare module "@salesforce/apex/WidgetController.fetchAllWidgets" {
  export default function fetchAllWidgets(param: {User: any}): Promise<any>;
}
