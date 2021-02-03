THEOS_DEVICE_IP = 192.168.1.246

FINALPACKAGE = 1

PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export TARGET = iphone:clang:13.5:13.5
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Cylinder

ifeq ($(THEOS_CURRENT_ARCH),arm64)
$(TWEAK_NAME)_LIBRARIES += lua5.4.0
Cylinder_FILES = $(wildcard tweak/*.x) $(wildcard tweak/*.m)

else
Cylinder_FILES = $(wildcard lua/*.c) $(wildcard tweak/*.x) $(wildcard tweak/*.m)
endif

tweak/lua_UIView_index.m_CFLAGS = -fno-objc-arc
tweak/icon_sort.m_CFLAGS = -fno-objc-arc
tweak/lua_UIView.m_CFLAGS = -fno-objc-arc

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += settings
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Cylinder/$(ECHO_END)
	$(ECHO_NOTHING)cp -r scripts/ $(THEOS_STAGING_DIR)/Library/Cylinder/$(ECHO_END)