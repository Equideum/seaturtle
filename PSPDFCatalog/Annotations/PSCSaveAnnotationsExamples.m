//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCEmbeddedAnnotationTestViewController : PSPDFViewController <PSPDFDocumentDelegate, PSPDFViewControllerDelegate>
@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsWriteAnnotationsIntoThePDFExample

@interface PSCAnnotationsWriteAnnotationsIntoThePDFExample : PSCExample
@end
@interface PSCAnnotationsWriteAnnotationsIntoThePDFExample () <PSPDFDocumentDelegate> {
    PSC_DEPRECATED_NOWARN(UISearchDisplayController *_searchDisplayController;)
    BOOL _firstShown;
    BOOL _clearCacheNeeded;
}
@end
@implementation PSCAnnotationsWriteAnnotationsIntoThePDFExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Write annotations into the PDF";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader writableDocumentWithName:PSCAssetNameQuickStart overrideIfExists:NO];

    return [[PSCEmbeddedAnnotationTestViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsWriteAnnotationsIntoEncryptedPDFExample

@interface PSCAnnotationsWriteAnnotationsIntoEncryptedPDFExample : PSCExample
@end
@implementation PSCAnnotationsWriteAnnotationsIntoEncryptedPDFExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Write annotations into encrypted PDF";
        self.contentDescription = @"Password is 'test123'";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 110;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader writableDocumentWithName:@"protected.pdf" overrideIfExists:NO];

    return [[PSCEmbeddedAnnotationTestViewController alloc] initWithDocument:document configuration:nil];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCAnnotationsPDFAnnotationWritingWithNSDataExample

@interface PSCAnnotationsPDFAnnotationWritingWithNSDataExample : PSCExample
@end
@implementation PSCAnnotationsPDFAnnotationWritingWithNSDataExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"PDF annotation writing with NSData";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 120;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSData *PDFData = [NSData dataWithContentsOfURL:(NSURL *)[samplesURL URLByAppendingPathComponent:PSCAssetNameJKHF]];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[[[PSPDFDataContainerProvider alloc] initWithData:PDFData]]];
    return [[PSCEmbeddedAnnotationTestViewController alloc] initWithDocument:document];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCEmbeddedAnnotationTestViewController

@implementation PSCEmbeddedAnnotationTestViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];

    self.delegate = self;
    document.delegate = self;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAnnotations)];

    self.navigationItem.leftBarButtonItems = @[saveButton];
    self.navigationItem.leftItemsSupplementBackButton = YES;

    if (PSCIsIPad()) {
        [self.navigationItem setRightBarButtonItems:@[self.thumbnailsButtonItem, self.outlineButtonItem, self.searchButtonItem, self.openInButtonItem, self.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.thumbnailsButtonItem, self.openInButtonItem, self.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// Note: This is just an example how to explicitly force saving. PSPDFKit will do this automatically on various events (app background, view dismissal).
// Further you don't have to call reloadData after saving - this is done for testing the saving (since annotations that are not saved would disappear)
// If you want immediate saving after creating annotations either hook onto PSPDFAnnotationsAddedNotification and PSPDFAnnotationChangedNotification or set saveAfterToolbarHiding to YES in PSPDFAnnotationToolbar (this will not be the same, but most of the time good enough).
- (void)saveAnnotations {
    // NSLog(@"Annotations before saving: %@", [self.document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeAll]);

    NSDictionary *dirtyAnnotations = [self.document documentProviderForPageAtIndex:0].annotationManager.dirtyAnnotations;
    NSLog(@"Dirty Annotations: %@", dirtyAnnotations);

    if (self.document.data) NSLog(@"Length of NSData before saving: %tu", self.document.data.length);

    NSError *error;
    if (![self.document saveWithOptions:nil error:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed to save annotations", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:NULL]];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        [self reloadData];
        NSLog(@"---------------------------------------------------");
        // NSLog(@"Annotations after saving: %@", [self.document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeAll]);
        //[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Saved %d annotation(s)", @""), dirtyAnnotationCount] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] show];

        if (self.document.data) NSLog(@"Length of NSData after saving: %tu", self.document.data.length);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentDelegate

- (void)pdfDocumentDidSave:(PSPDFDocument *)document {
    NSLog(@"Successfully saved document.");

    if (document.data) NSLog(@"This is your time to save the updated data!");

    NSLog(@"File: %@", document.fileURL.path);

    NSLog(@"(dirty: %d)", document.hasDirtyAnnotations);
}

- (void)pdfDocument:(PSPDFDocument *)document saveDidFailWithError:(NSError *)error {
    NSLog(@"Failed to save document: %@", error.localizedDescription);
}

@end
