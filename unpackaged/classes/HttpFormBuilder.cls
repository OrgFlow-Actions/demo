public class HttpFormBuilder {

    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';
    
    public static String getContentType(){
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }

    private static string SafelyPad(string value, string valueCrLf64, string lineBreaks){
            string valueCrLf = '';
            blob valueCrLfBlob = null;

            while(valueCrLf64.endsWith('=')){
                value += ' ';
                valueCrLf = value + lineBreaks;
                valueCrLfBlob = blob.valueOf(valueCrLf);
                valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
            }

            return valueCrLf64;
    }

    public static String WriteBoundary(){
        String value = '--' + Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    public static String WriteBoundary(EndingType ending){
        String value = '';

        if(ending == EndingType.Cr){
            value += '\n';
        }
        else if(ending == EndingType.None){
            value += '\r\n';
        }

        value += '--' + Boundary + '--';

        Blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    public static String WriteBodyParameter(String key, String value){
        String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n\r\n';
        Blob contentDispositionCrLfBlob = Blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
        String content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
        String valueCrLf = value + '\r\n';
        Blob valueCrLfBlob = Blob.valueOf(valueCrLf);
        String valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        content += SafelyPad(value, valueCrLf64, '\r\n');
        
        return content;

    }

    public enum EndingType{
        Cr,CrLf,None
    }

    
}