public class SecurityContextDO {
	public String version;
	public UserDO actor;
	public String auth_token;
	public String auth_token_type;
	public String global_session_id;
	public Double last_validated;
	public List<String> scopes;
    public String client_id;
    public String app_id;
	public AuthClaimsDO claims;
    public string step_up_context;
	public List<SubjectDO> subjects;
	public String signature;
    
	class UserDO {
        public String public_credential;
		public String client_id;
		public String id;
		public List<String> auth_claims;
		public String auth_state;
		public String account_number;
		public String encrypted_account_number;
		public String party_id;
		public Boolean authenticating_user;
        public String authflow_session_id;
		public String user_type;
        public AccountAccessPrivilegeDO account_access_privilege;
		public String legal_country;
	}
    
	class AuthClaimsDO {
		public String subject_payer_id;
		public String actor_payer_id;
	}
    
    class SubjectDO {
        public UserDO subject;
        public List<String> features;
    }
    
	class AccountAccessPrivilegeDO {
		public String access_class;
		public List<String> privileges;
		public Boolean account_owner;
		public String type;
	}
    
	public static SecurityContextDO parse(String json){
		return (SecurityContextDO) System.JSON.deserialize(json, SecurityContextDO.class);
	}
}