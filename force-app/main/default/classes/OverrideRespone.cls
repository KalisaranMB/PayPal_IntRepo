public class OverrideRespone {
    @InvocableVariable
    @AuraEnabled
    public String account_number;
    @InvocableVariable
    @AuraEnabled
    public String override_duration;

    public static OverrideRespone parse(String json) {
        return (OverrideRespone) System.JSON.deserialize(json, OverrideRespone.class);
    }
    
}