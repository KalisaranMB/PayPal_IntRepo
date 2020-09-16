public class ProfileDO {
    public String account_id;
    public String account_number;
    public String party_id;
    public String account_type;
    public String account_subtype;
    public String account_status;
    public String full_name;
    public String first_name;
    public String last_name;
    public String logo_url;
    public Integer age;
    public String location;
    public String legal_country_code;
    public String legal_country_name;
    public String timezone;
    public String language;
    public Datetime create_time;
    public String registration_type;
    public Boolean has_secondary_users;
    public String customer_segment;
    public List<EmailDO> emails;
    public List<PhoneDO> phone_numbers;
    public List<AddressDO> addresses;    
}