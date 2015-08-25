/*
  zOGIAction+Note.m
  License: LGPL
  Copyright: Whitemice Consulting, 2007

  A rendered ZOGI note -
  {'creatorObjectId': 10120, 
   'projectObjectId': '', 
   'objectId': 31350, 
   'dateObjectId': 28260, 
   'title': 'Appointment Note Title w/Project', 
   'entityName': 'Note', 
   'ownerObjectId': 10120, 
   'content': 'Appointment note text', 
   'createdTime': <DateTime u'20060819T23:09:17' at -484d0534>},
*/
#include "zOGIAction.h"
#include "zOGIAction+Object.h"
#include "zOGIAction+Note.h"
#include "zOGIAction+Appointment.h"
#include "zOGIAction+Project.h"

@implementation zOGIAction(Note)

-(id)_getNotesForKey:(NSString *)_objectId {
  NSArray        *notes;
  NSMutableArray *noteList;
  NSDictionary   *note;
  int count;
  
  notes = [self _getUnrenderedNotesForKey:_objectId];
  if ([notes count] == 0)
    return notes;
  noteList = [[NSMutableArray alloc] initWithCapacity:[notes count]];
  for (count = 0; count < [notes count]; count++) {
    note = [notes objectAtIndex:count];
    [noteList addObject:[self _renderNote:note]];
   }
  return noteList;
 } // End _getNotesForKey

-(id)_renderNote:(NSDictionary *)_note {
  return [NSDictionary dictionaryWithObjectsAndKeys:
    [_note valueForKey:@"documentId"], @"objectId",
    @"Note", @"entityName",
    [_note valueForKey:@"title"], @"title",
    [_note valueForKey:@"firstOwnerId"], @"creatorObjectId",
    [_note valueForKey:@"currentOwnerId"], @"ownerObjectId",
    [_note valueForKey:@"creationDate"], @"createdTime",
    [self NIL:[_note valueForKey:@"projectId"]], @"projectObjectId",
    [self NIL:[_note valueForKey:@"dateId"]], @"appointmentObjectId",
    [NSString stringWithContentsOfFile:[_note valueForKey:@"attachmentName"]],
    @"content",
    nil];
}
/*
   Retrieve and return the unrendered notes for the specified object.
 */
-(id)_getUnrenderedNotesForKey:(NSString *)_objectId {
  NSArray  *notes;
  NSString *entityName;
  
  notes = nil;
  [self logWithFormat:@"_getUnrenderedNotesForKey(%@)", _objectId];
  entityName = [self _getEntityNameForPKey:_objectId];
  if ([entityName isEqualToString:@"Date"]) {
    [self logWithFormat:@"_getUnrenderedNotesForKey;Date"];
    notes = [[self getCTX] runCommand:@"note::get", @"dateId", _objectId,
                @"returnType", intObj(LSDBReturnType_ManyObjects),
                nil];
   } else if ([entityName isEqualToString:@"Project"]) {
    [self logWithFormat:@"_getUnrenderedNotesForKey;Project"];
    notes = [[self getCTX] runCommand:@"note::get", @"projectId", _objectId,
                @"returnType", intObj(LSDBReturnType_ManyObjects),
                nil];
   }
  if (notes == nil)
    return [NSArray array];
  [self logWithFormat:@"_getUnrenderedNotesForKey(); getting note content"];
  [[self getCTX] runCommand:@"note::get-attachment-name", @"notes", notes, nil];
  [self logWithFormat:@"_getUnrenderedNotesForKey(); complete"];
  return notes;
 } // End _getUnrenderedNotesForKey

/*
  Save notes
  Note dictionaries in _notes with an objectId of "0" are created as new,
  notes with a non-zero objectId are updated.  If the object has notes not 
  provided in the array they are deleted.
 */
-(id)_saveNotes:(NSArray *)_notes 
      forObject:(NSString *)_objectId {
  NSEnumerator	 *enumerator;
  NSDictionary   *note;
  NSString       *objectId;
  NSMutableArray *noteList;
  NSArray        *objectNotes;

  [self logWithFormat:@"_saveNotes(%@)", _notes];
  if (_notes == nil) {
    [self logWithFormat:@"_saveNotes;no notes key in entity, bailling out"];
    return nil;  
   }
  if ([_notes count] == 0) {
    [self logWithFormat:@"_saveNotes;delete all notes, emtpy array"];
    return [self _deleteAllNotesFromObject:_objectId];
   }
  noteList = [[NSMutableArray alloc] initWithCapacity:[_notes count]];
  enumerator = [_notes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    objectId = [note objectForKey:@"objectId"];
    if ([objectId isKindOfClass:[NSNumber class]])
      objectId = [objectId stringValue];
    if ([objectId isEqualToString:@"0"]) {
      // objectId == 0, create note
      [self logWithFormat:@"_saveNotes; note insert"];
      note = [self _insertNote:_objectId
                     withTitle:[note objectForKey:@"title"]
                   withContent:[note objectForKey:@"content"]];
      if ([note isKindOfClass:[NSException class]]) {
        [self logWithFormat:@"_saveNotes;Exception:%@", note];
        return note;
       }
      [self logWithFormat:@"_saveNotes;note insert complere", note];
      [noteList addObject:[note objectForKey:@"objectId"]];
     } else {
         // objectId != 0, update note
         [self logWithFormat:@"_saveNotes; note update"];
         note = [self _updateNote:objectId
                        withTitle:[note objectForKey:@"title"]
                      withContent:[note objectForKey:@"content"]];
         if ([note isKindOfClass:[NSException class]]) {
           [self logWithFormat:@"_saveNotes;Exception:%@", note];
           return note;
          }
         [self logWithFormat:@"_saveNotes; note update complete"];
         [noteList addObject:[note objectForKey:@"objectId"]];
        } // End else objectId != 0
   } // End while (note = [enumerator nextObject]) != nil)
  // Delete notes that were not provided by the client
  [self logWithFormat:@"_saveNotes; delete notes?"];
  objectNotes = [self _getUnrenderedNotesForKey:_objectId];
  if (objectNotes == nil) {
    [self logWithFormat:@"_saveNotes; delete loop, no notes"];
    return nil;
   }
  [self logWithFormat:@"_saveNotes; delete loop, %d notes", [objectNotes count]];
  enumerator = [objectNotes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    objectId = [note objectForKey:@"documentId"];
    if ([noteList containsObject:objectId]) {
      [self logWithFormat:@"_saveNotes;delete keeping note %@", objectId];
     } else {
         [self _deleteNote:objectId];
        }
   } // End while ((note = [[self _getNotesForKey:objectId] nextObject])
  [self logWithFormat:@"_saveNotes; completed"];
  return nil;
 } // End _saveNotes

/*
  Delete all the notes from an object
 */
-(id)_deleteAllNotesFromObject:(NSString *)_objectId {
  NSArray       *objectNotes;
  NSEnumerator  *enumerator;
  NSDictionary  *note;

  [self logWithFormat:@"_deleteAllNotesFromObject;%@)", _objectId];
  objectNotes = [self _getUnrenderedNotesForKey:_objectId];
  enumerator = [objectNotes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    [self _deleteNote:_objectId];
   } // End while ((note = [enumerator nextObject]) != nil)
  return nil;
 }

/* 
  Insert a note attached to the specified object,  that object must be
  an appointment or a project.
 */
-(id)_insertNote:(id)_objectId
       withTitle:(id)_title
     withContent:(id)_content {
  id                    note, entityName, objectKey;
  NSNumber             *accountId;

  [self logWithFormat:@"_insertNote(for %@)", _objectId];
  accountId =[self _getCompanyId];
  entityName = [self _getEntityNameForPKey:_objectId];
  if ([entityName isEqualToString:@"Date"])
    objectKey = [NSString stringWithString:@"dateId"];
  else if ([entityName isEqualToString:@"Project"])
    objectKey = [NSString stringWithString:@"projectId"];
  else return [NSException exceptionWithHTTPStatus:500
                           reason:@"Cannot attach note to this object type"];
  note = [NSDictionary dictionaryWithObjectsAndKeys:
           _objectId, objectKey, accountId, @"firstOwnerId",
           accountId, @"currentOwnerId", _title, @"title",
           _content, @"fileContent",
           [NSNumber numberWithBool:NO], @"isFolder",
           [NSNumber numberWithInt:[_content length]], @"fileSize",
           nil];
  note = [[self getCTX] runCommand:@"note::new" arguments:note];
  if (note == nil)
      return [NSException exceptionWithHTTPStatus:500
                          reason:@"Note creation failed"];
  return [self _renderNote:note];
 } // End _insertNote

- (id)_deleteNote:(id)_noteId {
  id note, result;

  [self logWithFormat:@"_deleteNote(%@)", _noteId];
  if ([_noteId isKindOfClass:[NSString class]])
    _noteId = [NSNumber numberWithInt:[_noteId intValue]];
  note = [[self getCTX] runCommand:@"note::get",
             @"documentId", _noteId,
             nil];
  if (note == nil)
    return [NSException exceptionWithHTTPStatus:500
                        reason:@"Note does not exist"];
  result = [[self getCTX] runCommand:@"note::delete",
                   @"documentId", _noteId,
                   @"reallyDelete", [NSNumber numberWithBool:YES],
                 nil];
  return [NSNumber numberWithBool:YES];
 } // End _deleteNote

/*
  Update the title and content of the specified note
 */
-(id)_updateNote:(id)_noteId
       withTitle:(id)_title
     withContent:(id)_content {
  id note;

  [self logWithFormat:@"_updateNote(%@)", _noteId];
  note = [[[self getCTX] runCommand:@"note::get",
             @"documentId", _noteId,
             nil] lastObject];
  [note takeValue:[NSNumber numberWithInt:[_content length]] forKey:@"fileSize"];
  [note takeValue:_content forKey:@"fileContent"];
  [note takeValue:_title forKey:@"title"];
  [[self getCTX] runCommand:@"note::set",
     @"object", note,
     @"fileContent", _content, nil];
  note = [[[self getCTX] runCommand:@"note::get",
             @"documentId", _noteId,
             nil] lastObject];
  return [self _renderNote:note];
 } // End _updateNote

@end /* End zOGIAction(Note) */
