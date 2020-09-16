public class PrefetchDataDO {
    public Customer360DO customer_360;

    // Parse the Prefetch data into the Object
    public static PrefetchDataDO parse(String json) {
        return (PrefetchDataDO) System.JSON.deserialize(json, PrefetchDataDO.class);
    }
}