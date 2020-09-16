public class Customer360DO {
    public ProfileDO profile;
    public BusinessDetailsDO business_details;
    public ComplianceDO compliance;
    public AccountInfoDO account_attribute;
    public List<SecondaryUserDO> secondary_users;
    public List<LimitationDO> limitations;
    public List<FinancialInstrumentDO> financial_instruments;
    public List<TransactionDO> transactions;
    public List<PayPalCaseDO> cases;
    public List<ActivityLogDO> activities;
    public List<NoteDO> notes;
    public List<ProductDO> products;
    public List<LinkedAccountDO> linked_accounts;
    public List<PreviousInteractionDO> previous_interactions;

    // Error
    public PayPalAPIErrorDO error_object;

    // Parse the API response to Customer360DO
    public static Customer360DO parse(String json) {
        return (Customer360DO) System.JSON.deserialize(json, Customer360DO.class);
    }
}