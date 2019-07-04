//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCSplitViewController.h"
#import "PSCFloatingBarPDFViewController.h"
#import "PSCAppDelegate.h"

#import "PSCSplitDocumentSelectorController.h"
#import "PSCSplitPDFViewController.h"

@interface PSCEmptyViewController : UIViewController
@end

@interface PSCSplitViewController () <UISplitViewControllerDelegate, PSPDFDocumentPickerControllerDelegate>
@property (readonly, nonatomic) UIBarButtonItem *backToCatalogButton;
@end

@implementation PSCSplitViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Create global back button
        _backToCatalogButton = [[UIBarButtonItem alloc] initWithImage:[PSPDFKit imageNamed:@"x"] style:UIBarButtonItemStylePlain target:self action:@selector(backToCatalog:)];

        // Create the PDF controller. We'll need it when selecting a document.
        _pdfController = [PSCSplitPDFViewController new];

        // Create the document picker.
        _documentPicker = [[PSCSplitDocumentSelectorController alloc] initWithDirectory:@"/Bundle/Samples" includeSubdirectories:YES library:PSPDFKit.sharedInstance.library];
        _documentPicker.delegate = self;
        _documentPicker.navigationItem.leftBarButtonItems = @[self.backToCatalogButton];
        UINavigationController *documentWrapper = [[UINavigationController alloc] initWithRootViewController:self.documentPicker];

        // Placeholder view controller to show in regular size class bore a document is selected.
        PSCEmptyViewController *emptyController = [PSCEmptyViewController new];
        emptyController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
        UINavigationController *emptyWrapper = [[UINavigationController alloc] initWithRootViewController:emptyController];

        // Set up the split view controller. `emptyWrapper` will always be initially hidden in compact size
        // class due to our implementation of splitViewController:collapseSecondaryViewController:
        // ontoPrimaryViewController:.
        self.viewControllers = @[documentWrapper, emptyWrapper];
        self.delegate = self;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.viewControllers.lastObject;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.viewControllers.lastObject;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Be eager about enqueuing.
    [self.documentPicker enqueueDocumentsIfRequired];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Ensure the document picker is visible initially.
    if (self.isBeingPresented && self.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
            self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
        } completion:^(BOOL finished) {
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        }];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)backToCatalog:(id)sender {
    // Workaround for rdar://20962645
    // When primary controller is in popover we need to force split controller
    // to hide it before dismissing itsef.
    // Without this UIKit crashes because UIPopoverController thinks it's still visible when it gets deallocated.
    if (self.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
        self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    // Don’t show the empty placeholder when we collapse. This also happens initially in compact widths.
    if (![self pdfControllerIsDisplayingDocumentOn:(UINavigationController *)secondaryViewController]) return YES;
    // Push the PDF controller onto the primary navigation controller stack, discarding secondaryViewController
    // (a navigation controller with the pdfController as its root view controller).
    UINavigationController *primaryNavigationController = (UINavigationController *)primaryViewController;
    PSPDFViewController *pdfController = self.pdfController;
    [primaryNavigationController pushViewController:pdfController animated:NO];
    [self configurePDFController:pdfController forCollapsedMode:YES];
    return NO;
}

- (nullable UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController {
    // In split mode, the details controller should be a navigation controller with either
    // the pdf controller or empty controller, depending on whether a document was currently displayed.
    PSPDFViewController *pdfController = self.pdfController;
    UINavigationController *primaryNavigationController = (UINavigationController *)primaryViewController;
    if ([self pdfControllerIsDisplayingDocumentOn:primaryNavigationController]) {
        // Ensure only the document picker is shown (and the PDF controller is removed).
        primaryNavigationController.viewControllers = @[self.documentPicker];
        // Add the displayModeButtonItem and make sure it is always visible
        [self configurePDFController:pdfController forCollapsedMode:NO];
        return [[UINavigationController alloc] initWithRootViewController:pdfController];
    } else {
        // Add a new placeholder controller.
        PSCEmptyViewController *emptyController = [PSCEmptyViewController new];
        emptyController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
        return [[UINavigationController alloc] initWithRootViewController:emptyController];
    }
}

- (BOOL)pdfControllerIsDisplayingDocumentOn:(UINavigationController *)navigationController {
    // Document should be set and valid.
    PSPDFViewController *pdfController = self.pdfController;
    if (!pdfController.document.isValid) return NO;
    // The pdf controller should be in the view hierarchy.
    for (UIViewController *controller in navigationController.viewControllers) {
        if (controller == pdfController) return YES;
    }
    return NO;
}

- (void)configurePDFController:(PSPDFViewController *)pdfController forCollapsedMode:(BOOL)collapsed {
    // In collapsed mode a back button is provided automatically
    NSArray<UIBarButtonItem *> *items = collapsed ? @[] : @[self.displayModeButtonItem];
    pdfController.barButtonItemsAlwaysEnabled = items;
    pdfController.navigationItem.leftBarButtonItems = items;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentPickerControllerDelegate

- (void)documentPickerController:(PSPDFDocumentPickerController *)documentPickerController didSelectDocument:(PSPDFDocument *)document pageIndex:(PSPDFPageIndex)pageIndex searchString:(NSString *)searchString {

#if defined(PSCEnableDocumentStressTest) && PSCEnableDocumentStressTest
    // Copy is purely there as a stress test.
    document = [document copy];
#endif
    
    PSPDFViewController *pdfController = self.pdfController;
    pdfController.document = document;
    pdfController.pageIndex = pageIndex;

    const BOOL collapsed = self.collapsed;
    [self configurePDFController:pdfController forCollapsedMode:collapsed];

    if (collapsed) {
        // Will push the pdf controller onto the master navigation controller
        // (we don't need to wrap it into a second navigation controller).
        [self showDetailViewController:pdfController sender:self];
    } else {
        // Reusing the navigation controller gives slightly better results because if the navigation bar is hidden it stays hidden.
        UINavigationController *navigationController = self.viewControllers.lastObject;
        if (![navigationController.viewControllers isEqualToArray:@[self.pdfController]]) {
            navigationController.viewControllers = @[self.pdfController];
        }
    }

    if (searchString && documentPickerController.fullTextSearchEnabled) {
        [self.pdfController searchForString:searchString options:@{ PSPDFViewControllerSearchHeadlessKey: @YES } sender:nil animated:YES];
    }

    // Hide the document picker if it is overlaid.
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
            [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
                self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            } completion:^(BOOL finished) {
                self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
            }];
        }
    });
}

- (void)documentPickerControllerWillEndSearch:(PSPDFDocumentPickerController *)documentPickerController {
    [self.pdfController.searchHighlightViewManager clearHighlightedSearchResultsAnimated:NO];
}

@end

@implementation PSCEmptyViewController

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = NSLocalizedString(@"No Document Selected", @"");
    label.textColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [view addSubview:label];

    NSLayoutConstraint *xConstraint = [label.centerXAnchor constraintEqualToAnchor:view.centerXAnchor];
    NSLayoutConstraint *yConstraint = [label.centerYAnchor constraintEqualToAnchor:view.centerYAnchor];
    [NSLayoutConstraint activateConstraints:@[xConstraint, yConstraint]];

    self.view = view;
}

@end
