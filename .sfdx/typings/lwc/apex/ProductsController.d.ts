declare module "@salesforce/apex/ProductsController.getProducts" {
  export default function getProducts(param: {caseId: any, accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProductsController.getProductsWithoutCache" {
  export default function getProductsWithoutCache(param: {caseId: any, accountId: any}): Promise<any>;
}
