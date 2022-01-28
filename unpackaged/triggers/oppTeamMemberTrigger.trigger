trigger oppTeamMemberTrigger on OpportunityTeamMember (after insert) {

    if(trigger.isAfter && trigger.isInsert){
       // FeedItem post = new FeedItem();
       // post.ParentId = '0050J000008QrVE';
        //post.Body = 'test';
        //insert post;
        
         ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
          ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
          ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
          ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
          
          messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
          
          /*Specify the user id for @mention. You can create multiple ConnectApi.MentionSegmentInput if 
            there are multiple users.
           */
           
          mentionSegmentInput.id = '0050J000008QtSv';
          messageBodyInput.messageSegments.add(mentionSegmentInput);
          
          textSegmentInput.text = 'You have been added as Opportunity Team Member';
          messageBodyInput.messageSegments.add(textSegmentInput);
          
          feedItemInput.body = messageBodyInput;
          feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
          
          //SubjectId indicates to which record this feed item will be tagged to. 
          feedItemInput.subjectId = '0069E00000AvYHoQAN';
          
          ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput );
        
        
        
        }

}