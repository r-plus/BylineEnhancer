export GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = BylineTweetFormatter
BylineTweetFormatter_FILES = Tweak.xm
BylineTweetFormatter_FRAMEWORKS = UIKit
#BylineTweetFormatter_LDFLAGS = -lsubjc
THEOS_INSTALL_KILL = Byline

include $(THEOS_MAKE_PATH)/tweak.mk
