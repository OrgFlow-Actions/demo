/*-------------------------------------------------------------------------------------------------------
Author:         Roberto Narbona 20210716
Description:    ProductPricingERPCallOutWrapper -> This is a wrapper class created to be used for ERP call out

History:	Updated By:	Update Description:

----------------------------------------------------------------------------------------*/


public class ProductPricingERPCallOutWrapper {

	public class ProductEntry {
		@AuraEnabled
		public String productId{get;set;}
		@AuraEnabled
		public Integer quantity{get;set;}
	}

	public class Entries {
		@AuraEnabled
        public Double basePrice{get;set;}
		@AuraEnabled
		public ProductEntry productEntry{get;set;}
		@AuraEnabled
		public Double retailPrice{get;set;}
	}

    public class ProductPricingResponse {
		@AuraEnabled
		public List<Entries> entries{get;set;}
	}

    public class DeserializeTokenResponse {
        public String id;
        public String access_token;
        public String Name;
        public String Description;
    }
}