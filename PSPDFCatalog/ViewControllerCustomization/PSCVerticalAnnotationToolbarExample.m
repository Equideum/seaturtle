//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

/// Example how to add an always-visible vertical toolbar
@interface PSCVerticalAnnotationToolbar : UIView <PSPDFAnnotationStateManagerDelegate>

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder PSPDF_NOT_DESIGNATED_INITIALIZER_ATTRIBUTE;

@property (nonatomic, readonly) PSPDFAnnotationStateManager *annotationStateManager;
@property (nonatomic) UIButton *drawButton;
@property (nonatomic) UIButton *freeTextButton;
@property (nonatomic) UIButton *undoButton;
@property (nonatomic) UIButton *redoButton;

@end

@interface PSCExampleAnnotationViewController : PSPDFViewController
@property (nonatomic) PSCVerticalAnnotationToolbar *verticalToolbar;
@end

@interface PSCVerticalAnnotationToolbarExample : PSCExample
@end
@implementation PSCVerticalAnnotationToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Vertical always-visible annotation bar";
        self.contentDescription = @"Custom, vertically aligned annotation toolbar.";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSCExampleAnnotationViewController alloc] initWithDocument:document];
    // Remove the default annotationBarButtonItem
    NSMutableArray *items = [[controller.navigationItem rightBarButtonItemsForViewMode:PSPDFViewModeDocument] mutableCopy];
    [items removeObject:controller.annotationButtonItem];
    [controller.navigationItem setRightBarButtonItems:items forViewMode:PSPDFViewModeDocument animated:NO];
    return controller;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExampleAnnotationViewController

@implementation PSCExampleAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // create the custom toolbar and add it on top of the view.
    self.verticalToolbar = [[PSCVerticalAnnotationToolbar alloc] initWithAnnotationStateManager:self.annotationStateManager];
    self.verticalToolbar.frame = CGRectIntegral(CGRectMake(self.view.bounds.size.width - 44., (self.view.bounds.size.height - 44.) / 2, 44.0, 44.0 * 4));
    self.verticalToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.verticalToolbar];
}

- (void)setViewMode:(PSPDFViewMode)viewMode animated:(BOOL)animated {
    [super setViewMode:viewMode animated:animated];
    // ensure custom toolbar is hidden when we show the thumbnails
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.verticalToolbar.alpha = viewMode == PSPDFViewModeThumbnails ? 0.0 : 1.0;
    } completion:NULL];
}

@end

@implementation PSCVerticalAnnotationToolbar

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

PSC_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithFrame : (CGRect)frame)
PSC_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithCoder : (NSCoder *)coder)

- (instancetype)initWithAnnotationStateManager:(PSPDFAnnotationStateManager *)annotationStateManager {
    if ((self = [super initWithFrame:CGRectZero])) {
        _annotationStateManager = annotationStateManager;
        [annotationStateManager addDelegate:self];

        PSPDFViewController *pdfController = annotationStateManager.pdfController;
        self.backgroundColor = pdfController.navigationController.navigationBar.tintColor;

        // draw button
        if ([pdfController.configuration.editableAnnotationTypes containsObject:PSPDFAnnotationStringInk]) {
            UIButton *drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *sketchImage = [[PSPDFKit imageNamed:@"ink"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [drawButton setImage:sketchImage forState:UIControlStateNormal];
            [drawButton addTarget:self action:@selector(inkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:drawButton];
            self.drawButton = drawButton;
        }

        // draw button
        if ([pdfController.configuration.editableAnnotationTypes containsObject:PSPDFAnnotationStringFreeText]) {
            UIButton *freetextButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *freeTextImage = [[PSPDFKit imageNamed:@"freetext"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [freetextButton setImage:freeTextImage forState:UIControlStateNormal];
            [freetextButton addTarget:self action:@selector(freetextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:freetextButton];
            self.freeTextButton = freetextButton;
        }

        // undo button
        UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *undoImage = [[PSPDFKit imageNamed:@"undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [undoButton setImage:undoImage forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(undoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:undoButton];
        self.undoButton = undoButton;

        // redo button
        UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *redoImage = [[PSPDFKit imageNamed:@"redo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [redoButton setImage:redoImage forState:UIControlStateNormal];
        [redoButton addTarget:self action:@selector(redoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
        self.redoButton = redoButton;
    }
    return self;
}

- (void)dealloc {
    [_annotationStateManager removeDelegate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect rem = self.bounds, slice;
    CGRectDivide(rem, &slice, &rem, 44.0, CGRectMinYEdge);
    self.drawButton.frame = slice;
    CGRectDivide(rem, &slice, &rem, 44.0, CGRectMinYEdge);
    self.freeTextButton.frame = slice;
    CGRectDivide(rem, &slice, &rem, 44.0, CGRectMinYEdge);
    self.undoButton.frame = slice;
    self.redoButton.frame = rem;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];

    // While we have a delegate to be informed about undo state,
    // we still need to set up the initial state correctly.
    [self updateUndoRedoButtons];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Events

- (nullable PSPDFUndoController *)undoController {
    return self.annotationStateManager.pdfController.document.undoController;
}

- (void)inkButtonPressed:(id)sender {
    [self.annotationStateManager toggleState:PSPDFAnnotationStringInk];
}

- (void)freetextButtonPressed:(id)sender {
    [self.annotationStateManager toggleState:PSPDFAnnotationStringFreeText];
}

- (void)undoButtonPressed:(id)sender {
    [self.undoController undo];
}

- (void)redoButtonPressed:(id)sender {
    [self.undoController redo];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)updateUndoRedoButtons {
    self.undoButton.enabled = self.undoController.canUndo;
    self.redoButton.enabled = self.undoController.canRedo;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFAnnotationStateManagerDelegate

- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeState:(PSPDFAnnotationString)state to:(PSPDFAnnotationString)newState variant:(PSPDFAnnotationVariantString)variant to:(PSPDFAnnotationVariantString)newVariant {
    UIColor *selectedColor = [UIColor colorWithWhite:0.0 alpha:.2f];
    UIColor *deselectedColor = UIColor.clearColor;

    self.freeTextButton.backgroundColor = newState == PSPDFAnnotationStringFreeText ? selectedColor : deselectedColor;
    self.drawButton.backgroundColor = newState == PSPDFAnnotationStringInk ? selectedColor : deselectedColor;
}

- (void)annotationStateManager:(PSPDFAnnotationStateManager *)manager didChangeUndoState:(BOOL)undoEnabled redoState:(BOOL)redoEnabled {
    self.undoButton.enabled = undoEnabled;
    self.redoButton.enabled = redoEnabled;
}

@end
