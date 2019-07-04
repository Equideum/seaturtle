//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCUseParentNavigationBarChildViewControllerContainmentExample : PSCExample
@end
@implementation PSCUseParentNavigationBarChildViewControllerContainmentExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Child View Controller containment, useParentNavigationBar";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 33;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.useParentNavigationBar = YES;
    }]];

    // Show only the view mode button on the right side
    pdfController.navigationItem.rightBarButtonItems = @[pdfController.thumbnailsButtonItem];

    // Create simple view controller container.
    UIViewController *viewController = [UIViewController new];

    [viewController addChildViewController:pdfController];
    [viewController.view addSubview:pdfController.view];
    pdfController.view.frame = viewController.view.bounds;
    [pdfController didMoveToParentViewController:viewController];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];

    return navigationController;
}

@end
