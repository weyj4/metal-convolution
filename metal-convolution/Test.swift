//
//  Test.swift
//  metal-convolution
//
//  Created by Weyland Joyner on 10/19/16.
//  Copyright © 2016 madlab. All rights reserved.
//

import MetalKit

open class Test {
    var output: MTLTexture!
    
    init(output: MTLTexture) {
        self.output = output
    }
    
    private func bytes(x: Int, y: Int) -> UnsafeMutableRawPointer {
        let region = MTLRegionMake2D(0, 0, 10, 10)
        let pointer = malloc(x * y)
        self.output.getBytes(pointer!, bytesPerRow: x, from: region, mipmapLevel: 0)
        return pointer!
    }
    
    func run(x: Int, y: Int) -> UnsafeMutableRawPointer {
        return bytes(x: x, y: y)
    }
}
