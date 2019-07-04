//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCAnnotationButtonsInToolbarController : PSPDFViewController <PSPDFViewControllerDelegate>
@end

@interface PSCAnnotationButtonsInToolbarExample : PSCExample
@end
@implementation PSCAnnotationButtonsInToolbarExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Annotation buttons in navigation bar";
        self.contentDescription = @"Places some annotation buttons into the navigation bar.";
        self.category = PSCExampleCategoryBarButtons;
        self.priority = 80;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSCAnnotationButtonsInToolbarController alloc] initWithDocument:document];
}

@end

static void *PSCAnnotationStateManagerChangedStateContext = &PSCAnnotationStateManagerChangedStateContext;

@implementation PSCAnnotationButtonsInToolbarController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithDocument:(PSPDFDocument *)document {
    if ((self = [super initWithDocument:document])) {
        // observe state changes in annotationStateManager to change button states accordingly
        [self.annotationStateManager addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew context:PSCAnnotationStateManagerChangedStateContext];
    }

    return self;
}

- (void)dealloc {
    [self.annotationStateManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *inkBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[PSPDFKit imageNamed:@"ink"] style:UIBarButtonItemStylePlain target:self action:@selector(inkBarButtonPressed:)];
    UIBarButtonItem *eraserBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[PSPDFKit imageNamed:@"eraser"] style:UIBarButtonItemStylePlain target:self action:@selector(eraserBarButtonPressed:)];

    [self.navigationItem setRightBarButtonItems:@[self.annotationButtonItem, eraserBarButtonItem, inkBarButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Actions

- (void)inkBarButtonPressed:(UIBarButtonItem *)sender {
    [self.annotationStateManager toggleState:PSPDFAnnotationStringInk variant:PSPDFAnnotationVariantStringInkPen];
}

- (void)eraserBarButtonPressed:(UIBarButtonItem *)sender {
    [self.annotationStateManager toggleState:PSPDFAnnotationStringEraser];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context {
    if (context == PSCAnnotationStateManagerChangedStateContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            NSString *state = change[NSKeyValueChangeNewKey];

            UIBarButtonItem *inkBarButtonItem = [self.navigationItem rightBarButtonItemsForViewMode:PSPDFViewModeDocument][2];
            UIBarButtonItem *eraserBarButtonItem = [self.navigationItem rightBarButtonItemsForViewMode:PSPDFViewModeDocument][1];

            BOOL inkEnabled = [state isEqual:PSPDFAnnotationStringInk];
            BOOL eraserEnabled = [state isEqual:PSPDFAnnotationStringEraser];

            if (inkEnabled) {
                inkBarButtonItem.image = [PSPDFKit imageNamed:@"x"];
            } else {
                inkBarButtonItem.image = [PSPDFKit imageNamed:@"ink"];
            }

            if (eraserEnabled) {
                eraserBarButtonItem.image = [PSPDFKit imageNamed:@"x"];
            } else {
                eraserBarButtonItem.image = [PSPDFKit imageNamed:@"eraser"];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
