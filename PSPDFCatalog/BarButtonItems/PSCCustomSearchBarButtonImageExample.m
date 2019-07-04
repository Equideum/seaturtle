//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomSearchBarButtonImageExample : PSCExample
@end

@implementation PSCCustomSearchBarButtonImageExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Change the search button image";
        self.contentDescription = @"Replaces the search button with a custom view.";
        self.category = PSCExampleCategoryBarButtons;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

    UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 32.0)];
    customView.showsTouchWhenHighlighted = YES;
    customView.backgroundColor = UIColor.redColor;

    // Hook up target/action from the original search button item to our custom one.
    UIBarButtonItem *searchButtonItem = pdfController.searchButtonItem;

    // We cast nullability away since we can trust PSPDFKit to populate UIBarButtonItem correctly.
    // Important! The logic will find and recognize this button as the "search" button as long as you hook target/action the same way as it's on the provided searchButton.
    [customView addTarget:searchButtonItem.target action:(SEL)searchButtonItem.action forControlEvents:UIControlEventTouchUpInside];

    // Create the custom bar button item.
    UIBarButtonItem *customSearchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    // Be a nice citizen and set localization
    customSearchButtonItem.accessibilityLabel = PSPDFLocalize(@"Search");

    // Seat all button items as default except the search button item which we replace with our custom one.
    [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.activityButtonItem, pdfController.outlineButtonItem, customSearchButtonItem, pdfController.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];

    return pdfController;
}

@end
