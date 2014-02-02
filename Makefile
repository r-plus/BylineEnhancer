export GO_EASY_ON_ME=1
ARCHS = armv7 arm64
TARGET = iphone:clang::5.0
include theos/makefiles/common.mk

TWEAK_NAME = BylineEnhancer
BylineEnhancer_FILES = Tweak.xm AllAroundPullView/AllAroundPullView.m
BylineEnhancer_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
