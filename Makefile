include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SafariInMessages

SafariInMessages_FILES = Tweak.x
SafariInMessages_CFLAGS = -fobjc-arc
SafariInMessages_FRAMEWORKS = SafariServices UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS"