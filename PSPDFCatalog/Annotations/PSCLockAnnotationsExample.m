//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import "PSPDFInkAnnotation+PSCSamples.h"

@interface PSCLockAnnotationsExample : PSCExample
@end

@implementation PSCLockAnnotationsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Generate a new file with locked annotations";
        self.contentDescription = @"Uses the annotation flags to create a locked copy.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 1000;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // We use the same URL as in the "Write annotations into the PDF" example.

    // Original URL for the example file.
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *annotationSavingURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];

    // Document-based URL (we use the changed file from "writing annotations into a file" for additional test annotations)
    NSURL *documentSamplesURL = PSCCopyFileURLToDocumentFolderAndOverride(annotationSavingURL, NO);

    // Target temp directory and copy file.
    NSURL *tempURL = PSCTempFileURLWithPathExtension([NSString stringWithFormat:@"locked_%@", documentSamplesURL.lastPathComponent], @"pdf");
    if ([NSFileManager.defaultManager fileExistsAtPath:(NSString *)documentSamplesURL.path]) {
        [NSFileManager.defaultManager copyItemAtURL:documentSamplesURL toURL:tempURL error:NULL];
    } else {
        [NSFileManager.defaultManager copyItemAtURL:annotationSavingURL toURL:tempURL error:NULL];
    }

    // Open the new file and modify the annotations to be locked.
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:tempURL];
    document.annotationSaveMode = PSPDFAnnotationSaveModeEmbedded;

    // Create at least one annotation if the document is currently empty.
    if ([document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeAll & ~PSPDFAnnotationTypeLink].count == 0) {
        PSPDFInkAnnotation *ink = [PSPDFInkAnnotation psc_sampleInkAnnotationInRect:CGRectMake(100.0, 100.0, 200.0, 200.0)];
        ink.color = [UIColor colorWithRed:0.667 green:0.279 blue:0.748 alpha:1.];
        ink.pageIndex = 0;
        [document addAnnotations:@[ink] options:nil];
    }

    // Lock all annotations except links and forms/widgets.
    for (NSUInteger pageIndex = 0; pageIndex < document.pageCount; pageIndex++) {
        NSArray<PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:pageIndex type:PSPDFAnnotationTypeAll & ~(PSPDFAnnotationTypeLink | PSPDFAnnotationTypeWidget)];
        for (PSPDFAnnotation *annotation in annotations) {
            // Preserve existing flags, just set locked + read only.
            annotation.flags |= PSPDFAnnotationFlagLocked;
        }
    }

    [document saveWithOptions:nil error:nil];

    NSLog(@"Locked file: %@", tempURL.path);

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end
