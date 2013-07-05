#import "AllAroundPullView/AllAroundPullView.h"
//#define DEBUG 1
#import "debug.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/jp.r-plus.bylineenhancer.plist"

@interface AllAroundPullViewActionHandler : NSObject <AllAroundPullViewDelegate>
@end

static AllAroundPullViewActionHandler *pullViewActionHandler;

static AllAroundPullView *listPullViewBottom = nil;

static BOOL tweetFormatterIsEnabled;
static BOOL listPullViewBottomIsEnabled;
static CGFloat listPullViewBottomThreshold;
static NSUInteger listPullViewBottomAction;

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
    if ([listPullViewBottom respondsToSelector:@selector(hideAllAroundPullViewIfNeed:)]) [listPullViewBottom hideAllAroundPullViewIfNeed:listPullViewBottomIsEnabled ? NO : YES];
}

static void updateThreadhold()
{
    Log(@"----- updateThreadhold");
    if ([listPullViewBottom isMemberOfClass:[AllAroundPullView class]]) listPullViewBottom.threshold = listPullViewBottomThreshold;
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
        case 3333:
            actionNumber = listPullViewBottomAction;
            break;
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

%hook BLListViewController
- (void)viewDidLoad
{
    Log(@"----- listview viewDidLoad");
    %orig;
    UITableView *tableView = [self tableView];

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
    if (listPullViewBottom) {
        [listPullViewBottom removeFromSuperview];
        [listPullViewBottom release];
        listPullViewBottom = nil;
    }
}
%end

static void LoadSettings()
{   
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id existTweetFormatterIsEnabled = [dict objectForKey:@"TweetFormatterIsEnabled"];
    tweetFormatterIsEnabled = existTweetFormatterIsEnabled ? [existTweetFormatterIsEnabled boolValue] : YES;
    id existListPullViewBottomIsEnabled = [dict objectForKey:@"ListPullViewBottomIsEnabled"];
    listPullViewBottomIsEnabled = existListPullViewBottomIsEnabled ? [existListPullViewBottomIsEnabled boolValue] : YES;
    id existListPullViewBottomThreshold = [dict objectForKey:@"ListPullViewBottomThreshold"];
    listPullViewBottomThreshold = existListPullViewBottomThreshold ? [existListPullViewBottomThreshold floatValue] : 100.0f;
    id existListPullViewBottomAction = [dict objectForKey:@"ListPullViewBottomAction"];
    listPullViewBottomAction = existListPullViewBottomAction ? [existListPullViewBottomAction intValue] : 1; // markAllAsRead

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
