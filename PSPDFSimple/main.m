//
//  Copyright © 2015-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

@import UIKit;
@import PSPDFKit;
#import "AppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        // Since we use Storyboards here, we need to set up the license very early.

        // Set your license key here. PSPDFKit is commercial software.
        // Each PSPDFKit license is bound to a specific app bundle id.
        // Visit https://customers.pspdfkit.com to get your demo or commercial license key.
        [PSPDFKit setLicenseKey:@"YOUR_LICENSE_KEY_GOES_HERE"];

        return UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.class));
    }
}
