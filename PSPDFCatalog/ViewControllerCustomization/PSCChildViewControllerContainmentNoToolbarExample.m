//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCChildViewControllerContainmentNoToolbarExample : PSCExample
@end
@implementation PSCChildViewControllerContainmentNoToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Child View Controller containment, no toolbar";
        self.contentDescription = @"Will be dismissed automatically after 5 seconds";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 32;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    // Manually configure the top lable distance.
    // pdfController.userInterfaceView.documentLabelDistance = 80.0;

    // Create simple view controller container.
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController addChildViewController:pdfController];
    [viewController.view addSubview:pdfController.view];
    pdfController.view.frame = viewController.view.bounds;
    [pdfController didMoveToParentViewController:viewController];
    [delegate.currentViewController.navigationController presentViewController:viewController animated:YES completion:NULL];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [viewController dismissViewControllerAnimated:YES completion:NULL];
    });
    return nil;
}

@end
