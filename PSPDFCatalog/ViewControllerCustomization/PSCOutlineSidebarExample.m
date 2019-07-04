//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "UIBarButtonItem+PSCBlockSupport.h"

@interface PSCSidebarViewController : UIViewController <PSPDFDocumentPickerControllerDelegate>
- (instancetype)initWithDocument:(PSPDFDocument *)document NS_DESIGNATED_INITIALIZER;

@property (nonatomic) PSPDFDocument *document;
@property (nonatomic) PSPDFViewController *pdfController;
@property (nonatomic) PSPDFContainerViewController *sidebarController;
@property (nonatomic) UIBarButtonItem *pickerButtonItem;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;
@end

@interface PSCOutlineSidebarExample : PSCExample
@end
@implementation PSCOutlineSidebarExample

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Split View Controller Sidebar";
        self.contentDescription = @"Always visible in landscape mode split view controller to show the outline/annotation/bookmark/search view controller.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 1;
        // Split view is iPad only.
        self.targetDevice = PSCExampleTargetDeviceMaskPad;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    PSCSidebarViewController *sidebarController = [[PSCSidebarViewController alloc] initWithDocument:document];
    [delegate.currentViewController presentViewController:sidebarController animated:YES completion:NULL];
    return nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCSidebarViewController

@implementation PSCSidebarViewController

PSC_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithNibName : (nullable NSString *)nibNameOrNil bundle : (nullable NSBundle *)nibBundleOrNil)
PSC_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithCoder : (NSCoder *)aDecoder)

- (instancetype)initWithDocument:(PSPDFDocument *)document {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Set up the PDF controller
        PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
            builder.pageMode = PSPDFPageModeSingle;
            builder.spreadFitting = PSPDFConfigurationSpreadFittingFill;
        }]];

        // Set up the document picker button
        PSPDFDocumentPickerController *documentPicker = [[PSPDFDocumentPickerController alloc] initWithDirectory:@"/Bundle/Samples" includeSubdirectories:YES library:PSPDFKit.sharedInstance.library];
        documentPicker.delegate = self;
        __weak PSPDFViewController *weakPDFController = pdfController;
        UIBarButtonItem *pickerButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Documents" style:UIBarButtonItemStylePlain block:^(id sender) {
            documentPicker.modalPresentationStyle = UIModalPresentationPopover;
            [weakPDFController presentViewController:documentPicker options:@{ PSPDFPresentationInNavigationControllerKey: @YES } animated:YES sender:sender completion:NULL];
        }];
        self.pickerButtonItem = pickerButtonItem;
        [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.activityButtonItem, pdfController.bookmarkButtonItem, pdfController.brightnessButtonItem, pdfController.annotationButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
        self.pdfController = pdfController;
        UINavigationController *navPDFController = [[UINavigationController alloc] initWithRootViewController:pdfController];

        // Set up the controller for annotations/outline/bookmarks/search.
        PSPDFOutlineViewController *outlineController = [[PSPDFOutlineViewController alloc] initWithDocument:document];
        outlineController.delegate = pdfController;
        PSPDFBookmarkViewController *bookmarkController = [[PSPDFBookmarkViewController alloc] initWithDocument:document];
        bookmarkController.sortOrder = pdfController.configuration.bookmarkSortOrder; // connect settings
        bookmarkController.delegate = pdfController;
        PSPDFAnnotationTableViewController *annotationController = [[PSPDFAnnotationTableViewController alloc] initWithDocument:document];
        annotationController.delegate = pdfController;
        PSPDFSearchViewController *searchController = [[PSPDFSearchViewController alloc] initWithDocument:document];
        searchController.delegate = pdfController;
        searchController.searchBarPinning = PSPDFSearchBarPinningNone;

        // Create the container controller.
        PSPDFContainerViewController *containerController = [[PSPDFContainerViewController alloc] initWithControllers:@[outlineController, annotationController, bookmarkController, searchController] titles:nil];
        containerController.shouldAnimateChanges = NO;
        self.sidebarController = containerController;
        UINavigationController *navContainer = [[UINavigationController alloc] initWithRootViewController:containerController];

        // Create the split view controller
        UISplitViewController *splitController = [UISplitViewController new];
        splitController.viewControllers = @[navContainer, navPDFController];

        // Use a dummy to present, as the split controller doesn't like to be presented modally.
        [self addChildViewController:splitController];
        [self.view addSubview:splitController.view];
        [splitController didMoveToParentViewController:self];

        pdfController.navigationItem.leftBarButtonItems = @[pdfController.closeButtonItem, pickerButtonItem, splitController.displayModeButtonItem];
        pdfController.barButtonItemsAlwaysEnabled = @[pickerButtonItem, splitController.displayModeButtonItem];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (UIViewController *)childViewControllerForStatusBarStyle {
    UISplitViewController *splitViewController = self.childViewControllers.firstObject;
    return splitViewController.viewControllers.lastObject;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    UISplitViewController *splitViewController = self.childViewControllers.firstObject;
    return splitViewController.viewControllers.lastObject;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (PSPDFDocument *)document {
    return self.pdfController.document;
}

// Update document everywhere.
- (void)setDocument:(PSPDFDocument *)document {
    self.pdfController.document = document;
    // All controllers allow updating the document. If you add other controllers, customize this part to check for the selector.
    [self.sidebarController.viewControllers setValue:document forKey:@"document"];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFDocumentPickerControllerDelegate

- (void)documentPickerController:(PSPDFDocumentPickerController *)documentPickerController didSelectDocument:(PSPDFDocument *)document pageIndex:(PSPDFPageIndex)pageIndex searchString:(NSString *)searchString {
    // Set new document and dismiss.
    self.document = document;
    [documentPickerController dismissViewControllerAnimated:YES completion:NULL];
}

@end
