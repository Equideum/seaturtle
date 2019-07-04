//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'SplitScreenExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCSplitViewController.h"

@interface PSCSplitScreenExample : PSCExample
@end
@implementation PSCSplitScreenExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Split-screen interface";
        self.contentDescription = @"Uses a split-screen interface with a floating toolbar.";
        self.category = PSCExampleCategoryTop;
        self.priority = 9;
        self.wantsModalPresentation = YES;
        self.embedModalInNavigationController = NO;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    return [[PSCSplitViewController alloc] init];
}

@end
