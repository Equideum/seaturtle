//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCRemoveInkFromToolbarExample : PSCExample
@end
@implementation PSCRemoveInkFromToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Remove Ink from the annotation toolbar";
        self.category = PSCExampleCategoryBarButtons;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.navigationItem.rightBarButtonItems = @[pdfController.annotationButtonItem];
    NSMutableSet *editableTypes = [pdfController.configuration.editableAnnotationTypes mutableCopy];
    [editableTypes removeObject:PSPDFAnnotationStringInk];
    pdfController.annotationToolbarController.annotationToolbar.editableAnnotationTypes = editableTypes;
    return pdfController;
}

@end
