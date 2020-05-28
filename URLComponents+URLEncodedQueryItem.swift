//
//  URLComponents+URLEncodedQueryItem.swift
//  LabsSearch
//
//  Created by Xcode on ’18/11/03.
//

import Foundation

extension URLComponents {
    
    struct URLEncodedQueryItem: CustomStringConvertible {
        let name: String
        let value: String
        // Emulate `URLQueryItem` description
        var description: String {
            "\(name)=\(value)"
        }
    }
    
    /// Returns the query as a string, regardless of character encoding, iOS version, or empty query.
    func query(encoder: CharacterEncoder? = nil, removePercentEncodingIfUTF8: Bool = true) -> String {
        if encoder?.encoding.value == .utf8 && removePercentEncodingIfUTF8 {
            // Percent encoding can be safely removed if using UTF-8
            return self.query ?? ""
        } else {
            // Use the standard property if non-UTF8 or electing to keep percent encoding
            return self.percentEncodedQuery ?? ""
        }
    }
    
    /// Provides a dictionary of query items from a `URL` regardless of character encoding or iOS version.
    ///
    /// - Returns: An array of `URLEncodedQueryItem`s, accessed by `name` and `value`, or an empty array if the query is empty.
    func queryItems(encoder: CharacterEncoder? = nil, keepPercentEncoding: Bool = false) -> [URLEncodedQueryItem] {
        // Determine the best way to handle the queries
        if encoder?.encoding.value == .utf8 || encoder == nil {
            // Use the basic function for UTF
            // This function returns an empty array when no queries present
            return self.createQueryArray()
        } else if #available(iOS 11.0, *) {
            // Preserve percent encoding for non-UTF URLs
            // Query items can be get with percent encoding only in later versions of iOS
            return self.createQueryArray(keepPercentEncoding: keepPercentEncoding)
        } else {
            // Non-UTF but iOS too old; custom code ahead
            // Queries are non-UTF percent encoded, but these cannot be fetched before iOS 11
            guard let queryItems = self.percentEncodedQuery?.components(separatedBy: "&") else { return [] }
            
            return queryItems.map { item in
                let side = item.components(separatedBy: "=")
                return URLEncodedQueryItem(name: side[0], value: side[1])
            }
        }
    }
    
    /// Converts the `URLQueryItem` object array into a `URLEncodedQueryItem` array.
    ///
    /// - Returns: The query, divided into `[URLEncodedQueryItem]`.
    private func createQueryArray(keepPercentEncoding: Bool = false) -> [URLEncodedQueryItem] {
        var possibleQueryItems: [URLQueryItem]?
        
        if keepPercentEncoding,
            #available(iOS 11.0, *) {
            // We use this case when we have to preserve non-UTF encoding
            possibleQueryItems = self.percentEncodedQueryItems
        } else {
            possibleQueryItems = self.queryItems
        }
        
        // If the URL components don't include a query, return empty array
        guard let queryItems = possibleQueryItems else { return [] }
        
        return queryItems.map { item in
            URLEncodedQueryItem(name: item.name, value: item.value ?? "")
        }
    }
    
}
