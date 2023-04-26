//
//  HTMLParser.swift
//  
//
//  Created by Alessio Giordano on 16/04/23.
//

import Foundation

public class HTMLParser: NSObject {
    
    internal var _contents: String!
    internal var _active: Bool = false
    
    /**
    ### Initializing a Parser Object
    */
    
    /// Initializes a parser with the XML contents encapsulated in a given data object.
    public init(data: Data) {
        self._contents = String(data: data, encoding: .utf8)
    }
    /// Initializes a parser with the XML content referenced by the given URL.
    convenience public init?(contentsOf url: URL) {
        do {
            self.init(data: try Data(contentsOf: url))
        } catch { return nil }
    }
    /// Initializes a parser with the XML contents from the specified stream and parses it.
    convenience public init(stream: InputStream) {
        self.init(data: Data(reading: stream))
    }
    
    /**
    ### Managing Delegates
    */
    
    /// A delegate object that receives messages about the parsing process.
    unowned(unsafe) open var delegate: HTMLParserDelegate?
    
    /**
    ### Managing Parser Behavior
    */
    
    // MARK: The following flags are permanently set to false as their functionalty has not been implemented yet
    /// A Boolean value that determines whether the parser reports the namespaces and qualified names of elements.
    open var shouldProcessNamespaces: Bool {
        get { false }
        set {}
    }
    /// A Boolean value that determines whether the parser reports the prefixes indicating the scope of namespace declarations.
    open var shouldReportNamespacePrefixes: Bool {
        get { false }
        set {}
    }
    /// A Boolean value that determines whether the parser reports declarations of external entities.
    open var shouldResolveExternalEntities: Bool {
        get { false }
        set {}
    }
    
    /**
    ### Parsing
    */
    
    /// Starts the event-driven parsing operation.
    open func parse() -> Bool {
        if _contents == nil {
            let error = NSError(
                domain: Self.errorDomain,
                code: ErrorCode.emptyDocumentError.rawValue
            )
            self.parserError = error
            delegate?.parser(self, parseErrorOccurred: error)
            return false
        }
        return _parse()
    }
    /// Stops the parser object.
    open func abortParsing() {
        _active = false
    }
    /// An NSError object from which you can obtain information about a parsing error.
    open var parserError: Error?
    
    /**
    ### Obtaining Parser State
    */
    
    // MARK: The following flags are permanently set as their functionalty has not been implemented yet
    /// The column number of the XML document being processed by the parser.
    open var columnNumber: Int {
        get { 0 }
        set {}
    }
    /// The line number of the XML document being processed by the parser.
    open var lineNumber: Int {
        get { 0 }
        set {}
    }
    /// The public identifier of the external entity referenced in the XML document.
    var publicID: String? {
        get { nil }
        set {}
    }
    /// The system identifier of the external entity referenced in the XML document.
    var systemID: String? {
        get { nil }
        set {}
    }
    
    /**
    ### Constants
    */
    
    enum ExternalEntityResolvingPolicy : UInt, @unchecked Sendable {
        case always = 3
        case never = 0
        case noNetwork = 1
        case sameOriginOnly = 2
    }
    /// Indicates an error in XML parsing.
    static let errorDomain: String = "HTMLParserErrorDomain"
    /// The following error codes are defined by NSXMLParser. For error codes not listed here, see the <libxml/xmlerror.h> header file.
    enum ErrorCode: Int, @unchecked Sendable {
        // MARK: The following errors are never thrown but are declared anyway for complete compatibility with XMLParser
        /// The parser object encountered an internal error.
        case internalError = 1
        /// The parser object ran out of memory.
        case outOfMemoryError
        /// The parser object is unable to start parsing.
        case documentStartError
        /// The document is empty.
        case emptyDocumentError
        /// The document ended unexpectedly.
        case prematureDocumentEndError
        /// Invalid hexadecimal character reference encountered.
        case invalidHexCharacterRefError
        /// Invalid decimal character reference encountered.
        case invalidDecimalCharacterRefError
        /// Invalid character reference encountered.
        case invalidCharacterRefError
        /// Invalid character encountered.
        case invalidCharacterError
        /// Target of character reference cannot be found.
        case characterRefAtEOFError
        /// Invalid character found in the prolog.
        case characterRefInPrologError
        /// Invalid character found in the epilog.
        case characterRefInEpilogError
        /// Invalid character encountered in the DTD.
        case characterRefInDTDError
        /// Target of entity reference is not found.
        case entityRefAtEOFError
        /// Invalid entity reference found in the prolog.
        case entityRefInPrologError
        /// Invalid entity reference found in the epilog.
        case entityRefInEpilogError
        /// Invalid entity reference found in the DTD.
        case entityRefInDTDError
        /// Target of parsed entity reference is not found.
        case parsedEntityRefAtEOFError
        /// Target of parsed entity reference is not found in prolog.
        case parsedEntityRefInPrologError
        /// Target of parsed entity reference is not found in epilog.
        case parsedEntityRefInEpilogError
        /// Target of parsed entity reference is not found in internal subset.
        case parsedEntityRefInInternalSubsetError
        /// Entity reference is without name.
        case entityReferenceWithoutNameError
        /// Entity reference is missing semicolon.
        case entityReferenceMissingSemiError
        /// Parsed entity reference is without an entity name.
        case parsedEntityRefNoNameError
        /// Parsed entity reference is missing semicolon.
        case parsedEntityRefMissingSemiError
        /// Entity is not declared.
        case undeclaredEntityError
        /// Cannot parse entity.
        case unparsedEntityError
        /// Cannot parse external entity.
        case entityIsExternalError
        /// Entity is a parameter.
        case entityIsParameterError
        /// Document encoding is unknown.
        case unknownEncodingError
        /// Document encoding is not supported.
        case encodingNotSupportedError
        /// String is not started.
        case stringNotStartedError
        /// String is not closed.
        case stringNotClosedError
        /// Invalid namespace declaration encountered.
        case namespaceDeclarationError
        /// Entity is not started.
        case entityNotStartedError
        /// Entity is not finished.
        case entityNotFinishedError
        /// Angle bracket is used in attribute.
        case lessThanSymbolInAttributeError
        /// Attribute is not started.
        case attributeNotStartedError
        /// Attribute is not finished.
        case attributeNotFinishedError
        /// Attribute doesn’t contain a value.
        case attributeHasNoValueError
        /// Attribute is redefined.
        case attributeRedefinedError
        /// Literal is not started.
        case literalNotStartedError
        /// Literal is not finished.
        case literalNotFinishedError
        /// Comment is not finished.
        case commentNotFinishedError
        /// Processing instruction is not started.
        case processingInstructionNotStartedError
        /// Processing instruction is not finished.
        case processingInstructionNotFinishedError
        /// Notation is not started.
        case notationNotStartedError
        /// Notation is not finished.
        case notationNotFinishedError
        /// Attribute list is not started.
        case attributeListNotStartedError
        /// Attribute list is not finished.
        case attributeListNotFinishedError
        /// Mixed content declaration is not started.
        case mixedContentDeclNotStartedError
        /// Mixed content declaration is not finished.
        case mixedContentDeclNotFinishedError
        /// Element content declaration is not started.
        case elementContentDeclNotStartedError
        /// Element content declaration is not finished.
        case elementContentDeclNotFinishedError
        /// XML declaration is not started.
        case xmlDeclNotStartedError
        /// XML declaration is not finished.
        case xmlDeclNotFinishedError
        /// Conditional section is not started.
        case conditionalSectionNotStartedError
        /// Conditional section is not finished.
        case conditionalSectionNotFinishedError
        /// External subset is not finished.
        case externalSubsetNotFinishedError
        /// Document type declaration is not finished.
        case doctypeDeclNotFinishedError
        /// Misplaced CDATA end string.
        case misplacedCDATAEndStringError
        /// CDATA block is not finished.
        case cdataNotFinishedError
        /// Misplaced XML declaration.
        case misplacedXMLDeclarationError
        /// Space is required.
        case spaceRequiredError
        /// Separator is required.
        case separatorRequiredError
        /// Name token is required.
        case nmtokenRequiredError
        /// Name is required.
        case nameRequiredError
        /// CDATA is required.
        case pcdataRequiredError
        /// URI is required.
        case uriRequiredError
        /// Public identifier is required.
        case publicIdentifierRequiredError
        /// Left angle bracket is required.
        case ltRequiredError
        /// Right angle bracket is required.
        case gtRequiredError
        /// Left angle bracket slash is required.
        case ltSlashRequiredError
        /// Equal sign expected.
        case equalExpectedError
        /// Tag name mismatch.
        case tagNameMismatchError
        /// Unfinished tag found.
        case unfinishedTagError
        /// Standalone value found.
        case standaloneValueError
        /// Invalid encoding name found.
        case invalidEncodingNameError
        /// Comment contains double hyphen.
        case commentContainsDoubleHyphenError
        /// Invalid encoding.
        case invalidEncodingError
        /// External standalone entity.
        case externalStandaloneEntityError
        /// Invalid conditional section.
        case invalidConditionalSectionError
        /// Entity value is required.
        case entityValueRequiredError
        /// Document is not well balanced.
        case notWellBalancedError
        /// Error in content found.
        case extraContentError
        /// Invalid character in entity found.
        case invalidCharacterInEntityError
        /// Internal error in parsed entity reference found.
        case parsedEntityRefInInternalError
        /// Entity reference loop encountered.
        case entityRefLoopError
        /// Entity boundary error.
        case entityBoundaryError
        /// Invalid URI specified.
        case invalidURIError = 91
        /// URI fragment.
        case uriFragmentError
        /// Missing DTD.
        case noDTDError = 94
        /// Delegate aborted parse.
        case delegateAbortedParseError = 512
    }
    
    /**
    ### Instance Properties
    */
    
    // MARK: The following flags are permanently set as their functionalty has not been implemented yet
    var allowedExternalEntityURLs: Set<URL>? {
        get { nil }
        set {}
    }
    var externalEntityResolvingPolicy: XMLParser.ExternalEntityResolvingPolicy {
        get { .never }
        set {}
    }
}
