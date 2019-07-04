//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'ScientificPaperExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCScientificPaperExample : PSCExample
@end
@implementation PSCScientificPaperExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Settings for a scientific paper";
        self.contentDescription = @"Automatic text link detection, continuous scrolling, default style.";
        self.category = PSCExampleCategoryTop;
        self.priority = 8;
        self.wantsModalPresentation = YES;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.autodetectTextLinkTypes = PSPDFTextCheckingTypeAll;

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.pageTransition = PSPDFPageTransitionScrollContinuous;
        builder.scrollDirection = PSPDFScrollDirectionVertical;
        builder.renderAnimationEnabled = NO;
        builder.shouldHideNavigationBarWithUserInterface = NO;
        builder.shouldHideStatusBarWithUserInterface = NO;
    }]];

    PSPDFDocumentViewLayout *layout = controller.documentViewController.layout;
    if ([layout isKindOfClass:PSPDFContinuousScrollingLayout.class]) {
        ((PSPDFContinuousScrollingLayout *)layout).fillAlongsideTransverseAxis = YES;
    }

    [controller.navigationItem setRightBarButtonItems:@[controller.thumbnailsButtonItem, controller.searchButtonItem, controller.outlineButtonItem, controller.activityButtonItem, controller.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];

    return controller;
}

@end
