#import "AllAroundPullView/AllAroundPullView.h"
//#define DEBUG 1
#import "debug.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/jp.r-plus.bylineenhancer.plist"

@interface AllAroundPullViewActionHandler : NSObject <AllAroundPullViewDelegate>
@end

static AllAroundPullViewActionHandler *pullViewActionHandler;

/*static AllAroundPullView *rootPullViewTop = nil;*/
/*static AllAroundPullView *listPullViewTop = nil;*/
static AllAroundPullView *listPullViewBottom = nil;
/*static AllAroundPullView *feedPullViewTop = nil;*/
/*static AllAroundPullView *feedPullViewBottom = nil;*/
/*static AllAroundPullView *feedPullViewLeft = nil;*/
/*static AllAroundPullView *feedPullViewRight = nil;*/

static BOOL tweetFormatterIsEnabled;
/*static BOOL rootPullViewTopIsEnabled;*/
/*static BOOL listPullViewTopIsEnabled;*/
static BOOL listPullViewBottomIsEnabled;
/*static BOOL feedPullViewTopIsEnabled;*/
/*static BOOL feedPullViewBottomIsEnabled;*/
/*static BOOL feedPullViewLeftIsEnabled;*/
/*static BOOL feedPullViewRightIsEnabled;*/
/*static CGFloat rootPullViewTopThreshold;*/
/*static CGFloat listPullViewTopThreshold;*/
static CGFloat listPullViewBottomThreshold;
/*static CGFloat feedPullViewTopThreshold;*/
/*static CGFloat feedPullViewBottomThreshold;*/
/*static CGFloat feedPullViewLeftThreshold;*/
/*static CGFloat feedPullViewRightThreshold;*/
/*static NSUInteger listPullViewTopAction;*/
static NSUInteger listPullViewBottomAction;
/*static NSUInteger feedPullViewTopAction;*/
/*static NSUInteger feedPullViewBottomAction;*/
/*static NSUInteger feedPullViewLeftAction;*/
/*static NSUInteger feedPullViewRightAction;*/

@class BLGoogleReaderItem;

@interface BLItemViewController
- (BLGoogleReaderItem *)item;
- (void)linkAction:(id)button;
@end

@interface BLApplicationController
- (BLItemViewController *)itemViewController;
- (void)synchroniseAction:(id)button;
- (id)synchroniseButtonItem;
- (id)item;
- (id)source;
- (id)title;
- (id)tweet;
- (id)listViewController;
- (id)list;
- (void)markAllAsRead;
- (void)linkAction:(id)action;
- (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg;
@end

@interface BLWebServices
+ (id)sharedInstance;
- (void)shortenTweet:(id)tweet;
@end

@interface UITextView(Private)
- (void)setSelectionToStart;
@end

@interface UIWebView(iOS4Private)
- (UIScrollView *)_scrollView;
@end

static void hidePullView()
{
    Log(@"----- hidePullView");
/*    if ([rootPullViewTop respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [rootPullViewTop hideAllAroundPullViewIfNeed:rootPullViewTopIsEnabled ? NO : YES];*/
/*    if ([listPullViewTop respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [listPullViewTop hideAllAroundPullViewIfNeed:listPullViewTopIsEnabled ? NO : YES];*/
    if ([listPullViewBottom respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [listPullViewBottom hideAllAroundPullViewIfNeed:listPullViewBottomIsEnabled ? NO : YES];
/*    if ([feedPullViewTop respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [feedPullViewTop hideAllAroundPullViewIfNeed:feedPullViewTopIsEnabled ? NO : YES];*/
/*    if ([feedPullViewBottom respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [feedPullViewBottom hideAllAroundPullViewIfNeed:feedPullViewBottomIsEnabled ? NO : YES];*/
/*    if ([feedPullViewLeft respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [feedPullViewLeft hideAllAroundPullViewIfNeed:feedPullViewLeftIsEnabled ? NO : YES];*/
/*    if ([feedPullViewRight respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [feedPullViewRight hideAllAroundPullViewIfNeed:feedPullViewRightIsEnabled ? NO : YES];*/
}

static void updateThreadhold()
{
    Log(@"----- updateThreadhold");
/*    if ([rootPullViewTop isMemberOfClass:[AllAroundPullView class]]) rootPullViewTop.threshold = rootPullViewTopThreshold;*/
/*    if ([listPullViewTop isMemberOfClass:[AllAroundPullView class]]) listPullViewTop.threshold = listPullViewTopThreshold;*/
    if ([listPullViewBottom isMemberOfClass:[AllAroundPullView class]]) listPullViewBottom.threshold = listPullViewBottomThreshold;
/*    if ([feedPullViewTop isMemberOfClass:[AllAroundPullView class]]) feedPullViewTop.threshold = feedPullViewTopThreshold;*/
/*    if ([feedPullViewBottom isMemberOfClass:[AllAroundPullView class]]) feedPullViewBottom.threshold = feedPullViewBottomThreshold;*/
/*    if ([feedPullViewLeft isMemberOfClass:[AllAroundPullView class]]) feedPullViewLeft.threshold = feedPullViewLeftThreshold;*/
/*    if ([feedPullViewRight isMemberOfClass:[AllAroundPullView class]]) feedPullViewRight.threshold = feedPullViewRightThreshold;*/
}

static void DoPullToAction (NSUInteger actionNumber)
{
    Log(@"----- DoPullToAction");
    switch (actionNumber) {
        case 0:
            { // sync
                BLApplicationController *BLApp = (BLApplicationController *)[[UIApplication sharedApplication] delegate];
                [BLApp synchroniseAction:[BLApp synchroniseButtonItem]];
                /*      [[%c(BLGoogleReader) sharedInstance] synchronise:YES];*/
            }
            break;

        case 1:
            // markAllAsRead then pop
            [[[(BLApplicationController *)[[UIApplication sharedApplication] delegate] listViewController] list] markAllAsRead];

        case 2:
            // pop
            [[[(BLApplicationController *)[[UIApplication sharedApplication] delegate] listViewController] navigationController] popViewControllerAnimated:YES];
            break;

        case 3:
            // pop to root
            [[[(BLApplicationController *)[[UIApplication sharedApplication] delegate] listViewController] navigationController] popToRootViewControllerAnimated:YES];
            break;

        case 4:
            // link cache
            [[(BLApplicationController *)[[UIApplication sharedApplication] delegate] itemViewController] linkAction:nil];
            break;
    }
}

@implementation AllAroundPullViewActionHandler
- (void)pullViewShouldRefresh:(AllAroundPullView *)view
{
    Log(@"----- pullViewActionHandler");
    NSUInteger actionNumber;
    switch (view.tag) {
/*        case 1111:*/
/*            actionNumber = 0;*/
/*            break;*/
/*        case 2222:*/
/*            actionNumber = listPullViewTopAction;*/
/*            break;*/
        case 3333:
            actionNumber = listPullViewBottomAction;
            break;
/*        case 4444:*/
/*            actionNumber = feedPullViewLeftAction;*/
/*            break;*/
/*        case 5555:*/
/*            actionNumber = feedPullViewRightAction;*/
/*            break;*/
/*        case 6666:*/
/*            actionNumber = feedPullViewTopAction;*/
/*            break;*/
/*        case 7777:*/
/*            actionNumber = feedPullViewBottomAction;*/
/*            break;*/
        default:
            actionNumber = 0;
            break;
    };

    DoPullToAction(actionNumber);
    [view performSelector:@selector(finishedLoading) withObject:nil afterDelay:0.0f];
}
@end

// TweetFormatter
%hook UIActivityViewController
- (id)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities
{
    Log(@"----- initWithActivityItems");
    if (!tweetFormatterIsEnabled)
        return %orig;

    BLGoogleReaderItem *item = nil;
    NSString *string = nil;
    if ([activityItems count] == 1) {
        // 1 is only BLGoogleReaderItem
        for (id i in activityItems)
            if ([i isMemberOfClass:%c(BLGoogleReaderItem)] || [i isMemberOfClass:%c(BLGoogleReaderProvisionalNote)])
                item = i;

        if ([item isMemberOfClass:%c(BLGoogleReaderItem)])
            string = [NSString stringWithFormat:@"\"%@ - %@", [item source], [item title]];
        else
            string = [item title];
    } else {
        // 2 is NSString and BLGoogleReaderItem ("Send" menu action)
        NSString *selectedText = nil;
        for (id i in activityItems) {
            if ([i isMemberOfClass:%c(BLGoogleReaderItem)] || [i isMemberOfClass:%c(BLGoogleReaderProvisionalNote)])
                item = i;
            if ([i isKindOfClass:[NSString class]])
                selectedText = i;
        }
        if ([item isMemberOfClass:%c(BLGoogleReaderItem)])
            string = [NSString stringWithFormat:@"%@ \"%@ - %@", selectedText, [item source], [item title]];
        else
            string = [NSString stringWithFormat:@"%@ \"%@", selectedText, [item title]];
    }
    Log(@"string = %@", string);
    Log(@"item = %@", item);
    if (!item) {
        return %orig;
    }
    NSArray *array = @[string, item];
    return %orig(array, applicationActivities);
}
%end

// for iOS 4 and 5.
%hook BLTweet
- (BLTweet *)initWithURL:(NSURL *)url text:(NSString *)selectedText
{
    if (tweetFormatterIsEnabled) {
        BLGoogleReaderItem *item = [[((BLApplicationController *)[[UIApplication sharedApplication] delegate]) itemViewController] item];
        NSString *string = [NSString stringWithFormat:@"%@ \"%@ - %@", selectedText, [item source], [item title]];
        return %orig(url, string);
    } else {
        return %orig;
    }
}
%end

// for iOS 4 and 5.
// Forced url shorten and set caret
%hook BLTweetViewController
- (void)fixSelectedRange
{
    %orig;
    if (tweetFormatterIsEnabled) {
        BLTweet *tweet = [self tweet];
        [[%c(BLWebServices) sharedInstance] shortenTweet:tweet];
        UITextView *tv = MSHookIvar<UITextView *>(self, "_textView");
        [tv setSelectionToStart];
        //[tv insertText:@" "];
        //[tv setSelectionToStart];
    }
}
%end

// Notification
%hook BLApplicationController
- (void)googleReader:(id)reader didCacheItem:(id)item number:(int)number ofTotal:(int)total
{
    if (number == total) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        [notification setTimeZone:[NSTimeZone localTimeZone]];
        NSDate *date = [NSDate date];
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
    %orig;
}
%end

/*%hook BLRootViewController*/
/*- (void)viewDidLoad*/
/*{*/
/*    Log(@"----- rootview viewDidLoad");*/
/*    %orig;*/
/*    UITableView *tableView = [self tableView];*/

/*    // Root Top Sync*/
/*    rootPullViewTop = [[AllAroundPullView alloc] initWithScrollView:tableView position:AllAroundPullViewPositionTop];*/
/*    rootPullViewTop.delegate = pullViewActionHandler;*/
/*    rootPullViewTop.tag = 1111;*/
/*    [tableView addSubview:rootPullViewTop];*/

/*    hidePullView();*/
/*    updateThreadhold();*/
/*}*/

/*- (void)didReceiveMemoryWarning*/
/*{*/
/*    %orig;*/
/*    if (rootPullViewTop) {*/
/*        [rootPullViewTop removeFromSupoerview];*/
/*        [rootPullViewTop release];*/
/*        rootPullViewTop = nil;*/
/*    }*/
/*}*/
/*%end*/

%hook BLListViewController
- (void)viewDidLoad
{
    Log(@"----- listview viewDidLoad");
    %orig;
    UITableView *tableView = [self tableView];

/*    // FeedList Top*/
/*    listPullViewTop = [[AllAroundPullView alloc] initWithScrollView:tableView position:AllAroundPullViewPositionTop];*/
/*    listPullViewTop.delegate = pullViewActionHandler;*/
/*    listPullViewTop.tag = 2222;*/
/*    [tableView addSubview:listPullViewTop];*/

    // FeedList Bottom
    listPullViewBottom = [[AllAroundPullView alloc] initWithScrollView:tableView position:AllAroundPullViewPositionBottom];
    listPullViewBottom.delegate = pullViewActionHandler;
    listPullViewBottom.tag = 3333;
    [tableView addSubview:listPullViewBottom];

    hidePullView();
    updateThreadhold();
}

- (void)didReceiveMemoryWarning
{
    Log(@"----- listview viewDidUnLoad");
    %orig;
/*    if (listPullViewTop) {*/
/*        [listPullViewTop removeFromSuperview];*/
/*        [listPullViewTop release];*/
/*        listPullViewTop = nil;*/
/*    }*/
    if (listPullViewBottom) {
        [listPullViewBottom removeFromSuperview];
        [listPullViewBottom release];
        listPullViewBottom = nil;
    }
}
%end

/*%hook BLWebScrollView*/
/*- (id)initWithFrame:(CGRect)frame*/
/*{*/
/*    Log(@"----- webscrollview for left/right initWithFrame");*/
/*    UIScrollView *sv = %orig;*/

/*    if ([feedPullViewLeft retainCount] == 1) {*/
/*        Log(@"----- purging left view");*/
/*        [feedPullViewLeft release];*/
/*        feedPullViewLeft = nil;*/
/*    }*/
/*    if ([feedPullViewRight retainCount] == 1) {*/
/*        Log(@"----- purging right view");*/
/*        [feedPullViewRight release];*/
/*        feedPullViewRight = nil;*/
/*    }*/

/*    // WebView Left*/
/*    feedPullViewLeft = [[AllAroundPullView alloc] initWithScrollView:sv position:AllAroundPullViewPositionLeft];*/
/*    feedPullViewLeft.delegate = pullViewActionHandler;*/
/*    feedPullViewLeft.tag = 4444;*/
/*    [sv addSubview:feedPullViewLeft];*/

/*    // WebView Right*/
/*    feedPullViewRight = [[AllAroundPullView alloc] initWithScrollView:sv position:AllAroundPullViewPositionRight];*/
/*    feedPullViewRight.delegate = pullViewActionHandler;*/
/*    feedPullViewRight.tag = 5555;*/
/*    [sv addSubview:feedPullViewRight];*/

/*    hidePullView();*/
/*    updateThreadhold();*/

/*    return sv;*/
/*}*/
/*%end*/

/*%hook BLItemViewController*/
/*- (void)layoutWebViews*/
/*{*/
/*    Log(@"----- itemViewController top/bottom view");*/
/*    %orig;*/
/*    // BLItemWebView.*/
/*    UIWebView *vweb = MSHookIvar<UIWebView *>(self, "_visibleWebView");*/
/*    UIScrollView *sv = nil;*/
/*    if ([vweb respondsToSelector:@selector(_scrollView)])*/
/*        sv = [vweb _scrollView];*/

/*    Log(@"vweb = %@, sv = %@", vweb, sv);*/
/*    // WebView Top*/
/*    BOOL vwebHasAllAroundPullViewPositionTop = NO;*/
/*    for (AllAroundPullView *v in sv.subviews)*/
/*        if ([v isMemberOfClass:[AllAroundPullView class]])*/
/*            if (v.position == AllAroundPullViewPositionTop)*/
/*                vwebHasAllAroundPullViewPositionTop = YES;*/

/*    if (!vwebHasAllAroundPullViewPositionTop) {*/
/*        Log(@"----- top addSubview");*/
/*        feedPullViewTop = [[AllAroundPullView alloc] initWithScrollView:sv position:AllAroundPullViewPositionTop];*/
/*        feedPullViewTop.delegate = pullViewActionHandler;*/
/*        feedPullViewTop.tag = 6666;*/
/*        [sv addSubview:feedPullViewTop];*/
/*        [feedPullViewTop release];*/
/*    }*/

/*    // WebView Bottom*/
/*    BOOL vwebHasAllAroundPullViewPositionBottom = NO;*/
/*    for (AllAroundPullView *v in sv.subviews)*/
/*        if ([v isMemberOfClass:[AllAroundPullView class]])*/
/*            if (v.position == AllAroundPullViewPositionBottom)*/
/*                vwebHasAllAroundPullViewPositionBottom = YES;*/

/*    if (!vwebHasAllAroundPullViewPositionBottom) {*/
/*        Log(@"----- bottom addSubview");*/
/*        feedPullViewBottom = [[AllAroundPullView alloc] initWithScrollView:sv position:AllAroundPullViewPositionBottom];*/
/*        feedPullViewBottom.delegate = pullViewActionHandler;*/
/*        feedPullViewBottom.tag = 7777;*/
/*        [sv addSubview:feedPullViewBottom];*/
/*        [feedPullViewBottom release];*/
/*    }*/

/*    hidePullView();*/
/*    updateThreadhold();*/
/*    Log(@"----- itemViewController end");*/
/*}*/
/*%end*/

static void LoadSettings()
{   
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id existTweetFormatterIsEnabled = [dict objectForKey:@"TweetFormatterIsEnabled"];
    tweetFormatterIsEnabled = existTweetFormatterIsEnabled ? [existTweetFormatterIsEnabled boolValue] : YES;
/*    id existRootPullViewTopIsEnabled = [dict objectForKey:@"RootPullViewTopIsEnabled"];*/
/*    rootPullViewTopIsEnabled = existRootPullViewTopIsEnabled ? [existRootPullViewTopIsEnabled boolValue] : NO;*/
/*    id existListPullViewTopIsEnabled = [dict objectForKey:@"ListPullViewTopIsEnabled"];*/
/*    listPullViewTopIsEnabled = existListPullViewTopIsEnabled ? [existListPullViewTopIsEnabled boolValue] : NO;*/
    id existListPullViewBottomIsEnabled = [dict objectForKey:@"ListPullViewBottomIsEnabled"];
    listPullViewBottomIsEnabled = existListPullViewBottomIsEnabled ? [existListPullViewBottomIsEnabled boolValue] : YES;
/*    id existFeedPullViewTopIsEnabled = [dict objectForKey:@"FeedPullViewTopIsEnabled"];*/
/*    feedPullViewTopIsEnabled = existFeedPullViewTopIsEnabled ? [existFeedPullViewTopIsEnabled boolValue] : YES;*/
/*    id existFeedPullViewBottomIsEnabled = [dict objectForKey:@"FeedPullViewBottomIsEnabled"];*/
/*    feedPullViewBottomIsEnabled = existFeedPullViewBottomIsEnabled ? [existFeedPullViewBottomIsEnabled boolValue] : YES;*/
/*    id existFeedPullViewLeftIsEnabled = [dict objectForKey:@"FeedPullViewLeftIsEnabled"];*/
/*    feedPullViewLeftIsEnabled = existFeedPullViewLeftIsEnabled ? [existFeedPullViewLeftIsEnabled boolValue] : YES;*/
/*    id existFeedPullViewRightIsEnabled = [dict objectForKey:@"FeedPullViewRightIsEnabled"];*/
/*    feedPullViewRightIsEnabled = existFeedPullViewRightIsEnabled ? [existFeedPullViewRightIsEnabled boolValue] : YES;*/

/*    id existRootPullViewTopThreshold = [dict objectForKey:@"RootPullViewTopThreshold"];*/
/*    rootPullViewTopThreshold = existRootPullViewTopThreshold ? [existRootPullViewTopThreshold floatValue] : 60.0f;*/
/*    id existListPullViewTopThreshold = [dict objectForKey:@"ListPullViewTopThreshold"];*/
/*    listPullViewTopThreshold = existListPullViewTopThreshold ? [existListPullViewTopThreshold floatValue] : 60.0f;*/
    id existListPullViewBottomThreshold = [dict objectForKey:@"ListPullViewBottomThreshold"];
    listPullViewBottomThreshold = existListPullViewBottomThreshold ? [existListPullViewBottomThreshold floatValue] : 100.0f;
/*    id existFeedPullViewTopThreshold = [dict objectForKey:@"FeedPullViewTopThreshold"];*/
/*    feedPullViewTopThreshold = existFeedPullViewTopThreshold ? [existFeedPullViewTopThreshold floatValue] : 60.0f;*/
/*    id existFeedPullViewBottomThreshold = [dict objectForKey:@"FeedPullViewBottomThreshold"];*/
/*    feedPullViewBottomThreshold = existFeedPullViewBottomThreshold ? [existFeedPullViewBottomThreshold floatValue] : 60.0f;*/
/*    id existFeedPullViewLeftThreshold = [dict objectForKey:@"FeedPullViewLeftThreshold"];*/
/*    feedPullViewLeftThreshold = existFeedPullViewLeftThreshold ? [existFeedPullViewLeftThreshold floatValue] : 60.0f;*/
/*    id existFeedPullViewRightThreshold = [dict objectForKey:@"FeedPullViewRightThreshold"];*/
/*    feedPullViewRightThreshold = existFeedPullViewRightThreshold ? [existFeedPullViewRightThreshold floatValue] : 60.0f;*/

/*    id existListPullViewTopAction = [dict objectForKey:@"ListPullViewTopAction"];*/
/*    listPullViewTopAction = existListPullViewTopAction ? [existListPullViewTopAction intValue] : 0; // sync*/
    id existListPullViewBottomAction = [dict objectForKey:@"ListPullViewBottomAction"];
    listPullViewBottomAction = existListPullViewBottomAction ? [existListPullViewBottomAction intValue] : 1; // markAllAsRead
/*    id existFeedPullViewTopAction = [dict objectForKey:@"FeedPullViewTopAction"];*/
/*    feedPullViewTopAction = existFeedPullViewTopAction ? [existFeedPullViewTopAction intValue] : 2; // pop*/
/*    id existFeedPullViewBottomAction = [dict objectForKey:@"FeedPullViewBottomAction"];*/
/*    feedPullViewBottomAction = existFeedPullViewBottomAction ? [existFeedPullViewBottomAction intValue] : 4; // link cache*/
/*    id existFeedPullViewLeftAction = [dict objectForKey:@"FeedPullViewLeftAction"];*/
/*    feedPullViewLeftAction = existFeedPullViewLeftAction ? [existFeedPullViewLeftAction intValue] : 3; // pop to root*/
/*    id existFeedPullViewRightAction = [dict objectForKey:@"FeedPullViewRightAction"];*/
/*    feedPullViewRightAction = existFeedPullViewRightAction ? [existFeedPullViewRightAction intValue] : 3; // pop to root*/

    hidePullView();
    updateThreadhold();
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LoadSettings();
}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("jp.r-plus.BylineEnhancer.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    LoadSettings();
    pullViewActionHandler = [[AllAroundPullViewActionHandler alloc] init];
    [pool release];
}
