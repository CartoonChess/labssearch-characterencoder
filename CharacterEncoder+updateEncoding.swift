//
//  CharacterEncoder+updateEncoding.swift
//  LabsSearch
//
//  Created by Xcode on ’19/06/18.
//

import Foundation

extension CharacterEncoder {
    
    static func updateCharacterEncoding(newEncoder possibleEncoder: CharacterEncoder?,
                                        oldEncoder: CharacterEncoder?,
                                        url: URL,
                                        allowNilEncoder: Bool = false,
                                        completion: (_ encoder: CharacterEncoder?, _ url: URL) -> Void) {
        
        // Create mutable copy of encoder, in case using allowNilEncoder
        var temporaryEncoder = possibleEncoder
        
        // Update encoding even if nil (or unchanged)
        if allowNilEncoder && possibleEncoder == nil {
            // If URL is non-UTF and encoding nil, encoding will be changed to "invalid"
            temporaryEncoder = CharacterEncoder(encoding: .utf8)
        }
        
        // Only set encoding if not nil, as we don't want to delete any previous encoding for now
        guard let encoder = temporaryEncoder else {
            completion(oldEncoder, url)
            return
        }
        
        // And don't bother if the new encoding is the same as the old one
        if !allowNilEncoder {
            guard encoder.encoding != oldEncoder?.encoding else {
                completion(oldEncoder, url)
                return
            }
        }
        
            
        // Percent-encode with the new encoding
        let encodedUrlString = encoder.encode(url.absoluteString, fullUrl: true)
        
        // Check validity of newly encoded URL
        //- This should pass except when converting to UTF-8 while URL contains non-UTF characters
        if let url = encodedUrlString.encodedUrl(characterEncoder: encoder) {
            completion(encoder, url)
        } else {
            // If changing to UTF-8 and differently encoded characters are present, use "invalid" encoding
            //- This imitates UTF-8 while continuing to percent-encode using the custom encoder
            let invalidEncoder = CharacterEncoder(encoding: CharacterEncoder.invalidEncoding)
            
            // Check URL validity again. This should never fail
            if let url = encodedUrlString.encodedUrl(characterEncoder: invalidEncoder) {
                completion(encoder, url)
            } else if !allowNilEncoder {
                // The URL is no longer valid
                //- We won't do this with allowNilEncoder as that's mostly just for checking URL validity
                //- Otherwise, we should never get here, but we provide this for testing
                fatalError("URL validity check failed even with InvalidID encoding.")
            }
        }
    }
    
}
