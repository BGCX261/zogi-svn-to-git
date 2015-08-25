/*
  zOGIAction+Enterprise.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Enterprise_H__
#define __zOGIAction_Enterprise_H__

#include "zOGIAction.h"

@interface zOGIAction(Enterprise)

-(NSArray *)_renderEnterprises:(NSArray *)_enterprises 
                    withDetail:(NSNumber *)_detail;

-(NSArray *)_getUnrenderedEnterprisesForKeys:(id)_arg;

-(id)_getUnrenderedEnterpriseForKey:(id)_arg;

-(id)_getEnterprisesForKeys:(id)_arg 
                 withDetail:(NSNumber *)_detail;
-(id)_getEnterpriseForKeys:(id)_pk;

-(id)_getEnterpriseForKey:(id)_pk 
                withDetail:(NSNumber *)_detail;

-(id)_getEnterpriseForKey:(id)_pk;

-(void)_addProjectsToEnterprise:(NSMutableDictionary *)_enterprise;

-(void)_addContactsToEnterprise:(NSMutableDictionary *)_enterprise;

-(NSArray *)_getFavoriteEnterprises:(NSNumber *)_detail;

-(id)_searchForEnterprises:(id)_query 
                withDetail:(NSNumber *)_detail;

-(id)_deleteEnterprise:(NSString *)_objectId 
             withFlags:(NSArray *)_flags;

-(NSString *)_translateEnterpriseKey:(NSString *)_key;

-(id)_createEnterprise:(NSDictionary *)_enterprise 
             withFlags:(NSArray *)_flags;

-(id)_updateEnterprise:(NSDictionary *)_enterprise
              objectId:(NSString *)_objectId
             withFlags:(NSArray *)_flags;

-(id)_writeEnterprise:(NSDictionary *)_enterprise
          withCommand:(NSString *)_command
            withFlags:(NSArray *)_flags;

-(NSException *)_savePersonsToEnterprise:(NSArray *)_assignments 
                                objectId:(id)_objectId;

-(NSException *)_saveBusinessCards:(NSArray *)_contacts
                      enterpriseId:(id)_enterpriseId;

@end

#endif /* __zOGIAction_Enterprise_H__ */
