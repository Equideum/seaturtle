//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class InstantViewController: InstantViewControllerBase {
    override func showError(withTitle title: String, error: Error? = nil) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        let alertController = UIAlertController.init(title: title, message: String(describing: error), preferredStyle: .alert)
        alertController.show(rootViewController, sender: self)
    }
}
