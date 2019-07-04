//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCPrintDefaultsExample : PSCExample <PSPDFViewControllerDelegate>
@property (nonatomic) PSPDFDocument *document;
@property (nonatomic) PSPDFViewController *pdfController;
@end

@implementation PSCPrintDefaultsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom printer defaults";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 600;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    self.document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    self.pdfController = [[PSPDFViewController alloc] initWithDocument:self.document];
    self.pdfController.activityButtonItem.target = self;
    self.pdfController.activityButtonItem.action = @selector(printDocumentWithCustomOptions:);
    return self.pdfController;
}


- (void)printDocumentWithCustomOptions:(id)sender {
    PSPDFDocumentSharingConfiguration *customPrintConfiguration = [[PSPDFDocumentSharingConfiguration defaultConfigurationForDestination:PSPDFDocumentSharingDestinationPrint] configurationUpdatedWithBuilder:^(PSPDFDocumentSharingConfigurationBuilder * builder) {
        builder.pageSelectionOptions = PSPDFDocumentSharingPagesOptionCurrent;
        builder.annotationOptions = PSPDFDocumentSharingAnnotationOptionSummary;
    }];
    
    PSPDFDocumentSharingViewController *sharingViewController = [[PSPDFDocumentSharingViewController alloc] initWithDocuments:@[self.document]];
    sharingViewController.sharingConfigurations = @[customPrintConfiguration];
    sharingViewController.visiblePagesDataSource = self.pdfController;
    [sharingViewController presentFromViewController:self.pdfController sender:sender];
}

@end
