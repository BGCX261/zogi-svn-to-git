/*
  NSString+SearchingAdditions.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/

#ifndef __NSString_contains_H__
#define __NSString_contains_H__

@interface NSString (SearchingAdditions)

- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsString:(NSString *)aString ignoringCase:(BOOL)flag;

@end

#endif /* NSString_contains */
