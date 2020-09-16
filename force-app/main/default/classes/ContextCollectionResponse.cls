/*
* ───────────────────────────────────────────────────────────────────────────────────┐
* Swagger codegen generated Apex class of getContext API response.
*
* contact-contexts API response class.
* ──────────────────────────────────────────────────────────────────
* @author         Sugyan Sahu   <sugsahu@paypal.com>
* @version        1.0
* @created        2020-08-24
* ──────────────────────────────────────────────────────────────────
* @changes
* v1.0            sugsahu@paypal.com
* 2020-08-24      Created the class as part of integration to contact-contexts API.
* ───────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class ContextCollectionResponse {
    /**
     * Context summary array.
     * @return items
     */
    @AuraEnabled
    @InvocableVariable
    public List<Context> items;

    /**
     * Total number of items available.
     * minimum: 0
     * maximum: 2147483647
     * @return totalItems
     */
    @AuraEnabled
    public Integer total_items { get; set; }

    /**
     * Total number of pages available.
     * minimum: 0
     * maximum: 2147483647
     * @return totalPages
     */
    @AuraEnabled
    public Integer total_pages { get; set; }

    /**
     * An array of request-related [HATEOAS links](/docs/api/reference/api-responses/#hateoas-links).
     * @return links
     */
    @AuraEnabled
    public List<LinkDescription> links { get; set; }

    public ContextCollectionResponse() {
        items = new List<Context>();
        links = new List<LinkDescription>();
    }

    public static ContextCollectionResponse parse(String json) {
		return (ContextCollectionResponse) System.JSON.deserialize(json, ContextCollectionResponse.class);
    }
    
}