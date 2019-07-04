//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PasswordNotPresetExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCPasswordNotPresetExample : PSCExample
@end
@implementation PSCPasswordNotPresetExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Password not preset";
        self.contentDescription = @"Dialog will be shown. Password is 'test123'";
        self.category = PSCExampleCategorySecurity;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"protected.pdf"];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end
