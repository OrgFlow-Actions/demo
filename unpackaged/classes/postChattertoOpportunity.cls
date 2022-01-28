public class postChattertoOpportunity {
    @InvocableMethod()
    public static void postChatter(List<Id> oppTeamMemID) {
        List<OpportunityTeamMember> oppTeamMemList = [select Id,UserId, OpportunityId, Opportunity.Name from OpportunityTeamMember where Id IN : oppTeamMemID]; 
     
        for(OpportunityTeamMember each : oppTeamMemList ){
          ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
          ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
          ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
          ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
          
          messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
          
          /*Specify the user id for @mention. You can create multiple ConnectApi.MentionSegmentInput if 
            there are multiple users.
           */
          
          mentionSegmentInput.id = each.UserId;
          messageBodyInput.messageSegments.add(mentionSegmentInput);
          String linkUrl = URL.getSalesforceBaseUrl().toExternalForm()+ '/'+ each.OpportunityId;
          textSegmentInput.text = ' You have been added as Opportunity Team Member of Opportunity(' + each.Opportunity.Name+'). \nLink to opportunity- \n'+linkUrl ;
          
          messageBodyInput.messageSegments.add(textSegmentInput);
          
          feedItemInput.body = messageBodyInput;
          feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
          
          //SubjectId indicates to which record this feed item will be tagged to. 
          feedItemInput.subjectId = each.OpportunityId ;
          
          ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput );
          }
    
    }
    
}