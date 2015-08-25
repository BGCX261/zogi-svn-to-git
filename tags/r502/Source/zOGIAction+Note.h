/*
  zOGIAction+Note.h
  License: LGPL
  Copyright: Whitemice Consulting, 2006
*/
#ifndef __zOGIAction_Note_H__
#define __zOGIAction_Note_H__

#include "zOGIAction.h"

@interface zOGIAction(Note)
-(id)_getNotesForKey:(NSString *)_objectId;
-(id)_renderNote:(NSDictionary *)_note;
-(id)_getUnrenderedNotesForKey:(NSString *)_objectId;
-(id)_saveNotes:(NSArray *)_notes
      forObject:(NSString *)_objectId;
-(id)_deleteAllNotesFromObject:(NSString *)_objectId;
-(id)_deleteNote:(id)_noteId;
-(id)_insertNote:(id)_objectId
       withTitle:(id)_title
     withContent:(id)_content;
-(id)_updateNote:(id)_noteId
       withTitle:(id)_title
     withContent:(id)_content;
@end

#endif /* __zOGIAction_Note_H__ */
