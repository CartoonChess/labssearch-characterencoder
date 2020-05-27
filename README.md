# LabsSearch CharacterEncoder
A set of tools in Swift to find the character encoding of a webpage and, later, format URLs in that encoding so that site's server will understand.

## Project background
This class is broken out of [LabsSearch] (an early attempt at coding, so the code here, too, is messy) and can theoretically be used in other projects. It overcomes the headaches involved mainly with creating URLs that use GET on sites that do not use UTF-8 encoding.

## Usage
### Get webpage encoding
```swift
var characterEncoder: CharacterEncoder?
var encoding: String.Encoding? {
    characterEncoder?.encoding.value
}
let url = URL(string: "https://www.example.com/")!

let task = URLSession.shared.dataTask(with: url) { _, response, _ in
    let encodingName = response?.textEncodingName ?? "nil"
    self.characterEncoder = CharacterEncoder(encoding: encodingName)
}
task.resume()
```
### Update encoding
```swift
todo
```
### Encode URL
```
todo
```

## Files
Swift file | Description
---------- | -----------
CharacterEncoder | Takes an encoding name and URL and returns the properly formatted URL
CharacterSet+union | Convenience functions for mixing and matching `CharacterSet`s
CharacterSet+urlAllowedSets | Various URL-safe `CharacterSet`s
String+encodedUrl | String extension to convert URL as `String` into encoded `URL`
String.Encoding+alias | Converts human-readable encoding names to Swift equivalents

## To do
Currently only the encoding as set in the response header is retrieved. `XMLParser` could be used to check meta tags as well.

## Attributions
The encoding list is adapted from [WHATWG].

The code itself is based on code which manually mapped each ASCII character and outputted a string for use with Korean encoding. I found the same code posted in multiple places without any attribution, so I admit I'm unsure who wrote the original. If you know, please speak up!

[LabsSearch]: https://www.github.com/cartoonchess/labssearch
[WHATWG]: https://encoding.spec.whatwg.org/#names-and-labels
