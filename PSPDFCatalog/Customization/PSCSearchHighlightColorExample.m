//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomColoredSearchHighlightPDFViewController : PSPDFViewController
@end

@interface PSCSearchHighlightColorExample : PSCExample
@end
@implementation PSCSearchHighlightColorExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Search Highlight Color";
        self.contentDescription = @"Changes the search highlight color to blue via UIAppearance.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 50;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    // We use a custom subclass of the PSPDFViewController here, to not pollute other examples, since UIAppearance can't be re-set to the default.
    [PSPDFSearchHighlightView appearanceWhenContainedInInstancesOfClasses:@[PSCCustomColoredSearchHighlightPDFViewController.class]].selectionBackgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.5];

    PSPDFViewController *pdfController = [[PSCCustomColoredSearchHighlightPDFViewController alloc] initWithDocument:document];

    // We're lazy - automatically start search.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pdfController searchForString:@"Tom" options:nil sender:nil animated:YES];
    });

    return pdfController;
}

@end

@implementation PSCCustomColoredSearchHighlightPDFViewController
@end
