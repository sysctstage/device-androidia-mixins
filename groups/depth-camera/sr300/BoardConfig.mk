ifneq ($(USE_CAMERA_HAL_3),true)
$(error Camera V3 HAL must be enabled, check camera mixin option!)
endif

USE_CAMERA_REALSENSE := true

# Enable SR300 camera HAL support. This is built as the master/main camera HAL
# and will relay calls to camera3hal for other cameras in the system.
USE_CAMERA_SR300 := true

# Enable SR300 additional tools
USE_CAMERA_SR300_OEM_TOOLS := true

# Build camera3hal as system lib instead as camera HAL module.
USE_CAMERA_ATOMISP_EMBED := true

# Use the SR300 libusb specific SELinux rules
BOARD_SEPOLICY_DIRS +=  \
	device/intel/sepolicy/depth-camera/common \
	device/intel/sepolicy/depth-camera/sr300
