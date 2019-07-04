//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

/// Simple example that adds a UIButton on a PSPDFPageView.
@interface PSCButtonPDFViewController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSAddingButtonExample : PSCExample
@end
@implementation PSAddingButtonExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Adding a simple UIButton";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 40;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSCButtonPDFViewController alloc] initWithDocument:document];
}

@end

// Container to add a UIButton always centered at the page.
@interface PSCButtonContainerView : UIView <PSPDFAnnotationPresenting>
@property (nonatomic) UIButton *button;
@end

@implementation PSCButtonPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithDocument:(PSPDFDocument *)document {
    if ((self = [super initWithDocument:document])) {
        // register for the delegate.
        self.delegate = self;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didConfigurePageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    // Add a custom button at pageView on page 0.
    // PSPDFKit will re-use PSPDFPageView but will also clear all "foreign" added views - you don't have to remove it yourself.
    // `pdfViewController:didConfigurePageView:forPageAtIndex:` will be called once, while the pageView is processed for the new page, so it's the perfect time to add custom views.
    if (pageView.pageIndex == 0) {
        PSCButtonContainerView *buttonContainer = [[PSCButtonContainerView alloc] initWithFrame:CGRectZero];
        [buttonContainer.button setTitle:@"Press me!" forState:UIControlStateNormal];
        [buttonContainer.button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        buttonContainer.button.tintColor = UIColor.whiteColor;
        buttonContainer.button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        buttonContainer.button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        buttonContainer.button.layer.cornerRadius = 3.0;
        [buttonContainer sizeToFit];
        [pageView.annotationContainerView addSubview:buttonContainer];
        [buttonContainer didChangePageBounds:pageView.bounds]; // layout initially
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)buttonPressed:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"Button pressed on page %tu.", self.pageIndex + 1] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}

@end

@implementation PSCButtonContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self addSubview:self.button];
    }
    return self;
}

- (void)sizeToFit {
    [self.button sizeToFit];
    self.frame = self.button.bounds;
}

// called initially and on rotation change
- (void)didChangePageBounds:(CGRect)bounds {
    self.center = self.superview.center;
    self.frame = CGRectIntegral(self.frame);
}

@end
