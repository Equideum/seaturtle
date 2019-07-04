//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface SharingViewController : PSPDFDocumentSharingViewController
@end

@implementation SharingViewController

- (void)configureMailComposeViewController:(MFMailComposeViewController *)mailComposeViewController {
    [mailComposeViewController setMessageBody:@"<h1 style='color:blue'>Custom message body.</h1>" isHTML:YES];
}

@end

@interface PSCPredefinedEmailBodyExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCPredefinedEmailBodyExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Customize email sending (add body text)";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 500;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];

    PSPDFConfiguration *configuration = [PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder * builder) {
        [builder overrideClass:PSPDFDocumentSharingViewController.class withClass:SharingViewController.class];
    }];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:configuration];
    pdfController.navigationItem.rightBarButtonItems = @[pdfController.emailButtonItem];
    pdfController.delegate = self;

    return pdfController;
}

@end
