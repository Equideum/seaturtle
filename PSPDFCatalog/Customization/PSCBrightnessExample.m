//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCBrightnessExample : PSCExample
@end

@implementation PSCBrightnessExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Appearance and Brightness";
        self.contentDescription = @"Use PSPDFBrightnessViewController to customize page colors, brightness or enable night mode.";
        self.category = PSCExampleCategoryTop;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Set up the document.
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameWeb];
    // Set up the controller.
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    // Add brightnessButtonItem and some other default button items.
    [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.brightnessButtonItem, pdfController.outlineButtonItem, pdfController.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return pdfController;
}

@end
