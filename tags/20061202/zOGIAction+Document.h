/*
  zOGIAction+Document.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Document_H__
#define __zOGIAction_Document_H__

#include "zOGIAction.h"

@interface zOGIAction(Document)

-(id)_getDocumentsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(NSDictionary *)_renderACLsForDocument:(id)_document;
-(id)_storeACLsForDocument:(id)_document withAccess:(NSDictionary *)_acls;
-(NSArray *)_renderLogsForDocument:(id)_document;

@end

#endif /* __zOGIAction_Document_H__ */
