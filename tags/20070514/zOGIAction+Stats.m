/*
  zOGIAction+Stats.m
  License: LGPL
  Copyright: Whitemice Consulting, 2007

  A rendered ZOGI note -
  {'entityName': 'ApplicationAlert',
   },
*/
#include "zOGIAction.h"

@implementation zOGIAction(Stats)

-(id)_getServerStats {
  NSMutableDictionary  *dict;

  dict = [[NSMutableDictionary alloc] initWithCapacity:16];
  [dict setObject:@"ApplicationAlert" forKey:@"entityName"];
  return dict;
 } // End _getServerStats

@end /* End zOGIAction(Stats) */
