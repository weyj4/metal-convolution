//
//  MakeConv.swift
//  metal-convolution
//
//  Created by Weyland Joyner on 10/19/16.
//  Copyright © 2016 madlab. All rights reserved.
//

import MetalPerformanceShaders

@available(iOS 10.0, *)
private func makeConv(_ device: MTLDevice,
                      inDepth: Int,
                      outDepth: Int,
                      weights: [Float],
                      bias: [Float]) -> MPSCNNConvolution {
    
    let relu = MPSCNNNeuronReLU(device: device, a: 0)
    
    let desc = MPSCNNConvolutionDescriptor(kernelWidth: 3,
                                           kernelHeight: 3,
                                           inputFeatureChannels: inDepth,
                                           outputFeatureChannels: outDepth,
                                           neuronFilter: relu)
    
    desc.strideInPixelsX = 1
    desc.strideInPixelsY = 1
    
    let conv = MPSCNNConvolution(device: device,
                                 convolutionDescriptor: desc,
                                 kernelWeights: weights,
                                 biasTerms: bias,
                                 flags: MPSCNNConvolutionFlags.none)
    
    conv.edgeMode = .zero
    
    return conv
}

@available(iOS 10.0, *)
open class MakeConv {
    let conv: MPSCNNConvolution
    let commandQueue: MTLCommandQueue
    let device: MTLDevice
    let softmax: MPSCNNSoftMax
    
    public init(device: MTLDevice, weights: [Float], bias: [Float]) {
        print("creating convolution kernel")
        self.device = device
        conv = makeConv(device, inDepth: 3, outDepth: 1, weights: weights, bias: bias)
        commandQueue = device.makeCommandQueue()
        softmax = MPSCNNSoftMax(device: device)
    }
    
    open func run(from inputImage: MPSImage) -> [Float] {
        print("running convolution")
        let commandBuffer = self.commandQueue.makeCommandBuffer()
        let outputImgDesc = MPSImageDescriptor(channelFormat: .unorm8, width: 10, height: 10, featureChannels: 1)
        let outputArrayDesc = MPSImageDescriptor(channelFormat: .unorm8, width: 10, height: 10, featureChannels: 1)
        let outputImage = MPSImage(device: self.device, imageDescriptor: outputImgDesc)
        let outputArray = MPSImage(device: self.device, imageDescriptor: outputArrayDesc)
        conv.encode(commandBuffer: commandBuffer, sourceImage: inputImage, destinationImage: outputImage)
        softmax.encode(commandBuffer: commandBuffer, sourceImage: outputImage, destinationImage: outputArray)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        print("finished running convolution")
        return outputArray.toFloatArray()
    }
}
