//
//  ViewController.swift
//  metal-convolution
//
//  Created by Weyland Joyner on 10/19/16.
//  Copyright © 2016 madlab. All rights reserved.
//

import UIKit
import MetalKit
import MetalPerformanceShaders

@available(iOS 10.0, *)
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let weights: [Float] = Array(repeating: 1, count: 27)
        let bias: [Float] = [0]

        // this will throw nil if Metal is absent (i.e. you're in the simulator)
        let device = MTLCreateSystemDefaultDevice()!
        
        let kernel = MakeConv(device: device, weights: weights, bias: bias)
        
        func loadTexture(named filename: String) -> MTLTexture? {
            if let url = Bundle.main.url(forResource: filename, withExtension: "") {
                return loadTextureFromUrl(url)
            } else {
                print("Error: could not find image \(filename)")
                return nil
            }
        }
        
        func loadTextureFromUrl(_ url: URL) -> MTLTexture? {
            let textureLoader = MTKTextureLoader(device: device)
            do {
                return try textureLoader.newTexture(withContentsOf: url)
            } catch {
                print("Error: could not load texture \(error)")
                return nil
            }
        }
        
        func createImage(from texture: MTLTexture, channels: Int) -> MPSImage {
            return MPSImage(texture: texture, featureChannels: channels)
        }
        
        func runConvolution(on image: String, with kernel: MakeConv) -> MPSImage? {
            if let texture = loadTexture(named: image) {
                let inputImage = createImage(from: texture, channels: 3)
                let outputImage = kernel.run(from: inputImage)
                return outputImage
            } else {
                print("Error: could not loadTexture")
                return nil
            }
        }
        
        func test(png: String) -> UnsafeMutableRawPointer? {
            var pointer: UnsafeMutableRawPointer?
            if let new = runConvolution(on: png, with: kernel) {
                let newTexture = new.texture
                let check = Test(output: newTexture)
                pointer = check.run(x: 10, y: 10)
            }
            return pointer
        }
        
        let bytes = test(png: "Naranja3.png")!
        print("got bytes\n", bytes)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

