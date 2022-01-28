/**
 * Class used to serialize a single Lookup search result item
 * The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
 */
public class LookupSearchResult implements Comparable {
    private Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    // Test attributes for pill container
    private String label;
    private String name;
    private String iconName;
    private String type;
    private String alternativeText;

    public LookupSearchResult(
        Id id,
        String sObjectType,
        String icon,
        String title,
        String subtitle
    ) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        // Test attributes for pill container
        this.label = title;
        this.name = title;
        this.iconName = icon;
        this.alternativeText = title;
    }
    // Constructor overload
    public LookupSearchResult(
        Id id,
        String sObjectType,
        String icon,
        String title,
        String subtitle,
        String type
    ) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        // Test attributes for pill container
        this.label = title;
        this.name = title;
        this.iconName = icon;
        this.alternativeText = title;
        this.type = type;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    // Test getters for pill container
    @AuraEnabled
    public String getLabel() {
        return label;
    }

    @AuraEnabled
    public String getName() {
        return name;
    }

    @AuraEnabled
    public String getIconName() {
        return iconName;
    }

    @AuraEnabled
    public String getAlternativeText() {
        return alternativeText;
    }

    @AuraEnabled
    public String getType() {
        return type;
    }
    
    /**
     * Allow to sort search results based on title
     */
    public Integer compareTo(Object compareTo) {
        LookupSearchResult other = (LookupSearchResult) compareTo;
        if (this.getTitle() == null) {
            return (other.getTitle() == null) ? 0 : 1;
        }
        if (other.getTitle() == null) {
            return -1;
        }
        return this.getTitle().compareTo(other.getTitle());
    }
}