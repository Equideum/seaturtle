//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCImageGridViewLoader.h"
#import "PSCMagazine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PSCImageGridViewLoader ()

@property (nonatomic, weak) NSOperation *runningOperation;

@end

@interface PSCImageGridViewLoaderToken : NSObject <PSPDFPageCellImageRequestToken>

@property (nonatomic) CGSize expectedSize;
@property (nonatomic, copy, nullable) void (^cancellationHandler)(void);

- (instancetype)initWithExpectedSize:(CGSize)expectedSize cancellationHandler:(nullable void (^)(void))cancellationHandler NS_DESIGNATED_INITIALIZER;

@end

@implementation PSCImageGridViewLoaderToken

- (instancetype)init {
    return [self initWithExpectedSize:CGSizeZero cancellationHandler:NULL];
}

- (instancetype)initWithExpectedSize:(CGSize)expectedSize cancellationHandler:(nullable void (^)(void))cancellationHandler {
    self = [super init];
    if (self) {
        _expectedSize = expectedSize;
        _cancellationHandler = [cancellationHandler copy];
    }
    return self;
}

- (void)cancel {
    void (^cancellationHandler)(void) = self.cancellationHandler;
    if (cancellationHandler) {
        cancellationHandler();
    }
}

@end

@implementation PSCImageGridViewLoader

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

// Custom queue for thumbnail parsing.
+ (NSOperationQueue *)thumbnailQueue {
    static NSOperationQueue *_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 2;
        _queue.name = @"com.pspdfkiosk.thumbnail-queue";
    });
    return _queue;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image Loading

- (void)setMagazine:(nullable PSCMagazine *)magazine {
    _magazine = magazine;
    [self.runningOperation cancel];
}

- (id<PSPDFPageCellImageRequestToken>)requestImageForPageAtIndex:(PSPDFPageIndex)pageIndex availableSize:(CGSize)size completionHandler:(void (^)(UIImage *_Nullable, NSError *_Nullable))completionHandler {
    PSCMagazine *magazine = self.magazine;

    if (magazine.isAvailable) {
        PSPDFMutableRenderRequest *request = [[PSPDFMutableRenderRequest alloc] initWithDocument:magazine];
        request.imageSize = size;

        UIImage *memoryImage = [PSPDFKit.sharedInstance.cache imageForRequest:request imageSizeMatching:PSPDFCacheImageSizeMatchingDefault];
        if (memoryImage) {
            completionHandler(memoryImage, nil);
            PSCImageGridViewLoaderToken *token = [PSCImageGridViewLoaderToken new];
            token.expectedSize = memoryImage.size;
            return token;
        }
        PSPDFRenderTask *task = [[PSPDFRenderTask alloc] initWithRequest:request];
        task.priority = PSPDFRenderQueuePriorityUserInitiated;
        task.completionHandler = ^(UIImage *_Nullable image, NSError *_Nullable error) {
            if (error) {
                PSCLog(@"Failed to render page at index %@: %@", @(pageIndex), error.localizedDescription);
            }
            completionHandler(image, error);
        };
        [PSPDFKit.sharedInstance.renderManager.renderQueue scheduleTask:task];

        PSCImageGridViewLoaderToken *token = [PSCImageGridViewLoaderToken new];
        token.expectedSize = size;
        [token setCancellationHandler:^{
            [task cancel];
        }];
        return token;
    }

    // unavailable: download cover

    // If memory doesn't return anything, queue up here.
    NSBlockOperation *imageLoadOperation = [NSBlockOperation new];
    __weak NSBlockOperation *weakImageLoadOperation = imageLoadOperation;
    [imageLoadOperation addExecutionBlock:^{
        NSBlockOperation *strongImageLoadOperation = weakImageLoadOperation;
        if (strongImageLoadOperation.isCancelled) {
            return;
        }

        UIImage *image = [magazine coverImageForSize:size];
        if (image) {
            completionHandler(image, nil);
            return;
        } else if (strongImageLoadOperation.isCancelled) {
            return;
        }

        // try to download image
        NSURL *imageURL = magazine.imageURL;
        if (imageURL) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
            [request setHTTPShouldHandleCookies:NO];
            [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (data) {
                    UIImage *responseImage = [UIImage imageWithData:data];
                    completionHandler(responseImage, nil);
                } else {
                    PSCLog(@"Failed to download image: %@", error.localizedDescription);
                    completionHandler(nil, error);
                }
            }] resume];
        }
    }];

    PSCImageGridViewLoaderToken *token = [[PSCImageGridViewLoaderToken alloc] initWithExpectedSize:size cancellationHandler:^{
        [imageLoadOperation cancel];
    }];

    [self.class.thumbnailQueue addOperation:imageLoadOperation];
    self.runningOperation = imageLoadOperation;

    return token;
}

@end

NS_ASSUME_NONNULL_END
