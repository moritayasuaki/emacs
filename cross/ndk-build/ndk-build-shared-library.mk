# Copyright 2023 Free Software Foundation, Inc.

# This file is part of GNU Emacs.

# GNU Emacs is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# GNU Emacs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

# ndk-build works by including a bunch of Makefiles which set
# variables, and then having those Makefiles include another makefile
# which actually builds targets.

eq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
objname = $(1)-$(subst /,_,$(2).o)

define single-object-target

ifeq (x$(suffix $(1)),x.c)

$(call objname,$(LOCAL_MODULE),$(basename $(1))): $(LOCAL_PATH)/$(1)
	$(NDK_BUILD_CC) -c $$< -o $$@ $(NDK_CFLAGS_$(LOCAL_MODULE))

else
ifneq ($(or $(call eq,x$(suffix $(1)),x.s),$(call eq,x$(suffix $(1)),x.S)),)

$(call objname,$(LOCAL_MODULE),$(basename $(1))): $(LOCAL_PATH)/$(1)
	$(NDK_BUILD_CC) -c $$< -o $$@ $(NDK_ASFLAGS_$(LOCAL_MODULE))

else
$$(error Unsupported suffix: $(suffix $(1)))
endif
endif

ALL_OBJECT_FILES$(LOCAL_MODULE) += $(call objname,$(LOCAL_MODULE),$(basename $(1)))

endef

NDK_CFLAGS_$(LOCAL_MODULE)	 := $(addprefix -I,$(addprefix $(LOCAL_PATH),$(LOCAL_C_INCLUDES)))
NDK_CFLAGS_$(LOCAL_MODULE)	 ::= -fPIC -iquote $(LOCAL_EXPORT_CFLAGS) $(LOCAL_PATH) $(LOCAL_CFLAGS)
NDK_LDFLAGS_$(LOCAL_MODULE)	 := $(LOCAL_LDLIBS)
NDK_LDFLAGS_$(LOCAL_MODULE)	 := $(LOCAL_LDFLAGS)
ALL_OBJECT_FILES_$(LOCAL_MODULE) :=

ifeq ($(NDK_BUILD_ARCH)$(NDK_ARM_MODE),armarm)
NDK_CFLAGS ::= -marm
else
ifeq ($(NDK_BUILD_ARCH),arm)
NDK_CFLAGS ::= -mthumb
endif
endif

LOCAL_MODULE_FILENAME := $(strip $(LOCAL_MODULE_FILENAME))

ifndef LOCAL_MODULE_FILENAME
ifeq ($(findstring lib,$(LOCAL_MODULE)),lib)
LOCAL_MODULE_FILENAME := $(LOCAL_MODULE)_emacs
else
LOCAL_MODULE_FILENAME := lib$(LOCAL_MODULE)_emacs
endif
endif

# Since a shared library is being built, suffix the library with
# _emacs.  Otherwise, libraries already on the system will be found
# first, with potentially nasty consequences.

LOCAL_MODULE_FILENAME := $(LOCAL_MODULE_FILENAME).so

# Then define rules to build all objects.
ALL_SOURCE_FILES = $(LOCAL_SRC_FILES)
$(foreach source,$(ALL_SOURCE_FILES),$(eval $(call single-object-target,$(source))))

# Now define the rule to build the shared library.
$(LOCAL_MODULE_FILENAME): $(ALL_OBJECT_FILES$(LOCAL_MODULE))
	$(NDK_BUILD_CC) $^ -o $@ -shared $(NDK_LDFLAGS$(LOCAL_MODULE))
