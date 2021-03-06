#
# Telemetry
PRODUCT_PACKAGES += \
    telemetryd tm_record tm_fprobe tm_pstore_probe tm_dmesg_probe \
    tm_logcount_probe tm_logprobe tm_storage_setup \
    DataReport \
    DataReportSettings 


DEVICE_PACKAGE_OVERLAYS += device/intel/common/telemetry/overlay

TELEMETRY_SETNAME := all1
TELEMETRY_DOMAIN := tmfe.intel.com
TELEMETRY_KEYPATH := device/intel/common/telemetry/keys

# Telemetry keys need to be installed on device. The zipped archive that
# contains the keys can be found in vendor/intel/telemetry-client/keys. The
# ideal way would be to install the keys from those archives directly.
# Until the best way to do so (see IRDA-298) can be determined we extract
# the keys into device/intel/common/telemetry/keys and install them from here
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/all/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/all/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/all1/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/all1/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/devel/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/devel/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/qa01/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/qa01/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/qa02/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/qa02/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/qa03/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/qa03/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/qa04/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/qa04/$(notdir $(file)))
TELEMETRY_KEY_FILES := $(wildcard $(TELEMETRY_KEYPATH)/qa05/rsa*aa.x509.pem)
PRODUCT_COPY_FILES += $(foreach file,$(TELEMETRY_KEY_FILES),\
                $(file):system/etc/tm/keys/qa05/$(notdir $(file)))


ifeq ($(TARGET_BUILD_VARIANT),user)
    TELEMETRY_NONCOMPLIANT := 0
else
    TELEMETRY_NONCOMPLIANT := 2
endif

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
        persist.intel.tm.setname=$(TELEMETRY_SETNAME) \
        persist.intel.tm.domain=$(TELEMETRY_DOMAIN) \
        persist.intel.tm.server_name=$(TELEMETRY_SETNAME).$(TELEMETRY_DOMAIN) \
        persist.intel.tm.server_port=25001 \
        persist.intel.tm.state=not_set \
        persist.intel.tm.noncompliant=$(TELEMETRY_NONCOMPLIANT) \
        persist.intel.tm.kern_dbg_raw=0 \
        persist.intel.tm.tomb_dbg_raw=0 \
        persist.intel.tm.fprobe_rmfile=0 \
        persist.intel.tm.logprobe=0


#install configuration file of events that should always be sent if
#logprobe enabled in non-compliant mode
PRODUCT_COPY_FILES += device/intel/common/telemetry/logevent/logprobe-logevent.conf:system/etc/tm/logprobe-logevent.conf

#install configuration file describing compliant events that can always be sent
PRODUCT_COPY_FILES += device/intel/common/telemetry/logevent/event-log-tags:system/etc/tm/logevent/event-log-tags
