//
//  Copyright © 2014-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCLargeFontNoteAnnotationViewController : PSPDFNoteAnnotationViewController
@end
@interface PSCLargeNoteControllerFontExample : PSCExample
@end
@implementation PSCLargeNoteControllerFontExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Customized PSPDFNoteAnnotationViewController font";
        self.category = PSCExampleCategoryViewCustomization;
        self.priority = 89;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFNoteAnnotationViewController.class withClass:PSCLargeFontNoteAnnotationViewController.class];
    }]];

    // We create appearance rule on the custom subclass
    // so that this example doesn't change all note controllers within the Catalog
    [UITextView appearanceWhenContainedInInstancesOfClasses:@[PSCLargeFontNoteAnnotationViewController.class]].font = [UIFont fontWithName:@"Noteworthy" size:30.];
    [UITextView appearanceWhenContainedInInstancesOfClasses:@[PSCLargeFontNoteAnnotationViewController.class]].textColor = UIColor.greenColor;

    return pdfController;
}

@end

@implementation PSCLargeFontNoteAnnotationViewController

- (void)updateTextView:(UITextView *)textView {
    // Possible to set the color here, but it's even cleaner to use UIAppearance rules (see above).
    // textView.font = [UIFont fontWithName:@"Futura" size:40.];
    // textView.textColor = UIColor.brownColor;
}

@end
