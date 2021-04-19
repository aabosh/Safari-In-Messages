#include "SIMRootListController.h"
void BKSTerminateApplicationForReasonAndReportWithDescription(NSString* bundleId, int reasonId, bool report, NSString *description);

@implementation SIMRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	BKSTerminateApplicationForReasonAndReportWithDescription(@"com.apple.MobileSMS", 5, false, @"Killing Messages to refresh Safari In Messages preferences.");
}

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed: 0.23 green: 0.70 blue: 0.72 alpha: 1.00];
		appearanceSettings.largeTitleStyle = HBAppearanceSettingsLargeTitleStyleNever;
		self.hb_appearanceSettings = appearanceSettings;
	}

	return self;
}

@end
