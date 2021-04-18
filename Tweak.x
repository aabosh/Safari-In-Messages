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
- (void)openNonUniversalLink:(NSURL*)url;
@end

%hook SMSApplication

%new
- (void)openNonUniversalLink:(NSURL*)url {
	// We only want to open URLs that aren't universal links in the SFSafariViewController
	[[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @YES} completionHandler:^(BOOL success) {
		if (!success) {
			SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
			[[self keyWindow].rootViewController presentViewController:safariViewController animated:YES completion:nil];
		}
	}];
}

- (BOOL)openURL:(NSURL*)url {
	if (isEnabled && ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"])) {
		[self openNonUniversalLink:url];
		return YES;
	} else {
		return %orig;
	}
}

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion {
	BOOL universalLinksOnly = [[options objectForKey:UIApplicationOpenURLOptionUniversalLinksOnly] boolValue];
	if (isEnabled && ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) &&  !universalLinksOnly) {
		[self openNonUniversalLink:url];
	} else {
		%orig;
	}
}

%end