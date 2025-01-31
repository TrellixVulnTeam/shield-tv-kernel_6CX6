#
# Copyright (c) 2010-2016, NVIDIA CORPORATION.  All rights reserved.
#
# Global build system definitions go here
#

# Inherit build shell from Android if applicable
ifdef ANDROID_BUILD_SHELL
SHELL := $(ANDROID_BUILD_SHELL)
endif

ifndef NV_TARGET_BOOTLOADER_PINMUX
NV_TARGET_BOOTLOADER_PINMUX := kernel
endif

ifndef TEGRA_TOP
TEGRA_TOP := vendor/nvidia/tegra
endif

NVIDIA_BUILD_ROOT          := vendor/nvidia/build

# Bug 1498457: TARGET_OUT_HEADERS dependencies
$(TARGET_OUT_HEADERS):
	$(hide) mkdir -p $@

#Bug 1266062: Temporary switch to use new ODM repo sync location path
#This needs to be removed later
ifndef NV_BUILD_WAR_1266062
NV_BUILD_WAR_1266062 := 1
endif

#Bug 1408881: Choose which location to build camera sanity test
#This needs to be removed later
ifndef NV_BUILD_WAR_1408881
NV_BUILD_WAR_1408881 := 1
endif

# Bug 1251947: Choose which location to build NVogtest
# This needs to be removed later
ifndef NV_BUILD_WAR_1251947
NV_BUILD_WAR_1251947 := apps-graphics
endif

ifndef NV_GPUDRV_SOURCE
NV_GPUDRV_SOURCE := $(TEGRA_TOP)/gpu/drv
endif

include vendor/nvidia/build/detectversion.mk

# build modularization
include $(NVIDIA_BUILD_ROOT)/build_modularization.mk

ADDITIONAL_BUILD_PROPERTIES += ro.product.first_api_level=24

# This hook is called by build/core/base_rules.mk.
# It is documented as something the user can define in buildspec.mk, so to
# avoid incorrect interaction we only define it here in case the user didn't.
# Consequently all the code we place under this hook must be optional (ie. error
# checks).
ifdef base-rules-hook
  $(warning User-defined base-rules-hook found. Will skip NV implementation)
else
  define base-rules-hook
    $(nvidia-build-modularization-base-rules-hook)
  endef
endif

# links to build system files

NVIDIA_CUDA_STATIC_LIBRARY := $(NVIDIA_BUILD_ROOT)/cuda_static_library.mk
NVIDIA_BASE                := $(NVIDIA_BUILD_ROOT)/base.mk
NVIDIA_POST                := $(NVIDIA_BUILD_ROOT)/post.mk
NVIDIA_POST_DUMMY          := $(NVIDIA_BUILD_ROOT)/post_dummy.mk
NVIDIA_DEBUG               := $(NVIDIA_BUILD_ROOT)/debug.mk
NVIDIA_DEFAULTS            := $(NVIDIA_BUILD_ROOT)/defaults.mk
NVIDIA_BUILD_MODULARIZATION_BASE  := $(NVIDIA_BUILD_ROOT)/build_modularization_base.mk
NVIDIA_STATIC_LIBRARY      := $(NVIDIA_BUILD_ROOT)/static_library.mk
NVIDIA_STATIC_AVP_LIBRARY  := $(NVIDIA_BUILD_ROOT)/static_avp_library.mk
NVIDIA_SHARED_LIBRARY      := $(NVIDIA_BUILD_ROOT)/shared_library.mk
NVIDIA_HAL_MODULE          := $(NVIDIA_BUILD_ROOT)/hal_module.mk
NVIDIA_EXECUTABLE          := $(NVIDIA_BUILD_ROOT)/executable.mk
NVIDIA_NVMAKE_BASE         := $(NVIDIA_BUILD_ROOT)/nvmake_base.mk
NVIDIA_NVMAKE_INTERNAL     := $(NVIDIA_BUILD_ROOT)/nvmake_internal.mk
NVIDIA_NVMAKE_CLEAR        := $(NVIDIA_BUILD_ROOT)/nvmake_clear.mk
NVIDIA_NVMAKE_EXECUTABLE   := $(NVIDIA_BUILD_ROOT)/nvmake_executable.mk
NVIDIA_NVMAKE_SHARED_LIBRARY := $(NVIDIA_BUILD_ROOT)/nvmake_shared_library.mk
NVIDIA_STATIC_AVP_EXECUTABLE := $(NVIDIA_BUILD_ROOT)/static_avp_executable.mk
NVIDIA_STATIC_EXECUTABLE := $(NVIDIA_BUILD_ROOT)/static_executable.mk
NVIDIA_STATIC_AND_SHARED_LIBRARY := $(NVIDIA_BUILD_ROOT)/static_and_shared_library.mk
NVIDIA_HOST_STATIC_LIBRARY := $(NVIDIA_BUILD_ROOT)/host_static_library.mk
NVIDIA_HOST_SHARED_LIBRARY := $(NVIDIA_BUILD_ROOT)/host_shared_library.mk
NVIDIA_HOST_EXECUTABLE     := $(NVIDIA_BUILD_ROOT)/host_executable.mk
NVIDIA_JAVA_LIBRARY        := $(NVIDIA_BUILD_ROOT)/java_library.mk
NVIDIA_STATIC_JAVA_LIBRARY := $(NVIDIA_BUILD_ROOT)/static_java_library.mk
NVIDIA_PACKAGE             := $(NVIDIA_BUILD_ROOT)/package.mk
NVIDIA_COVERAGE            := $(NVIDIA_BUILD_ROOT)/coverage.mk
NVIDIA_PREBUILT            := $(NVIDIA_BUILD_ROOT)/prebuilt.mk
NVIDIA_MULTI_PREBUILT      := $(NVIDIA_BUILD_ROOT)/multi_prebuilt.mk
NVIDIA_PREBUILT_NOTICE     := $(NVIDIA_BUILD_ROOT)/nv_prebuilt_notice_files.mk
NVIDIA_HOST_PREBUILT       := $(NVIDIA_BUILD_ROOT)/host_prebuilt.mk
NVIDIA_WARNINGS            := $(NVIDIA_BUILD_ROOT)/warnings.mk
NVIDIA_GENERATED_HEADER    := $(NVIDIA_BUILD_ROOT)/generated_headers.mk
NVIDIA_TMAKE_PART                   := $(NVIDIA_BUILD_ROOT)/tmake_part.mk
NVIDIA_TMAKE_PART_GENERATED_HEADER  := $(NVIDIA_BUILD_ROOT)/tmake_part_generated_header.mk
NVIDIA_TMAKE_PART_HOST_EXECUTABLE   := $(NVIDIA_BUILD_ROOT)/tmake_part_host_executable.mk
NVIDIA_TMAKE_PART_STATIC_EXECUTABLE := $(NVIDIA_BUILD_ROOT)/tmake_part_static_executable.mk
NVIDIA_TMAKE_STATIC_LIBRARY         := $(NVIDIA_BUILD_ROOT)/tmake_static_library.mk
NVIDIA_TEST_FILES          := $(NVIDIA_BUILD_ROOT)/test_files.mk

# compiler

NVIDIA_AR20ASM             := $(TEGRA_TOP)/cg/Cg/$(HOST_OS)/ar20asm
NVIDIA_CGC                 := $(HOST_OUT_EXECUTABLES)/cgc
NVIDIA_CGC_PROFILE         := glest114
NVIDIA_SHADERFIX           := $(HOST_OUT_EXECUTABLES)/shaderfix
NVIDIA_AR20SHADERLAYOUT    := $(HOST_OUT_EXECUTABLES)/ar20shaderlayout

# tools

NVIDIA_GETEXPORTS          := $(NVIDIA_BUILD_ROOT)/getexports.py
NVIDIA_HEXIFY              := $(TEGRA_TOP)/core/tools/scripts/build/hexify.py
NVIDIA_LZ4C                := $(HOST_OUT_EXECUTABLES)/lz4c
NVIDIA_TNTEST              := $(TEGRA_TOP)/core/tools/tntest/tntest.sh

# test suites

NVIDIA_TNTEST_TESTSUITES   := $(TEGRA_TOP)/tests

# cuda

CUDA_TOOLKIT_REPO_NAME     := cuda-toolkit-7.0
CUDA_TOOLKIT_PATH          := $(TEGRA_TOP)/$(CUDA_TOOLKIT_REPO_NAME)

# global vars
ALL_NVIDIA_MODULES :=
ALL_NVIDIA_TESTS :=

# rule generation to be used via $(call)

define transform-shader-to-cgbin
@echo "Compiling shader $@ from $<"
@mkdir -p $(@D)
$(hide) cat $< | $(NVIDIA_CGC) -quiet $(PRIVATE_CGOPTS) -o $(basename $@).cgbin
endef

define transform-cgbin-to-cghex
@echo "Generating shader binary $@ from $<"
@mkdir -p $(@D)
$(hide) $(NVIDIA_SHADERFIX) -o $(basename $@).ar20bin $(basename $@).cgbin
$(hide) $(NVIDIA_HEXIFY) $(basename $@).ar20bin $@
endef

define transform-cgbin-to-h
@echo "Generating non-shaderfixed binary $@ from $<"
@mkdir -p $(@D)
$(hide) $(NVIDIA_HEXIFY) $(basename $@).cgbin $@
endef

define transform-shader-to-string
@echo "Generating shader source $@ from $<"
@mkdir -p $(@D)
$(hide) cat $< | sed -e 's|^.*$$|"&\\n"|' > $@
endef

define transform-ar20asm-to-h
@echo "Generating shader $@ from $<"
@mkdir -p $(@D)
$(hide) LD_LIBRARY_PATH=$(TEGRA_TOP)/cg/Cg/$(HOST_OS) $(NVIDIA_AR20ASM) $< $(basename $@).ar20bin
$(hide) $(NVIDIA_HEXIFY) $(basename $@).ar20bin $@
endef

define shader-rule
# shaders and shader source to output
SHADERS_COMPILE_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cgbin,$(filter %.$(1),$(2))))
GEN_SHADERS_COMPILE_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cgbin,$(filter %.$(1),$(3))))
SHADERS_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cghex,$(filter %.$(1),$(2))))
GEN_SHADERS_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.cghex,$(filter %.$(1),$(3))))
SHADERS_NOFIX_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.h,$(filter %.$(1),$(2))))
GEN_SHADERS_NOFIX_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.h,$(filter %.$(1),$(3))))
SHADERSRC_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.$(1)h,$(filter %.$(1),$(2))))
GEN_SHADERSRC_$(1) := $(addprefix $(intermediates)/shaders/, \
	$(patsubst %.$(1),%.$(1)h,$(filter %.$(1),$(3))))

# create lists to "output"
ALL_SHADERS_COMPILE_$(1) := $$(SHADERS_COMPILE_$(1)) $$(GEN_SHADERS_COMPILE_$(1))
ALL_SHADERS_$(1) := $$(SHADERS_$(1)) $$(GEN_SHADERS_$(1))
ALL_SHADERS_NOFIX_$(1) := $$(SHADERS_NOFIX_$(1)) $$(GEN_SHADERS_NOFIX_$(1))
ALL_SHADERSRC_$(1) := $$(SHADERSRC_$(1)) $$(GEN_SHADERSRC_$(1))

# rules for building the shaders and shader source
$$(SHADERS_COMPILE_$(1)): $(intermediates)/shaders/%.cgbin : $(LOCAL_PATH)/%.$(1)
	$$(transform-shader-to-cgbin)
$$(GEN_SHADERS_COMPILE_$(1)): $(intermediates)/shaders/%.cgbin : $(intermediates)/%.$(1)
	$$(transform-shader-to-cgbin)
$$(SHADERS_$(1)): $(intermediates)/shaders/%.cghex : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-cghex)
$$(GEN_SHADERS_$(1)): $(intermediates)/shaders/%.cghex : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-cghex)
$$(SHADERS_NOFIX_$(1)): $(intermediates)/shaders/%.h : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbin-to-h)
$$(GEN_SHADERS_NOFIX_$(1)): $(intermediates)/shaders/%.h : $(intermediates)/shaders/%.cgbin
	$$(transform-cgbinr-to-h)
$$(SHADERSRC_$(1)): $(intermediates)/shaders/%.$(1)h : $(LOCAL_PATH)/%.$(1)
	$$(transform-shader-to-string)
$$(GEN_SHADERSRC_$(1)): $(intermediates)/shaders/%.$(1)h : $(intermediates)/%.$(1)
	$$(transform-shader-to-string)
endef

define normalize-abspath-libraries
$(foreach a,$(filter %.a,$(1)),$(abspath $(a)))\
$(call normalize-libraries,$(filter-out %.a,$(1)))
endef

# Tntest validation tool

###############################################################################
# Tntest - build-time test runner
#
# Usage:
# Include the following line to run test cases for the target module.
#
# $(eval $(call tntest,$(TARGET_MODULE),$(TESTSUITE),"Test Name"))
#
# $(1) - TARGET_MODULE (Required)
#  Target module to test. Test cases are executed before the target module is
#  built.
#  e.g.
#   - $(LOCAL_BUILT_MODULE)
#   - file names added to PRODUCT_COPY_FILES
#
# $(2) - TESTSUITE
#  Test Suite location where test cases (prefixed with "test") are located.
#  Default is "testsuite"
#
# $(3) - Test Name
#
# $(4) - Ignore test failure (Optional)
#  Set 1 if it's desired to continue build after test failure.
#
# $(5) - Verbose (Optional)
#  "fail" - prints intermediate steps for failed tests.
#  "all"  - prints intermediate steps for all tests.
#
# $(TNTEST_ARGS) - Test Suite Arguments
#  These are passed to test scripts as-is.
#
###############################################################################
define tntest
$(1): $(1)-tntest
$(1)-tntest::
	$(hide) \
		if [ -x $(NVIDIA_TNTEST) ]; then \
			TNTEST_SUITE=$(2) TNTEST_TITLE=$(3) TNTEST_IGNORE=$(4) \
			TNTEST_VERBOSE=$(5) $(NVIDIA_TNTEST) $(TNTEST_ARGS); \
		else \
			echo "TNTEST for \"$(3)\" skipped."; \
		fi
endef

# tntest wrapper with default values
# $(1) - TARGET
# $(2) - TESTSUITE - under $(TEGRA_TOP)/tests
# $(3) - Test Name
define nv-tntest
$(eval $(call tntest,$(1),$(NVIDIA_TNTEST_TESTSUITES)/$(2),$(3),,fail))
endef

##############
# DEPRECATED #
##############
# Use NVIIDA_TEST_FILES directly instead
#
# nv-add-file copies a given list of file to $OUT by creating a makefile module
# on the fly
# $(1) - Path under $OUT where this should be added
# $(2) - list of files to add
define nv-add-files-to-test-internal
include $(NVIDIA_DEFAULTS)
LOCAL_MODULE := $(firstword $(2))_$(lastword $(2))
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_RELATIVE_PATH := \
  $(or $(patsubst nvidia_tests/host/%,%,$(filter nvidia_tests/host/%,$(1))), \
       $(error $(1): Must begin with nvidia-tests/host))
LOCAL_SRC_FILES := $(foreach f,$(2),$(f):$(f))
include $(NVIDIA_TEST_FILES)
endef
define nv-add-files-to-test
$(eval $(call nv-add-files-to-test-internal,$(patsubst nvidia_tests/host,nvidia_tests/host/.,$(1)),$(2)))
endef
