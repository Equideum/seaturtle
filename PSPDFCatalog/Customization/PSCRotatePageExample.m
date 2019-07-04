//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"

@interface PSCRotatePagePDFViewController : PSPDFViewController
@end

@interface PSCRotatePageExample : PSCExample
@end
@implementation PSCRotatePageExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Rotate pages permanently";
        self.contentDescription = @"Adds a button to rotate pages in 90 degree steps and saves the new orientation to the PDF.";
        self.category = PSCExampleCategoryDocumentEditing;
    }
    return self;
}

- (UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Document needs to be in a writable location because rotating changes it.
    PSPDFDocument *document = [PSCAssetLoader writableDocumentWithName:PSCAssetNameQuickStart overrideIfExists:NO];
    PSPDFViewController *pdfController = [[PSCRotatePagePDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCRotatePagePDFViewController

- (void)commonInitWithDocument:(nullable PSPDFDocument *)document configuration:(PSPDFConfiguration *_Nonnull)configuration {
    [super commonInitWithDocument:document configuration:configuration];

    UIBarButtonItem *rotatePageButton = [[UIBarButtonItem alloc] initWithTitle:@"Rotate Page" style:UIBarButtonItemStylePlain target:self action:@selector(rotatePage:)];
    self.navigationItem.rightBarButtonItems = @[self.thumbnailsButtonItem, self.searchButtonItem, rotatePageButton];
}

- (void)rotatePage:(id)sender {
    // Can't modify a pdf that is not valid.
    if (!self.document.isValid) return;

    // Rotates the current page via the document editor.
    PSPDFDocumentEditor *editor = [[PSPDFDocumentEditor alloc] initWithDocument:self.document];
    [editor rotatePages:[NSIndexSet indexSetWithIndex:self.pageIndex] rotation:90];
    [editor saveWithCompletionBlock:^(PSPDFDocument *document, NSError *error) {
        if (error) {
            NSLog(@"Error while saving: %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        }
    }];
}

@end
