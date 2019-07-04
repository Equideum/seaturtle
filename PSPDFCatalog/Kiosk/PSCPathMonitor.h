//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const PSCPathMonitorErrorDomain;

typedef NS_ERROR_ENUM(PSCPathMonitorErrorDomain, PSCPathMonitorErrorCode) {
    PSCPathMonitorErrorCodeAlreadyMonitoring = 1, /// The given URL is already monitored by this path monitor instance.

    PSCPathMonitorErrorCodeCanNotCreateFileDescriptor = -1, /// A file descriptor for the given URL could not be created.
    PSCPathMonitorErrorCodeCanNotCreateDispatchSource = -2 /// A dispatch source for the given URL could not be created.
};

/// A PSCPathMonitor monitors file URLs pointing to directories or files for write and delete actions.
/// This enables you to e.g. get notified when a new file is created inside a directory.
@interface PSCPathMonitor : NSObject

/// Checks if monitoring is in place for the given fileURL.
///
/// @param fileURL The file URL to check for.
///
/// @return YES if the given resource is already monitored, NO otherwise.
- (BOOL)isMonitoringFileURL:(NSURL *)fileURL;

/// Starts monitoring the given file URL if it is not already monitored.
///
/// When a change is detected that affects the resource an updateHandler is called on the passed in queue.
///
/// @param fileURL       The resource you want to start monitoring.
/// @param error         Upon return contains an error if monitoring was not started.
/// @param queue         The queue you want `updateHandler` to be called on or `nil` if you want it to be called on the main queue.
/// @param updateHandler The update handler that should be called every time changes are detected that affect the `fileURL`.
///
/// @return `YES` if the receiver started monitoring the file URL or `NO` otherwise.
- (BOOL)startMonitoringFileURL:(NSURL *)fileURL error:(NSError **)error queue:(nullable dispatch_queue_t)queue updateHandler:(void (^)(NSURL *fileURL))updateHandler;

/// Stops monitoring the given file URL.
///
/// If no monitoring was in place, this method does nothing.
///
/// @param fileURL The resource you want to stop monitoring.
- (void)stopMonitoringFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
