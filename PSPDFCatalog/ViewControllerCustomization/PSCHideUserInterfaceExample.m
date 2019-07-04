//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCHideUserInterfaceForThumbnailsViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCHideUserInterfaceExample : PSCExample
@end
@implementation PSCHideUserInterfaceExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Hide user interface while showing thumbnails";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 20;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCHideUserInterfaceForThumbnailsViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCHideUserInterfaceForThumbnailsViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    [super commonInitWithDocument:document configuration:configuration];
    self.delegate = self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeViewMode:(PSPDFViewMode)viewMode {
    // Hide when we enter thumbnail view, show again when we are in document mode.
    [self setUserInterfaceVisible:viewMode == PSPDFViewModeDocument animated:YES];
}

@end
