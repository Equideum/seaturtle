//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAppDelegate.h"
#import "PSCCatalogViewController.h"
#import "PSCExample.h"
#import "PSCFileHelper.h"
#import "PSCExampleManager.h"
#import "PSCAssetLoader.h"

static NSString *const PSCCatalogSpotlightIndexName = @"PSCCatalogIndex";

@interface PSCAppDelegate () <UINavigationControllerDelegate, PSCExampleRunnerDelegate>
@end

@implementation PSCAppDelegate

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    // Set your license key here. PSPDFKit is commercial software.
    // Each PSPDFKit license is bound to a specific app bundle id.
    // Visit https://customers.pspdfkit.com to get your demo or commercial license key.
    [PSPDFKit setLicenseKey:@"YOUR_LICENSE_KEY_GOES_HERE"];

    // Example how to easily change certain images in PSPDFKit.
    //[self customizeImages];

    // Example how to localize strings in PSPDFKit.
    //[self customizeLocalization];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    // Configure callback for Open In Chrome feature. Optional.
    PSPDFKit.sharedInstance[PSPDFXCallbackURLStringKey] = @"pspdfcatalog://";

    // Create catalog controller delayed because we also dynamically load the license key.
    PSCCatalogViewController *catalog = [[PSCCatalogViewController alloc] initWithStyle:UITableViewStyleGrouped];

    //    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    //    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:[samplesURL URLByAppendingPathComponent:PSCAssetNameQuickStart]];
    //    PSPDFViewController *catalog = [[PSPDFViewController alloc] initWithDocument:document];

    self.catalogStack = [[PSPDFNavigationController alloc] initWithRootViewController:catalog];
    self.catalogStack.delegate = self;
    self.catalogStack.navigationBar.prefersLargeTitles = YES;

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // Forward the window to catalogController early, so it can set the default tintColor
    catalog.keyWindow = self.window;
    self.window.rootViewController = self.catalogStack;
    [self.window makeKeyAndVisible];

    // Enable global undo/redo support for annotation editing.
    application.applicationSupportsShakeToEdit = YES;

    // Opened with the Open In... feature?
    [self handleOpenURL:launchOptions[UIApplicationLaunchOptionsURLKey] options:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL options:(NSDictionary<NSString *, id> *)options {
    NSLog(@"Open %@ from %@ (annotation: %@)", URL, options[UIApplicationLaunchOptionsSourceApplicationKey], options[UIApplicationLaunchOptionsAnnotationKey]);
    return [self handleOpenURL:URL options:options];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler {
    NSLog(@"Opening a shortcut item: %@", shortcutItem);

    NSArray<PSCExample *> *examples = PSCExampleManager.defaultManager.allExamples;
    PSCExample *filteredExample;
    for (PSCExample *example in examples) {
        if ([example.type isEqual:shortcutItem.type]) {
            filteredExample = example;
        }
    }

    if (filteredExample) {
        [self.catalogStack popToRootViewControllerAnimated:NO];

        UIViewController *controller = [filteredExample invokeWithDelegate:self];
        if (controller) {
            [self.catalogStack pushViewController:controller animated:NO];
        }
    } else {
        NSLog(@"Example for shortcut %@ not found.", shortcutItem);
    }
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    if (!url) return NO;

    // Directly open the PDF.
    if (url.isFileURL) {
        NSURL *fileURL = url;
        NSNumber *openInPlaceVal = options[UIApplicationOpenURLOptionsOpenInPlaceKey];
        
        // UIApplicationOpenURLOptionsOpenInPlaceKey is set NO when file is already copied to Documents/Inbox by iOS (ex: in drag and drop)
        if (openInPlaceVal == nil || openInPlaceVal.boolValue == NO) {
            // Move to Documents if already present in Inbox, otherwise copy.
            if (PSCIsFileLocatedInInbox(url)) {
                fileURL = PSCMoveFileURLToDocumentFolderAndOverride(url, YES);
            } else {
                if (!([url startAccessingSecurityScopedResource] && [NSFileManager.defaultManager fileExistsAtPath:(NSString *)url.path])) {
                    return NO;
                }
                fileURL = PSCCopyFileURLToDocumentFolderAndOverride(url, YES);
                // Original URL needs to be used to revoke access.
                [url stopAccessingSecurityScopedResource];
            }
        }
        
        [self presentViewControllerForDocumentAtFileURL:fileURL];
        
        return YES;
        // Only show alert if there's content.
    } else if ([url.scheme.lowercaseString isEqualToString:@"pspdfcatalog"] && url.absoluteString.length > @"pspdfcatalog://".length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Custom Protocol Handler" message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
        UIViewController *frontMostController = self.window.rootViewController;
        while (frontMostController.presentedViewController) {
            frontMostController = frontMostController.presentedViewController;
        }
        [frontMostController presentViewController:alert animated:YES completion:NULL];
    }
    return NO;
}

- (PSPDFViewController *)viewControllerForDocument:(PSPDFDocument *)document {
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    [pdfController.navigationItem setRightBarButtonItems:@[pdfController.thumbnailsButtonItem, pdfController.annotationButtonItem, pdfController.outlineButtonItem, pdfController.searchButtonItem] forViewMode:PSPDFViewModeDocument animated:NO];
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Helper

- (void)presentViewControllerForDocumentAtFileURL:(NSURL *)fileURL {
    PSPDFDocument *document = [[PSPDFDocument alloc] initWithURL:fileURL];
    PSPDFViewController *pdfController = [self viewControllerForDocument:document];
    [self.catalogStack popToRootViewControllerAnimated:NO];
    [self.catalogStack pushViewController:pdfController animated:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Customization

- (void)customizeImages {
    PSPDFKit.sharedInstance.imageLoadingHandler = ^UIImage *(NSString *imageName) {
        if ([imageName isEqualToString:@"knob"]) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0, 20.0), NO, 0.0);
            UIBezierPath *round = [UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, 20.0, 20.0)];
            [round fill];
            UIImage *newKnob = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newKnob;
        }
        return nil;
    };
}

- (void)customizeLocalization {
    // Either use the block-based system.
    PSPDFSetLocalizationBlock(^NSString *(NSString *stringToLocalize) {
        // This will look up strings in language/PSPDFKit.strings inside resources.
        // (In PSPDFCatalog, there are no such files, this is just to demonstrate best practice)
        return NSLocalizedStringFromTable(stringToLocalize, @"PSPDFKit", nil);
        // return [NSString stringWithFormat:@"_____%@_____", stringToLocalize];
    });

    // Or override via dictionary.
    // See PSPDFKit.bundle/en.lproj/PSPDFKit.strings for all available strings.
    PSPDFSetLocalizationDictionary(@{ @"en": @{@"%d of %d": @"Page %d of %d", @"%d-%d of %d": @"Pages %d-%d of %d"} });
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSCExampleRunner

- (nullable UIViewController *)currentViewController {
    return self.window.rootViewController;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:PSCCatalogViewController.class]) {
        navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

@end
