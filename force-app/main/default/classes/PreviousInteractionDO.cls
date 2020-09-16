public class PreviousInteractionDO {
    public String case_id;
    public String channel_id;
    public String channel_name;
    public Datetime create_time;
    public Datetime end_time;
    public String parent_case_id;
    public String status;
    public String actor;
    public String contact_reason;
    public Boolean followup;
    public Datetime followup_date;
    public String followup_reason;
    public List<InteractionIntentDO> intents;    
}