/*
* ──────────────────────────────────────────────────────────────────────────────────────┐
* Swagger codegen generated Apex class of getContext API response model.
*
* Part of contact-contexts API response model class.
* ──────────────────────────────────────────────────────────────────
* @author         Sugyan Sahu   <sugsahu@paypal.com>
* @version        1.0
* @created        2020-08-24
* ──────────────────────────────────────────────────────────────────
* @changes
* v1.0            sugsahu@paypal.com
* 2020-08-24      Created the class as part of integration to contact-contexts API.
* ──────────────────────────────────────────────────────────────────────────────────────┘
*/
public class LinkDescription {
    /**
     * The complete target URL. To make the related call, combine the method with this [URI Template-formatted](https://tools.ietf.org/html/rfc6570) link. For pre-processing, include the `$`, `(`, and `)` characters. The `href` is the key HATEOAS component that links a completed call with a subsequent call.
     * @return href
     */
    @AuraEnabled
    public String href { get; set; }

    /**
     * The [link relation type](https://tools.ietf.org/html/rfc5988#section-4), which serves as an ID for a link that unambiguously describes the semantics of the link. See [Link Relations](https://www.iana.org/assignments/link-relations/link-relations.xhtml).
     * @return rel
     */
    @AuraEnabled
    public String rel { get; set; }

    /**
     * The HTTP method required to make the related call.
     */
    public enum MethodEnum {
        GET,
        POST,
        PUT,
        //DELETE,
        HEAD,
        CONNECT,
        OPTIONS,
        PATCH
    }

    /**
     * The HTTP method required to make the related call.
     * tweaked to String instead of an Enum.
     * @return method
     */
    @AuraEnabled
    public String method { get; set; }

    /**
     * The link title.
     * @return title
     */
    @AuraEnabled
    public String title { get; set; }

    /**
     * The media type, as defined by [RFC 2046](https://www.ietf.org/rfc/rfc2046.txt). Describes the link target.
     * @return mediaType
     */
    @AuraEnabled
    public String media_type { get; set; }

    /**
     * The media type in which to submit the request data.
     * @return encType
     */
    @AuraEnabled
    public String enc_type { get; set; }

    /**
     * The schema that describes the request data.
     * @return schema
     */
    @AuraEnabled
    public LinkSchema schema { get; set; }

    /**
     * The schema that describes the link target.
     * @return targetSchema
     */
    @AuraEnabled
    public LinkSchema target_schema { get; set; }

    public LinkDescription() {
        enc_type = 'application/json';
    }
    
}