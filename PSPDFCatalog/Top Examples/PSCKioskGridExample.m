//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'KioskGridExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCGridViewController.h"

@interface PSCKioskGridExample : PSCExample
@end
@implementation PSCKioskGridExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Kiosk Grid";
        self.contentDescription = @"Displays all documents in the Samples directory.";
        self.type = @"com.pspdfkit.catalog.kiosk";
        self.category = PSCExampleCategoryTop;
        self.priority = 3;
        self.wantsModalPresentation = YES; // Both PSCGridViewController and PSCAppDelegate want to be the delegate of the navigation controller, so use separate navigation controllers.
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    return [PSCGridViewController new];
}

@end
