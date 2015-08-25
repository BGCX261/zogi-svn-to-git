/*
  zOGIAction+Contact.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Contact_H__
#define __zOGIAction_Contact_H__

#include "zOGIAction.h"

@interface zOGIAction(Contact)

-(NSArray *)_renderContacts:(NSArray *)_contacts withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedContactsForKeys:(id)_arg;
-(id)_getContactsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getContactsForKeys:(id)_arg;
-(id)_getContactForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getContactForKey:(id)_pk;
-(void)_addEnterprisesToPerson:(NSMutableDictionary *)_contact;
-(void)_addProjectsToPerson:(NSMutableDictionary *)_contact;
-(NSArray *)_getFavoriteContacts;
-(void)_unfavoriteContact:(NSString *)enterpriseId;
-(void)_favoriteContact:(NSString *)enterpriseId;
-(id)_searchForContacts:(NSArray *)_query withDetail:(NSNumber *)_detail;
-(NSString *)_translateContactKey:(NSString *)_key;

@end

#endif /* __zOGIAction_Contact_H__ */
