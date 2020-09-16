public class TransactionDO {
    public String transaction_type;
    public Datetime create_time;
    public String transaction_id;
    public String encrypted_transaction_id;
    public String status;
    public MoneyDO gross_amount;
    public MoneyDO fee_amount;
    public MoneyDO net_amount;
    public MoneyDO running_balance_amount;
    public String last_digits;
    public String to_and_from;
    public String counterparty_name;
    public String counterparty_email;
    public Boolean parent;
    public Boolean disputed;
}