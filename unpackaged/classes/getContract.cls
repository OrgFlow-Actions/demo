public with sharing class getContract {
public Contract contr {get;set;}
public String currentRecordId {get;set;}
//public String parameterValue {get;set;}
//public Flow.Interview.Contract_update_allowed_discount myFlow {get; set;}
//public Flow.Interview.Contract_Update_sales_history myFlow2 {get; set;}
//public PageReference conlink {get; set;}

public getContract(ApexPages.StandardController stdController) {
currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
contr = [select id, Name, StartDate, Discount_Model__r.Webshop_discount__c, New_customer__c, Correction_of_sales_needed__c, Payment_discount__c, Revenue_forecast__c, Implant_forecast__c, Account.Id, Revenue_basis_for_allowance__c,
Allowed_discount_revenue_materials__c, Negative_discount_materials__c, Negative_discount_equipment__c, 
Allowed_discount_revenue_equipments__c, Allowed_discount_Implants_materials__c, Allowed_discount_Implants_equipment__c, 
Allowed_discount_abutment_materials__c, Allowed_discount_abutment_equipment__c, Allowed_discount_pooling_materials__c, 
Allowed_discount_pooling_equipment__c, Allowed_discount_materials__c, Sales_L12M__c, Abutment_commitment_pick__c, 
Pooled_order_commitment__c, Previous_contract__r.Contract_discount_pricing_materials__c, Previous_contract__r.Contract_discount_equipment__c, 
Allowed_discount_equipment__c, Remains_impl_material__c, Row_discount_rev_mat__r.Min__c, Row_discount_rev_mat__r.Max__c, 
Row_discount_impl_mat__r.Min_perc__c, Row_discount_impl_mat__r.Max_perc__c, Implant_volume_L12M__c, 
Implant_commitment__c, Implant_commitment_perc__c, Implant_commitment_perc_input__c, Implant_commitment_abs__c, Pooled_order_commitment_perc_input__c, Abutment_commitment_formula__c
from Contract where id =: currentRecordId ];
//parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
}

public List<Sales_History__c> Sales_Account {get; set;}

public Decimal Sales_CY_C {get; set;}
public Decimal Sales_LY_C {get; set;}
public Decimal Sales_L2Y_C {get; set;}
public Decimal Sales_L3Y_C {get; set;}

public Decimal Sales_CY_M_C {get; set;}
public Decimal Sales_LY_M_C {get; set;}
public Decimal Sales_L2Y_M_C {get; set;}
public Decimal Sales_L3Y_M_C {get; set;}

public Decimal Sales_CY_EI_C {get; set;}
public Decimal Sales_LY_EI_C {get; set;}
public Decimal Sales_L2Y_EI_C {get; set;}
public Decimal Sales_L3Y_EI_C {get; set;}

public Decimal Sales_CY_A {get; set;}
public Decimal Sales_LY_A {get; set;}
public Decimal Sales_L2Y_A {get; set;}
public Decimal Sales_L3Y_A {get; set;}

public Decimal Discount_CY_C {get; set;}
public Decimal Discount_LY_C {get; set;}
public Decimal Discount_L2Y_C {get; set;}
public Decimal Discount_L3Y_C {get; set;}

public Decimal Discount_CY_M_C {get; set;}
public Decimal Discount_LY_M_C {get; set;}
public Decimal Discount_L2Y_M_C {get; set;}
public Decimal Discount_L3Y_M_C {get; set;}

public Decimal Discount_CY_EI_C {get; set;}
public Decimal Discount_LY_EI_C {get; set;}
public Decimal Discount_L2Y_EI_C {get; set;}
public Decimal Discount_L3Y_EI_C {get; set;}

public Decimal Implants_CY_C {get; set;}
public Decimal Implants_LY_C {get; set;}
public Decimal Implants_L2Y_C {get; set;}
public Decimal Implants_L3Y_C {get; set;}

public Decimal Abutments_CY_C {get; set;}
public Decimal Abutments_LY_C {get; set;}
public Decimal Abutments_L2Y_C {get; set;}
public Decimal Abutments_L3Y_C {get; set;}

public Decimal ContractImplantsSalesActivation {get; set;}
public Decimal ContractAbutmentsSalesActivation {get; set;}

public PageReference getSales_CY () {

Sales_CY_C = 0;
Sales_LY_C = 0;
Sales_L2Y_C = 0;
Sales_L3Y_C = 0;

Sales_CY_M_C = 0;
Sales_LY_M_C = 0;
Sales_L2Y_M_C = 0;
Sales_L3Y_M_C = 0;

Sales_CY_EI_C = 0;
Sales_LY_EI_C = 0;
Sales_L2Y_EI_C = 0;
Sales_L3Y_EI_C = 0;

Discount_CY_M_C = 0;
Discount_LY_M_C = 0;
Discount_L2Y_M_C = 0;
Discount_L3Y_M_C = 0;

Discount_CY_EI_C = 0;
Discount_LY_EI_C = 0;
Discount_L2Y_EI_C = 0;
Discount_L3Y_EI_C = 0;

Discount_CY_C = 0;
Discount_LY_C = 0;
Discount_L2Y_C = 0;
Discount_L3Y_C = 0;

Implants_CY_C = 0;
Implants_LY_C = 0;
Implants_L2Y_C = 0;
Implants_L3Y_C = 0;

Abutments_CY_C = 0;
Abutments_LY_C = 0;
Abutments_L2Y_C = 0;
Abutments_L3Y_C = 0;

Sales_CY_A = 0;
Sales_LY_A = 0;
Sales_L2Y_A = 0;
Sales_L3Y_A = 0;

Sales_Account = [Select Id, Account__c, Quantity__c, Contract__c, Implants_Qty__c, Product__r.GlobalSKUMapping__r.PG2_Code__c, Discount_Amount__c, Tot_Price__c, Discount_Model__c, Gross_price__c, Invoice_Date__c, Invoice_Year_numeric__c FROM Sales_History__c WHERE Account__c =: contr.Account.Id];

For (Sales_history__c salesH : Sales_account) {
 
    if (salesH.Invoice_Year_numeric__c == System.Today().year()){
    Sales_CY_C = Sales_CY_C + salesH.Tot_Price__c;
    Implants_CY_C = Implants_CY_C + salesH.Implants_Qty__c;
    Discount_CY_C= Discount_CY_C + salesH.Gross_price__c - salesH.Tot_Price__c;    
    /*If (salesH.Discount_Amount__c>0){
    Discount_CY_C = Discount_CY_C + salesH.Discount_Amount__c;    
    }*/
    
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II11')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II13')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II14')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II16')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II17')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR31')||
            (salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR32')
             ){
            Sales_CY_M_C = Sales_CY_M_C + salesH.Tot_Price__c;
            Discount_CY_M_C= Discount_CY_M_C + salesH.Gross_price__c - salesH.Tot_Price__c;
            /*If (salesH.Discount_Amount__c>0){
            Discount_CY_M_C = Discount_CY_M_C + salesH.Discount_Amount__c; 
            }*/
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II15')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II18')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR30')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID85')
           ) {
        Sales_CY_EI_C = Sales_CY_EI_C + salesH.Tot_Price__c;
        Discount_CY_EI_C= Discount_CY_EI_C + salesH.Gross_price__c - salesH.Tot_Price__c;            
            
            /*If (salesH.Discount_Amount__c>0){
            Discount_CY_EI_C = Discount_CY_EI_C + salesH.Discount_Amount__c; 
            }*/
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID21')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID22')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID23')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID28')) {
        Abutments_CY_C = Abutments_CY_C + salesH.Quantity__c;
        
        }
        
        
    }

    if (salesH.Invoice_Year_numeric__c == (System.Today().year()-1)){
    Sales_LY_C = Sales_LY_C + salesH.Tot_Price__c;
    Implants_LY_C = Implants_LY_C + salesH.Implants_Qty__c;
    Discount_LY_C= Discount_LY_C + salesH.Gross_price__c - salesH.Tot_Price__c;    
            /*If (salesH.Discount_Amount__c>0){
            Discount_LY_C = Discount_LY_C + salesH.Discount_Amount__c;
            }*/
    
    
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II11')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II13')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II14')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II16')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II17')) {
        Sales_LY_M_C = Sales_LY_M_C + salesH.Tot_Price__c;
        Discount_LY_M_C= Discount_LY_M_C + salesH.Gross_price__c - salesH.Tot_Price__c;
             /*If (salesH.Discount_Amount__c>0){
             Discount_LY_M_C = Discount_LY_M_C + salesH.Discount_Amount__c; 
             }*/
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II15')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II18')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR30')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID85')
           ) {
        Sales_LY_EI_C = Sales_LY_EI_C + salesH.Tot_Price__c;
        Discount_LY_EI_C= Discount_LY_EI_C + salesH.Gross_price__c - salesH.Tot_Price__c;    
            /*If (salesH.Discount_Amount__c>0){
            Discount_LY_EI_C = Discount_LY_EI_C + salesH.Discount_Amount__c; 
            }*/
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID21')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID22')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID23')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID28')) {
        Abutments_LY_C = Abutments_LY_C + salesH.Quantity__c;
        }
              
      
    }

    if (salesH.Invoice_Year_numeric__c == (System.Today().year()-2)){
    Sales_L2Y_C = Sales_L2Y_C + salesH.Tot_Price__c;
    Implants_L2Y_C = Implants_L2Y_C + salesH.Implants_Qty__c;
    Discount_L2Y_C= Discount_L2Y_C + salesH.Gross_price__c - salesH.Tot_Price__c;    
    /*If (salesH.Discount_Amount__c>0){
        Discount_L2Y_C = Discount_L2Y_C + salesH.Discount_Amount__c;
    }*/
    
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II11')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II13')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II14')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II16')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II17')) {
        Sales_L2Y_M_C = Sales_L2Y_M_C + salesH.Tot_Price__c;
        Discount_L2Y_M_C= Discount_L2Y_M_C + salesH.Gross_price__c - salesH.Tot_Price__c;            
            /*If (salesH.Discount_Amount__c>0){
            Discount_L2Y_M_C = Discount_L2Y_M_C + salesH.Discount_Amount__c;
            }*/ 
            
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II15')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II18')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR30')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID85')
           ) {
        Sales_L2Y_EI_C = Sales_L2Y_EI_C + salesH.Tot_Price__c;
        Discount_L2Y_EI_C= Discount_L2Y_EI_C + salesH.Gross_price__c - salesH.Tot_Price__c;        
            /*If (salesH.Discount_Amount__c>0){
            Discount_L2Y_EI_C = Discount_L2Y_EI_C + salesH.Discount_Amount__c;
            }*/
        } 
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID21')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID22')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID23')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID28')) {
        Abutments_L2Y_C = Abutments_L2Y_C + salesH.Quantity__c;
        }           
    
    }
    
        if (salesH.Invoice_Year_numeric__c == (System.Today().year()-3)){
    Sales_L3Y_C = Sales_L3Y_C + salesH.Tot_Price__c;
    Implants_L3Y_C = Implants_L3Y_C + salesH.Implants_Qty__c;
    Discount_L3Y_C= Discount_L3Y_C + salesH.Gross_price__c - salesH.Tot_Price__c;
       /*If (salesH.Discount_Amount__c>0){
        Discount_L3Y_C = Discount_L3Y_C + salesH.Discount_Amount__c;       
       }*/
    
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II11')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II13')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II14')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II16')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II17')) {
        Sales_L3Y_M_C = Sales_L3Y_M_C + salesH.Tot_Price__c;
        Discount_L3Y_M_C= Discount_L3Y_M_C + salesH.Gross_price__c - salesH.Tot_Price__c;            
            /*If (salesH.Discount_Amount__c>0){
            Discount_L3Y_M_C = Discount_L3Y_M_C + salesH.Discount_Amount__c; 
            }*/
        }
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II15')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II18')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'IR30')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID85')  
           ) {
        Sales_L3Y_EI_C = Sales_L3Y_EI_C + salesH.Tot_Price__c;
        Discount_L3Y_EI_C= Discount_L3Y_EI_C + salesH.Gross_price__c - salesH.Tot_Price__c;        
            /*If (salesH.Discount_Amount__c>0){
            Discount_L3Y_EI_C = Discount_L3Y_EI_C + salesH.Discount_Amount__c;
            }*/
        } 
        
        if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID21')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID22')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID23')
            ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID28')) {
        Abutments_L3Y_C = Abutments_L3Y_C + salesH.Quantity__c;
        }
              
    }
    
   
}

return null;
}


public PageReference getContractStatus () {

ContractImplantsSalesActivation = 0;
ContractAbutmentsSalesActivation = 0;

Sales_Account = [Select Id, Account__c, Quantity__c, Contract__c, Implants_Qty__c, Product__r.GlobalSKUMapping__r.PG2_Code__c, Discount_Amount__c, Discount_Model__c, Tot_Price__c, Gross_price__c, Invoice_Date__c, Invoice_Year_numeric__c FROM Sales_History__c WHERE Account__c =: contr.Account.Id];
    
For (Sales_history__c salesH : Sales_account) {

        if(salesH.Contract__c == currentRecordId || (salesH.Discount_Model__c == 'DE-DENTAL2' && salesH.Invoice_Date__c >= contr.StartDate)) {
                ContractImplantsSalesActivation = ContractImplantsSalesActivation + salesH.Implants_Qty__c;
        
                if ((salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'II12')
                    ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID21')
                    ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID22')
                    ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID23')
                    ||(salesH.Product__r.GlobalSKUMapping__r.PG2_Code__c == 'ID28')){
         
                     ContractAbutmentsSalesActivation = ContractAbutmentsSalesActivation + salesH.Quantity__c;          
                   
                 }
         }    

}

return null;

}



public Boolean HasM {get; set;}

Public void save(){

try{
upsert contr;
HasM = false;
}

catch(Exception ex){
ApexPages.addMessages(ex);
HasM = true;
}

}


public void doAction () {
}

public String stepname {get; set;}

public void navFlow () {
stepname = 'FLOW';
}

public void navEnd () {
stepname = 'END';
}


}