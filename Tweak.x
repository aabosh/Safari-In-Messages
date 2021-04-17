#import <SafariServices/SafariServices.h>

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
	if ([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) {
		[self openNonUniversalLink:url];
		return YES;
	} else {
		return %orig;
	}
}

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion {
	BOOL universalLinksOnly = [[options objectForKey:UIApplicationOpenURLOptionUniversalLinksOnly] boolValue];
	if (([url.scheme isEqual:@"http"] || [url.scheme isEqual:@"https"]) &&  !universalLinksOnly) {
		[self openNonUniversalLink:url];
	} else {
		%orig;
	}
}

%end