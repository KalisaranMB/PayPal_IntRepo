public class LimitationDO {
    public String name;
    public String category;
    public Integer level;
    public Datetime limited_time;
    public List<LimitationSubtypeDO> subtypes;
    public String status;
    public List<LimitationCaseDO> cases;
    public List<LimitationAccessChangeDO> access_changes;
}