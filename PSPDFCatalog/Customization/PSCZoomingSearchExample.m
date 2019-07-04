//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCZoomingSearchPDFViewController : PSPDFViewController
@property (nonatomic, getter=isInitialSearchAlreadyPerformed) BOOL initialSearchAlreadyPerformed;
@end

@interface PSCZoomingSearchExample : PSCExample
@end

@implementation PSCZoomingSearchExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Zooming Inline Search Results";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSCZoomingSearchPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.searchMode = PSPDFSearchModeInline;
    }]];
    return pdfController;
}

@end

@implementation PSCZoomingSearchPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Automatically start searching for the first time this view is displayed.
    // This is just for convenience
    if (!self.isInitialSearchAlreadyPerformed) {
        [self searchForString:@"Report" options:nil sender:nil animated:YES];
        self.initialSearchAlreadyPerformed = YES;
    }
}

@end
