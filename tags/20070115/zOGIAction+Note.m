/*
  zOGIAction+Note.m
  License: LGPL
  Copyright: Whitemice Consulting, 2006

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
    [noteList addObject:
       [NSDictionary dictionaryWithObjectsAndKeys:
          [note valueForKey:@"documentId"], @"objectId",
          @"Note", @"entityName",
          [note valueForKey:@"title"], @"title",
          [note valueForKey:@"firstOwnerId"], @"creatorObjectId",
          [note valueForKey:@"currentOwnerId"], @"ownerObjectId",
          [note valueForKey:@"creationDate"], @"createdTime",
          [NSNull null], @"projectObjectId",
          _objectId, @"dateObjectId",
          [NSString stringWithContentsOfFile:[note valueForKey:@"attachmentName"]],
            @"content",
          nil]];
   }
  return noteList;
 } // End _getNotesForKey

/*
   Retrieve and return the unrendered notes for the specified object.
 */
-(id)_getUnrenderedNotesForKey:(NSString *)_objectId {
  NSArray  *notes;
  NSString *entityName;
  
  notes = nil;
  entityName = [self _getEntityNameForPKey:_objectId];
  if ([entityName isEqualToString:@"Appointment"])
    notes = [[self getCTX]runCommand:@"note::get", @"dateId", _objectId,
                @"returnType", intObj(LSDBReturnType_ManyObjects),
                nil];
  if (notes == nil)
    return [NSArray array];
  [[self getCTX] runCommand:@"note::get-attachment-name", @"notes", notes, nil];
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

  if (_notes == nil)
    return nil;
  [self logWithFormat:@"_saveNotes(%@)", _notes];
  if ([_notes count] == 0)
    return [self _deleteAllNotesFromObject:_objectId];
  noteList = [[NSMutableArray alloc] initWithCapacity:[_notes count]];
  enumerator = [_notes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    objectId = [note objectForKey:@"objectId"];
    if ([objectId isKindOfClass:[NSNumber class]])
      objectId = [objectId stringValue];
    if ([objectId isEqualToString:@"0"]) {
      // objectId == 0, create note
      note = [self _insertNote:_objectId
                     withTitle:[note objectForKey:@"title"]
                   withContent:[note objectForKey:@"content"]];
      if ([note isKindOfClass:[NSException class]])
        return note;
      [noteList addObject:[note objectForKey:@"objectId"]];
     } else {
         // objectId != 0, update note
         note = [self _updateNote:objectId
                        withTitle:[note objectForKey:@"title"]
                      withContent:[note objectForKey:@"content"]];
         if ([note isKindOfClass:[NSException class]])
           return note;
         [noteList addObject:[note objectFoKey:@"objectId"]];
        } // End else objectId != 0
   } // End while (note = [enumerator nextObject]) != nil)
  // Delete notes that were not provided by the client
  objectNotes = [self _getUnrenderedNotesForKey:_objectId];
  enumerator = [_notes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    if (![noteList containsObject:[note objectForKey:@"documentId"]])
      [[self getCTX] runCommand:@"note::delete",
                       @"documentId", [note objectForKey:@"documentId"],
                       @"reallyDelete", [NSNumber numberWithBool:YES],
                       nil];
   } // End while ((note = [[self _getNotesForKey:objectId] nextObject])
  [self logWithFormat:@"_saveNotes; completed"];
  return nil;
 } // End _saveNotes

/*
  Delete all the notes from an object
 */
-(NSException *)_deleteAllNotesFromObject:(NSString *)_objectId {
  NSArray       *objectNotes;
  NSEnumerator  *enumerator;
  NSDictionary  *note;

  objectNotes = [self _getUnrenderedNotesForKey:_objectId];
  enumerator = [objectNotes objectEnumerator];
  while ((note = [enumerator nextObject]) != nil) {
    [[self getCTX] runCommand:@"note::delete",
                     @"documentId", [note objectForKey:@"documentId"],
                     @"reallyDelete", [NSNumber numberWithBool:YES],
                     nil];
   } // End while ((note = [enumerator nextObject]) != nil)
  return nil;
 }


/* 
  Insert a note attached to the specified object,  that object must be
  an appointment or a project.
 */
-(id)_insertNote:(id)_objectId
       withTitle:(NSString *)_title
     withContent:(NSString *)_content {
  id                    note, entityName, objectKey;
  NSNumber             *accountId;

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
  return [NSDictionary dictionaryWithObjectsAndKeys:
           [note valueForKey:@"documentId"], @"objectId",
           @"Note", @"entityName",
           [note valueForKey:@"title"], @"title",
           [note valueForKey:@"firstOwnerId"], @"creatorObjectId",
           [note valueForKey:@"currentOwnerId"], @"ownerObjectId",
           [note valueForKey:@"creationDate"], @"createdTime",
           [NSNull null], @"projectObjectId",
           _objectId, @"dateObjectId",
           _content, @"content",
           nil];
 } // End _insertNote

- (id)_deleteNote:(id)_noteId {
  id note, result;

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
-(id)_updateNote:(id)_noteId:
       withTitle:(NSString *)_title:
     withContent:(NSString *)_content {
  id note;

  [[self getCTX] runCommand:@"note::set"
     @"documentId", _noteId, @"title", _title,
     @"fileContent", _content, nil];
  note = [[[self getCTX] runCommand:@"note::get",
             @"documentId", _noteId,
             nil] lastObject];
  return [NSDictionary dictionaryWithObjectsAndKeys:
           [note valueForKey:@"documentId"], @"objectId",
           [note valueForKey:@"title"], @"title",
           [note valueForKey:@"currentOwnerId"], @"creatorObjectId",
           [note valueForKey:@"currentOwnerId"], @"ownerObjectId",
           [note valueForKey:@"creationDate"], @"createdTime",
           [NSNull null], @"projectObjectId",
           [note valueForKey:@"dateId"], @"dateObjectId",
           _content, @"content",
           nil];
 } // End _updateNote

@end /* End zOGIAction(Note) */
