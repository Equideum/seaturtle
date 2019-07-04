//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCMagazine.h"
#import <tgmath.h>

@implementation PSCMagazine

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle

+ (nullable PSCMagazine *)magazineWithPath:(NSString *)path {
    NSURL *URL = path ? [NSURL fileURLWithPath:path] : nil;
    if (URL) {
        PSCMagazine *magazine = [(PSCMagazine *)[self.class alloc] initWithURL:URL];
        magazine.available = YES;
        return magazine;
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: UID:%@ pageCount:%tu URL:%@ fileURLs:%@>", self.class, (void *)self, self.UID, self.pageCount, self.URL, self.fileURLs];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Meta Data

- (nullable UIImage *)coverImageForSize:(CGSize)size {
    UIImage *coverImage;

    PSPDFMutableRenderRequest *request = [[PSPDFMutableRenderRequest alloc] initWithDocument:self];
    request.imageSize = size;

    coverImage = [PSPDFKit.sharedInstance.cache imageForRequest:request imageSizeMatching:PSPDFCacheImageSizeMatchingDefault];

    // Draw a custom, centered lock image if the magazine is password protected.
    @autoreleasepool {
        if (self.isLocked) {
            if (!CGSizeEqualToSize(size, CGSizeZero)) {
                UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
                [[UIColor colorWithWhite:0.9 alpha:1.] setFill];
                CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect){.size = size});
                UIImage *lockImage = [UIImage imageNamed:@"lock"];
                CGFloat scale = PSCIsIPad() ? 0.6 : 0.3;
                CGSize lockImageTargetSize = CGSizeMake(__tg_round(lockImage.size.width * scale), __tg_round(lockImage.size.height * scale));
                [lockImage drawInRect:(CGRect){.origin = {__tg_floor((size.width - lockImageTargetSize.width) / 2), __tg_floor((size.height - lockImageTargetSize.height) / 2)}, .size = lockImageTargetSize}];
                coverImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }

    return coverImage;
}

- (PSPDFViewState *)lastViewState {
    PSPDFViewState *viewState;

    // Restore viewState (sadly, NSKeyedUnarchiver might throw an exception on error).
    if (self.isValid) {
        NSData *viewStateData = [NSUserDefaults.standardUserDefaults objectForKey:self.UID];
        @try {
            if (viewStateData) {
                viewState = [NSKeyedUnarchiver unarchiveObjectWithData:viewStateData];
            }
        } @catch (NSException *exception) {
            PSCLog(@"Failed to load saved viewState: %@", exception);
            [NSUserDefaults.standardUserDefaults removeObjectForKey:self.UID];
        }
    }
    return viewState;
}

- (void)setLastViewState:(PSPDFViewState *)lastViewState {
    if (self.isValid) {
        if (lastViewState) {
            NSData *viewStateData = [NSKeyedArchiver archivedDataWithRootObject:lastViewState];
            [NSUserDefaults.standardUserDefaults setObject:viewStateData forKey:self.UID];
        } else {
            [NSUserDefaults.standardUserDefaults removeObjectForKey:self.UID];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (BOOL)isDeletable {
    static NSString *bundlePath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundlePath = NSBundle.mainBundle.bundlePath;
    });

    // If magazine is within the app bundle, we can't delete it.
    BOOL deletable = ![[self pathForPageAtIndex:0].path hasPrefix:bundlePath];
    return deletable;
}

@end
