@class BLGoogleReaderItem;

%hook BLTweet
-(BLTweet *)initWithURL:(NSURL *)url text:(NSString *)selectedText
{
  BLGoogleReaderItem *item = [[[[UIApplication sharedApplication] delegate] itemViewController] item];
  NSString *string = [NSString stringWithFormat:@"%@ \"%@ - %@", selectedText, [item source], [item title]];
  return %orig(url, string);
}
%end
/*
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

%hook BLGoogleReader
- (void)setSyncDate:(NSDate *)date
{
  %orig;
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  //[notification setFireDate:[NSDate date]];
  [notification setTimeZone:[NSTimeZone localTimeZone]];
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"Y/M/d H:m:ss Z"];
  // http://d.hatena.ne.jp/nakamura001/20100525/1274802305
  //NSLog(@"descriptionWithLocale = %@", [date descriptionWithLocale:[NSLocale currentLocale]]);
  //NSLog(@"formatter = %@", [dateFormatter stringFromDate:date]);
  [notification setAlertBody:[NSString stringWithFormat:@"Synced at %@", [dateFormatter stringFromDate:date]]];
  [notification setSoundName:UILocalNotificationDefaultSoundName];
  [notification setAlertAction:@"Open"];
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
  [notification release];
}
%end
*/
