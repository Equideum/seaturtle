//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCMultimediaPDFExample

@interface PSCMultimediaPDFExample : PSCExample
@end
@implementation PSCMultimediaPDFExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multimedia PDF example";
        self.contentDescription = @"Load PDF with various multimedia additions and an embedded video.";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"multimedia.pdf"];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.openInButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return pdfController;
}

@end
