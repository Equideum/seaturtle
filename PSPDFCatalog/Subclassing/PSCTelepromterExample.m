//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PSCTelepromterExample : PSCExample
@end

@interface PSCPauseAutoScrollGestureRecognizer : UIGestureRecognizer
@end

@interface PSCAutoScrollPDFViewController : PSPDFViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, strong) PSCPauseAutoScrollGestureRecognizer *pauseAutoScrollGestureRecognizer;
@property (nonatomic, getter = isScrollingPaused) BOOL scrollingPaused;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation PSCTelepromterExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Teleprompter example";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 30;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfViewController = [[PSCAutoScrollPDFViewController alloc] initWithDocument:document];

    return pdfViewController;
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation PSCPauseAutoScrollGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if ((self = [super initWithTarget:target action:action])) {
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }

    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
}

@end

////////////////////////////////////////////////////////////////////////////////

@implementation PSCAutoScrollPDFViewController

- (instancetype)initWithDocument:(PSPDFDocument *)document {
    if ((self = [super initWithDocument:document])) {
        [self updateConfigurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
            builder.pageTransition = PSPDFPageTransitionScrollContinuous;
            builder.scrollDirection = PSPDFScrollDirectionVertical;
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pauseAutoScrollGestureRecognizer = [[PSCPauseAutoScrollGestureRecognizer alloc] initWithTarget:self action:@selector(handlePauseAutoScroll:)];
    self.pauseAutoScrollGestureRecognizer.delegate = self;
    [self.documentViewController.view addGestureRecognizer:self.pauseAutoScrollGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
}

- (void)scroll {
    if (self.scrollingPaused) return;

    // The layout object knows how many spreads we currently have:
    NSInteger numberOfSpreads = self.documentViewController.layout.numberOfSpreads;
    CGFloat lastSpreadIndex = (CGFloat)(numberOfSpreads > 0 ? numberOfSpreads - 1 : 0);

    // We scroll by updating the continuous spread index as long as we can:
    CGFloat continuousSpreadIndex = self.documentViewController.continuousSpreadIndex + 0.001;
    if (continuousSpreadIndex <= lastSpreadIndex) {
        self.documentViewController.continuousSpreadIndex = continuousSpreadIndex;
    }
}

- (void)handlePauseAutoScroll:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.scrollingPaused = YES;
    }

    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.scrollingPaused = NO;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // We'll ignore long presses but allow everything else, such as scrolling.
    if (gestureRecognizer == self.pauseAutoScrollGestureRecognizer && [otherGestureRecognizer isKindOfClass:UILongPressGestureRecognizer.class]) {
        return NO;
    }

    return YES;
}

@end
