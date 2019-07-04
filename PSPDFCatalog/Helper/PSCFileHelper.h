//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "NSURL+PSCSampleLoading.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Creates a temp URL.
FOUNDATION_EXTERN NSURL *PSCTempFileURLWithPathExtension(NSString *_Nullable prefix, NSString *pathExtension);

/// Copies a file to the documents directory.
FOUNDATION_EXTERN NSURL *PSCCopyFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override);

/// Moves a file to the documents directory.
FOUNDATION_EXTERN NSURL *PSCMoveFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override);

/// Detects if the file is located in the app's Documents/Inbox directory.
FOUNDATION_EXTERN BOOL PSCIsFileLocatedInInbox(NSURL *documentURL);

NS_ASSUME_NONNULL_END
