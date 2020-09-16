public class Sms {
    @AuraEnabled
    @InvocableVariable
    public List<PhoneNumber> phone_numbers;
    @AuraEnabled
    public Boolean can_add_phone;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String reason;
}