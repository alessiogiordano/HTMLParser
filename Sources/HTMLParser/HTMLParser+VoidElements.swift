//
//  HTMLParser+VoidElements.swift
//  
//
//  Created by Alessio Giordano on 16/04/23.
//

import Foundation

extension HTMLParser {
    /// A void element is an element in HTML that cannot have any child nodes. Void elements only have a start tag; end tags must not be specified for void elements. https://developer.mozilla.org/en-US/docs/Glossary/Void_element
    internal enum VoidElements: String {
        /// The <area> HTML element defines an area inside an image map that has predefined clickable areas.
        case AREA
        /// The <base> HTML element specifies the base URL to use for all relative URLs in a document
        case BASE
        /// The <br> HTML element produces a line break in text (carriage-return).
        case BR
        /// The <col> HTML element defines a column within a table and is used for defining common semantics on all common cells.
        case COL
        /// The <embed> HTML element embeds external content at the specified point in the document.
        case EMBED
        /// The <hr> HTML element represents a thematic break between paragraph-level elements.
        case HR
        /// The <img> HTML element embeds an image into the document.
        case IMG
        /// The <input> HTML element is used to create interactive controls for web-based forms in order to accept data from the user.
        case INPUT
        /// The <keygen> HTML element exists to facilitate generation of key material, and submission of the public key as part of an HTML form.
        case KEYGEN
        /// The <link> HTML element specifies relationships between the current document and an external resource.
        case LINK
        /// The <meta> HTML element represents metadata that cannot be represented by other HTML meta-related elements.
        case META
        /// The <param> HTML element defines parameters for an <object> element.
        case PARAM
        /// The <source> HTML element specifies multiple media resources for the <picture>, the <audio> element, or the <video> element.
        case SOURCE
        /// The <track> HTML element is used as a child of the media elements, <audio> and <video>.
        case TRACK
        /// The <wbr> HTML element represents a word break opportunity.
        case WBR
    }
}
