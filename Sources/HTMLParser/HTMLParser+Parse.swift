//
//  HTMLParser+Parse.swift
//  
//
//  Created by Alessio Giordano on 16/04/23.
//

import Foundation

extension HTMLParser {
    internal enum ParserState {
        case lookingForCharacters,
             lookingForCommentOrDTD,
             lookingForCommentEnd(suffix: String?),
             /// foundExternalEntityDeclarationWithName
             lookingForDTDEnd, // Only the presence of the DTD is reported, without content
             /// didStartElement
             lookingForTagName,
             lookingForAttribute(delimiter: Character?, name: String?, tag: Tag),
             /// didEndElement
             lookingForTagEnd(foundName: Bool)
    }
    internal struct Tag {
        let name: String
        let attributes: [String: String]
        init(name: String) {
            self.init(name, [:])
        }
        init(_ name: String, _ attributes: [String: String]) {
            /// Tag names are case insensitive
            self.name = name.uppercased()
            /// Attribute names are case insensitive
            self.attributes = attributes.reduce(into: .init()) { result, attribute in
                result[attribute.key.lowercased()] = attribute.value
            }
        }
        func appending(attributes: [String: String]) -> Tag {
            /// Attribute names are case insensitive and lowercased
            return Tag(self.name, self.attributes.merging(attributes.reduce(into: .init()) { result, attribute in
                result[attribute.key.lowercased()] = attribute.value
            }, uniquingKeysWith: { return $1 }))
        }
        func dispatchDidStartElement(_ parser: HTMLParser, on delegate: HTMLParserDelegate?) {
            delegate?.parser(parser, didStartElement: self.name, namespaceURI: nil, qualifiedName: nil, attributes: attributes)
            if VoidElements(rawValue: self.name) != nil {
                /// Void elements cannot contain any child elements and are closed as soon as they are opened
                delegate?.parser(parser, didEndElement: self.name, namespaceURI: nil, qualifiedName: nil)
            }
        }
        func dispatchDidEndElement(_ parser: HTMLParser, on delegate: HTMLParserDelegate?) {
            if VoidElements(rawValue: self.name) == nil {
                /// Only non-void elements can be closed
                delegate?.parser(parser, didEndElement: self.name, namespaceURI: nil, qualifiedName: nil)
            }
        }
    }
    internal func _parse() -> Bool {
        self._active = true
        
        if self._contents.isEmpty {
            // MARK: parserDidStartDocument Event
            delegate?.parserDidStartDocument(self)
            // MARK: parserDidEndDocument Event
            delegate?.parserDidEndDocument(self)
            self._active = false
            return true
        }
        
        let startIndex = self._contents.startIndex
        let endIndex = self._contents.index(before: self._contents.endIndex)
        var iterator: String.Index? = startIndex
        let advanceIterator: () -> Character? = {
            guard let index = iterator else { return nil }
            iterator = self._contents.index(index, offsetBy: 1, limitedBy: endIndex)
            return iterator != nil ? self._contents[iterator!] : nil
        }
        
        var state: ParserState = .lookingForCharacters
        var pending: String = ""
        var ignorableWhitespace: String = ""
        
        // MARK: parserDidStartDocument Event
        delegate?.parserDidStartDocument(self)
        
        while iterator != nil {
            guard self._active else { return false }
            guard let index = iterator else { break }
            let currentCharacter = self._contents[index]
            let nextCharacter = advanceIterator()
            
            switch state {
                case .lookingForCharacters: /************************************************************************************/
                    if currentCharacter.isWhitespace {
                        if pending.isEmpty || (pending.last?.isWhitespace ?? false) {
                            ignorableWhitespace.append(currentCharacter)
                        } else {
                            /// Whitespace is normalized to the simple space %20 character
                            pending.append(" ")
                        }
                    } else {
                        ///
                        if ignorableWhitespace.isEmpty == false {
                            // MARK: foundIgnorableWhitespace Event
                            delegate?.parser(self, foundIgnorableWhitespace: pending)
                            ignorableWhitespace = ""
                        }
                        ///
                        let dispatchFoundCharactersEvent: Bool
                        if currentCharacter == "<" && (nextCharacter?.isLetter ?? false) {
                            dispatchFoundCharactersEvent = true
                            state = .lookingForTagName
                        } else if currentCharacter == "<" && nextCharacter == "!" {
                            dispatchFoundCharactersEvent = true
                            state = .lookingForCommentOrDTD
                            _ = advanceIterator()
                        } else if currentCharacter == "<" && nextCharacter == "?" {
                            dispatchFoundCharactersEvent = true
                            state = .lookingForCommentEnd(suffix: nil)
                            _ = advanceIterator()
                        } else if currentCharacter == "<" && nextCharacter == "/" {
                            dispatchFoundCharactersEvent = true
                            state = .lookingForTagEnd(foundName: false)
                            _ = advanceIterator()
                        } else {
                            dispatchFoundCharactersEvent = false
                        }
                        if dispatchFoundCharactersEvent {
                            if pending.last?.isWhitespace ?? false {
                                pending.removeLast()
                            }
                            // MARK: foundCharacters Event
                            delegate?.parser(self, foundCharacters: pending)
                            pending = ""
                            break
                        } else {
                            pending.append(currentCharacter)
                            break
                        }
                    }
                    break
                case .lookingForCommentOrDTD: /**********************************************************************************/
                    if pending == "-" && currentCharacter == "-" {
                        /// Found comment
                        state = .lookingForCommentEnd(suffix: "--")
                        pending = ""
                        break
                    } else if pending.uppercased() == "DOCTYPE" {
                        /// Found DTD
                        state = .lookingForDTDEnd
                        pending = ""
                        break
                    } else if pending.count > 7 {
                        state = .lookingForCommentEnd(suffix: nil)
                        pending.append(currentCharacter)
                        break
                    } else {
                        pending.append(currentCharacter)
                        break
                    }
                case .lookingForCommentEnd(let suffix): /******************************************************************/
                    let endCommentRange: Range<String.Index>?
                    if let suffix, suffix.count > 0, let iterator,
                       let range = self._contents[iterator...].firstRange(of: "\(suffix)>") {
                        endCommentRange = range
                    } else if let iterator,
                              let range = self._contents[iterator...].firstRange(of: ">") {
                        endCommentRange = range
                    } else { endCommentRange = nil }
                    // MARK: foundComment Event
                    if let iterator {
                        self.delegate?.parser(self, foundComment: pending + self._contents[iterator..<(endCommentRange?.lowerBound ?? self._contents.endIndex)])
                    }
                    if let endCommentRange {
                        iterator = endCommentRange.upperBound
                        _ = advanceIterator()
                    } else {
                        // Unterminated comment detected
                        iterator = nil
                    }
                    state = .lookingForCharacters
                    pending = ""
                    break
                case .lookingForDTDEnd: /******************************************************************************************/
                    if let i = iterator, let range = self._contents[i...].firstRange(of: ">") {
                        iterator = range.upperBound
                        _ = advanceIterator()
                    } else {
                        // Unterminated DTD declaration
                        iterator = nil
                    }
                    // MARK: foundExternalEntityDeclarationWithName Event
                    self.delegate?.parser(self, foundExternalEntityDeclarationWithName: "html", publicID: nil, systemID: nil)
                    state = .lookingForCharacters
                    pending = ""
                    break
                case .lookingForTagName: /****************************************************************************************/
                    if currentCharacter == ">" || (currentCharacter == "/" && nextCharacter == ">") {
                        // MARK: didStartElement Event
                        Tag(name: pending).dispatchDidStartElement(self, on: self.delegate)
                        state = .lookingForCharacters
                        pending = ""
                    } else if currentCharacter.isWhitespace {
                        state = .lookingForAttribute(delimiter: nil, name: nil, tag: Tag(name: pending))
                        pending = ""
                    } else {
                        pending.append(currentCharacter)
                    }
                    break
                case .lookingForAttribute(let delimeter, let name, let tag): /**********************************/
                    if delimeter == nil {
                        if currentCharacter == ">" {
                            if pending != "" {
                                if let name {
                                    // MARK: didStartElement Event
                                    // Parsing the value part of the attribute
                                    tag.appending(attributes: [name: pending]).dispatchDidStartElement(self, on: self.delegate)
                                } else {
                                    // MARK: didStartElement Event
                                    // Parsing the name part of the attribute
                                    tag.appending(attributes: [pending: ""]).dispatchDidStartElement(self, on: self.delegate)
                                }
                                pending = ""
                            } else {
                                // MARK: didStartElement Event
                                tag.dispatchDidStartElement(self, on: self.delegate)
                            }
                            state = .lookingForCharacters
                            break
                        } else if currentCharacter == "/" {
                            // HTML doesn't support XML self-closing tags, so either the slash is used as part of an unquoted attribute value, or it is ignored
                            if name != nil {
                                pending.append(currentCharacter)
                            }
                            break
                        } else if currentCharacter.isWhitespace && pending != "" {
                            if let name {
                                // Parsing the value part of the attribute
                                state = .lookingForAttribute(delimiter: nil, name: nil, tag: tag.appending(attributes: [name: pending]))
                            } else {
                                var char = nextCharacter
                                while char?.isWhitespace ?? false {
                                    // Pass by all the whitespace
                                    char = advanceIterator()
                                }
                                if char == "=" {
                                    // This is an attribute of the kind "attr = value"
                                    // The next iteration will take care of the = symbol
                                    break
                                } else {
                                    // This is an attribute of the kind "attr1 attr2"
                                    // Parsing the name part of the attribute
                                    state = .lookingForAttribute(delimiter: nil, name: nil, tag: tag.appending(attributes: [pending: ""]))
                                }
                            }
                            pending = ""
                            break
                        } else if currentCharacter == "'" || currentCharacter == "\"" {
                            if pending == "" {
                                state = .lookingForAttribute(delimiter: currentCharacter, name: name, tag: tag)
                            } else {
                                if let name {
                                    state = .lookingForAttribute(delimiter: nil, name: nil, tag: tag.appending(attributes: [name: pending]))
                                } else {
                                    state = .lookingForAttribute(delimiter: nil, name: nil, tag: tag.appending(attributes: [pending: ""]))
                                }
                            }
                            pending = ""
                            break
                        } else if currentCharacter == "=" {
                            if name == nil {
                                state = .lookingForAttribute(delimiter: nil, name: pending, tag: tag)
                                pending = ""
                            } else {
                                pending.append(currentCharacter)
                            }
                            break
                        } else {
                            pending.append(currentCharacter)
                            break
                        }
                    } else if currentCharacter == delimeter {
                        state = .lookingForAttribute(delimiter: nil, name: name, tag: tag)
                        break
                    } else {
                        pending.append(currentCharacter)
                        break
                    }
                case .lookingForTagEnd(let foundName): /********************************************************************/
                    if foundName {
                        if currentCharacter == ">" {
                            // MARK: didEndElement Event
                            Tag(name: pending).dispatchDidEndElement(self, on: self.delegate)
                            state = .lookingForCharacters
                            pending = ""
                            break
                        } else {
                            break
                        }
                    } else {
                        if pending.isEmpty {
                            if currentCharacter.isLetter {
                                pending.append(currentCharacter)
                                break
                            } else {
                                if currentCharacter == ">" {
                                    // TODO: DISPATCH FOUND COMMENT EVENT
                                    /// The comment is empty
                                    state = .lookingForCharacters
                                    break
                                } else {
                                    // Malformed tag end, turn into comment
                                    state = .lookingForCommentEnd(suffix: nil)
                                    if currentCharacter.isWhitespace {
                                        pending.append(" ")
                                    } else {
                                        pending.append(currentCharacter)
                                    }
                                    break
                                }
                            }
                        } else if currentCharacter.isWhitespace {
                            state = .lookingForTagEnd(foundName: true)
                            break
                        } else if currentCharacter == ">" {
                            // MARK: didEndElement Event
                            Tag(name: pending).dispatchDidEndElement(self, on: self.delegate)
                            state = .lookingForCharacters
                            pending = ""
                            break
                        } else {
                            pending.append(currentCharacter)
                            break
                        }
                    }
                /**********************************************************************************************************************/
            }
        }
        
        // MARK: parserDidEndDocument Event
        delegate?.parserDidEndDocument(self)
        self._active = false
        return true
    }
}
