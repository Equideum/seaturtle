//
//  Copyright © 2011-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import "PSCBasicViewController.h"
#import "PSCAvailability.h"

#if !__has_feature(objc_arc)
#error "Compile this file with ARC"
#endif

@implementation PSCBasicViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)closeModalView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
