//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import "PSCMergeDocumentsViewController.h"

@interface PSCMergeDocumentsExample : PSCExample
@end
@implementation PSCMergeDocumentsExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Merge Annotations Interface";
        self.contentDescription = @"Proof-of-concept interface that shows two documents and allows copying and merging annotations.";
        self.category = PSCExampleCategoryAnnotations;
        self.targetDevice = PSCExampleTargetDeviceMaskPad;
        self.priority = 500;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *jkhfPDFURL = [samplesURL URLByAppendingPathComponent:@"A.pdf"];
    NSURL *paperPDFURL = [samplesURL URLByAppendingPathComponent:@"B.pdf"];

    NSURL *originalPDF = PSCCopyFileURLToDocumentFolderAndOverride(jkhfPDFURL, NO);
    [NSFileManager.defaultManager copyItemAtURL:jkhfPDFURL toURL:originalPDF error:NULL];

    NSURL *revisedPDF = PSCCopyFileURLToDocumentFolderAndOverride(paperPDFURL, NO);
    [NSFileManager.defaultManager copyItemAtURL:paperPDFURL toURL:revisedPDF error:NULL];

    PSPDFDocument *document1 = [[PSPDFDocument alloc] initWithURL:revisedPDF];
    PSPDFDocument *document2 = [[PSPDFDocument alloc] initWithURL:originalPDF];

    UIViewController *mergeController = [[PSCMergeDocumentsViewController alloc] initWithLeftDocument:document1 rightDocument:document2];
    return mergeController;
}

@end
