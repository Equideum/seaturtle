//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation
import PSPDFKit
import PSPDFKitUI
import PSPDFKitSwift

class DocumentProgressExample: PSCExample {

    let destinationFileURL = PSCTempFileURLWithPathExtension("document", "pdf")
    let remoteURL = URL(string: "https://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf")!
    var downloader: Downloader?
    lazy var cancelButton = {
        return UIBarButtonItem(title: PSPDFLocalize("Cancel"), style: .plain, target: self, action: #selector(cancelButtonPressed))
    }()

    override init() {
        super.init()
        title = "Document progress"
        contentDescription = "Show file download progress before the PDF file becomes available."
        category = .documentDataProvider
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        downloader?.cleanup()
        downloader = Downloader(remoteURL: remoteURL, destinationFileURL: destinationFileURL)
        downloader?.didFinishDownloading = { [unowned self] (location) in
            self.cancelButton.isEnabled = false
        }

        // Configure the data provider with our NSProgress instance.
        let provider = PSPDFCoordinatedFileDataProvider(fileURL: destinationFileURL, progress: downloader?.progress)
        let document = PDFDocument(dataProviders: [provider])
        let controller = PSPDFViewController(document: document)

        controller.navigationItem.setRightBarButtonItems([cancelButton] + controller.navigationItem.rightBarButtonItems!, animated: false)

        return controller
    }

    @objc func cancelButtonPressed(sender: UIBarButtonItem?) {
        guard let downloader = self.downloader else { return }
        sender?.isEnabled = false
        downloader.progress.cancel()
        downloader.cleanup()
    }
}

class Downloader: NSObject {

    let progress = Progress(totalUnitCount: 100)
    let downloadProgress = Progress(totalUnitCount: 1)
    let moveProgress = Progress(totalUnitCount: 1)

    let destinationFileURL: URL
    let remoteURL: URL

    var session: URLSession?
    var task: URLSessionDownloadTask?

    var didFinishDownloading: ((_ location: URL) -> Void)?

    init(remoteURL: URL, destinationFileURL: URL) {
        self.remoteURL = remoteURL
        self.destinationFileURL = destinationFileURL

        super.init()

        // Download the file using URLSession API.
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        self.session = session
        let task = session.downloadTask(with: remoteURL)
        self.task = task
        task.resume()

        // Setup progress hierarchy. The download should take much longer than the final move.
        progress.addChild(downloadProgress, withPendingUnitCount: 99)
        progress.addChild(moveProgress, withPendingUnitCount: 1)
    }

    func cleanup() {
        do {
            task?.cancel()
            session?.invalidateAndCancel()

            try FileManager().removeItem(at: destinationFileURL)
        } catch {
            print(error)
        }
    }
}

extension Downloader: URLSessionDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager().moveItem(at: location, to: destinationFileURL)
            // We must ensure that the complete progress (`progress`) only completes when the file is already at its final location.
            moveProgress.completedUnitCount = moveProgress.totalUnitCount
            didFinishDownloading?(location)
        } catch {
            print(error)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadProgress.totalUnitCount = totalBytesExpectedToWrite
        downloadProgress.completedUnitCount = totalBytesWritten
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            // Complete the progress.
            progress.completedUnitCount = progress.totalUnitCount
        }
    }
}
