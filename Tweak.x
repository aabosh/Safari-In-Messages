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