# SR300 HAL modules.
PRODUCT_PACKAGES += \
	camera.$(TARGET_BOARD_PLATFORM) \
	camera.plugin.sr300.$(TARGET_BOARD_PLATFORM)

# SR300 camera2 API extensions.
PRODUCT_PACKAGES += \
	com.intel.camera2.extensions.depthcamera \
	com.intel.camera2.extensions.depthcamera.xml \
	libinteldepthcamera_jni

# Build static library for app development in userdebug
# and eng builds
ifneq ($(filter userdebug eng, $(TARGET_BUILD_VARIANT)),)
PRODUCT_PACKAGES += \
        com.intel.camera2.extensions.depthcamera.static
endif

# Add mediaserver to USB group, as this is required for mediaserver
# to access the USB device via libusb.
PRODUCT_PACKAGES += add-sr300-to-usb-group

# SR300 FW Update Tool.
PRODUCT_PACKAGES += \
	FWUpdateSR300

# Add recalibration tools and scripts
PRODUCT_PACKAGES += \
	SR300RecalibCaptureData \
	SR300RecalibWriteData \
	capture_recalib_data.sh \
	write_recalib_data.sh \

# Apps can now be compiled against the add-on without having to
# manually copy the com.intel.camera2.extensions.depthcamera.jar to the
# app 'libs' folder, ensuring only the built-in jar file
# on the device is used.
#PRODUCT_BOOT_JARS += com.intel.camera2.extensions.depthcamera

# Product configuration files.
PRODUCT_COPY_FILES += \
	device/intel/common/camera/sr300/camera_realsense.xml:system/etc/camera_realsense.xml \
	device/intel/common/camera/sr300/com.intel.camera.depth.xml:vendor/etc/permissions/com.intel.camera.depth.xml

$(eval PRODUCT_COPY_FILES += $(LOCAL_PATH)/camera_realsense.xml:system/etc/camera_realsense.$(TARGET_BOARD_PLATFORM).xml)

