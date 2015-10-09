{{^useprebuilt}}
ifeq ($(TARGET_PREBUILT_KERNEL),)

LOCAL_KERNEL_PATH := $(PRODUCT_OUT)/obj/kernel
KERNEL_BUILD_OUTPUT := ../../$(LOCAL_KERNEL_PATH)
KERNEL_INSTALL_MOD_PATH := .
LOCAL_KERNEL := $(LOCAL_KERNEL_PATH)/arch/x86/boot/{{{binary_name}}}
LOCAL_KERNEL_MODULE_TREE_PATH := $(LOCAL_KERNEL_PATH)/lib/modules

KERNEL_CCACHE := $(realpath $(CC_WRAPPER))

#remove time_macros from ccache options, it breaks signing process
KERNEL_CCSLOP := $(filter-out time_macros,$(subst $(comma), ,$(CCACHE_SLOPPINESS)))
KERNEL_CCSLOP := $(subst $(space),$(comma),$(KERNEL_CCSLOP))

{{#build_dtbs}}
BOARD_DTB := $(LOCAL_KERNEL_PATH)/{{{board_dtb}}}
{{/build_dtbs}}
LOCAL_KERNEL_SRC := {{{src_path}}}
EXTERNAL_MODULES := {{{external_modules}}} {{{debug_modules}}}
EXTMOD_SRC := ../modules
{{#use_iwlwifi}}
IWL_DEFCONFIG := {{{iwl_defconfig}}}
ifeq ($(IWL_DEFCONFIG), )
IWL_DEFCONFIG := iwlwifi-public
endif
{{/use_iwlwifi}}

KERNEL_DEFCONFIG := $(LOCAL_KERNEL_SRC)/arch/x86/configs/$(TARGET_KERNEL_ARCH)_{{{kdefconfig}}}defconfig
ifneq ($(TARGET_BUILD_VARIANT), user)
ifneq ($(wildcard $(LOCAL_KERNEL_SRC)/arch/x86/configs/$(TARGET_KERNEL_ARCH)_{{{kdefconfig}}}debug_diffconfig),)
KERNEL_DIFFCONFIG += $(LOCAL_KERNEL_SRC)/arch/x86/configs/$(TARGET_KERNEL_ARCH)_{{{kdefconfig}}}debug_diffconfig
else # wildcard debug_diffconfig
KERNEL_DEFCONFIG := $(LOCAL_KERNEL_SRC)/arch/x86/configs/$(TARGET_KERNEL_ARCH)_{{{kdefconfig}}}debug_defconfig
endif # wildcard debug_diffconfig
endif # variant not eq USER
KERNEL_CONFIG := $(LOCAL_KERNEL_PATH)/.config

KERNEL_MAKE_OPTIONS = \
    -C $(LOCAL_KERNEL_SRC) \
    O=$(KERNEL_BUILD_OUTPUT) \
    ARCH=$(TARGET_KERNEL_ARCH) \
    INSTALL_MOD_PATH=$(KERNEL_INSTALL_MOD_PATH) \
    CROSS_COMPILE="$(KERNEL_CCACHE) $(YOCTO_CROSSCOMPILE)" \
    CCACHE_SLOPPINESS=$(KERNEL_CCSLOP)

{{#use_iwlwifi}}
KERNEL_MAKE_OPTIONS_IWLWIFI = \
    -C kernel/modules/iwlwifi/{{{extmod_platform}}} \
    ARCH=$(TARGET_KERNEL_ARCH) \
    INSTALL_MOD_PATH=$(KERNEL_INSTALL_MOD_PATH) \
    KLIB_BUILD=../../../../$(LOCAL_KERNEL_PATH) \
    O=../../../../$(LOCAL_KERNEL_PATH) \
    CROSS_COMPILE="$(KERNEL_CCACHE) $(YOCTO_CROSSCOMPILE)" \
    CCACHE_SLOPPINESS=$(KERNEL_CCSLOP)
{{/use_iwlwifi}}

KERNEL_CONFIG_DEPS := $(strip $(KERNEL_DEFCONFIG) $(KERNEL_DIFFCONFIG))
KERNEL_CONFIG_MK := $(LOCAL_KERNEL_PATH)/config.mk
-include $(KERNEL_CONFIG_MK)

ifneq ($(KERNEL_CONFIG_DEPS),$(KERNEL_CONFIG_PREV_DEPS))
.PHONY: $(KERNEL_CONFIG)
endif

$(KERNEL_CONFIG): $(KERNEL_CONFIG_DEPS) | yoctotoolchain
	$(hide) mkdir -p $(@D)
	$(hide) echo "KERNEL_CONFIG_PREV_DEPS := $^" > $(KERNEL_CONFIG_MK)
	$(hide) cat $^ > $@
	@echo "Generating Kernel configuration, using $^"
	$(MAKE) $(KERNEL_MAKE_OPTIONS) oldconfig

$(PRODUCT_OUT)/kernel: $(LOCAL_KERNEL) copy_modules
	cp $(LOCAL_KERNEL) $@

{{#modules_in_bootimg}}
# kernel modules must be copied before ramdisk is generated
$(PRODUCT_OUT)/ramdisk.img: copy_modules
{{/modules_in_bootimg}}
{{^modules_in_bootimg}}
# kernel modules must be copied before systemimage is generated
$(PRODUCT_OUT)/system.img: copy_modules
{{/modules_in_bootimg}}

# Copy modules in directory pointed by $(KERNEL_MODULES_ROOT)
# First copy modules keeping directory hierarchy lib/modules/`uname-r`for libkmod
# Second, create flat hierarchy for insmod linking to previous hierarchy
copy_modules: $(LOCAL_KERNEL) build_external_modules
	@echo Copy modules from $(LOCAL_KERNEL_PATH)/lib/modules into $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) rm -rf $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) mkdir -p $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)
	$(hide) cd $(LOCAL_KERNEL_PATH)/lib/modules/ && for f in `find . -name '*.ko'`; do \
		mkdir -p $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$$(dirname $$f) ; \
		cp $$f $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$$(dirname $$f) || exit 1; \
		done
	$(hide) cd $(LOCAL_KERNEL_PATH)/lib/modules/ && for f in `find . -name 'modules.*'`; do \
		mkdir -p $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$$(dirname $$f) ; \
		cp $$f $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT)/$$(dirname $$f) || exit 1; \
		done
	$(hide) cd $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT) && for f in `find . -name '*.ko'` ; do cp $$f . ; done
	$(hide) cd $(ANDROID_PRODUCT_OUT)/$(KERNEL_MODULES_ROOT) && for f in `find . -name 'modules.*'` ; do cp $$f . ; done

$(LOCAL_KERNEL): yoctotoolchain $(MINIGZIP) $(KERNEL_CONFIG) $(BOARD_DTB)
	$(MAKE) $(KERNEL_MAKE_OPTIONS)
	$(MAKE) $(KERNEL_MAKE_OPTIONS) modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) INSTALL_MOD_STRIP=1 modules_install
{{#build_dtbs}}
	cp $(LOCAL_KERNEL_PATH)/scripts/dtc/dtc $(LOCAL_KERNEL_PATH)
{{/build_dtbs}}

build_external_modules: $(LOCAL_KERNEL)
	for dir in $(EXTERNAL_MODULES) ; do \
		mkdir -p $(LOCAL_KERNEL_PATH)/../modules/$$dir ;\
		$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/$$dir modules || exit 1;\
		$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/$$dir INSTALL_MOD_STRIP=1 modules_install || exit 1;\
	done

{{#use_iwlwifi}}
copy_modules: build_iwlwifi
build_iwlwifi: build_external_modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS_IWLWIFI) clean
	$(MAKE) $(KERNEL_MAKE_OPTIONS_IWLWIFI) defconfig-$(IWL_DEFCONFIG)
	$(MAKE) $(KERNEL_MAKE_OPTIONS_IWLWIFI) modules
	-$(MAKE) $(KERNEL_MAKE_OPTIONS_IWLWIFI) INSTALL_MOD_STRIP=1 modules_install
{{/use_iwlwifi}}

{{#use_bcmdhd}}
copy_modules: build_bcmdhd
build_bcmdhd: build_external_modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} clean
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} CONFIG_BCM4356=m CONFIG_BCMDHD=m CONFIG_BCMDHD_PCIE=y CONFIG_BCMDHD_SDIO= modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} CONFIG_BCM4356=m CONFIG_BCMDHD=m CONFIG_BCMDHD_PCIE=y CONFIG_BCMDHD_SDIO= modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} INSTALL_MOD_STRIP=1 modules_install
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} clean
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} CONFIG_BCM43241=m CONFIG_BCMDHD=m CONFIG_BCMDHD_PCIE=  CONFIG_BCMDHD_SDIO=y  modules
	$(MAKE) $(KERNEL_MAKE_OPTIONS) M=$(EXTMOD_SRC)/bcm43xx/{{{extmod_platform}}} INSTALL_MOD_STRIP=1 modules_install
{{/use_bcmdhd}}

{{#build_dtbs}}
$(BOARD_DTB): yoctotoolchain $(KERNEL_CONFIG)
	$(MAKE) $(KERNEL_MAKE_OPTIONS) dtbs
	cp $(LOCAL_KERNEL_PATH)/arch/x86/boot/dts/{{{board_dtb}}} $@
{{/build_dtbs}}

# Add a kernel target, so "make kernel" will build the kernel
.PHONY: kernel
kernel: copy_modules

endif
{{/useprebuilt}}
