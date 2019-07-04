//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCCustomGalleryExample : PSCExample
@end
@implementation PSCCustomGalleryExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Custom Gallery Example";
        self.contentDescription = @"Add animated gif or inline video.";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 200;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    // Set up the document.
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    // Get rects to position.
    UIImage *image = [UIImage imageNamed:@"mas_audio_b41570.gif"];
    CGSize imageSize = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5));
    CGSize pageSize = [document pageInfoForPageAtIndex:0].size;

    // Create tap action (open new popover with video in fullscreen)
    PSPDFURLAction *videoAction = [[PSPDFURLAction alloc] initWithURLString:@"http://movietrailers.apple.com/movies/wb/islandoflemurs/islandoflemurs-tlr1_480p.mov?width=848&height=480"];

    // Create action that opens a sheet.
    NSDictionary *options = @{
        PSPDFActionOptionControlsKey: @NO, // Disable browser controls.
        PSPDFActionOptionSizeKey: [NSValue valueWithCGSize:CGSizeMake(620.0, 400.0)] // Will present as sheet on iPad, is ignored on iPhone.
    };
    PSPDFURLAction *sheetVideoAction = [[PSPDFURLAction alloc] initWithURL:videoAction.URL options:options];

    // First example - use a special link annotation.
    PSPDFLinkAnnotation *videoLink = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://localhost/Bundle/mas_audio_b41570.gif"]];
    videoLink.boundingBox = CGRectMake(0.0, pageSize.height - imageSize.height - 64., imageSize.width, imageSize.height);
    videoLink.controlsEnabled = NO; // Disable gallery touch processing.
    videoLink.action.subActions = @[sheetVideoAction]; // attach action after the image action.
    [document addAnnotations:@[videoLink] options:nil];

    // Second example - just add the video inline.
    // Notice the pspdfkit:// prefix that enables automatic video detection.
    PSPDFLinkAnnotation *videoEmbedded = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://movietrailers.apple.com/movies/wb/islandoflemurs/islandoflemurs-tlr1_480p.mov?width=848&height=480"]];
    videoEmbedded.boundingBox = CGRectMake(pageSize.width - imageSize.width, pageSize.height - imageSize.height - 64., imageSize.width, imageSize.height);
    [document addAnnotations:@[videoEmbedded] options:nil];

    return [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.editableAnnotationTypes = nil; // Disable annotation editing.
    }]];
}

@end
