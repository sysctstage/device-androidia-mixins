TELEPHONY_CONFIG_DIR := device/intel/common/telephony-config
TELEPHONY_CATALOG_DIR := $(TELEPHONY_CONFIG_DIR)/catalog

# Used in PRODUCT_COPY_FILES :
TELEPHONY_OUT_CATALOG_DIR := $(TARGET_COPY_OUT_VENDOR)/etc/telephony/catalog

SELECTED_CATALOG := {{{catalog}}}

TELEPHONY_FOUND_CONFIGS := $(wildcard $(TELEPHONY_CATALOG_DIR)/$(SELECTED_CATALOG)/*.xml)

PRODUCT_COPY_FILES += \
    $(foreach _conf, $(TELEPHONY_FOUND_CONFIGS), $(_conf):$(TELEPHONY_OUT_CATALOG_DIR)/$(patsubst $(TELEPHONY_CATALOG_DIR)/%,%,$(_conf)))