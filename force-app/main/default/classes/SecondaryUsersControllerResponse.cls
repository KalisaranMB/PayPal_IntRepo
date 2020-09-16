public class SecondaryUsersControllerResponse {
    @AuraEnabled
    public List<ContactSO> secondaryUsers;

    @AuraEnabled
    public Customer360StatusWO result;

    public SecondaryUsersControllerResponse() {
        secondaryUsers = new List<ContactSO>();
        result = new Customer360StatusWO();
    }
}