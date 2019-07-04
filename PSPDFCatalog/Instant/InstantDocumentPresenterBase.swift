//
//  Copyright © 2018-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import PSPDFKitUI

/**
 * InstantDocumentPresenter is responsible for verifying the URL and opening the Instant Document Screen.
 */
class InstantDocumentPresenterBase {
    private let codeResolver: InstantCodeResolver = InstantCodeResolver()

    func showError(withTitle title: String, error: Error? = nil) {
        fatalError("Not implemented")
    }

    /**
     - Parameter urlString: Instant API endpoint scanned from the barcode or entered by the user.
     */
    func verify(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showError(withTitle: NSLocalizedString("This is not an Instant document link.", comment: "Instant Input String Conversion To URL Failure Title"))
            return
        }
        verifyAndOpenOnSuccess(url) { error in
            if let error = error {
                self.showError(withTitle: InstantViewController.loadingFailureTitle, error: error)
            }
        }
    }

    /**
     - Parameter url: Instant API endpoint URL
     */
    func verifyAndOpenOnSuccess(_ url: URL, _ completion: @escaping (Error?) -> Void) {
        let progressText = NSLocalizedString("Verifying", comment: "Instant Document Code Verification Progress Text")
        let progressHUDItem = PSPDFStatusHUDItem.indeterminateProgress(withText: progressText)
        progressHUDItem.setHUDStyle(.black)

        progressHUDItem.push(animated: true) {
            self.codeResolver.resolve(url) { result in
                switch result {
                case let .success(documentInfo):
                    let successHUDItem = PSPDFStatusHUDItem.success(withText: nil)
                    successHUDItem.setHUDStyle(.black)
                    successHUDItem.pushAndPop(withDelay: 1, animated: true) {
                        do {
                            try InstantDocumentPresenter.openDocument(documentInfo)
                        } catch {
                            completion(error)
                        }
                        completion(nil)
                    }
                case let .failure(error):
                    completion(error)
                }

                progressHUDItem.pop(animated: true, completion: nil)
            }
        }
    }

    @discardableResult class func openDocument(_ documentInfo: InstantDocumentInfo) throws -> Bool {
        let viewController = try InstantViewController(documentInfo: documentInfo)
        let navigationController = UINavigationController(rootViewController: viewController)
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return false }
        rootViewController.pspdf_frontmost.present(navigationController, animated: true, completion: nil)
        return true
    }
}
