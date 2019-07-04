//
//  Copyright © 2016-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class DisallowCopyApplicationPolicy: NSObject, PSPDFApplicationPolicy {

    // MARK: PSPDFApplicationPolicy
    func hasPermission(forEvent event: PSPDFPolicyEvent, isUserAction: Bool) -> Bool {
        if event == .pasteboard {
            return false
        }
        return true
    }
}
