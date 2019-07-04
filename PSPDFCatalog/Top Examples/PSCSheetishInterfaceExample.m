//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'SheetishInterfaceExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCSheetishInterfaceExample : PSCExample
@end
@implementation PSCSheetishInterfaceExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Sheet-ish interface";
        self.contentDescription = @"Uses a vanilla PSPDFViewController presented in a popover presentation controller.";
        self.category = PSCExampleCategoryTop;
        self.priority = 10;
        self.wantsModalPresentation = YES;
        self.customizations = ^(UINavigationController *container) {
            container.modalPresentationStyle = UIModalPresentationPopover;
            container.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        };
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    controller.preferredContentSize = CGSizeMake(640, 480);
    return controller;
}

@end
