@class BLGoogleReaderItem;

%hook BLTweet
-(BLTweet *)initWithURL:(NSURL *)url text:(NSString *)selectedText
{
  BLGoogleReaderItem *item = [[[[UIApplication sharedApplication] delegate] itemViewController] item];
  NSString *string = [NSString stringWithFormat:@"%@ \"%@ - %@\"", selectedText, [item source], [item title]];
  return %orig(url, string);
}
%end

%hook BLTweetViewController
- (void)fixSelectedRange
{
  %orig;
  //BLTweet *tweet = [self tweet];
  UITextView *tv = MSHookIvar<UITextView *>(self, "_textView");
  [tv setSelectionToStart];
  [tv insertText:@" "];
  [tv setSelectionToStart];
}
%end
