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
public with sharing class LinkSchema {
    /**
     * Any additional items.
     * @return additionalItems
     */
    @AuraEnabled
    public Object additional_items { get; set; }

    /**
     * Get dependencies
     * @return dependencies
     */
    @AuraEnabled
    public Object dependencies { get; set; }

    /**
     * An item.
     * @return items
     */
    @AuraEnabled
    public Object items { get; set; }

    /**
     * Get definitions
     * @return definitions
     */
    @AuraEnabled
    public Object definitions { get; set; }

    /**
     * The pattern properties.
     * @return patternProperties
     */
    @AuraEnabled
    public Object pattern_properties { get; set; }

    /**
     * Get properties
     * @return properties
     */
    @AuraEnabled
    public Object properties { get; set; }

    /**
     * An array of sub-schemas. The data must validate against all sub-schemas.
     * @return allOf
     */
    @AuraEnabled
    public List<Object> all_of { get; set; }

    /**
     * An array of sub-schemas. The data must validate against one or more sub-schemas.
     * @return anyOf
     */
    @AuraEnabled
    public List<Object> any_of { get; set; }

    /**
     * An array of sub-schemas. The data must validate against one sub-schema.
     * @return oneOf
     */
    @AuraEnabled
    public List<Object> one_of { get; set; }

    /**
     * Get r_not
     * @return r_not
     */
    @AuraEnabled
    public Object r_not { get; set; }

    /**
     * An array of links.
     * @return links
     */
    @AuraEnabled
    public List<Object> links { get; private set; }

    /**
     * The fragment resolution.
     * @return fragmentResolution
     */
    @AuraEnabled
    public String fragment_resolution { get; set; }

    /**
     * Get media
     * @return media
     */
    @AuraEnabled
    public Media media { get; set; }

    /**
     * To apply this schema to the instances\' URIs, start the URIs with this value.
     * @return pathStart
     */
    @AuraEnabled
    public String path_start { get; set; }

    public LinkSchema() {
        all_of = new List<Object>();
        any_of = new List<Object>();
        one_of = new List<Object>();
        links = new List<Object>();
    }

}