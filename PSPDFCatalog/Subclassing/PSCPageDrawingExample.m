//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"
#import <tgmath.h>

@interface PSCPageDrawingExample : PSCExample
@end
@implementation PSCPageDrawingExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Page Drawing";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 501;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.title = @"Custom Page Drawing";
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];

    const PSPDFRenderDrawBlock drawBlock = ^(CGContextRef context, NSUInteger page, CGRect cropBox, NSUInteger unused, NSDictionary *options) {
        // Careful, this code is executed on background threads. Only use thread-safe drawing methods.

        // Set up the text and it's drawing attributes.
        NSString *overlayText = @"Example Overlay";
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:24.];
        UIColor *textColor = UIColor.blueColor;
        NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};

        // Set text drawing mode (fill).
        CGContextSetTextDrawingMode(context, kCGTextFill);

        // Calculate the font box to center the text on the page.
        CGSize boundingBox = [overlayText sizeWithAttributes:attributes];
        CGPoint point = CGPointMake(__tg_round((cropBox.size.width - boundingBox.width) / 2), __tg_round((cropBox.size.height - boundingBox.height) / 2));

        // Finally draw the text.
        [overlayText drawAtPoint:point withAttributes:attributes];
    };
    [document updateRenderOptions:@{ PSPDFRenderOptionDrawBlockKey: drawBlock } type:PSPDFRenderTypeAll];

    return pdfController;
}

@end
