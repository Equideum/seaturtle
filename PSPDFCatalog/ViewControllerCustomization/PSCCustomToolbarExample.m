//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "UINavigationItem+PSCFiltering.h"
#import <tgmath.h>

/// Example to show how to add a custom toolbar.
@interface PSCToolbarController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCCustomToolbarExample : PSCExample
@end
@implementation PSCCustomToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Customized Toolbar";
        self.contentDescription = @"Uses a textual switch button for thumbnails/content.";
        self.category = PSCExampleCategoryBarButtons;
        self.priority = 70;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSCToolbarController alloc] initWithDocument:document];
}

@end

@interface PSCToolbarController ()
@property (nonatomic) UISegmentedControl *customViewModeSegment;
@property (nonatomic) UIBarButtonItem *viewModeButton;
@property (nonatomic) CGSize *originalThumbnailSize;
@end

@implementation PSCToolbarController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (void)commonInitWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    configuration = [configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.renderAnimationEnabled = NO; // custom implementation here
        builder.thumbnailSize = PSCIsIPad() ? CGSizeMake(235.0, 305.0) : CGSizeMake(200.0, 250.0);
    }];
    [super commonInitWithDocument:document configuration:configuration];

    // Create custom controls to our toolbar
    UISegmentedControl *customViewModeSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Page", @""), NSLocalizedString(@"Thumbnails", @"")]];
    customViewModeSegment.selectedSegmentIndex = 0;
    [customViewModeSegment addTarget:self action:@selector(viewModeSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [customViewModeSegment sizeToFit];
    _customViewModeSegment = customViewModeSegment;

    UIBarButtonItem *viewModeButton = [[UIBarButtonItem alloc] initWithCustomView:_customViewModeSegment];
    _viewModeButton = viewModeButton;

    __weak typeof(self) weakSelf = self;
    [self setUpdateSettingsForBoundsChangeBlock:^(PSPDFViewController *pdfController) {
        __strong typeof(self) strongSelf = weakSelf;
        // The available space for our button items might have changed. We should adjust for that.
        [strongSelf updateBarButtonItems];
    }];

    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBarButtonItems];
}

- (void)dealloc {
    self.delegate = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons

- (void)updateBarButtonItems {
    NSArray<UIBarButtonItem *> *allItems = @[self.viewModeButton, self.printButtonItem, self.searchButtonItem, self.emailButtonItem, self.annotationButtonItem];
    NSArray<UIBarButtonItem *> *filteredItems = [UINavigationItem psc_filteredItems:allItems forNavigationBar:self.navigationController.navigationBar];

    // We use a customized navigation item method to set the buttons for a single view mode.
    // The standard `setRightBarButtonItems:` is also available.
    [self.navigationItem setRightBarButtonItems:filteredItems forViewMode:PSPDFViewModeDocument animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)viewModeSegmentChanged:(id)sender {
    UISegmentedControl *viewMode = (UISegmentedControl *)sender;
    NSUInteger selectedSegment = viewMode.selectedSegmentIndex;
    [self setViewMode:selectedSegment == 0 ? PSPDFViewModeDocument : PSPDFViewModeThumbnails animated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

// simple example how to re-color the link annotations
- (void)pdfViewController:(PSPDFViewController *)pdfController willShowAnnotationView:(UIView<PSPDFAnnotationPresenting> *)annotationView onPageView:(PSPDFPageView *)pageView {
    if ([annotationView isKindOfClass:[PSPDFLinkAnnotationView class]]) {
        PSPDFLinkAnnotationView *linkAnnotation = (PSPDFLinkAnnotationView *)annotationView;
        linkAnnotation.strokeWidth = 1;
        linkAnnotation.borderColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
    }
}

#define PSPDFLoadingViewTag 225475
- (void)pdfViewController:(PSPDFViewController *)pdfController willBeginDisplayingPageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    self.navigationItem.title = [NSString stringWithFormat:@"Custom always visible header bar. Page %tu", pageView.pageIndex];
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didChangeViewMode:(PSPDFViewMode)viewMode {
    self.customViewModeSegment.selectedSegmentIndex = (NSUInteger)viewMode;
}

// *** implemented just for your curiosity. you can use that to add custom loading views to the PSPDFScrollView ***

// called after pdf page has been loaded and added to the pagingScrollView
- (void)pdfViewController:(PSPDFViewController *)pdfController willScheduleRenderTaskForPageView:(PSPDFPageView *)pageView {
    NSLog(@"willScheduleRenderTaskForPageView: %@", pageView);

    // add loading indicator
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[pageView viewWithTag:PSPDFLoadingViewTag];
    if (!indicator) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator sizeToFit];
        [indicator startAnimating];
        indicator.tag = PSPDFLoadingViewTag;
        indicator.frame = CGRectMake(__tg_floor((pageView.frame.size.width - indicator.frame.size.width) / 2.), __tg_floor((pageView.frame.size.height - indicator.frame.size.height) / 2.), indicator.frame.size.width, indicator.frame.size.height);
        [pageView addSubview:indicator];
    }
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didFinishRenderTaskForPageView:(PSPDFPageView *)pageView {
    NSLog(@"page %@ rendered.", pageView);

    // remove loading indicator
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[pageView viewWithTag:PSPDFLoadingViewTag];
    if (indicator) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            indicator.alpha = 0.0;
        } completion:^(BOOL finished) {
            [indicator removeFromSuperview];
        }];
    }
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didConfigurePageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    // Page views are reused. Clean up in case we left the page view while still loading!
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[pageView viewWithTag:PSPDFLoadingViewTag];
    if (indicator) {
        [indicator removeFromSuperview];
    }
}

@end
