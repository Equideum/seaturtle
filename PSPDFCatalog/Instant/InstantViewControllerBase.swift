//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Instant

class InstantViewControllerBase: PSPDFInstantViewController {
    class var loadingFailureTitle: String {
        return NSLocalizedString("Cannot load the document", comment: "Instant Document Loading Failure Title")
    }

    let instantClient: PSPDFInstantClient
    let instantDocumentDescriptor: PSPDFInstantDocumentDescriptor

    let observer: InstantDocumentObserver

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        try! instantClient.removeLocalStorage()
    }

    init(documentInfo: InstantDocumentInfo) throws {
        instantClient = try PSPDFInstantClient(serverURL: documentInfo.serverURL)
        instantDocumentDescriptor = try instantClient.documentDescriptor(forJWT: documentInfo.jwt)

        observer = InstantDocumentObserver(descriptor: instantDocumentDescriptor)

        super.init(document: instantDocumentDescriptor.editableDocument, configuration: nil)

        do {
            try instantDocumentDescriptor.download(usingJWT: documentInfo.jwt)
        } catch PSPDFInstantError.alreadyDownloaded {
            // This is fine, we only have to reauthenticate. Any other errors are passed up.
            instantDocumentDescriptor.reauthenticate(withJWT: documentInfo.jwt)
        }

        setup(observer: observer)
    }

    func showError(withTitle title: String, error: Error? = nil) {
        fatalError("Not implemented")
    }

    private func setup(observer: InstantDocumentObserver) {
        observer.didFailDownload = { [weak self] (_, error) in
            self?.showError(withTitle: InstantViewController.loadingFailureTitle, error: error)
        }

        observer.didFailSyncing = { [weak self] (_, error) in
            // ignoring cancel errors which are sent often by Instant 1.0
            if error?.code == NSUserCancelledError {
                return
            }

            self?.showError(withTitle: InstantViewController.loadingFailureTitle, error: error)
        }

        observer.didFailAuthentication = { [weak self] _ in
            self?.showError(withTitle: InstantViewController.loadingFailureTitle)
        }
    }
}
