//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCPasswordPresetExample.m' for the Objective-C version of this example.

import Foundation

class PasswordPresetExample: PSCExample {

    override init() {
        super.init()
        title = "Password preset"
        category = .security
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let document = PSCAssetLoader.document(withName: PSCAssetName(rawValue: "protected.pdf"))
        document?.unlock(withPassword: "test123")
        return PSPDFViewController(document: document)
    }
}
