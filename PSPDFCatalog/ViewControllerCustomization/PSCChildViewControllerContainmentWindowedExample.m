//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCChildViewController : UIViewController

@property (nonatomic, nullable) PSPDFDocument *document;

/// Convenience initializer.
- (instancetype)initWithDocument:(PSPDFDocument *)document;

@end

@interface PSCChildViewControllerContainmentWindowedExample : PSCExample
@end
@implementation PSCChildViewControllerContainmentWindowedExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Child View Controller containment, windowed";
        self.category = PSCExampleCategoryControllerCustomization;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameAnnualReport];
    return [[PSCChildViewController alloc] initWithDocument:document];
}

@end

@interface PSCChildViewController () <PSPDFViewControllerDelegate, UIToolbarDelegate>
@property (nonatomic) PSPDFViewController *pdfController;
@property (nonatomic) UIToolbar *toolbar;
@end

@implementation PSCChildViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithDocument:(PSPDFDocument *)document {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _document = document;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)createPDFViewController {
    // configure the PSPDF controller
    self.pdfController = [[PSPDFViewController alloc] initWithDocument:self.document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.pageTransition = PSPDFPageTransitionScrollContinuous;
        builder.scrollDirection = PSPDFScrollDirectionVertical;
        builder.shadowEnabled = NO;
        builder.doubleTapAction = PSPDFTapActionZoom;
        // Also blocks code that is responsible for showing the user interface.
        builder.shouldHideNavigationBarWithUserInterface = NO;
    }]];
    self.pdfController.delegate = self;

    // Those need to be nilled out if you use the barButton items externally!
    self.pdfController.navigationItem.leftBarButtonItems = nil;
    self.pdfController.navigationItem.rightBarButtonItems = nil;

    [self addChildViewController:self.pdfController];
    [self.pdfController didMoveToParentViewController:self];
    [self.view addSubview:self.pdfController.view];

    // As an example, here we're not using the UINavigationController but instead a custom UIToolbar.
    // Note that if you're going that way, you'll lose some features that PSPDFKit provides, like dynamic toolbar updating or accessibility.
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    // Ensure we're top attached.
    toolbar.barTintColor = UIColor.pspdfColor;
    toolbar.delegate = self;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 8;

    NSMutableArray *toolbarItems = [NSMutableArray array];
    [toolbarItems addObjectsFromArray:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)], flexibleSpace, self.pdfController.searchButtonItem]];

    if (self.pdfController.document.documentProviders.firstObject.outlineParser.isOutlineAvailable) {
        [toolbarItems addObjectsFromArray:@[fixedSpace, self.pdfController.outlineButtonItem]];
    }
    if (self.pdfController.document.canSaveAnnotations) {
        [toolbarItems addObjectsFromArray:@[fixedSpace, self.pdfController.annotationButtonItem]];
    }
    [toolbarItems addObjectsFromArray:@[fixedSpace, self.pdfController.bookmarkButtonItem]];

    toolbar.items = toolbarItems;
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;

    // Layout views using auto layout.
    UIToolbar *statusBarBackgroundView = [UIToolbar new];
    statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:statusBarBackgroundView];

    UIView *pdfControllerView = self.pdfController.view;
    pdfControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *bindings = NSDictionaryOfVariableBindings(pdfControllerView, toolbar, statusBarBackgroundView);

    // Lyout PSPDFViewController.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[pdfControllerView]-50-|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[pdfControllerView]-50-|" options:0 metrics:nil views:bindings]];
    // Layout the toolbar.
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBarBackgroundView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:@[[statusBarBackgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                [statusBarBackgroundView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                [toolbar.topAnchor constraintEqualToAnchor:statusBarBackgroundView.bottomAnchor]
                                ]];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.lightGrayColor;
    [self createPDFViewController];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // viewWillAppear: is too early for this, we need to hide the navBar here (UISearchDisplayController related issue)
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.navigationBarHidden = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)setDocument:(PSPDFDocument *)document {
    if (document != _document) {
        _document = document;
        self.pdfController.document = document;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)doneButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
