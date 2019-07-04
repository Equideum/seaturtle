//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "CustomPDFViewController.h"

@implementation CustomPDFViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSURL *documentURL = [NSBundle.mainBundle.bundleURL URLByAppendingPathComponent:@"Samples/PSPDFKit 8 QuickStart Guide.pdf"];

        // We copy the document into a writable location.
        // This is not necessary, but will enable the Document Editor feature - as this requires the PDF to be writable.
        NSURL *writableURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, NO);
        PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableURL];
        self.document = document;

        [self updateConfigurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
            builder.maximumZoomScale = 20.f;
        }];
    }
    return self;
}

NSURL *PSCCopyFileURLToDocumentFolderAndOverride(NSURL *documentURL, BOOL override) {
    NSCAssert([documentURL isKindOfClass:NSURL.class], @"documentURL must be of type NSURL");

    // copy file from the bundle to a location where we can write on it.
    NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *newPath = [docsFolder stringByAppendingPathComponent:(NSString *)documentURL.lastPathComponent];
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    const BOOL needsCopy = ![NSFileManager.defaultManager fileExistsAtPath:newPath];
    if (override) {
        [NSFileManager.defaultManager removeItemAtURL:newURL error:NULL];
    }

    NSError *error;
    if ((needsCopy || override) && ![NSFileManager.defaultManager copyItemAtURL:documentURL toURL:newURL error:&error]) {
        NSLog(@"Error while copying %@: %@", documentURL.path, error.localizedDescription);
    }

    return newURL;
}

@end
