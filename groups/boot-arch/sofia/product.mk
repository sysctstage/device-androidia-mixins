PRODUCT_PACKAGES += \
    setup_fs \
    setup_fs_nvm \
    libnvmmodule \
    nvm_useragent \
    nvmtest \
    bt_nvm_init.sh \
    libstlport

TARGET_BOARD_PLATFORM := {{{board_platform}}}
TARGET_PROJECT := {{{board_platform}}}

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.rc:root/init.{{{hardware}}}.rc \
    $(LOCAL_PATH)/init.recovery.rc:root/init.recovery.{{{hardware}}}.rc \
    $(LOCAL_PATH)/ueventd.rc:root/ueventd.{{{hardware}}}.rc \
    $(LOCAL_PATH)/fstab:root/fstab.{{{hardware}}} \

{{#wv_level3}}
{{#enc1080p}}
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/../media_codecs_WV_L3.xml:system/etc/media_codecs.xml
{{/enc1080p}}
{{^enc1080p}}
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/../media_codecs_WV_L3_enc720p.xml:system/etc/media_codecs.xml
{{/enc1080p}}
    BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 3
{{/wv_level3}}

{{^wv_level3}}
{{#enc1080p}}
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/../media_codecs.xml:system/etc/media_codecs.xml
{{/enc1080p}}
{{^enc1080p}}
    PRODUCT_COPY_FILES += $(LOCAL_PATH)/../media_codecs_enc720p.xml:system/etc/media_codecs.xml
{{/enc1080p}}
    BOARD_WIDEVINE_OEMCRYPTO_LEVEL := 1
{{/wv_level3}}

PRODUCT_COPY_FILES += $(LOCAL_PATH)/../media_codecs_performance.xml:system/etc/media_codecs_performance.xml

{{#lte_gvb_feature}}
#if lte gvb feature enabled, export a flag
#so as that bootloader and prg generation can be controlled
export GVB_FEATURE_ENABLE := true
{{/lte_gvb_feature}}

#Add persistent property to enable factory protection
PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/by-name/ImcPartID126

{{#lte_interactive_fastboot_ui_feature}}
# if interactive fastboot ui feature enabled
# enable interactive UI flag
INTERACTIVE_FASTBOOT_UI := true
{{/lte_interactive_fastboot_ui_feature}}
#Build a verified /system partition
PRODUCT_SYSTEM_VERITY_PARTITION := /dev/block/platform/soc0/e0000000.noc/by-name/ImcPartID068
#Declare feature android.software.verified_boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:vendor/etc/permissions/android.software.verified_boot.xml

{{#dm_verity}}
#Include verity.mk for GVB and DM_VERITY feature
$(call inherit-product,build/target/product/verity.mk)
{{/dm_verity}}

{{#verity_warning}}
PRODUCT_PACKAGES += \
    slideshow \
    verity_warning_images
{{/verity_warning}}
