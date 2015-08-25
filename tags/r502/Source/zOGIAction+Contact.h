/*
  zOGIAction+Contact.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Contact_H__
#define __zOGIAction_Contact_H__

#include "zOGIAction.h"

@interface zOGIAction(Contact)

-(NSArray *)_renderContacts:(NSArray *)_contacts 
                 withDetail:(NSNumber *)_detail;
-(NSArray *)_getUnrenderedContactsForKeys:(id)_arg;
-(id)_getUnrenderedContactForKey:(id)_arg;
-(id)_getContactsForKeys:(id)_arg withDetail:(NSNumber *)_detail;
-(id)_getContactsForKeys:(id)_arg;
-(id)_getContactForKey:(id)_pk withDetail:(NSNumber *)_detail;
-(id)_getContactForKey:(id)_pk;
-(NSException *)_addEnterprisesToPerson:(NSMutableDictionary *)_contact;
-(NSException *)_addProjectsToPerson:(NSMutableDictionary *)_contact;
-(NSException *)_addMembershipToPerson:(NSMutableDictionary *)_contact;
-(NSArray *)_getFavoriteContacts:(NSNumber *)_detail;
-(id)_searchForContacts:(NSArray *)_query 
             withDetail:(NSNumber *)_detail;
-(NSString *)_translateContactKey:(NSString *)_key;
-(id)_deleteContact:(NSString *)_objectId
          withFlags:(NSArray *)_flags;
-(id)_createContact:(NSDictionary *)_contact
               withFlags:(NSArray *)_flags;
-(id)_updateContact:(NSDictionary *)_contact
           objectId:(NSString *)_objectId
          withFlags:(NSArray *)_flags;

-(id)_writeContact:(NSDictionary *)_contact
       withCommand:(NSString *)_command
         withFlags:(NSArray *)_flags;

-(NSException *)_saveEnterprisesToPerson:(NSArray *)_assignments 
                                objectId:(id)_objectId;
@end

#endif /* __zOGIAction_Contact_H__ */
