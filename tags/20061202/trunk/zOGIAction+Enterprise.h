/*
  zOGIAction+Enterprise.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Enterprise_H__
#define __zOGIAction_Enterprise_H__

#include "zOGIAction.h"

@interface zOGIAction(Enterprise)

-(NSArray *)_renderEnterprises:(NSArray *)_enterprises withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedEnterprisesForKeys:(id)_arg;
-(id)_getEnterprisesForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getEnterpriseForKeys:(id)_pk;
-(id)_getEnterpriseForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getEnterpriseForKey:(id)_pk;
-(void)_addProjectsToEnterprise:(NSMutableDictionary *)_enterprise;
-(void)_addContactsToEnterprise:(NSMutableDictionary *)_enterprise;
-(NSArray *)_getFavoriteEnterprises;
-(void)_unfavoriteEnterprise:(NSString *)enterpriseId;
-(void)_favoriteEnterprise:(NSString *)enterpriseId;
-(id)_searchForEnterprises:(id)_query withDetail:(NSNumber *)_detail;

@end

#endif /* __zOGIAction_Enterprise_H__ */
