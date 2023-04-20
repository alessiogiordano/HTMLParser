//
//  Data+InputStream.swift
//  
//
//  Created by Alessio Giordano on 15/04/23.
//

import Foundation

extension Data {
    init(reading stream: InputStream, with bufferSize: Int = 1024) {
        self.init()
        stream.open()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
            stream.close()
        }
        while stream.hasBytesAvailable {
            let count = stream.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: count)
        }
    }
}
