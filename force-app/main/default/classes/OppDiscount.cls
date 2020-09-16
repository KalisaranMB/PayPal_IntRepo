public with sharing class OppDiscount {
    public static Boolean isHighPriorityReturn=false;
    public OppDiscount() {
        
    }
    public static String getTotalDiscount(){
        if (isHighPriorityReturn) {
         return '2';
            
        }else{
            return '1';
        }
    }
}