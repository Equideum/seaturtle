//
//  Copyright © 2019 by Mitch the Sea Turtle
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import UIKit
import PSPDFKitUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set your license key here. PSPDFKit is commercial software.
        // Each PSPDFKit license is bound to a specific app bundle id.
        // Visit https://customers.pspdfkit.com to get your demo or commercial license key.
        PSPDFKit.setLicenseKey("oleHEWMqdAcfWLJ3ahEt/5eALucyC6ygnLy4RCn1G0Cj6pBT7bhGOgdirdQAiEezxerWSQ5mE6lX+DfugNrSTE1FmxZm1MjI23y0zuRhOVYwC+RT40uRUc50/EYE9gOG/Cl7iwHKMaLTz0T+M3qYjFeTpAGpv8lfOWTaNR12UMvqjQEMPcRVozcHePBHZpEBIHXY7MMenVVNjcgmKEOJ6qnldxFez33llPiOE9oLse0BqE9L8vYtHWBOyQ2TV9oWQ8SVOFjFK+RkNor9brN72vWcY9RlKljVWDspAWkOUIKJKfak9WUjgulZNjCoT5e+A/LBHOdM9WHP8q4riHsZrtBeo+8sEgbwbjJnuvV96ZcLQuftnylh3u5fmGFZ7AASVDwBe4NbELU3fFIwGtzJbTq+JMdCmRn8NZvnTcDpNwqmpcENYTtb7EFV9Dy3NtXb")

        return true
    }
    
    static let johnAppleseedSigner: PSPDFSigner = {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let p12URL = samplesURL.appendingPathComponent("tom.p12")
        let p12data = try! Data(contentsOf: p12URL)
        let p12 = PSPDFPKCS12(data: p12data)
        return PSPDFPKCS12Signer(displayName: "Tom Danner", pkcs12: p12)
    }()

    class DigitalSignatureViewController: PSPDFSignatureViewController {
        // Use a specific signer to force creating a digital signature.
        override var signer: PSPDFSigner? {
            return AppDelegate.johnAppleseedSigner
        }
        // Set the certificate selection mode to `.never` to disable the ability for users to select a different signer.
        override var certificateSelectionMode: PSPDFSignatureCertificateSelectionMode {
            get { return .never }
            set {}
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = UIColor.white

        // FTD magic
        let signatureManager = PSPDFKit.sharedInstance.signatureManager
        signatureManager.clearRegisteredSigners()
        signatureManager.register(AppDelegate.johnAppleseedSigner)
        signatureManager.clearTrustedCertificates()
        // Add certs to trust store for the signature validation process
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let certURL = samplesURL.appendingPathComponent("tom.p7c")
        let certData = try! Data(contentsOf: certURL)
        let certificates = try! PSPDFX509.certificates(fromPKCS7Data: certData)
        for x509 in certificates {
            signatureManager.addTrustedCertificate(x509)
        }
        
        let fileURL = Bundle.main.bundleURL.appendingPathComponent("Samples/Form_example.pdf")
        let writableURL = copyFileURLToDocumentFolder(fileURL)
        let document = PSPDFDocument(url: writableURL)
       /* old original snippet  let configuration = PSPDFConfiguration { builder in
            builder.thumbnailBarMode = .scrollable
        }
 */
        let configuration = PSPDFConfiguration {
            builder in
            builder.overrideClass(PSPDFSignatureViewController.self, with: DigitalSignatureViewController.self)
        }
        
 
        let pdfController = PDFViewController(document: document, configuration: configuration)

        window.rootViewController = UINavigationController(rootViewController: pdfController)
        window.makeKeyAndVisible()

        // Example how to use the library and start background indexing.
        DispatchQueue.global().async {
            let libraryExample = LibraryExample()
            libraryExample.indexDocuments()
        }

        return true
    }

    private func copyFileURLToDocumentFolder(_ documentURL: URL, override: Bool = false) -> URL {
        let docsURL = URL(fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!))
        let newURL = docsURL.appendingPathComponent(documentURL.lastPathComponent)
        let needsCopy = !FileManager.default.fileExists(atPath: newURL.path)
        if override {
            _ = try? FileManager.default.removeItem(at: newURL)
        }
        if needsCopy || override {
            do {
                try FileManager.default.copyItem(at: documentURL, to: newURL)
            } catch let error as NSError {
                print("Error while copying \(documentURL.path): \(error.description)")
            }
        }
        return newURL
    }
}
