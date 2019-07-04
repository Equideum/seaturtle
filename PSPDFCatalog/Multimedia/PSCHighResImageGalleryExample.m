//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCHighResImageGalleryExample : PSCExample
@end
@implementation PSCHighResImageGalleryExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"High-Resolution Image Gallery Example";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 200;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://localhost/Bundle/highres.gallery"]];
    CGSize pageSize = [document pageInfoForPageAtIndex:0].size;
    CGSize size = CGSizeMake(400.0, 300.0);
    galleryAnnotation.boundingBox = CGRectMake((pageSize.width - size.width) / 2.0, (pageSize.height - size.height) / 2.0, size.width, size.height);
    [document addAnnotations:@[galleryAnnotation] options:nil];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
    return pdfController;
}

@end
