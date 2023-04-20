//
//  HTMLParserDelegate.swift.swift
//  
//
//  Created by Alessio Giordano on 15/04/23.
//

import Foundation

public protocol HTMLParserDelegate: AnyObject {
    /// Sent by the parser object to the delegate when it begins parsing a document.
    func parserDidStartDocument(_ parser: HTMLParser)
    /// Sent by the parser object to the delegate when it has successfully completed parsing.
    func parserDidEndDocument(_ parser: HTMLParser)
    /// Sent by a parser object to its delegate when it encounters a start tag for a given element.
    func parser(_ parser: HTMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    /// Sent by a parser object to its delegate when it encounters an end tag for a specific element.
    func parser(_ parser: HTMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    /// Sent by a parser object to its delegate the first time it encounters a given namespace prefix, which is mapped to a URI.
    func parser(_ parser: HTMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String)
    /// Sent by a parser object to its delegate when a given namespace prefix goes out of scope.
    func parser(_ parser: HTMLParser, didEndMappingPrefix prefix: String)
    /// Sent by a parser object to its delegate when it encounters a given external entity with a specific system ID.
    func parser(_ parser: HTMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data?
    /// Sent by a parser object to its delegate when it encounters a fatal error.
    func parser(_ parser: HTMLParser, parseErrorOccurred parseError: Error)
    /// Sent by a parser object to its delegate when it encounters a fatal validation error. NS_ parser: HTMLParser currently does not invoke this method and does not perform validation.
    func parser(_ parser: HTMLParser, validationErrorOccurred validationError: Error)
    /// Sent by a parser object to provide its delegate with a string representing all or part of the characters of the current element.
    func parser(_ parser: HTMLParser, foundCharacters string: String)
    /// Reported by a parser object to provide its delegate with a string representing all or part of the ignorable whitespace characters of the current element.
    func parser(_ parser: HTMLParser, foundIgnorableWhitespace whitespaceString: String)
    /// Sent by a parser object to its delegate when it encounters a processing instruction.
    func parser(_ parser: HTMLParser, foundProcessingInstructionWithTarget target: String, data: String?)
    /// Sent by a parser object to its delegate when it encounters a comment in the XML.
    func parser(_ parser: HTMLParser, foundComment comment: String)
    /// Sent by a parser object to its delegate when it encounters a CDATA block.
    func parser(_ parser: HTMLParser, foundCDATA CDATABlock: Data)
    /// Sent by a parser object to its delegate when it encounters a declaration of an attribute that is associated with a specific element.
    func parser(_ parser: HTMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?)
    /// Sent by a parser object to its delegate when it encounters a declaration of an element with a given model.
    func parser(_ parser: HTMLParser, foundElementDeclarationWithName elementName: String, model: String)
    /// Sent by a parser object to its delegate when it encounters an external entity declaration.
    func parser(_ parser: HTMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?)
    /// Sent by a parser object to the delegate when it encounters an internal entity declaration.
    func parser(_ parser: HTMLParser, foundInternalEntityDeclarationWithName name: String, value: String?)
    /// Sent by a parser object to its delegate when it encounters an unparsed entity declaration.
    func parser(_ parser: HTMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?)
    /// Sent by a parser object to its delegate when it encounters a notation declaration.
    func parser(_ parser: HTMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?)
}

public extension HTMLParserDelegate {
    func parserDidStartDocument(_ parser: HTMLParser) {}
    func parserDidEndDocument(_ parser: HTMLParser) {}
    func parser(_ parser: HTMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {}
    func parser(_ parser: HTMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {}
    func parser(_ parser: HTMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {}
    func parser(_ parser: HTMLParser, didEndMappingPrefix prefix: String) {}
    func parser(_ parser: HTMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? { nil }
    func parser(_ parser: HTMLParser, parseErrorOccurred parseError: Error) {}
    func parser(_ parser: HTMLParser, validationErrorOccurred validationError: Error) {}
    func parser(_ parser: HTMLParser, foundCharacters string: String) {}
    func parser(_ parser: HTMLParser, foundIgnorableWhitespace whitespaceString: String) {}
    func parser(_ parser: HTMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {}
    func parser(_ parser: HTMLParser, foundComment comment: String) {}
    func parser(_ parser: HTMLParser, foundCDATA CDATABlock: Data) {}
    func parser(_ parser: HTMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {}
    func parser(_ parser: HTMLParser, foundElementDeclarationWithName elementName: String, model: String) {}
    func parser(_ parser: HTMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {}
    func parser(_ parser: HTMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {}
    func parser(_ parser: HTMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {}
    func parser(_ parser: HTMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {}
}
