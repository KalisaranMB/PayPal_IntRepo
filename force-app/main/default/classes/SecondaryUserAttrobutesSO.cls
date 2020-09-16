public class SecondaryUserAttrobutesSO {
    @AuraEnabled
    public String loginId;

    @AuraEnabled
    public Boolean canContactCS;

    @AuraEnabled
    public List<String> permissions;
}