//
//  CharacterEncoder+updateEncoding.swift
//  LabsSearch
//
//  Created by Xcode on ’19/06/18.
//

import Foundation

// TODO: This was originally the SearchEngineEditor class in LabsSearch. The original is working, but this extension is untested.

extension CharacterEncoder {
    
    static func updateCharacterEncoding(newEncoder possibleEncoder: CharacterEncoder?, oldEncoder: CharacterEncoder?, urlString: String, allowNilEncoder: Bool = false, completion: ((_ encodingDidChange: Bool) -> Void)? = nil) {
        
        // If the encoding ever changes, update this value, for the completion handler
        var encodingDidChange = false
        
        // Create mutable copy of encoder, in case using allowNilEncoder
        var temporaryEncoder = possibleEncoder
        
        // Update encoding even if nil (or unchanged)
        if allowNilEncoder && possibleEncoder == nil {
            // If URL is non-UTF and encoding nil, encoding will be changed to "invalid"
            temporaryEncoder = CharacterEncoder(encoding: .utf8)
        }
        
        // Only set encoding if not nil, as we don't want to delete any previous encoding for now
        guard let encoder = temporaryEncoder else {
            completion?(encodingDidChange)
            return
        }
        
        // And don't bother if the new encoding is the same as the old one
        if !allowNilEncoder {
            guard encoder.encoding != newEncoder?.encoding else {
                completion?(encodingDidChange)
                return
            }
        }
        
            
        // Percent-encode with the new encoding
        let encodedUrl = encoder.encode(urlString, fullUrl: true)
        
        // Check validity of newly encoded URL
        //- This should pass except when converting to UTF-8 while URL contains non-UTF characters
        if let url = encodedUrl.encodedUrl(characterEncoder: encoder) {
            
            // If there is no encoder, but URL is already UTF-8 compliant, no change necessary
            // Otherwise...
             if !allowNilEncoder && possibleEncoder != nil {
                // Under normal circumstances, make sure queries are encoded properly, then save them along with new encoding
                updateEncoderAndUrl(encoder: encoder, url: url)
                encodingDidChange = true
            }
        } else {
            // If changing to UTF-8 and differently encoded characters are present, use "invalid" encoding
            //- This imitates UTF-8 while continuing to percent-encode using the custom encoder
            let invalidEncoder = CharacterEncoder(encoding: CharacterEncoder.invalidEncoding)
            
            // Check URL validity again. This should never fail
            if let url = encodedUrl.encodedUrl(characterEncoder: invalidEncoder) {
                updateEncoderAndUrl(encoder: invalidEncoder, url: url)
                encodingDidChange = true

            } else if !allowNilEncoder {
                // The URL is no longer valid
                //- We won't do this with allowNilEncoder as that's mostly just for checking URL validity
                //- Otherwise, we should never get here, but we provide this for testing
                fatalError("URL validity check failed even with InvalidID encoding.")
            }
        }
        
        // Let the caller know the encoding has changed
        completion?(encodingDidChange)
    }
    
    /// Make sure queries are encoded properly, then save them along with new encoding
    private func updateEncoderAndUrl(encoder: CharacterEncoder, url: String) {
        characterEncoder = encoder
        delegate?.updateUrlDetails(baseUrl: baseUrl, queries: queries, updateView: false)
    }
    
}
