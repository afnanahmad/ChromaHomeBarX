THEOS_DEVICE_IP = 192.168.0.100
THEOS_PACKAGE_DIR_NAME = debs

TARGET = iphone:clang
ARCHS = armv7 armv7s arm64 arm64e

# TARGET = simulator:clang::11.0
# ARCHS = x86_64 i386
# i386 slice is required for 32-bit iOS Simulator (iPhone 5, etc.)
DEBUG = 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ChromaHomeBarX
ChromaHomeBarX_FILES = ChromaHomeBarX.xm
ChromaHomeBarX_FRAMEWORKS = UIKit QuartzCore
ChromaHomeBarX_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -std=c++11
ChromaHomeBarX_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: clean all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
endif

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += chromahomebarx
include $(THEOS_MAKE_PATH)/aggregate.mk
