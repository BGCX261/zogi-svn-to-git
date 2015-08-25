/*
  zOGIAction+Document.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Document_H__
#define __zOGIAction_Document_H__

#include "zOGIAction.h"

@interface zOGIAction(Document)

-(id)_renderDocuments:(NSArray *)_docs withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedDocsForKeys:(id)_arg;
-(id)_getDocumentsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getDocumentsForKeys:(id)_pk;
-(id)_getDocumentForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getDocumentForKey:(id)_pk;
-(id)_getContentsOfFolder:(id)_folderId;

@end

#endif /* __zOGIAction_Document_H__ */
