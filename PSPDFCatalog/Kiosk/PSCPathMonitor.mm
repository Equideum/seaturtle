//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCPathMonitor.h"

#include <mutex>

NS_ASSUME_NONNULL_BEGIN

NSString *const PSCPathMonitorErrorDomain = @"PSCPathMonitorErrorDomain";

@interface PSCPathMonitor () {
    std::mutex _listLock;
}

@property (nonatomic, readonly) NSMutableDictionary<NSURL *, dispatch_source_t> *monitorSources;

@end

@implementation PSCPathMonitor

- (instancetype)init {
    if ((self = [super init])) {
        _monitorSources = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    for (dispatch_source_t source in self.monitorSources) {
        dispatch_source_cancel(source);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Monitoring

- (BOOL)isMonitoringFileURL:(NSURL *)fileURL {
    std::lock_guard<std::mutex> listLock(_listLock);
    NSParameterAssert(fileURL && fileURL.isFileURL);
    return (self.monitorSources[fileURL] != nil);
}

- (BOOL)startMonitoringFileURL:(NSURL *)fileURL error:(NSError *_Nullable __autoreleasing *)error queue:(nullable dispatch_queue_t)queue updateHandler:(void (^)(NSURL *fileURL))updateHandler {
    std::lock_guard<std::mutex> listLock(_listLock);
    NSParameterAssert(fileURL && fileURL.isFileURL);
    NSParameterAssert(updateHandler);
    if (self.monitorSources[fileURL] != nil) {
        if (error) {
            *error = [NSError errorWithDomain:PSCPathMonitorErrorDomain code:PSCPathMonitorErrorCodeAlreadyMonitoring userInfo:nil];
        }
        return NO;
    }

    int fileDescriptor = open(fileURL.fileSystemRepresentation, O_EVTONLY);
    if (fileDescriptor < 0) {
        if (error) {
            *error = [NSError errorWithDomain:PSCPathMonitorErrorDomain code:PSCPathMonitorErrorCodeCanNotCreateFileDescriptor userInfo:nil];
        }
        return NO;
    }

    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE, queue ?: dispatch_get_main_queue());
    if (source == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:PSCPathMonitorErrorDomain code:PSCPathMonitorErrorCodeCanNotCreateDispatchSource userInfo:nil];
        }
        return NO;
    }

    // Ensure we close the file descriptor if we no longer need the source
    dispatch_source_set_cancel_handler(source, ^{
        close(fileDescriptor);
    });

    // This is the actual update that is going on
    dispatch_source_set_event_handler(source, ^{
        updateHandler(fileURL);
    });

    self.monitorSources[fileURL] = source;

    // dispatch_source_t are initialized with a suspend count of 1 and need to be resumed before they start delivering events.
    dispatch_resume(source);

    return YES;
}

- (void)stopMonitoringFileURL:(NSURL *)fileURL {
    std::lock_guard<std::mutex> listLock(_listLock);
    NSParameterAssert(fileURL && fileURL.isFileURL);
    if (dispatch_source_t source = self.monitorSources[fileURL]) {
        dispatch_source_cancel(source);
    }
    [self.monitorSources removeObjectForKey:fileURL];
}

@end

NS_ASSUME_NONNULL_END
