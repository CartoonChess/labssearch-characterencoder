//
//  String+encodedUrl.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/07.
//

import Foundation

extension String {
    
    // TODO: Account for weird (and maybe wrong) URLs that have two hashes in them, by percent-encoding subsequent hashes after the first.
    
    /// Converts a string to a percent-encoded URL, including Unicode characters.
    ///
    /// - Parameter encoder: A `CharacterEncoder` object, if available.
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    func encodedUrl(characterEncoder encoder: CharacterEncoder? = nil) -> URL? {
        // We will get the value differently depending on the encoding
        var partiallyEncodedString: String
        
        if encoder?.encoding.value != .utf8,
            // Custom encode the URL if using non-Unicode
            let characterEncodedString = encoder?.encode(self, fullUrl: true) {
            partiallyEncodedString = characterEncodedString
        } else {
            // Remove preexisting encoding,
            guard let decodedString = self.removingPercentEncoding else {
                print("String could not be encoded as URL: failed to remove preexisting percent encoding.")
                return nil
            }
            // encode any Unicode characters so URLComponents doesn't choke,
            guard let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters) else {
                print("String could not be encoded as URL: failed to add percent encoding to non-ASCII characters.")
                return nil
            }
            partiallyEncodedString = unicodeEncodedString
        }
        
        // break into components to use proper encoding for each part,
        guard let components = URLComponents(string: partiallyEncodedString) else {
            print("String could not be encoded as URL: URL could not be broken into components.")
            return nil
        }
        // and reencode, to revert decoding while encoding missed characters.
        guard let percentEncodedUrl = components.url else {
            // Encoding failed
            print("String could not be encoded as URL: failed to add percent encoding to URL control characters.")
            return nil
        }
        
        return percentEncodedUrl
    }

}
