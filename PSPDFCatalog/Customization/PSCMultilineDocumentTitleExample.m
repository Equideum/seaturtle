//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCMultilineDocumentTitleExample : PSCExample
@end
@implementation PSCMultilineDocumentTitleExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Multiline document title";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.title = @"This PDF document has a pretty long title. It should wrap into multiple lines on an iPhone.";

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        // If you're expecting long titles and want make sure as much of it as possible is shown,
        // you should set `documentLabelEnabled` to `PSPDFAdaptiveConditionalYES` explicity.
        builder.documentLabelEnabled = PSPDFAdaptiveConditionalYES;
    }]];

    // The standard numberOfLines conventions apply here (0 = use as many lines as needed)
    pdfController.userInterfaceView.documentLabel.label.numberOfLines = 0;

    return pdfController;
}

@end
