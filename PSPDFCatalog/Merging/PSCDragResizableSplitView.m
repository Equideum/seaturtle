//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCDragResizableSplitView.h"

@interface PSCDraggbleDividerView : UIView
@end

@interface PSCDragResizableSplitView ()
@property (nonatomic, readonly) UIView *leftContainer, *rightContainer;
@property (nonatomic, readonly) PSCDraggbleDividerView *dividerView;
@property (nonatomic, readonly) NSLayoutConstraint *dividerX;
@end

static inline void RemoveSubviewsOf(UIView *view) {
    NSArray *children = [view.subviews copy];
    [children makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

static inline void MakeViewFillOther(UIView *content, UIView *container) {
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:content];
    [container addConstraints:@[
        [content.widthAnchor constraintEqualToAnchor:container.widthAnchor],
        [content.heightAnchor constraintEqualToAnchor:container.heightAnchor],
        [content.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [content.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
    ]];
}

@implementation PSCDragResizableSplitView

#pragma mark - Managing Subviews

- (void)installLeftView:(UIView *)leftView rightView:(UIView *)rightView {
    RemoveSubviewsOf(self.leftContainer);
    if (leftView) {
        MakeViewFillOther(leftView, self.leftContainer);
    }
    RemoveSubviewsOf(self.rightContainer);
    if (rightView) {
        MakeViewFillOther(rightView, self.rightContainer);
    }
    [self setNeedsLayout];
}

@synthesize leftContainer = _leftContainer;
- (UIView *)leftContainer {
    if (!_leftContainer) {
        _leftContainer = [UIView new];
        _leftContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftContainer];
    }
    return _leftContainer;
}

@synthesize rightContainer = _rightContainer;
- (UIView *)rightContainer {
    if (!_rightContainer) {
        _rightContainer = [UIView new];
        _rightContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightContainer];
    }
    return _rightContainer;
}

@synthesize dividerX = _dividerX;
- (NSLayoutConstraint *)dividerX {
    return _dividerX ?: (_dividerX = [self.dividerView.centerXAnchor constraintEqualToAnchor:self.leftAnchor]);
}

@synthesize dividerView = _dividerView;
- (PSCDraggbleDividerView *)dividerView {
    if (!_dividerView) {
        // Create a know so that one can actually see the divider
        UIView *knob = [UIView new];
        knob.translatesAutoresizingMaskIntoConstraints = NO;
        knob.backgroundColor = [UIColor lightGrayColor];
        NSLayoutConstraint *aspectRatio = [knob.widthAnchor constraintEqualToAnchor:knob.heightAnchor];
        NSLayoutConstraint *size = [knob.widthAnchor constraintEqualToConstant:40];
        [knob addConstraints:@[aspectRatio, size]];

        // Install the knob inside the divider (we clip, so the knob wont visually overlap)
        PSCDraggbleDividerView *divider = [PSCDraggbleDividerView new];
        divider.clipsToBounds = YES;
        [divider addSubview:knob];
        [divider addConstraints:@[
            [divider.centerXAnchor constraintEqualToAnchor:knob.centerXAnchor],
            [divider.centerYAnchor constraintEqualToAnchor:knob.centerYAnchor],
        ]];

        // Make sure we can drag…
        [divider addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didUpdateDrag:)]];
        _dividerView = divider;
    }
    return _dividerView;
}

#pragma mark - Event Handling

- (void)didUpdateDrag:(UIPanGestureRecognizer *)panGesture {
    UIView *reference = self.superview;
    const CGPoint delta = [panGesture translationInView:reference];

    // Only apply and reset the translation if valid
    const CGFloat proposedX = self.dividerX.constant + delta.x;
    const CGFloat width = CGRectGetWidth(self.bounds);
    if (proposedX >= 0.3 * width && proposedX <= 0.7 * width) {
        self.dividerX.constant = proposedX;
        [panGesture setTranslation:CGPointZero inView:reference];
    }
}

#pragma mark - Layout

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];

    UIView *divider = self.dividerView;
    // Once we have the complete view hierarchy, we don’t need to do anything more.
    if ([divider isDescendantOfView:self]) return;

    // Set up the view hierarchy and make our subviews constrainable
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:divider];

    // Pin the divider to fill us vertically, allowing its X position to give in
    NSLayoutConstraint *dividerX = self.dividerX;
    dividerX.priority = UILayoutPriorityDefaultHigh + 10;
    [self addConstraints:@[
        dividerX,
        [self.heightAnchor constraintEqualToAnchor:divider.heightAnchor],
        [self.topAnchor constraintEqualToAnchor:divider.topAnchor],
    ]];

    // Make all our subviews sit horizontally flush and top/bottom aligned — this completes and disambiguates our entire layout
    UIView *left = self.leftContainer;
    UIView *right = self.rightContainer;
    NSArray *horizontallyFlushViewsOfEqualHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"|[left][divider(3)][right]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(left, right, divider)];
    [self addConstraints:horizontallyFlushViewsOfEqualHeight];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    // First time we have a usable frame: center the divider!
    self.dividerX.constant = CGRectGetWidth(self.bounds) / 2;
}

@end

@implementation PSCDraggbleDividerView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounding = CGRectUnion(self.bounds, self.subviews.lastObject.frame);
    return CGRectContainsPoint(bounding, point);
}

@end
