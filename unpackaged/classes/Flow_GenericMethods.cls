/*------------------------------------------------------------	
	Author: 		Richard Trum (Glimt) 2019-12-04	
	Description:   	Class used for generic methods that can be used in screen flows
	------------------------------------------------------------*/ 

public class Flow_GenericMethods {
    
    @InvocableMethod
    public static List<Boolean> checkObjectAccess(List<String> objects){
        
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(objects);
        
        List<Boolean> result = new List<Boolean>();
        result.add(results[0].isCreateable());
        
        return result;
    }    

}