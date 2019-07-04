//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import "PSCKioskPDFViewController.h"

@interface PSCCustomAlertControllerAppearance : PSCExample <PSPDFViewControllerDelegate>
@end

@implementation PSCCustomAlertControllerAppearance

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"UIAlertController Appearance";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    PSPDFViewController *controller = [[PSCKioskPDFViewController alloc] initWithDocument:document];
    controller.delegate = self;
    return controller;
}

- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated {
    // UIAppearance doesn't work for UIAlertController and tint needs to be set after presentation.
    if ([controller isKindOfClass:UIAlertController.class]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            controller.view.tintColor = UIColor.orangeColor;
        });
    }

    return YES;
}

@end
