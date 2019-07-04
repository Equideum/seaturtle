//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCButtonImageGalleryExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCButtonImageGalleryExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Galleries with button activation";
        self.contentDescription = @"Buttons that show/hide gallery or videos.";
        self.category = PSCExampleCategoryMultimedia;
        self.priority = 51;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader temporaryDocumentWithString:@"Galleries with button activation"];
    document.annotationSaveMode = PSPDFAnnotationSaveModeDisabled;

    {
        PSPDFFreeTextAnnotation *galleryText = [[PSPDFFreeTextAnnotation alloc] initWithContents:@"Gallery that opens inline\nPSPDFActionOptionButtonKey : @YES"];
        galleryText.boundingBox = CGRectMake(20.0, 700.0, galleryText.boundingBox.size.width, galleryText.boundingBox.size.height);

        // @{PSPDFActionOptionButtonKey : @"pspdfkit://localhost/Bundle/eye.png"};
        // Setting the button option to yes will show the default button.
        PSPDFURLAction *galleryAction = [[PSPDFURLAction alloc] initWithURL:[NSURL URLWithString:@"pspdfkit://localhost/Bundle/sample.gallery"] options:@{ PSPDFActionOptionButtonKey: @YES }];
        PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithAction:galleryAction];
        galleryAnnotation.boundingBox = CGRectMake(200.0, 560.0, 400.0, 300.0);
        [document addAnnotations:@[galleryText, galleryAnnotation] options:nil];
    }

    {
        PSPDFFreeTextAnnotation *galleryText = [[PSPDFFreeTextAnnotation alloc] initWithContents:@"Gallery that opens inline with a custom button image\nPSPDFActionOptionButtonKey : @\"https://www.dropbox.com/s/8diroz5npb3eciy/webimage2%402x.png?raw=1\""];
        galleryText.boundingBox = CGRectMake(20.0, 400.0, galleryText.boundingBox.size.width, galleryText.boundingBox.size.height);

        // Setting the button option to an URL will load this URL. The URL can be local or remote. Use pspdfkit://localhost for local URLs.
        PSPDFAction *action = [[PSPDFURLAction alloc] initWithURL:[NSURL URLWithString:@"pspdfkit://localhost/Bundle/sample.gallery"] options:@{ PSPDFActionOptionButtonKey: @"https://www.dropbox.com/s/8diroz5npb3eciy/webimage2%402x.png?raw=1" }];
        PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithAction:action];
        galleryAnnotation.boundingBox = CGRectMake(200.0, 350.0, 250.0, 200.0);
        [document addAnnotations:@[galleryText, galleryAnnotation] options:nil];
    }

    {
        PSPDFFreeTextAnnotation *popovertext = [[PSPDFFreeTextAnnotation alloc] initWithContents:@"Opens Gallery in popover"];
        popovertext.boundingBox = CGRectMake(20.0, 250.0, popovertext.boundingBox.size.width, popovertext.boundingBox.size.height);

        PSPDFLinkAnnotation *galleryAnnotation = [[PSPDFLinkAnnotation alloc] initWithURL:(NSURL *)[NSURL URLWithString:@"pspdfkit://[popover:1,size:50x50]localhost/Bundle/sample.gallery"]];
        CGSize size = CGSizeMake(200.0, 100.0);
        galleryAnnotation.boundingBox = CGRectMake(200.0, 250.0, size.width, size.height);
        [document addAnnotations:@[popovertext, galleryAnnotation] options:nil];
    }

    {
        PSPDFFreeTextAnnotation *webText = [[PSPDFFreeTextAnnotation alloc] initWithContents:@"Link that opens modally.\nPSPDFActionOptionButtonKey : @YES,\nPSPDFActionOptionModalKey : @YES,\nPSPDFActionOptionSizeKey : @(CGSizeMake(550.0, 550.0)"];
        webText.boundingBox = CGRectMake(20.0, 100.0, webText.boundingBox.size.width, webText.boundingBox.size.height);

        PSPDFAction *action = [[PSPDFURLAction alloc] initWithURL:[NSURL URLWithString:@"pspdfkit://www.apple.com/ipad/"] options:@{ PSPDFActionOptionButtonKey: @YES, PSPDFActionOptionModalKey: @YES, PSPDFActionOptionSizeKey: @(CGSizeMake(550.0, 550.0)) }];
        PSPDFLinkAnnotation *webAnnotation = [[PSPDFLinkAnnotation alloc] initWithAction:action];
        webAnnotation.boundingBox = CGRectMake(200.0, 100.0, 200.0, 200.0);
        [document addAnnotations:@[webText, webAnnotation] options:nil];
    }

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        builder.editableAnnotationTypes = nil; // disable free text editing here as we use them as labels.
    }]];
    return pdfController;
}

@end
