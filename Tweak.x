#import <SafariServices/SafariServices.h>
#import <Cephei/HBPreferences.h>

// MARK: Preferences

static NSString* const kPrefsBundleId = @"com.andrewabosh.safari-in-messages-prefs";
static NSString* const kPrefsEnabledKey = @"IsEnabled";
static NSString* const kPrefsOpenUniversalLinksKey = @"OpenUniversalLinks";
HBPreferences *preferences;
BOOL isEnabled;
BOOL openUniversalLinks;

%ctor {
	preferences = [[HBPreferences alloc] initWithIdentifier:kPrefsBundleId];
	[preferences registerDefaults:@{
		kPrefsEnabledKey: @YES,
		kPrefsOpenUniversalLinksKey: @NO,
	}];
	[preferences registerBool:&isEnabled default:YES forKey:kPrefsEnabledKey];
	[preferences registerBool:&openUniversalLinks default:NO forKey:kPrefsOpenUniversalLinksKey];
}


// MARK: The Magic

@interface SMSApplication: UIApplication
- (void)presentUrlInSafariVC:(NSURL*)url;
- (void)openLink:(NSURL*)url;
@end

%hook SMSApplication

%new
- (void)presentUrlInSafariVC:(NSURL*)url {
	UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
	while (topController.presentedViewController) {
		topController = topController.presentedViewController;
	}
	SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
	[topController presentViewController:safariViewController animated:YES completion:nil];
}

%new
- (void)openLink:(NSURL*)url {
	if (openUniversalLinks) {
		[self presentUrlInSafariVC:url];
		return;
	}
	// We only want to open URLs that aren't universal links in the SFSafariViewController
	[[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @YES} completionHandler:^(BOOL success) {
		if (!success) {
			[self presentUrlInSafariVC:url];
		}
	}];
}

- (BOOL)openURL:(NSURL*)url {
	if (isEnabled && ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"])) {
		[self openLink:url];
		return YES;
	} else {
		return %orig;
	}
}

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion {
	BOOL universalLinksOnly = [[options objectForKey:UIApplicationOpenURLOptionUniversalLinksOnly] boolValue];
	if (isEnabled && ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) &&  !universalLinksOnly) {
		[self openLink:url];
	} else {
		%orig;
	}
}

%end


@interface CKHyperlinkBalloonView: UIView
- (UIViewController *)parentViewController;
@end

%hook CKHyperlinkBalloonView

%new
- (UIViewController *)parentViewController {
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    return (UIViewController *)responder;
}

- (BOOL)textView:(id)arg1 shouldInteractWithURL:(NSURL*)url inRange:(NSRange)arg3 {
	SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
	[[self parentViewController] presentViewController:safariViewController animated:YES completion:nil];
	return NO;
}

- (void)interactionStartedFromPreviewItemControllerInTextView:(id)arg1 {}

- (void)interactionStartedLongPressInTextView:(id)arg1 {}

%end