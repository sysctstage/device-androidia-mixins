BOARD_KERNEL_CMDLINE += thermal.off=1

BOARD_SEPOLICY_M4DEFS += module_thermal=true
BOARD_SEPOLICY_DIRS += device/intel/sepolicy/thermal
BOARD_SEPOLICY_DIRS += device/intel/sepolicy/thermal/itux
