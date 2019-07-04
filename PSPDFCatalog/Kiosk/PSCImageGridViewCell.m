//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCImageGridViewCell.h"
#import "PSCAvailability.h"
#import "PSCImageGridViewLoader.h"
#import "PSCMagazine.h"
#import "PSCMagazineFolder.h"
#import "PSCStoreManager.h"
#import <tgmath.h>

static CGSize PSCSizeThatFits(CGSize size, CGSize constraints) {
    if (size.width == 0.0 || size.height == 0.0) {
        return size;
    }

    if (size.height > size.width) {
        size = CGSizeMake(constraints.height / size.height * size.width, constraints.height);
        if (size.width > constraints.width) {
            const CGFloat d = (size.width - constraints.width) * (size.height / size.width);
            size.width = constraints.width;
            size.height = size.height - d;
        }
    } else {
        size = CGSizeMake(constraints.width, constraints.width / size.width * size.height);
        if (size.height > constraints.height) {
            const CGFloat d = (size.height - constraints.height) * (size.width / size.height);
            size.height = constraints.height;
            size.width = size.width - d;
        }
    }
    return size;
}

@interface PSCImageGridViewCell ()
@property (nonatomic) UILabel *magazineCounter;
@property (nonatomic) NSMutableSet *observedMagazineDownloads;
@property (nonatomic) CGRect defaultFrame;

@property (nonatomic) UIImageView *magazineCounterBadgeImage;
@property (nonatomic, copy) NSString *magazineTitle;
@end

@implementation PSCImageGridViewCell

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _defaultFrame = frame;

        // incomplete downloads stay here
        _observedMagazineDownloads = [[NSMutableSet alloc] init];

        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.pageLabelEnabled = YES;
        self.edgeInsets = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);

        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [_deleteButton sizeToFit];
        _deleteButton.hidden = YES;
        [self.contentView addSubview:_deleteButton];

        self.imageLoader = [PSCImageGridViewLoader new];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    self.deleteButton.frame = CGRectMake(self.imageView.frame.origin.x - 10., self.imageView.frame.origin.y - 10., self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
    [self.contentView bringSubviewToFront:self.deleteButton];

    [self updateMagazineBadgeFrame];
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    self.defaultFrame = frame;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    UIImage *image = self.image;
    if (image) {
        CGSize imageSize = PSCSizeThatFits(image.size, contentRect.size);
        CGRect imageRect = {.size = imageSize};
        imageRect.origin.x = contentRect.origin.x + (CGRectGetWidth(contentRect) / 2. - CGRectGetWidth(imageRect) / 2.);
        imageRect.origin.y = contentRect.origin.y + (CGRectGetHeight(contentRect) / 2. - CGRectGetHeight(imageRect) / 2.);

        CGFloat scale = UIScreen.mainScreen.scale;
        imageRect.origin.x = round(imageRect.origin.x * scale) / scale;
        imageRect.origin.y = round(imageRect.origin.y * scale) / scale;
        imageRect.size.width = round(imageRect.size.width * scale) / scale;
        imageRect.size.height = round(imageRect.size.height * scale) / scale;

        return imageRect;
    }
    return contentRect;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFThumbnailGridViewCell

// Override to change label (default is within the image, has rounded borders)
- (void)updatePageLabel {
    UILabel *pageLabel = self.pageLabel;
    if (!self.pageLabelEnabled) {
        [pageLabel removeFromSuperview];
    } else {
        if (pageLabel.superview == self.contentView) {
            [self.contentView bringSubviewToFront:pageLabel];
        } else {
            [self.contentView addSubview:pageLabel];
        }
    }

    // Calculate new frame and position correct.
    CGRect imageFrame = [self imageRectForContentRect:[self contentRectForBounds:self.bounds]];
    pageLabel.frame = CGRectIntegral(CGRectMake(0.0, CGRectGetMaxY(imageFrame), self.frame.size.width, 20.0));
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

static NSString *PSCStripPDFFileType(NSString *pdfFileName) { return [pdfFileName stringByReplacingOccurrencesOfString:@".pdf" withString:@"" options:NSCaseInsensitiveSearch | NSBackwardsSearch range:NSMakeRange(0, pdfFileName.length)]; }

- (void)setMagazine:(PSCMagazine *)magazine {
    if (self.magazineFolder) {
        self.magazineFolder = nil;
    }

    if (_magazine != magazine) {
        _magazine = magazine;
        self.pageIndex = 0;

        ((PSCImageGridViewLoader *)self.imageLoader).magazine = magazine;

        // setup for magazine
        if (magazine) {
            [self setNeedsUpdateImage];
            [self layoutIfNeeded];

            self.magazineCount = 0;

            if (magazine.isTitleLoaded) {
                self.magazineTitle = magazine.title;
            } else {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    NSString *title = magazine.title;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.magazineTitle = title;
                    });
                });
            }
        }

        NSString *pageLabelText = PSCStripPDFFileType(magazine.fileURLs.lastObject.lastPathComponent);
        [self updatePageLabel]; // create lazily
        self.pageLabel.text = pageLabelText.length ? pageLabelText : magazine.title;
        [self updatePageLabel];
    }
}

- (void)setMagazineFolder:(PSCMagazineFolder *)magazineFolder {
    if (self.magazine) {
        self.magazine = nil;
    }

    if (_magazineFolder != magazineFolder) {
        _magazineFolder = magazineFolder;

        // setup for folder
        if (magazineFolder) {
            NSUInteger magazineCount = magazineFolder.magazines.count;
            self.magazineCount = magazineCount;

            PSCMagazine *coverMagazine = magazineFolder.firstMagazine;
            self.image = [coverMagazine coverImageForSize:self.frame.size];
        }
    }
}

- (void)updateMagazineBadgeFrame {
    _magazineCounterBadgeImage.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, 50.0, 50.0);
}

- (void)setMagazineCount:(NSUInteger)magazineCount {
    _magazineCount = magazineCount;
    if (!_magazineCounter && magazineCount > 1) { // lazy creation
        self.magazineCounterBadgeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge"]];
        _magazineCounterBadgeImage.opaque = NO;
        _magazineCounterBadgeImage.alpha = 0.9;
        [self.contentView addSubview:_magazineCounterBadgeImage];

        _magazineCounter = [[UILabel alloc] init];
        _magazineCounter.font = [UIFont boldSystemFontOfSize:20.];
        _magazineCounter.textColor = UIColor.whiteColor;
        _magazineCounter.shadowColor = UIColor.blackColor;
        _magazineCounter.shadowOffset = CGSizeMake(1.0, 1.0);
        _magazineCounter.backgroundColor = UIColor.clearColor;
        _magazineCounter.frame = CGRectMake(1.0, 1.0, 25.0, 25.0);
        _magazineCounter.textAlignment = NSTextAlignmentCenter;
        [_magazineCounterBadgeImage addSubview:_magazineCounter];
    }

    _magazineCounter.text = [NSString stringWithFormat:@"%tu", magazineCount];
    _magazineCounter.hidden = magazineCount < 2;
    _magazineCounterBadgeImage.hidden = magazineCount < 2;
    [self updateMagazineBadgeFrame];
}

- (NSString *)accessibilityLabel {
    return self.pageLabel.text;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Progress

- (void)setImage:(UIImage *)image {
    super.image = image;

    // Ensure magazineCounter is at top.
    [self bringSubviewToFront:_magazineCounterBadgeImage];

    // Recalculate edit button position.
    [self setNeedsLayout];
}

- (void)setShowDeleteImage:(BOOL)showDeleteImage {
    _showDeleteImage = showDeleteImage;
    _deleteButton.hidden = !_showDeleteImage;
    [self setNeedsLayout];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFGridViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.magazine = nil;
    self.magazineFolder = nil;
    [self.magazineCounter removeFromSuperview];
    self.magazineCounter = nil;
    [self.magazineCounterBadgeImage removeFromSuperview];
    self.magazineCounterBadgeImage = nil;
}

@end
