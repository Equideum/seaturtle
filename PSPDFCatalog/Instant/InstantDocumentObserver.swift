//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import Instant

class InstantDocumentObserver {

    // Callback will be called on this queue. Set to main queue by default.
    var queue = DispatchQueue.main

    let instantDocumentDescriptor: PSPDFInstantDocumentDescriptor

    init(descriptor: PSPDFInstantDocumentDescriptor) {
        instantDocumentDescriptor = descriptor

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didFinishDownload(_:)), name: .PSPDFInstantDidFinishDownload, object: instantDocumentDescriptor)
        nc.addObserver(self, selector: #selector(didFailDownload(_:)), name: .PSPDFInstantDidFailDownload, object: instantDocumentDescriptor)
        nc.addObserver(self, selector: #selector(didFailSyncing(_:)), name: .PSPDFInstantDidFailSyncing, object: instantDocumentDescriptor)
        nc.addObserver(self, selector: #selector(didFailAuthentication(_:)), name: .PSPDFInstantDidFailAuthentication, object: instantDocumentDescriptor)
    }

    var didFinishDownload: ((_ descriptor: PSPDFInstantDocumentDescriptor) -> Void)?
    var didFailDownload: ((_ descriptor: PSPDFInstantDocumentDescriptor, _ error: NSError?) -> Void)?
    var didFailSyncing: ((_ descriptor: PSPDFInstantDocumentDescriptor, _ error: NSError?) -> Void)?
    var didFailAuthentication: ((_ descriptor: PSPDFInstantDocumentDescriptor) -> Void)?

    // MARK: Notification Handlers

    @objc private func didFinishDownload(_ notification: NSNotification) {
        guard let callback = didFinishDownload else {
            return
        }

        queue.async {
            callback(self.instantDocumentDescriptor)
        }
    }

    @objc private func didFailDownload(_ notification: NSNotification) {
        guard let callback = didFailDownload else {
            return
        }

        queue.async {
            let error = notification.userInfo?[PSPDFInstantErrorKey] as? NSError
            callback(self.instantDocumentDescriptor, error)
        }
    }

    @objc private func didFailSyncing(_ notification: NSNotification) {
        guard let callback = didFailSyncing else {
            return
        }

        queue.async {
            let error = notification.userInfo?[PSPDFInstantErrorKey] as? NSError
            callback(self.instantDocumentDescriptor, error)
        }
    }

    @objc private func didFailAuthentication(_ notification: NSNotification) {
        guard let callback = didFailAuthentication else {
            return
        }

        queue.async {
            callback(self.instantDocumentDescriptor)
        }
    }

}
