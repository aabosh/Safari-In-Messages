TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Preferences

Preferences_FILES = SIMRootListController.m
Preferences_FRAMEWORKS = UIKit
Preferences_PRIVATE_FRAMEWORKS = Preferences
Preferences_INSTALL_PATH = /Library/PreferenceBundles
Preferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
