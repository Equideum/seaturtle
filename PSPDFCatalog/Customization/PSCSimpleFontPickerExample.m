//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCSimpleFontPickerViewController : PSPDFFontPickerViewController
@end

@interface PSCSimpleFontPickerExample : PSCExample <PSPDFViewControllerDelegate>
@end
@implementation PSCSimpleFontPickerExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Simplified Font Picker";
        self.category = PSCExampleCategoryViewCustomization;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];

    // Create a sample annotation.
    PSPDFFreeTextAnnotation *freeText = [[PSPDFFreeTextAnnotation alloc] initWithContents:@"This is a test free-text annotation."];
    freeText.fillColor = UIColor.whiteColor;
    freeText.fontSize = 30.0;
    freeText.boundingBox = CGRectMake(300.0, 300.0, 150.0, 150.0);
    [freeText sizeToFit];
    [document addAnnotations:@[freeText] options:nil];

    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFFontPickerViewController.class withClass:PSCSimpleFontPickerViewController.class];
    }]];
    pdfController.delegate = self;
    return pdfController;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController willBeginDisplayingPageView:(PSPDFPageView *)pageView forPageAtIndex:(NSInteger)pageIndex {
    // Just a convenience helper to automatically select the free text annotation.
    if (pageIndex == 0) {
        pageView.selectedAnnotations = [pdfController.document annotationsForPageAtIndex:0 type:PSPDFAnnotationTypeFreeText];
        [pageView showMenuIfSelectedAnimated:YES];
    }
}

@end

@implementation PSCSimpleFontPickerViewController

+ (NSArray *)psc_fontFamilyDescriptors {
    NSArray *fontNames = @[@"Arial", @"Calibri", @"Times New Roman", @"Courier New", @"Helvetica", @"Comic Sans MS"];

    NSMutableArray *fontFamilyDescription = [NSMutableArray array];
    for (NSString *fontName in fontNames) {
        [fontFamilyDescription addObject:[[UIFontDescriptor alloc] initWithFontAttributes:@{UIFontDescriptorNameAttribute: fontName}]];
    }

    return fontFamilyDescription;
}

- (instancetype)initWithFontFamilyDescriptors:(NSArray *)fontFamilyDescriptors {
    // Choose a default set if none is given.
    if (!fontFamilyDescriptors) {
        fontFamilyDescriptors = [self.class psc_fontFamilyDescriptors];
    }

    return [super initWithFontFamilyDescriptors:fontFamilyDescriptors];
}

- (BOOL)showDownloadableFonts {
    return NO;
}

- (BOOL)searchEnabled {
    return NO;
}

@end
