//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCRequestSigningExample : PSCExample
@end
@implementation PSCRequestSigningExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Open and immediately request signing";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 60;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.signatureSavingStrategy = PSPDFSignatureSavingStrategyAlwaysSave;
    }]];

    // Delay the presentation of the controller until after the present animation is finished.
    double const delayInSeconds = 0.3;
    dispatch_time_t const popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        PSPDFPageView *pageView = pdfController.visiblePageViews.firstObject;
        [pageView showSignatureControllerAtRect:CGRectNull withTitle:PSPDFLocalize(@"Add Signature") signatureFormElement:nil options:nil animated:YES];
    });
    return pdfController;
}

@end
