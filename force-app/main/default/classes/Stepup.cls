public class Stepup {

	@AuraEnabled
    public List<String> availableOptions;
    @AuraEnabled
    public String challenge_id;
    @AuraEnabled
    public Sms sms;
    @AuraEnabled
    public Kba kba;
    @AuraEnabled
    public String status;

    public static Stepup parse(String json) {
        return (Stepup) System.JSON.deserialize(json, Stepup.class);
    }
}