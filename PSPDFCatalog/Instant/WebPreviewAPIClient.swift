//
//  Copyright © 2017-2019 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

import Foundation

/**
 Interfaces with our web-preview server.

 This is just networking and JSON parsing. It’s very specific our backend so not very useful as sample code.
 In your own app you would connect to your own server backend to get Instant document identifiers and authentication tokens.
 */
class WebPreviewAPIClient {

    enum Failure: Error {
        case invalidCode
        case internalError
    }

    enum Result {
        case success(InstantDocumentInfo)
        case failure(Error)
    }

    typealias APIClientCompletionHandler = (_ result: Result) -> Void
    let minimumCodeLength = 6

    let instantCodeEndpoint = URL(string: "https://web-preview.pspdfkit.com/api/")!

    func resolve(_ code: String, completion: @escaping APIClientCompletionHandler) {
        guard let escapedCode = code.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Could not add percent encoding to \(code)")
            return
        }

        let url = instantCodeEndpoint.appendingPathComponent("instant", isDirectory: true).appendingPathComponent(escapedCode, isDirectory: false)
        resolve(url, completion: completion)
    }

    func resolve(barcode: String, completion: @escaping APIClientCompletionHandler) {
        guard let url = URL(string: barcode) else {
            fatalError("Scanned barcode not a valid URL.")
        }
        resolve(url, completion: completion)
    }

    func resolve(_ url: URL, completion: @escaping APIClientCompletionHandler) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let result = self.resultFromResponse(with: data, response: response, error: error)
            completion(result)
        }

        task.resume()
    }

    func createNewDocument(completion: @escaping APIClientCompletionHandler) {
        let url = instantCodeEndpoint.appendingPathComponent("instant-landing-page", isDirectory: false)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let result = self.resultFromResponse(with: data, response: response, error: error)
            completion(result)
        }

        task.resume()
    }

    private func resultFromResponse(with data: Data?, response: URLResponse?, error: Error?) -> Result {
        if let error = error {
            return .failure(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(Failure.internalError)
        }

        switch httpResponse.statusCode {
        case 200:
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) {
                if let document = InstantDocumentInfo(json: json) {
                    return .success(document)
                }
            }
            return .failure(Failure.internalError)
        case 400:
            return .failure(Failure.invalidCode)
        default:
            return .failure(Failure.internalError)
        }
    }
}

extension WebPreviewAPIClient.Failure: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCode:
            return "Invalid Document Code"
        case .internalError:
            return "Internal Error"
        }
    }
}
