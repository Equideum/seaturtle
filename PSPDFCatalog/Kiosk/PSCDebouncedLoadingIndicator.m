//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCDebouncedLoadingIndicator.h"

@interface PSCDebouncedLoadingIndicator ()

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@end

@implementation PSCDebouncedLoadingIndicator

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _gracePeriod = 0.2;

        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
        activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:activityIndicator];
        _activityIndicator = activityIndicator;
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    if (self.superview) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.gracePeriod * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityIndicator startAnimating];
        });
    } else {
        [self.activityIndicator stopAnimating];
    }
}

@end
