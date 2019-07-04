//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'CaseStudyExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCaseStudeExample : PSCExample
@end
@implementation PSCCaseStudeExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Case Study from Box";
        self.contentDescription = @"Includes a RichMedia inline video.";
        self.category = PSCExampleCategoryTop;
        self.priority = 4;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameCaseStudyBox];

    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.thumbnailBarMode = PSPDFThumbnailBarModeNone;
        builder.shouldShowUserInterfaceOnViewWillAppear = NO;
        builder.pageLabelEnabled = NO;
    }]];
    
    controller.navigationItem.rightBarButtonItems = @[controller.activityButtonItem, controller.searchButtonItem, controller.annotationButtonItem];
    return controller;
}

@end
