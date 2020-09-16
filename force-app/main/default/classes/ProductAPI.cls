public class ProductAPI {
    
    public static Customer360SO mapResponseToCustomer360SO(Customer360SO cx360SO, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProductAPI:mapResponseToCustomer360SO - mapping Products Information');
        
        // Check if there are any failures in loading Products
        if (response.isProductInfoFailed() || (response.getCustomer360DO().products == null) ||
            (response.getCustomer360DO().products.size() == 0))
        {
            System.debug('No Products available in Customer360 API response');
            return cx360SO;
        }
        
        // Map Products to the cx360SO object passed in the request
        for (ProductDO product : response.getCustomer360DO().products)
        {
            cx360SO.products.add(mapProductDOToSO(product));
        }

        return cx360SO;
    }

    public static Account storeResponseInSObject(Account acct, Customer360APIRequest request, Customer360APIResponse response)
    {
        System.debug('ProductAPI:storeResponseInSObject - Storing Product Details into SObject');
        
        // Check if there are any failures in loading Product Details
        if (response.isProductInfoFailed())
        {
            System.debug('Customer360 API did not successfully load Product Details');
            return acct;
        }

        // Remove all existing Products from the account
        removeProductsFromAccount(acct);

        List<ProductDO> products = response.getCustomer360DO().products;
        
        if ((products != null) && (products.size() > 0))
        {
            List<Account_Product__c> productObjs = new List<Account_Product__c>();

            for (ProductDO product : products)
            {
                Account_Product__c productObj = mapProductDOToSO(product);
                productObj.Account__c = acct.Id;
                productObjs.add(productObj);
            }

            insert productObjs;
        }

        // If Product Information is successfully loaded (NOT a failure or partial success), update the cache time
        if (response.isProductInfoSuccessfullyLoaded())
        {
            acct.Product_Info_Loaded_Time__c = Datetime.now();
        }

        return acct;
    }

    private static void removeProductsFromAccount(Account acct)
    {
        List<Account_Product__c> products = queryProductsFromAccount(acct.Id);
        System.debug('Removing existing products from the account. Number of records found - ' + products.size());
        if (products.size() > 0)
        {
            delete products;
        }
        return;
    }

    private static Account_Product__c mapProductDOToSO(ProductDO product)
    {
        Account_Product__c prod = new Account_Product__c();
        prod.Name = getproductName(product.product_code);
        prod.Product_Code__c = product.product_code;
        prod.Time_Created__c = product.create_time;
        prod.Time_Last_Updated__c = product.update_time;
        prod.Status__c = product.status.toLowerCase().capitalize();

        if (product.status.equalsIgnoreCase('SUBSCRIBED'))
        {
            // If the status is subscribed, the last updated time will indicate the activation time
            prod.Time_Activated__c = product.update_time;
        }
        else if (product.status.equalsIgnoreCase('CANCELLED'))
        {
            // If the status is cancelled, the last updated time will indicate the de-activation time
            prod.Time_Deactivated__c = product.update_time;
        }
        
        return prod;
    }

    private static String getproductName(String productCode)
    {
        // TBD - get list of all product codes
        if (productCode.equalsIgnoreCase('PAYPAL_HERE'))
        {
            return 'PayPal Here';
        }
        else
        {
            return productCode;
        }
    }

    private static List<Account_Product__c> queryProductsFromAccount(Id accountId)
    {
        return [SELECT Id, Account__c FROM Account_Product__c
                WHERE Account__c=:accountId];
    }
}