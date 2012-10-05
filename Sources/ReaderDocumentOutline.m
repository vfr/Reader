//
//	ReaderDocumentOutline.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2012-09-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderDocumentOutline.h"
#import "CGPDFDocument.h"

@implementation ReaderDocumentOutline

#pragma mark Build option flags

#define HIERARCHICAL_OUTLINE TRUE

#pragma mark ReaderDocumentOutline functions

void logDictionaryEntry(const char *key, CGPDFObjectRef object, void *info)
{
	//CGPDFDictionaryApplyFunction(dictionary, logDictionaryEntry, NULL);

	NSString *kind = nil; // CGPDFObject type

	CGPDFObjectType type = CGPDFObjectGetType(object);

	switch (type) // CGPDFObjectTypes
	{
		case kCGPDFObjectTypeNull:
			kind = @"CGPDFObjectTypeNull";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeBoolean:
			kind = @"CGPDFObjectTypeBoolean";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeInteger:
			kind = @"CGPDFObjectTypeInteger";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeReal:
			kind = @"CGPDFObjectTypeReal";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeName:
		{
			kind = @"CGPDFObjectTypeName"; const char *pdfName = NULL;

			if (CGPDFObjectGetValue(object, kCGPDFObjectTypeName, &pdfName))
			{
				if (pdfName != NULL) NSLog(@"%s %@ %s", key, kind, pdfName);
			}
			break;
		}

		case kCGPDFObjectTypeString:
		{
			kind = @"CGPDFObjectTypeString"; CGPDFStringRef pdfString = NULL;

			if (CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &pdfString))
			{
				const unsigned char *string = CGPDFStringGetBytePtr(pdfString);

				if (string != NULL) NSLog(@"%s %@ %s", key, kind, string);
			}
			break;
		}

		case kCGPDFObjectTypeArray:
			kind = @"CGPDFObjectTypeArray";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeDictionary:
			kind = @"CGPDFObjectTypeDictionary";
			NSLog(@"%s %@", key, kind);
			break;

		case kCGPDFObjectTypeStream:
			kind = @"CGPDFObjectTypeStream";
			NSLog(@"%s %@", key, kind);
			break;
	}
}

#pragma mark ReaderDocumentOutline class methods

+ (void)logDocumentOutlineArray:(NSArray *)array
{
	for (DocumentOutlineEntry *item in array) // Enumerate array entries
	{
		NSInteger indent = (item.level * 2); // Indent amount for NSLog output

		NSLog(@"%@%@", [@"" stringByPaddingToLength:indent withString:@" " startingAtIndex:0], item);

		[self logDocumentOutlineArray:item.children]; // Log any child entries
	}
}

+ (CGPDFArrayRef)destinationWithName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node
{
	CGPDFArrayRef destinationArray = NULL;

	CGPDFArrayRef limitsArray = NULL; // Limits array

	if (CGPDFDictionaryGetArray(node, "Limits", &limitsArray) == true)
	{
		CGPDFStringRef lowerLimit = NULL; CGPDFStringRef upperLimit = NULL;

		if (CGPDFArrayGetString(limitsArray, 0, &lowerLimit) == true) // Lower limit
		{
			if (CGPDFArrayGetString(limitsArray, 1, &upperLimit) == true) // Upper limit
			{
				const char *ll = (const char *)CGPDFStringGetBytePtr(lowerLimit); // Lower string
				const char *ul = (const char *)CGPDFStringGetBytePtr(upperLimit); // Upper string

				if ((strcmp(destinationName, ll) < 0) || (strcmp(destinationName, ul) > 0))
				{
					return NULL; // Destination name is outside this node's limits
				}
			}
		}
	}

	CGPDFArrayRef namesArray = NULL; // Names array

	if (CGPDFDictionaryGetArray(node, "Names", &namesArray) == true)
	{
		NSInteger namesCount = CGPDFArrayGetCount(namesArray);

		for (NSInteger index = 0; index < namesCount; index += 2)
		{
			CGPDFStringRef destName; // Destination name string

			if (CGPDFArrayGetString(namesArray, index, &destName) == true)
			{
				const char *dn = (const char *)CGPDFStringGetBytePtr(destName);

				if (strcmp(dn, destinationName) == 0) // Found the destination name
				{
					if (CGPDFArrayGetArray(namesArray, (index + 1), &destinationArray) == false)
					{
						CGPDFDictionaryRef destinationDictionary = NULL; // Destination dictionary

						if (CGPDFArrayGetDictionary(namesArray, (index + 1), &destinationDictionary) == true)
						{
							CGPDFDictionaryGetArray(destinationDictionary, "D", &destinationArray);
						}
					}

					return destinationArray; // Return the destination array
				}
			}
		}
	}

	CGPDFArrayRef kidsArray = NULL; // Kids array

	if (CGPDFDictionaryGetArray(node, "Kids", &kidsArray) == true)
	{
		NSInteger kidsCount = CGPDFArrayGetCount(kidsArray);

		for (NSInteger index = 0; index < kidsCount; index++)
		{
			CGPDFDictionaryRef kidNode = NULL; // Kid node dictionary

			if (CGPDFArrayGetDictionary(kidsArray, index, &kidNode) == true) // Recurse into node
			{
				destinationArray = [self destinationWithName:destinationName inDestsTree:kidNode];

				if (destinationArray != NULL) return destinationArray; // Return destination array
			}
		}
	}

	return NULL;
}

+ (id)outlineEntryTarget:(CGPDFDictionaryRef)outlineDictionary document:(CGPDFDocumentRef)document
{
	id entryTarget = nil; // Entry target object

	CGPDFStringRef destName = NULL; const char *destString = NULL;

	CGPDFDictionaryRef actionDictionary = NULL; CGPDFArrayRef destArray = NULL;

	if (CGPDFDictionaryGetDictionary(outlineDictionary, "A", &actionDictionary) == true)
	{
		const char *actionType = NULL; // Outline entry action type string

		if (CGPDFDictionaryGetName(actionDictionary, "S", &actionType) == true)
		{
			if (strcmp(actionType, "GoTo") == 0) // GoTo action type
			{
				if (CGPDFDictionaryGetArray(actionDictionary, "D", &destArray) == false)
				{
					CGPDFDictionaryGetString(actionDictionary, "D", &destName);
				}
			}
			else // Handle other entry action type possibility
			{
				if (strcmp(actionType, "URI") == 0) // URI action type
				{
					CGPDFStringRef uriString = NULL; // Action's URI string

					if (CGPDFDictionaryGetString(actionDictionary, "URI", &uriString) == true)
					{
						const char *uri = (const char *)CGPDFStringGetBytePtr(uriString); // Destination URI string

						entryTarget = [NSURL URLWithString:[NSString stringWithCString:uri encoding:NSASCIIStringEncoding]];
					}
				}
			}
		}
	}
	else // Handle other entry target possibilities
	{
		if (CGPDFDictionaryGetArray(outlineDictionary, "Dest", &destArray) == false)
		{
			if (CGPDFDictionaryGetString(outlineDictionary, "Dest", &destName) == false)
			{
				CGPDFDictionaryGetName(outlineDictionary, "Dest", &destString);
			}
		}
	}

	if (destName != NULL) // Handle a destination name
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(document);

		CGPDFDictionaryRef namesDictionary = NULL; // Destination names in the document

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Names", &namesDictionary) == true)
		{
			CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

			if (CGPDFDictionaryGetDictionary(namesDictionary, "Dests", &destsDictionary) == true)
			{
				const char *destinationName = (const char *)CGPDFStringGetBytePtr(destName); // Name

				destArray = [self destinationWithName:destinationName inDestsTree:destsDictionary];
			}
		}
	}

	if (destString != NULL) // Handle a destination string
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(document);

		CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Dests", &destsDictionary) == true)
		{
			CGPDFDictionaryRef targetDictionary = NULL; // Destination target dictionary

			if (CGPDFDictionaryGetDictionary(destsDictionary, destString, &targetDictionary) == true)
			{
				CGPDFDictionaryGetArray(targetDictionary, "D", &destArray);
			}
		}
	}

	if (destArray != NULL) // Handle a destination array
	{
		NSInteger targetPageNumber = 0; // The target page number

		CGPDFDictionaryRef pageDictionaryFromDestArray = NULL; // Target reference

		if (CGPDFArrayGetDictionary(destArray, 0, &pageDictionaryFromDestArray) == true)
		{
			NSInteger pageCount = CGPDFDocumentGetNumberOfPages(document); // Pages

			for (NSInteger pageNumber = 1; pageNumber <= pageCount; pageNumber++)
			{
				CGPDFPageRef pageRef = CGPDFDocumentGetPage(document, pageNumber);

				CGPDFDictionaryRef pageDictionaryFromPage = CGPDFPageGetDictionary(pageRef);

				if (pageDictionaryFromPage == pageDictionaryFromDestArray) // Found it
				{
					targetPageNumber = pageNumber; break;
				}
			}
		}
		else // Try page number from array possibility
		{
			CGPDFInteger pageNumber = 0; // Page number in array

			if (CGPDFArrayGetInteger(destArray, 0, &pageNumber) == true)
			{
				targetPageNumber = (pageNumber + 1); // 1-based
			}
		}

		if (targetPageNumber > 0) // We have a target page number
		{
			entryTarget = [NSNumber numberWithInteger:targetPageNumber];
		}
	}

	return entryTarget;
}

+ (void)outlineItems:(CGPDFDictionaryRef)outlineDictionary document:(CGPDFDocumentRef)document array:(NSMutableArray *)array level:(NSInteger)level
{
	do // Loop through current level outline entries
	{
		DocumentOutlineEntry *outlineEntry = nil; // An entry

		CGPDFStringRef string = NULL; // Outline entry title string

		if (CGPDFDictionaryGetString(outlineDictionary, "Title", &string) == true)
		{
			CFStringRef title = NULL; // Actual outline title (CFObject) string

			if ((title = CGPDFStringCopyTextString(string)) != NULL) // Copy of CFObject string
			{
				NSString *titleString = (__bridge NSString *)title; // CFString to NSString toll-free bridge cast

				id entryTarget = [self outlineEntryTarget:outlineDictionary document:document]; // Get target object

				NSString *trimmed = [titleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

				outlineEntry = [DocumentOutlineEntry newWithTitle:trimmed target:entryTarget level:level]; // New entry

				[array addObject:outlineEntry]; CFRelease(title); // Add new entry and cleanup
			}
		}

		if (outlineEntry != nil) // Must have a current outline entry
		{
			CGPDFDictionaryRef childItem = NULL; // First child outline item

			if (CGPDFDictionaryGetDictionary(outlineDictionary, "First", &childItem) == true)
			{
#if (HIERARCHICAL_OUTLINE == TRUE) // Option
				NSMutableArray *childArray = [NSMutableArray array]; outlineEntry.children = childArray;

				[self outlineItems:childItem document:document array:childArray level:(level + 1)];
#else // Flat
				[self outlineItems:childItem document:document array:array level:(level + 1)];

#endif // end of HIERARCHICAL_OUTLINE Option
			}
		}

	} while (CGPDFDictionaryGetDictionary(outlineDictionary, "Next", &outlineDictionary) == true);
}

+ (NSArray *)outlineFromFileURL:(NSURL *)fileURL password:(NSString *)phrase
{
	NSMutableArray *outlineArray = nil; // Mutable outline array

	if ((fileURL != nil) && [fileURL isFileURL]) // Check for valid file URL
	{
		CGPDFDocumentRef document = CGPDFDocumentCreateX((__bridge CFURLRef)fileURL, phrase);

		if (document != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			CGPDFDictionaryRef outlines = NULL; // Document's outlines

			CGPDFDictionaryRef catalog = CGPDFDocumentGetCatalog(document);

			if (CGPDFDictionaryGetDictionary(catalog, "Outlines", &outlines) == true)
			{
				CGPDFDictionaryRef firstItem = NULL; // First outline item entry

				if (CGPDFDictionaryGetDictionary(outlines, "First", &firstItem) == true)
				{
					outlineArray = [NSMutableArray array]; // Top level outline entries array

					[self outlineItems:firstItem document:document array:outlineArray level:0];
				}
			}

			CGPDFDocumentRelease(document); // Cleanup
		}
	}

	//[self logDocumentOutlineArray:outlineArray]; // Log it

	return [outlineArray copy]; // NSArray
}

@end

#pragma mark -

//
//	DocumentOutlineEntry class implementation
//

@interface DocumentOutlineEntry ()

@property (nonatomic, assign, readwrite) NSInteger level;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) id target;

@end

@implementation DocumentOutlineEntry
{
	NSInteger _level;

	NSMutableArray *_children;

	NSString *_title;

	id _target;
}

#pragma mark Properties

@synthesize level = _level;
@synthesize children = _children;
@synthesize target = _target;
@synthesize title = _title;

#pragma mark DocumentOutlineEntry class methods

+ (id)newWithTitle:(NSString *)title target:(id)target level:(NSInteger)level
{
	return [[DocumentOutlineEntry alloc] initWithTitle:title target:target level:level];
}

#pragma mark DocumentOutlineEntry instance methods

- (id)initWithTitle:(NSString *)title target:(id)target level:(NSInteger)level
{
	if ((self = [super init]))
	{
		self.title = title; self.target = target; self.level = level;
	}

	return self;
}

- (NSString *)description
{
	NSString *format = @"%@ Title = '%@', Target = '%@', Level = (%i)";

	return [NSString stringWithFormat:format, [super description], _title, _target, _level];
}

@end
