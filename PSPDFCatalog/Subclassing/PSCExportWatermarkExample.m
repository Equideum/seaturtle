//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCExportWatermarkExample : PSCExample
@end
@interface PSCWatermarkingDocumentSharingViewController : PSPDFDocumentSharingViewController
@end

@implementation PSCExportWatermarkExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Watermark exported pages (print, email, open in)";
        self.contentDescription = @"Adds a global handler to watermark documents when they are exported.";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 1;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        // To add a watermark, we can either subclass every object that implements the PSPDFDocumentSharingViewControllerDelegate
        // and customize `processorOptionsForDocumentSharingViewController:`, or we simply subclass the PSPDFDocumentSharingViewController
        // directly and override `delegateProcessorOptions` which is the method that queries the delegates
        [builder overrideClass:PSPDFDocumentSharingViewController.class withClass:PSCWatermarkingDocumentSharingViewController.class];
    }]];

    const PSPDFRenderDrawBlock drawBlock = ^(CGContextRef context, NSUInteger page, CGRect cropBox, NSUInteger unused, NSDictionary *options) {
        // Careful, this code is executed on background threads. Only use thread-safe drawing methods.
        NSString *text = @"PSPDFKit Live Watermark";
        NSStringDrawingContext *stringDrawingContext = [NSStringDrawingContext new];
        stringDrawingContext.minimumScaleFactor = 0.1;

        CGContextTranslateCTM(context, 0.0, cropBox.size.height / 2.);
        CGContextRotateCTM(context, -(CGFloat)M_PI / 4.);
        [text drawWithRect:cropBox options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:100], NSForegroundColorAttributeName: [UIColor.redColor colorWithAlphaComponent:0.5] } context:stringDrawingContext];
    };
    [document updateRenderOptions:@{ PSPDFRenderOptionDrawBlockKey: drawBlock } type:PSPDFRenderTypeAll];

    return pdfController;
}

@end

@implementation PSCWatermarkingDocumentSharingViewController

- (void)configureProcessorConfigurationOptions:(PSPDFProcessorConfiguration *)processorConfiguration {
    // Create watermark drawing block. This will be called once per page on exporting, after the PDF and the annotations have been drawn.
    PSPDFRenderDrawBlock drawBlock = ^(CGContextRef context, NSUInteger page, CGRect cropBox, NSUInteger unused, NSDictionary *options) {
        // Careful, this code is executed on background threads. Only use thread-safe drawing methods.
        NSString *text = @"PSPDFKit Example Watermark";
        NSStringDrawingContext *stringDrawingContext = [NSStringDrawingContext new];
        stringDrawingContext.minimumScaleFactor = 0.1;

        CGContextTranslateCTM(context, 0.0, cropBox.size.height / 2.);
        CGContextRotateCTM(context, -(CGFloat)M_PI / 4.);
        [text drawWithRect:cropBox options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:100], NSForegroundColorAttributeName: [UIColor.redColor colorWithAlphaComponent:0.5] } context:stringDrawingContext];
    };

    [processorConfiguration drawOnAllCurrentPages:drawBlock];
}

@end
