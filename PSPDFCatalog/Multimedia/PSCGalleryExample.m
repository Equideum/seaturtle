//
//  Copyright © 2012-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCGalleryExample : PSCExample
@end
@implementation PSCGalleryExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Image/Audio/Video/YouTube Gallery";
        self.contentDescription = @"Gallery example with video, images, audio and YouTube gallery items.";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 10;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Add local image gallery on page 1
    PSPDFLinkAnnotation *imageGalleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://localhost/Bundle/sample.gallery"]];
    CGSize pageSize = [document pageInfoForPageAtIndex:0].size;
    CGPoint position = CGPointMake(0.5 * pageSize.width, pageSize.height);
    CGSize size = CGSizeMake(300.0, 200.0);
    imageGalleryAnnotation.boundingBox = CGRectMake(position.x - size.width / 2.0, position.y - size.height, size.width, size.height);
    [document addAnnotations:@[imageGalleryAnnotation] options:nil];

    // Add mp3 audio annotation on page 1
    PSPDFLinkAnnotation *audioAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[type:audio]f.cl.ly/items/3f2y1i0q3W283J3b291f/Up_Above.mp3"]];
    CGPoint annotationPosition = CGPointMake(0.5 * pageSize.width, 0.5 * pageSize.height);
    CGSize annotationSize = CGSizeMake(300.0, 80.0);
    audioAnnotation.boundingBox = CGRectMake(annotationPosition.x - annotationSize.width / 2., annotationPosition.y - annotationSize.height / 2., annotationSize.width, annotationSize.height);
    [document addAnnotations:@[audioAnnotation] options:nil];

    // Add local video on page 1
    PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://localhost/Bundle/video.gallery"]];
    CGPoint center = CGPointMake(0.5 * pageSize.width, 0);
    CGSize gallerySize = CGSizeMake(380.0, 290.0);
    galleryAnnotation.boundingBox = CGRectMake(center.x - gallerySize.width / 2.0, center.y / 2.0, gallerySize.width, gallerySize.height);
    [document addAnnotations:@[galleryAnnotation] options:nil];

    // Dynamically add YouTube video box on page 2
    PSPDFPerformBlockWithoutUndo(document.undoController, ^{
        PSPDFLinkAnnotation *video = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://youtube.com/embed/8B-y4idg700?VQ=HD720&start=10&end=20"]];
        video.boundingBox = CGRectMake(70.0, 150.0, 470.0, 270.0);
        video.pageIndex = 1;
        [document addAnnotations:@[video] options:nil];
    });

    // Add local image on page 2
    PSPDFLinkAnnotation *imageAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:[NSURL fileURLWithPath:[NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"exampleimage.jpg"]]];
    imageAnnotation.linkType = PSPDFLinkAnnotationImage;
    imageAnnotation.fillColor = UIColor.clearColor;
    imageAnnotation.boundingBox = (CGRect){CGPointMake(3.0, 450.0), CGSizeMake(300.0, 150.0)};
    imageAnnotation.pageIndex = 1;
    [document addAnnotations:@[imageAnnotation] options:nil];

    // Add local video with cover on page 3
    PSPDFPerformBlockWithoutUndo(document.undoController, ^{
        PSPDFLinkAnnotation *videoLink = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[autostart:false,coverMode:preview]localhost/Bundle/big_buck_bunny.mp4"]];
        videoLink.boundingBox = CGRectInset((CGRect){.size = [document pageInfoForPageAtIndex:0].size}, 100.0, 100.0);
        videoLink.pageIndex = 2;
        [document addAnnotations:@[videoLink] options:nil];
    });

    return [[PSPDFViewController alloc] initWithDocument:document];
}

@end
