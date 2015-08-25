# GNUstep environment configuration
#   created by: './configure --enable-debug        '

# Note: you can override any option as a 'make' parameter, eg:
#         make debug=yes

# configured for FHS install
FHS_INSTALL_ROOT:=/usr/local/

# configured to produce debugging code
debug:=yes

# configured to produce stripped code
strip:=yes

# enforce shared libraries
shared:=yes

# GNUstep environment variables:
GNUSTEP_FLATTENED:=yes
GNUSTEP_HOST_CPU:=ix86
GNUSTEP_HOST:=i686-pc-linux-gnu
GNUSTEP_HOST_OS:=linux-gnu
GNUSTEP_HOST_VENDOR:=pc
GNUSTEP_LOCAL_ROOT:=/usr/local/OGo-GNUstep
GNUSTEP_MAKEFILES:=/usr/local/OGo-GNUstep/Library/Makefiles
GNUSTEP_NETWORK_ROOT:=/usr/local/OGo-GNUstep
GNUSTEP_PATHLIST:=/usr/local/OGo-GNUstep
GNUSTEP_ROOT:=/usr/local/OGo-GNUstep
GNUSTEP_SYSTEM_ROOT:=/usr/local/OGo-GNUstep
GNUSTEP_USER_ROOT:=/home/awilliam/GNUstep
LIBRARY_COMBO:=gnu-fd-nil

ifeq ($(findstring _64, $(GNUSTEP_HOST_CPU)), _64)
CONFIGURE_64BIT:=yes
ifneq ($(FHS_INSTALL_ROOT),)
CONFIGURE_FHS_INSTALL_LIBDIR:=$(FHS_INSTALL_ROOT)/lib64/
endif
CONFIGURE_SYSTEM_LIB_DIR += -L$(CONFIGURE_FHS_INSTALL_LIBDIR) -L/usr/lib64
else
ifneq ($(FHS_INSTALL_ROOT),)
CONFIGURE_FHS_INSTALL_LIBDIR:=$(FHS_INSTALL_ROOT)/lib/
endif
CONFIGURE_SYSTEM_LIB_DIR += -L$(CONFIGURE_FHS_INSTALL_LIBDIR) -L/usr/lib
endif
# avoid a gstep-make warning
PATH:=$(GNUSTEP_SYSTEM_ROOT)/Tools:$(PATH)
HAS_LIBRARY_NGLdap=yes
HAS_LIBRARY_NGObjWeb=yes
HAS_LIBRARY_GDLAccess=yes
HAS_LIBRARY_pisock=yes

# enable PDA
libpisock = yes
