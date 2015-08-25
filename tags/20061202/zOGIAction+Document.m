/*
  zOGIAction+Document.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Document.h"

@implementation zOGIAction(Document)

-(id)_getDocumentsForKeys:(id)_arg withDetail:(NSString *)_detail {
  NSArray      *eoIDs;

  eoIDs = [self _getEOsForPKeys:_arg];
  
  return [NSArray arrayWithObjects:nil];
}

@end /* End zOGIAction(Document) */
