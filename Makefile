include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SafariInMessages

SafariInMessages_FILES = Tweak.x
SafariInMessages_CFLAGS = -fobjc-arc
SafariInMessages_FRAMEWORKS = SafariServices UIKit
SafariInMessages_PRIVATE_FRAMEWORKS = ChatKit
SafariInMessages_EXTRA_FRAMEWORKS = Cephei
SUBPROJECTS += prefs
export ARCHS = armv7 arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 MobileSMS Preferences"