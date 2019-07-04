//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomGalleryBackgroundExample : PSCExample
@end

@interface PSCCustomGalleryContentView : PSPDFGalleryContentView
@end
@interface PSCCustomGalleryImageContentView : PSPDFGalleryImageContentView
@end
@interface PSCCustomGalleryContentCaptionView : PSPDFGalleryContentCaptionView
@end
@interface PSCCustomGalleryEmbeddedBackgroundView : PSPDFGalleryEmbeddedBackgroundView
@end
@interface PSCCustomGalleryFullscreenBackgroundView : PSPDFGalleryFullscreenBackgroundView
@end

@implementation PSCCustomGalleryBackgroundExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Image Gallery Background";
        self.contentDescription = @"Changes internal gallery classes to customize the default background gradient.";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 100;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Dynamically add gallery annotation.
    PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://localhost/Bundle/sample.gallery"]];
    CGSize pageSize = [document pageInfoForPageAtIndex:0].size;
    CGSize size = CGSizeMake(400.0, 300.0);
    galleryAnnotation.boundingBox = CGRectMake((pageSize.width - size.width) / 2., (pageSize.height - size.height) / 2., size.width, size.height);
    [document addAnnotations:@[galleryAnnotation] options:nil];

    [PSCCustomGalleryEmbeddedBackgroundView appearance].backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [PSCCustomGalleryFullscreenBackgroundView appearance].backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {

                                                                                                    // You need to override both, PSPDFGalleryContentView and PSPDFScrollableGalleryContentView - both will be used.
                                                                                                    [builder overrideClass:PSPDFGalleryContentView.class withClass:PSCCustomGalleryContentView.class];
                                                                                                    [builder overrideClass:PSPDFGalleryImageContentView.class withClass:PSCCustomGalleryImageContentView.class];
                                                                                                    [builder overrideClass:PSPDFGalleryEmbeddedBackgroundView.class withClass:PSCCustomGalleryEmbeddedBackgroundView.class];
                                                                                                    [builder overrideClass:PSPDFGalleryFullscreenBackgroundView.class withClass:PSCCustomGalleryFullscreenBackgroundView.class];
                                                                                                }]];

    return pdfController;
}

@end

@implementation PSCCustomGalleryImageContentView

+ (Class)captionViewClass {
    return [PSCCustomGalleryContentCaptionView class];
}

@end

@implementation PSCCustomGalleryContentView

+ (Class)captionViewClass {
    return [PSCCustomGalleryContentCaptionView class];
}

@end

@implementation PSCCustomGalleryContentCaptionView

+ (Class)layerClass {
    // Disable gradient background.
    return [CALayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.contentInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        self.backgroundColor = UIColor.clearColor;
        self.label.shadowColor = UIColor.blackColor;
    }
    return self;
}

@end

@implementation PSCCustomGalleryEmbeddedBackgroundView
@end
@implementation PSCCustomGalleryFullscreenBackgroundView
@end
