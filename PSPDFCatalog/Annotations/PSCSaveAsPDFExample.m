//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

/// This class will ask the user as soon as the first annotation has been added/modified
/// where the annotation should be saved, and optionally copies the file to a new location.
@interface PSCSaveAsPDFViewController : PSPDFViewController
@property (nonatomic) BOOL hasUserBeenAskedAboutSaveLocation;
@end

@interface PSCAnnotationsSaveAsForAnnotationEditingExample : PSCExample
@end
@implementation PSCAnnotationsSaveAsForAnnotationEditingExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Save as... for annotation editing";
        self.contentDescription = @"Adds an alert after detecting annotation writes to define a new save location.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *documentURL = [samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF];
    NSURL *writableDocumentURL = PSCCopyFileURLToDocumentFolderAndOverride(documentURL, NO);
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:writableDocumentURL];
    return [[PSCSaveAsPDFViewController alloc] initWithDocument:document];
}

@end

@implementation PSCSaveAsPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];

    self.navigationItem.rightBarButtonItems = @[self.thumbnailsButtonItem, self.annotationButtonItem];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[PSPDFKit imageNamed:@"x"] style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonPressed:)];
    self.navigationItem.leftBarButtonItems = @[closeButton];

    // PSPDFViewController will unregister all notifications on dealloc.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationChangedNotification:) name:PSPDFAnnotationChangedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationAddedOrRemovedNotification:) name:PSPDFAnnotationsAddedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(annotationAddedOrRemovedNotification:) name:PSPDFAnnotationsRemovedNotification object:nil];
}

- (void)dealloc {
    // Clear document cache, so we don't get annotation-artefacts when loading the doc again.
    [PSPDFKit.sharedInstance.cache removeCacheForDocument:self.document];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)closeButtonPressed:(id)sender {
    self.annotationStateManager.state = nil; // Commit any annotations.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)annotationChangedNotification:(NSNotification *)notification {
    [self processChangeForAnnotation:notification.object];
}

- (void)annotationAddedOrRemovedNotification:(NSNotification *)notification {
    for (PSPDFAnnotation *annotation in notification.object) {
        [self processChangeForAnnotation:annotation];
    }
}

- (void)processChangeForAnnotation:(PSPDFAnnotation *)annotation {
    if (annotation.document == self.document) {
        // The notification might not be on main thread.
        if (NSThread.isMainThread) {
            [self askUserAboutSaveLocationIfNeeded];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self askUserAboutSaveLocationIfNeeded];
            });
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Document Copying Logic

// This code assumes that the PDF location itself is writeable, and will fail for documents in the bundle folder.
- (void)askUserAboutSaveLocationIfNeeded {
    // Make sure the alert gets displayed only once per session
    if (self.hasUserBeenAskedAboutSaveLocation) return;
    self.hasUserBeenAskedAboutSaveLocation = YES;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Would you like to save annotations into the current file, or create a copy to save the annotation changes?", @"") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save to this file" style:UIAlertActionStyleDestructive handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save as Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                         [self replaceDocumentWithCopy];
                     }]];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)replaceDocumentWithCopy {
    // Build new URL, tests for a filename that doesn't yet exist.
    NSUInteger appendFileCount = 0;
    NSURL *documentURL = self.document.fileURL;
    if (!documentURL) return;

    NSString *newPath;
    do {
        newPath = documentURL.path;
        NSString *appendSuffix = [NSString stringWithFormat:@"_annotated%@.pdf", appendFileCount == 0 ? @"" : @(appendFileCount)];
        if ([newPath.lowercaseString hasSuffix:@".pdf"]) {
            newPath = [newPath stringByReplacingOccurrencesOfString:@".pdf" withString:appendSuffix options:NSCaseInsensitiveSearch range:NSMakeRange(newPath.length - 4, 4)];
        } else {
            newPath = [newPath stringByAppendingString:appendSuffix];
        }
        appendFileCount++;
    } while ([NSFileManager.defaultManager fileExistsAtPath:newPath]);
    NSURL *newURL = [NSURL fileURLWithPath:newPath];

    NSError *error;
    if (![NSFileManager.defaultManager copyItemAtURL:documentURL toURL:newURL error:&error]) {
        NSLog(@"Failed to copy file to %@: %@", newURL.path, error.localizedDescription);
    } else {
        // Since the annotation has already been edited, we copy the file *before* it will be saved
        // then save the current state and switch out the documents.
        if (![self.document saveWithOptions:nil error:&error]) {
            NSLog(@"Failed to save document: %@", error.localizedDescription);
        }
        NSURL *tmpURL = [newURL URLByAppendingPathExtension:@"temp"];
        if (![NSFileManager.defaultManager moveItemAtURL:documentURL toURL:tmpURL error:&error]) {
            NSLog(@"Failed to move file: %@", error.localizedDescription);
            return;
        }
        if (![NSFileManager.defaultManager moveItemAtURL:newURL toURL:documentURL error:&error]) {
            NSLog(@"Failed to move file: %@", error.localizedDescription);
            return;
        }
        if (![NSFileManager.defaultManager moveItemAtURL:tmpURL toURL:newURL error:&error]) {
            NSLog(@"Failed to move file: %@", error.localizedDescription);
            return;
        }
        // Finally update the fileURL, this will clear the current document cache.
        PSPDFDocument *newDocument = [[PSPDFDocument alloc] initWithURL:newURL];
        newDocument.title = self.document.title; // preserve title.

        // Preserve annotation selection
        PSPDFPageView *pageView = [self pageViewForPageAtIndex:self.pageIndex];
        NSArray *selectedAnnotations = pageView.selectedAnnotations;

        self.document = newDocument;

        // Restore selection
        pageView = [self pageViewForPageAtIndex:self.pageIndex];
        NSMutableArray *newSelectedAnnotations = [NSMutableArray array];
        for (PSPDFAnnotation *annotation in [newDocument annotationsForPageAtIndex:self.pageIndex type:PSPDFAnnotationTypeAll]) {
            for (PSPDFAnnotation *selectedAnnotation in selectedAnnotations) {
                if ([annotation.name isEqual:selectedAnnotation.name]) {
                    [newSelectedAnnotations addObject:annotation];
                }
            }
        }
        pageView.selectedAnnotations = newSelectedAnnotations;

        // To re-show the popover, we need to wait until the alert view disappears.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self pageViewForPageAtIndex:self.pageIndex] showMenuIfSelectedAnimated:NO allowPopovers:YES];
        });
    }
}

@end
