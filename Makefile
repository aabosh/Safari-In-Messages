THEOS_DEVICE_IP = 10.0.1.48
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SafariInMessages

SafariInMessages_FILES = Tweak.x
SafariInMessages_CFLAGS = -fobjc-arc
SafariInMessages_FRAMEWORKS = SafariServices UIKit
SafariInMessages_PRIVATE_FRAMEWORKS = ChatKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS"