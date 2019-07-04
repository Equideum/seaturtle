//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PasswordPresetExample.swift' for the Swift version of this example.

#import "PSCAssetLoader.h"
#import "PSCExample.h"

@interface PSCPasswordPresetExample : PSCExample
@end
@implementation PSCPasswordPresetExample

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"Password preset";
        self.category = PSCExampleCategorySecurity;
    }
    return self;
}

- (nullable UIViewController *)invokeWithDelegate:(id<PSCExampleRunnerDelegate>)delegate {
    PSPDFDocument *document = [PSCAssetLoader documentWithName:@"protected.pdf"];
    [document unlockWithPassword:@"test123"];
    PSPDFViewController *controller = [[PSPDFViewController alloc] initWithDocument:document];
    return controller;
}

@end
