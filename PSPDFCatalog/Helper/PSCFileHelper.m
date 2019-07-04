//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCFileHelper.h"

NSURL *PSCTempFileURLWithPathExtension(NSString * _Nullable prefix, NSString *pathExtension) {
    if (pathExtension && ![pathExtension hasPrefix:@"."]) pathExtension = [NSString stringWithFormat:@".%@", pathExtension];
    if (!pathExtension) pathExtension = @"";

    NSString *UDIDString = NSUUID.UUID.UUIDString;
    if (prefix) {
        UDIDString = [NSString stringWithFormat:@"_%@", UDIDString];
    }

    NSURL *tempURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@", prefix ?: @"", UDIDString, pathExtension] isDirectory:NO];
    return tempURL;
}

static NSURL *PSCInstallFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override, BOOL copy) {
    NSCAssert([documentURL isKindOfClass:NSURL.class], @"documentURL must be of type NSURL");

    // copy file from the bundle to a location where we can write on it.
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *newPath = [docsFolder stringByAppendingPathComponent:(NSString *)documentURL.lastPathComponent];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    const BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:newPath];
    if (override) {
        [NSFileManager.defaultManager removeItemAtURL:newURL error:NULL];
    }

    NSError *error;
    if (!exists || override) {
        if (copy && ![NSFileManager.defaultManager copyItemAtURL:documentURL toURL:newURL error:&error]) {
            NSLog(@"Error while copying %@: %@", documentURL.path, error.localizedDescription);
        } else if (![NSFileManager.defaultManager moveItemAtURL:documentURL toURL:newURL error:&error]) {
            NSLog(@"Error while moving %@: %@", documentURL.path, error.localizedDescription);
        }
    }

    return newURL;
}

NSURL *PSCMoveFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override) {
    return PSCInstallFileURLToDocumentFolderAndOverride(documentURL, override, NO);
}

NSURL *PSCCopyFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override) {
    return PSCInstallFileURLToDocumentFolderAndOverride(documentURL, override, YES);
}

BOOL PSCIsFileLocatedInInbox(NSURL *documentURL) {
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *inboxPath = [docsFolder stringByAppendingPathComponent:@"Inbox"];
    // We need to resolve symlinks using `URLByResolvingSymlinksInPath` to strip the private designator in the start of the URL.
    return [documentURL.URLByResolvingSymlinksInPath.path hasPrefix:inboxPath];
}
