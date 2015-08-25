/*
  zOGIAction+Company.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Company_H__
#define __zOGIAction_Company_H__

#include "zOGIAction.h"

@interface zOGIAction(Company)

/*
-(NSDictionary *)_renderACLsForCompany:(id)_company;
-(id)_storeACLsForCompany:(id)_company withAccess:(NSDictionary *)_acls;
-(NSDictionary *)_getCompanyValuesForCompany:(id)_company;
-(id)_storeCompanyValuesForKey:(id)_pk withValues:(NSDictionary *)_values;
*/

-(NSException *)_addAddressesToCompany:(NSMutableDictionary *)_company;
-(NSException *)_addPhonesToCompany:(NSMutableDictionary *)_company;
-(NSException *)_addCompanyValuesToCompany:(NSMutableDictionary *)_company;

@end

#endif /* __zOGIAction_Company_H__ */
