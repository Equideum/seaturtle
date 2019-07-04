//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCUserInterfaceViewGapExample

@interface PSCUserInterfaceGapPDFViewController : PSPDFViewController
@end
@interface PSCUserInterfaceViewGapExample : PSCExample
@end
@implementation PSCUserInterfaceViewGapExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Leave some bottom space for the user interface";
        self.contentDescription = @"Useful if you e.g. also have a UITabBar.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 410;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCUserInterfaceGapPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end

@implementation PSCUserInterfaceGapPDFViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGRect userInterfaceFrame = self.view.bounds;
    userInterfaceFrame.size.height -= 100.0;
    self.userInterfaceView.frame = userInterfaceFrame;
}

@end
