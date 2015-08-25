/*
  zOGIAction+Company.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#include "zOGIAction.h"
#include "zOGIAction+Company.h"

@implementation zOGIAction(Company)

-(void)_addAddressesToCompany:(NSMutableDictionary *)_company {
  NSArray             *addresses;
  NSMutableDictionary *addressList;
  NSEnumerator        *enumerator;
  id                   address;

  addresses = [[self getCTX] runCommand:@"address::get",
                 @"companyId",  [NSNumber numberWithInt:[[_company objectForKey:@"objectId"] intValue]],
                 @"returnType", intObj(LSDBReturnType_ManyObjects),
                 nil];
  if (addresses == nil) addresses = [NSArray array];
  addressList = [[NSMutableDictionary alloc] initWithCapacity:[addresses count]];
  enumerator = [addresses objectEnumerator];
  while ((address = [enumerator nextObject]) != nil) {
    [addressList setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [address valueForKey:@"addressId"], @"objectId",
       @"Address", @"entityName",
       [address valueForKey:@"companyId"], @"companyObjectId",
       [self NIL:[address valueForKey:@"name1"]], @"name1",
       [self NIL:[address valueForKey:@"name2"]], @"name2",
       [self NIL:[address valueForKey:@"name3"]], @"name3",
       [self NIL:[address valueForKey:@"city"]], @"city",
       [self NIL:[address valueForKey:@"state"]], @"state",
       [self NIL:[address valueForKey:@"street"]], @"street",
       [self NIL:[address valueForKey:@"zip"]], @"zip",
       [self NIL:[address valueForKey:@"country"]], @"country",
       [self NIL:[address valueForKey:@"type"]], @"type",
       nil] forKey:@"type" ];
   }
  [_company setObject:addressList forKey:@"_ADDRESSES"];
}

-(void)_addPhonesToCompany:(NSMutableDictionary *)_company {
  NSArray             *phones;
  NSMutableDictionary *phoneList;
  NSEnumerator        *enumerator;
  id                   phone;

  phones = [[self getCTX] runCommand:@"telephone::get",
              @"companyId",  [NSNumber numberWithInt:[[_company objectForKey:@"objectId"] intValue]],
              @"returnType", intObj(LSDBReturnType_ManyObjects),
              nil];
  if (phones == nil) phones = [NSArray array];
  phoneList = [[NSMutableDictionary alloc] initWithCapacity:[phones count]];
  enumerator = [phones objectEnumerator];
  while ((phone = [enumerator nextObject]) != nil) {
    [phoneList setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: 
       [phone valueForKey:@"telephoneId"], @"objectId",
       @"Telephone", @"entityName",
       [phone valueForKey:@"companyId"], @"companyObjectId",
       [self NIL:[phone valueForKey:@"info"]], @"info",
       [self NIL:[phone valueForKey:@"number"]], @"number",
       [self NIL:[phone valueForKey:@"realNumber"]], @"realNumber",
       [self NIL:[phone valueForKey:@"type"]], @"type",
       [self NIL:[phone valueForKey:@"url"]], @"url",
       nil] forKey:[phone valueForKey:@"type"]];
   }
  [_company setObject:phoneList forKey:@"_PHONES"];
}

-(void)_addCompanyValuesToCompany:(NSMutableDictionary *)_company {
  NSMutableDictionary *valueList;
  NSEnumerator        *enumerator;
  id                   value;

  valueList = [NSMutableDictionary new];
  [self logWithFormat:@"************************************"];
  [self logWithFormat:@"_addCompanyValuesToPerson()"];
  enumerator = [[[_company objectForKey:@"eoObject"] valueForKey:@"attributeMap"] objectEnumerator];
  while ((value = [enumerator nextObject]) != nil) {
    if ([value isKindOfClass:[EOGenericRecord class]]) {
      [self logWithFormat:@"_addCompanyValuesToPerson():value=%@", value];
      [valueList setObject:[NSDictionary dictionaryWithObjectsAndKeys:
           @"companyValue", @"entityName",
           [value valueForKey:@"companyValueId"], @"objectId",
           [value valueForKey:@"companyId"], @"companyObjectId",
           [self NIL:[value valueForKey:@"label"]], @"label",
           [self NIL:[value valueForKey:@"type"]], @"type",
           [self NIL:[value valueForKey:@"uid"]], @"uid",
           [self NIL:[value valueForKey:@"value"]], @"value",
           [value valueForKey:@"attribute"], @"attribute",
           nil]
         forKey:[value valueForKey:@"attribute"]];
     }
   }
  [_company setObject:valueList forKey:@"_COMPANYVALUES"];
}

@end /* End zOGIAction(Company) */
