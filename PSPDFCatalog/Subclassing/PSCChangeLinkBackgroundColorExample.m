//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCLinkAnnotationView : PSPDFLinkAnnotationView
@end

@interface PSCChangeLinkBackgroundColorExample : PSCExample
@end
@implementation PSCChangeLinkBackgroundColorExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Change the link border color to red";
        self.category = PSCExampleCategorySubclassing;
        self.priority = 170;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameQuickStart];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        [builder overrideClass:PSPDFLinkAnnotationView.class withClass:PSCLinkAnnotationView.class];
    }]];
    return controller;
}

@end

@implementation PSCLinkAnnotationView

- (CGFloat)strokeWidth {
    return 1;
}

- (UIColor *)borderColor {
    return [UIColor.redColor colorWithAlphaComponent:0.5];
}

@end
