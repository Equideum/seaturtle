//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'CustomStampAnnotationsExample.swift' for the Swift version of this example.

#import "NSObject+PSCDeallocationBlock.h"
#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomStampAnnotationsExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCCustomStampAnnotationsExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom stamp annotations";
        self.contentDescription = @"Customizes the default set of stamps in the PSPDFStampViewController.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 200;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    NSMutableArray<PSPDFStampAnnotation *> *defaultStamps = [NSMutableArray array];
    for (NSString *stampTitle in @[@"Great!", @"Stamp", @"Like"]) {
        PSPDFStampAnnotation *stamp = [[PSPDFStampAnnotation alloc] initWithTitle:stampTitle];
        stamp.boundingBox = CGRectMake(0.0, 0.0, 200.0, 70.0);
        [defaultStamps addObject:stamp];
    }
    // Careful with memory - you don't wanna add large images here.
    PSPDFStampAnnotation *imageStamp = [[PSPDFStampAnnotation alloc] init];
    imageStamp.image = [UIImage imageNamed:@"exampleimage.jpg"];
    imageStamp.boundingBox = CGRectMake(0.0, 0.0, imageStamp.image.size.width / 4., imageStamp.image.size.height / 4.);
    [defaultStamps addObject:imageStamp];

    NSURL *samplesURL = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"Samples"];
    NSURL *logoURL = [samplesURL URLByAppendingPathComponent:@"PSPDFKit Logo.pdf"];

    PSPDFStampAnnotation *vectorStamp = [[PSPDFStampAnnotation alloc] init];
    vectorStamp.appearanceStreamGenerator = [[PSPDFFileAppearanceStreamGenerator alloc] initWithFileURL:logoURL];
    vectorStamp.boundingBox = CGRectMake(0.0, 0.0, 200.0, 200.0);
    [defaultStamps addObject:vectorStamp];

    [PSPDFStampViewController setDefaultStampAnnotations:defaultStamps];

    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    pdfController.delegate = self;
    pdfController.navigationItem.rightBarButtonItems = @[pdfController.annotationButtonItem];

    // Add cleanup block so other examples will use the default stamps.
    [pdfController psc_addDeallocBlock:^{
        [PSPDFStampViewController setDefaultStampAnnotations:nil];
    }];

    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (BOOL)pdfViewController:(PSPDFViewController *)pdfController shouldShowController:(UIViewController *)controller options:(nullable NSDictionary<NSString *, id> *)options animated:(BOOL)animated {
    PSPDFStampViewController *stampController = (PSPDFStampViewController *)PSPDFChildViewControllerForClass(controller, PSPDFStampViewController.class);
    stampController.customStampEnabled = NO;
    stampController.dateStampsEnabled = NO;

    return YES;
}

@end
