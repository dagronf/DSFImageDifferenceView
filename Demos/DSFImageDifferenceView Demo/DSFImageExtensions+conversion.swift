//
//  DSFImageExtensions+conversion.swift
//
//  Created by Darren Ford on 3/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa

// MARK: - Extensions

@available(macOS 10, *)
extension NSImage {
	/// Create a CIImage using the first available bitmap representation of the image
	///
	///  NSImage can contain multiple representations of the image. This function uses the first 'bitmappable' image
	///
	/// - Returns: Converted image, or nil
	func asCIImage() -> CIImage? {
		if let tiffdata = self.tiffRepresentation,
			let bitmap = NSBitmapImageRep(data: tiffdata) {
			return CIImage(bitmapImageRep: bitmap)
		}
		return nil
	}

	/// Create a CGImage using the first available bitmap representation of the image
	///
	///  NSImage can contain multiple representations of the image. This function uses the first 'bitmappable' image
	///
	/// - Returns: Converted image, or nil
	func asCGImage() -> CGImage? {
		if let imageData = self.tiffRepresentation,
			let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) {
			return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
		}
		return nil
	}

	/// Create an NSImage from a CALayer
	///
	/// - Parameter layer: the layer to snapshot
	/// - Returns: the created NSImage, or nil if the snapshot failed
	static func fromLayer(layer: CALayer) -> NSImage? {
		let width = Int(layer.bounds.width * layer.contentsScale)
		let height = Int(layer.bounds.height * layer.contentsScale)
		guard let imageRepresentation =
			NSBitmapImageRep(
				bitmapDataPlanes: nil,
				pixelsWide: width,
				pixelsHigh: height,
				bitsPerSample: 8,
				samplesPerPixel: 4,
				hasAlpha: true,
				isPlanar: false,
				colorSpaceName: NSColorSpaceName.deviceRGB,
				bytesPerRow: 0,
				bitsPerPixel: 0
			) else {
			return nil
		}
		imageRepresentation.size = layer.bounds.size

		guard let context = NSGraphicsContext(bitmapImageRep: imageRepresentation) else {
			return nil
		}

		layer.layoutIfNeeded()
		layer.render(in: context.cgContext)

		return NSImage(cgImage: imageRepresentation.cgImage!, size: layer.bounds.size)
	}

	/// Create an NSImage from an NSView
	///
	/// - Parameters:
	///   - view: the view to snapshot
	///   - inRect: (optional) the frame within the view to snapshot, or nil to create a full snapshot
	/// - Returns: the created image, or nil if an image couldn't be generated
	static func fromView(view: NSView, inRect: CGRect? = nil) -> NSImage? {
		let bound = inRect ?? view.bounds
		guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: bound) else { return nil }
		view.cacheDisplay(in: bound, to: bitmapRep)
		let image = NSImage()
		image.addRepresentation(bitmapRep)
		return image
	}
}

extension CIImage {
	/// Create a CGImage version of this image
	///
	/// - Returns: Converted image, or nil
	func asCGImage(context: CIContext? = nil) -> CGImage? {
		let ctx = context ?? CIContext(options: nil)
		return ctx.createCGImage(self, from: self.extent)
	}

	/// Create an NSImage version of this image
	///
	/// - Returns: Converted image, or nil
	@available(macOS 10, *)
	func asNSImage() -> NSImage? {
		let rep = NSCIImageRep(ciImage: self)
		let updateImage = NSImage(size: rep.size)
		updateImage.addRepresentation(rep)
		return updateImage
	}
}

extension CGImage {
	/// Create a CIImage version of this image
	///
	/// - Returns: Converted image, or nil
	func asCIImage() -> CIImage {
		return CIImage(cgImage: self)
	}

	/// Create an NSImage version of this image
	///
	/// - Returns: Converted image, or nil
	@available(macOS 10, *)
	func asNSImage() -> NSImage? {
		return NSImage(cgImage: self, size: .zero)
	}
}
