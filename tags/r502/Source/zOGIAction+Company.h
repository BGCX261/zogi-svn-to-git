/*
  zOGIAction+Company.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Company_H__
#define __zOGIAction_Company_H__

#include "zOGIAction.h"

@interface zOGIAction(Company)
-(NSMutableArray *)_renderCompanyFlags:(EOGenericRecord *)_company
                            entityName:(NSString *)_entityName;

-(NSException *)_addAddressesToCompany:(NSMutableDictionary *)_company;

-(NSException *)_addPhonesToCompany:(NSMutableDictionary *)_company;

-(NSException *)_addCompanyValuesToCompany:(NSMutableDictionary *)_company;

-(NSMutableDictionary *)_translateAddress:(NSDictionary *)_address 
                               forCompany:(id)_objectId;

-(NSException *)_saveAddresses:(NSArray *)_addresses 
                    forCompany:(id)_objectId;

-(NSMutableDictionary *)_translatePhone:(NSDictionary *)_phone 
                             forCompany:(id)_objectId;

-(NSException *)_savePhones:(NSArray *)_phones 
                 forCompany:(id)_objectId;

-(id)_writeCompany:(NSDictionary *)_company
       withCommand:(NSString *)_command
         withFlags:(NSArray *)_flags 
        forEntity:(NSString *)_entity;
@end

#endif /* __zOGIAction_Company_H__ */
