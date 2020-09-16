// Class to parse the PayPal API Error response that is returned by CSDAS
// Typically returned in scenarios like 400, 404 or 500. Check the API spec for more details
public class PayPalAPIErrorDO {
    public String name;
    public String message;
    public String debug_id;
    public String information_link;
    public List<PayPalAPIErrorDetailDO> details;
    // Error Object defined in CSDAS has links which is an array
    // We can implement it later if it is useful :)

    // Function used to parse the Error response into the object
    public static PayPalAPIErrorDO parse(String json) {
        return (PayPalAPIErrorDO) System.JSON.deserialize(json, PayPalAPIErrorDO.class);
    }
}