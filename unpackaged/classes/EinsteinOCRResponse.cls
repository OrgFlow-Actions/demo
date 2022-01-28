public class EinsteinOCRResponse {
    public String task;	
    public Probabilities[] probabilities;
    public class Probabilities {
        public Double probability;
        public String label;	
        public BoundingBox boundingBox;
        public Attributes attributes;
    }
    public class BoundingBox {
        public Integer minX;	
        public Integer minY;	
        public Integer maxX;	
        public Integer maxY;	
    }
    public class Attributes{
        public Integer pageNumber;
        public String tag;
    }
}