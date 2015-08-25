/*
  NSObject+zOGI.h

  Copyright (C) 2006 Whitemice Consulting
  License: LGPL
*/

#ifndef __zOGI_NSObject_zOGI_H__
#define __zOGI_NSObject_zOGI_H__

#import <Foundation/NSObject.h>
#include <NGObjWeb/SoObjects.h>

/*
  Category for zOGI API.
*/

@class NSString, NSArray, NSDictionary, NSCalendarDate;

@interface NSObject(zOGI)

@end

@interface NSObject(zOGIObject)

@end

@interface NSObject(PostObject)

/*- (NSString *)ogiContentInContext:(id)_ctx;
- (NSDictionary *)zOgiPostInfoInContext:(id)_ctx; */

@end

#endif /* __zOGI_NSObject_zOGI_H__ */
