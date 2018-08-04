include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ChromaHomeBarX
ChromaHomeBarX_FILES = ACXRootListController.m
ChromaHomeBarX_INSTALL_PATH = /Library/PreferenceBundles
ChromaHomeBarX_FRAMEWORKS = UIKit
ChromaHomeBarX_PRIVATE_FRAMEWORKS = Preferences
ChromaHomeBarX_LIBRARIES = colorpicker 

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ChromaHomeBarX.plist$(ECHO_END)
