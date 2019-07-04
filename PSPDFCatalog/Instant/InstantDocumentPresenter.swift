//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

class InstantDocumentPresenter: InstantDocumentPresenterBase {
    override func showError(withTitle title: String, error: Error? = nil) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        let alertController = UIAlertController.init(title: title, message: error?.localizedDescription, preferredStyle: .alert)

        let dismissActionTitle = NSLocalizedString("Dismiss", comment: "")
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .default, handler: { [weak alertController] (_) in
            alertController?.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(dismissAction)
        rootViewController.present(alertController, animated: true, completion: nil)
    }
}
