//
//	CGPDFDocument.m
//	Reader v2.6.0
//
//	Created by Julius Oklamcak on 2011-07-01.
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

#import "CGPDFDocument.h"

//
//	CGPDFDocumentRef CGPDFDocumentCreateX(CFURLRef, NSString *) function
//

CGPDFDocumentRef CGPDFDocumentCreateX(CFURLRef theURL, NSString *password)
{
	CGPDFDocumentRef thePDFDocRef = NULL;

	if (theURL != NULL) // Check for non-NULL CFURLRef
	{
		thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);

		if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) // Encrypted
			{
				// Try a blank password first, per Apple's Quartz PDF example

				if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE)
				{
					// Nope, now let's try the provided password to unlock the PDF

					if ((password != nil) && ([password length] > 0)) // Not blank?
					{
						char text[128]; // char array buffer for the string conversion

						[password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];

						if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE) // Log failure
						{
							#ifdef DEBUG
								NSLog(@"CGPDFDocumentCreateX: Unable to unlock [%@] with [%@]", theURL, password);
							#endif
						}
					}
				}

				if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) // Cleanup unlock failure
				{
					CGPDFDocumentRelease(thePDFDocRef), thePDFDocRef = NULL;
				}
			}
		}
	}
	else // Log an error diagnostic
	{
		#ifdef DEBUG
			NSLog(@"CGPDFDocumentCreateX: theURL == NULL");
		#endif
	}

	return thePDFDocRef;
}

//
//	BOOL CGPDFDocumentNeedsPassword(CFURLRef, NSString *) function
//

BOOL CGPDFDocumentNeedsPassword(CFURLRef theURL, NSString *password)
{
	BOOL needPassword = NO; // Default flag

	if (theURL != NULL) // Check for non-NULL CFURLRef
	{
		CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);

		if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) // Encrypted
			{
				// Try a blank password first, per Apple's Quartz PDF example

				if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE)
				{
					// Nope, now let's try the provided password to unlock the PDF

					if ((password != nil) && ([password length] > 0)) // Not blank?
					{
						char text[128]; // char array buffer for the string conversion

						[password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];

						if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE)
						{
							needPassword = YES;
						}
					}
					else
					{
						needPassword = YES;
					}
				}
			}

			CGPDFDocumentRelease(thePDFDocRef); // Cleanup CGPDFDocumentRef
		}
	}
	else // Log an error diagnostic
	{
		#ifdef DEBUG
			NSLog(@"CGPDFDocumentNeedsPassword: theURL == NULL");
		#endif
	}

	return needPassword;
}

// EOF
