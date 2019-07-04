//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCScrubberBarWithButtonsExample : PSCExample
@end
@implementation PSCScrubberBarWithButtonsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Scrubber Bar with buttons";
        self.contentDescription = @"Adds UIBarButtonItems to the scrubber bar";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 401;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

    // Add buttons to the scrubber toolbar
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(leftButtonPressed:)];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonPressed:)];
    UIBarButtonItem *spacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    pdfController.userInterfaceView.scrubberBar.toolbar.items = @[leftBarButtonItem, spacingItem, rightBarButtonItem];

    // Set the margin
    const CGFloat margin = 50.0;
    pdfController.userInterfaceView.scrubberBar.leftBorderMargin = margin;
    pdfController.userInterfaceView.scrubberBar.rightBorderMargin = margin;

    return pdfController;
}

- (void)leftButtonPressed:(id)sender {
    NSLog(@"Left button pressed.");
}

- (void)rightButtonPressed:(id)sender {
    NSLog(@"Right button pressed.");
}

@end
