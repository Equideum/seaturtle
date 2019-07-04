//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

// See 'PSCEncryptDecryptDocumentExample.m' for the Objective-C version of this example.

import Foundation

class EncryptDecryptDocumentExample: PSCExample {
	override init() {
        super.init()
        title = "Encrypt and decrypt a PDF"
        contentDescription = "Example how to encrypt and decrypt PDF."
        category = .security
    }

    override func invoke(with delegate: PSCExampleRunnerDelegate) -> UIViewController {
        let samplesURL = Bundle.main.resourceURL!.appendingPathComponent("Samples")
        let originalURL = samplesURL.appendingPathComponent(PSCAssetName.JKHF.rawValue)
        let cryptor = PSPDFCryptor()
        let key = cryptor.key(fromPassphrase: "passphrase", salt: "salt")

        // Encrypt the original PDF
        let encryptedURL = PSCTempFileURLWithPathExtension("encrypted", "pdf")
        do {
            try cryptor.encrypt(from: originalURL, to: encryptedURL, key: key)
        } catch {
            print("Encryption failed with error: \(error.localizedDescription)")
        }

        // Decrypt the encrypted PDF
        let decryptedURL = PSCTempFileURLWithPathExtension("PSPDFCryptorTests", "pdf")
        do {
            try cryptor.decrypt(from: encryptedURL, to: decryptedURL, key: key)
        } catch {
            print("Decrypton failed with error: \(error.localizedDescription)")
        }
        // Open the decrypted PDF
        let document = PSPDFDocument(url: decryptedURL)
        return PSPDFViewController(document: document)
    }
}
