//
//  Copyright © 2013-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'AnnotationLinkEditorExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCAnnotationLinkEditorExample : PSCExample
@end
@implementation PSCAnnotationLinkEditorExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Annotation Link Editor";
        self.contentDescription = @"Shows how to create link annotations.";
        self.category = PSCExampleCategoryAnnotations;
        self.priority = 71;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:PSCAssetNameJKHF];
    return [[PSPDFViewController alloc] initWithDocument:document configuration:[PSPDFConfiguration configurationWithBuilder:^(PSPDFConfigurationBuilder *builder) {
        // We only allow creating link annotations here
        builder.editableAnnotationTypes = [NSSet setWithArray:@[PSPDFAnnotationStringLink]];
    }]];
}

@end
