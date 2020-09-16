public class PreviousInteractionSearchCriteria {

    /************************** Search By Time Range **************************/
    // This criteria will help to search for previous interactions within a specifiec
    // time range. Please note that both fromTime and toTime should be passed in the input
    // if we are searching using the time, we cannot pass one and leave another. Also, fromTime
    // cannot be greater than toTime and both fromTime and toTime cannot be in future since it
    // doesn't make any sense

    @AuraEnabled
    public Datetime fromTime {get; set;}
    
    @AuraEnabled
    public Datetime toTime {get; set;}
}