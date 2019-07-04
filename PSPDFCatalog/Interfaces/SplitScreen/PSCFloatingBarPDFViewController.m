//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCFloatingBarPDFViewController.h"
#import "UIImage+PSCTinting.h"

static const CGFloat PSCToolbarMargin = 20.0;

@interface UIImage (PSCatalogAdditions)
- (UIImage *)psc_imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
@end

@interface PSCFloatingBarPDFViewController () <PSPDFViewControllerDelegate>
@end

@implementation PSCFloatingBarPDFViewController

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.pageTransition = PSPDFPageTransitionScrollContinuous;
        builder.scrollDirection = PSPDFScrollDirectionVertical;
        builder.renderAnimationEnabled = NO;
        builder.thumbnailBarMode = PSPDFThumbnailBarModeNone;
        builder.backgroundColor = [UIColor colorWithRed:0.918 green:0.918 blue:0.945 alpha:1.];
        builder.shouldHideNavigationBarWithUserInterface = YES;
        builder.useParentNavigationBar = YES;
        builder.documentLabelEnabled = PSPDFAdaptiveConditionalNO;
    }];
    [super commonInitWithDocument:document configuration:configuration];

    self.title = document.title;
    self.thumbnailController.filterOptions = nil;
    self.documentInfoCoordinator.availableControllerOptions = @[PSPDFDocumentInfoOptionOutline];
    self.navigationItem.rightBarButtonItems = @[self.activityButtonItem, self.annotationButtonItem];
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add the floating toolbar to the user interface.
    PSCFloatingToolbar *floatingToolbar = [[PSCFloatingToolbar alloc] initWithFrame:CGRectMake(PSCToolbarMargin, PSCToolbarMargin, 0.0, 0.0)];
    self.floatingToolbar = floatingToolbar;
    [self updateFloatingToolbarAnimated:NO]; // will update size.
    [self.userInterfaceView addSubview:floatingToolbar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.floatingToolbar.frame;
    // Keep the fixed position, even if the status bar gets hidden
    CGFloat statusBarHeight = 20.0;
    frame.origin.y = PSCToolbarMargin + self.navigationController.navigationBar.frame.size.height + statusBarHeight;
    self.floatingToolbar.frame = frame;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (void)setDocument:(PSPDFDocument *)document {
    super.document = document;
    [self updateFloatingToolbarAnimated:self.isViewLoaded];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)updateFloatingToolbarAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        BOOL showToolbar = self.document.isValid && self.viewMode == PSPDFViewModeDocument;
        self.floatingToolbar.alpha = showToolbar ? 0.8 : 0.0;
    }];

    NSMutableArray *floatingToolbarButtons = [NSMutableArray array];

    UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thumbnailButton.accessibilityLabel = PSPDFLocalize(@"Thumbnails");
    [thumbnailButton setImage:[[PSPDFKit imageNamed:@"thumbnails"] psc_imageTintedWithColor:UIColor.whiteColor fraction:0.] forState:UIControlStateNormal];
    [thumbnailButton addTarget:self action:@selector(thumbnailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [floatingToolbarButtons addObject:thumbnailButton];

    if (self.document.documentProviders.firstObject.outlineParser.isOutlineAvailable) {
        UIButton *outlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        outlineButton.accessibilityLabel = PSPDFLocalize(@"Outline");
        [outlineButton setImage:[[PSPDFKit imageNamed:@"outline"] psc_imageTintedWithColor:UIColor.whiteColor fraction:0.] forState:UIControlStateNormal];
        [outlineButton addTarget:self action:@selector(outlineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [floatingToolbarButtons addObject:outlineButton];
    }

    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.accessibilityLabel = PSPDFLocalize(@"Search");
    [searchButton setImage:[[PSPDFKit imageNamed:@"search"] psc_imageTintedWithColor:UIColor.whiteColor fraction:0.] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [floatingToolbarButtons addObject:searchButton];

    self.floatingToolbar.buttons = floatingToolbarButtons;
}

- (void)thumbnailButtonPressed:(UIButton *)sender {
    if (self.viewMode == PSPDFViewModeDocument) {
        [self setViewMode:PSPDFViewModeThumbnails animated:YES];
    } else {
        [self setViewMode:PSPDFViewModeDocument animated:YES];
    }
}

- (void)outlineButtonPressed:(UIButton *)sender {
    PSPDFOutlineViewController *outlineController = [[PSPDFOutlineViewController alloc] initWithDocument:self.document];
    outlineController.modalPresentationStyle = UIModalPresentationPopover;

    [self presentViewController:outlineController options:@{ PSPDFPresentationCloseButtonKey: @YES, PSPDFPresentationPopoverArrowDirectionsKey: @(UIPopoverArrowDirectionUp) } animated:YES sender:sender completion:NULL];
}

- (void)searchButtonPressed:(UIButton *)sender {
    [self searchForString:nil options:0 sender:sender animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeViewMode:(PSPDFViewMode)viewMode {
    [self updateFloatingToolbarAnimated:YES];
}

- (void)pdfViewController:(PSPDFViewController *)pdfController willBeginDisplayingPageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    NSLog(@"willShowPageView: page:%tu", pageView.pageIndex);
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didFinishRenderTaskForPageView:(PSPDFPageView *)pageView {
    NSLog(@"didFinishRenderTaskForPageView: page:%tu", pageView.pageIndex);
}

@end
