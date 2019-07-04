//
//  Copyright © 2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"


@interface PSCDownloader: NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) NSProgress *progress;
@property (nonatomic) NSProgress *downloadProgress;
@property (nonatomic) NSProgress *moveProgress;

@property (nonatomic) NSURL *destinationFileURL;
@property (nonatomic) NSURL *remoteURL;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *task;

@property (nonatomic, copy) void (^didFinishDownload)(NSURL *location);

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL destinationURL:(NSURL *)destinationURL;
- (void)cleanup;

@end


@interface PSCDocumentProgressExample : PSCExample

@property (nonatomic) PSCDownloader *downloader;
@property (nonatomic) UIBarButtonItem *cancelButton;

@property (nonatomic) NSURL *destinationURL;

@end

@implementation PSCDocumentProgressExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Document progress";
        self.contentDescription = @"Show file download progress before the PDF file becomes available.";
        self.category = PSCExampleCategoryDocumentDataProvider;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    [self.downloader cleanup];

    self.downloader = [[PSCDownloader alloc] initWithRemoteURL:self.remoteURL destinationURL:self.destinationFileURL];
    __weak typeof(self) weakSelf;
    self.downloader.didFinishDownload = ^(NSURL *location) {
        weakSelf.cancelButton.enabled = NO;
    };

    PSPDFCoordinatedFileDataProvider *provider = [[PSPDFCoordinatedFileDataProvider alloc] initWithFileURL:self.destinationFileURL progress:self.downloader.progress];
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithDataProviders:@[provider]];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];

    NSArray<UIBarButtonItem *> *existingItems = controller.navigationItem.rightBarButtonItems;
    NSArray<UIBarButtonItem *> *buttonItems = [@[self.cancelButton] arrayByAddingObjectsFromArray:existingItems];
    [controller.navigationItem setRightBarButtonItems:buttonItems animated:NO];

    return controller;
}

- (NSURL *)destinationFileURL {
    if (!_destinationURL) {
        _destinationURL = PSCTempFileURLWithPathExtension(@"document", @"pdf");
    }
    return _destinationURL;
}

- (NSURL *)remoteURL {
    return [NSURL URLWithString:@"https://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf"];
}

- (UIBarButtonItem *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:PSPDFLocalize(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    }
    return _cancelButton;
}

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {
    sender.enabled = NO;

    [self.downloader.progress cancel];
    [self.downloader cleanup];
}

@end

@implementation PSCDownloader

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL destinationURL:(NSURL *)destinationURL {
    if ((self = [super init])) {
        _progress = [NSProgress progressWithTotalUnitCount:100];
        _downloadProgress = [NSProgress progressWithTotalUnitCount:1];
        _moveProgress = [NSProgress progressWithTotalUnitCount:100];

        _remoteURL = remoteURL;
        _destinationFileURL = destinationURL;

        // Download the file using URLSession API.
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:NSOperationQueue.mainQueue];

        _task = [_session downloadTaskWithURL:_remoteURL];
        [_task resume];

        // Setup progress hierarchy. The download should take much longer than the final move.
        [_progress addChild:_downloadProgress withPendingUnitCount:99];
        [_progress addChild:_moveProgress withPendingUnitCount:1];
    }

    return self;
}

- (void)cleanup {
    [self.task cancel];
    [self.session invalidateAndCancel];

    [NSFileManager.defaultManager removeItemAtURL:self.destinationFileURL error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [NSFileManager.defaultManager moveItemAtURL:location toURL:self.destinationFileURL error:nil];

    self.moveProgress.completedUnitCount = self.moveProgress.totalUnitCount;

    self.didFinishDownload(location);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error != nil) {
        NSLog(@"%@", error.localizedDescription);

        // Complete the progress.
        self.progress.completedUnitCount = self.progress.totalUnitCount;
    }
}

@end
