/*
  common.h

  Copyright (C) 2006 Whitemice Consulting
  License: LGPL
*/

#import <Foundation/Foundation.h>

#if !LIB_FOUNDATION_LIBRARY
#  include <NGExtensions/NGObjectMacros.h>
#  include <NGExtensions/NSString+Ext.h>
#endif

#include <NGExtensions/NGExtensions.h>
#include <NGObjWeb/NGObjWeb.h>
#include <NGObjWeb/WEClientCapabilities.h>
#include <NGObjWeb/SoObjects.h>
#include <NGObjWeb/WODirectAction.h>
#include <NGXmlRpc/WODirectAction+XmlRpc.h>
#include <LSFoundation/LSFoundation.h>
#include <LSFoundation/LSCommandContext.h>
#include <EOControl/EOKeyGlobalID.h>
#include <GDLAccess/EOAdaptorChannel.h>
#include <EOControl/EOControl.h>
#include "NSString+SearchingAdditions.h"

#define OGo_HTML_MARKER @"<!-- html marker -->\n"
