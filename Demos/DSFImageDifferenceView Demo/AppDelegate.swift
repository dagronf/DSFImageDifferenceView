//
//  AppDelegate
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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var window: NSWindow!
	@IBOutlet var originalImageView: NSImageView!
	@IBOutlet var outputImageView: NSImageView!

	@IBOutlet var imageDifferenceView: DSFImageDifferenceView!

	func applicationDidFinishLaunching(_: Notification) {
		self.setupDemoImages()
	}

	func applicationWillTerminate(_: Notification) {
		// Insert code here to tear down your application
	}
}

extension AppDelegate {
	private func setupDemoImages() {
		let inputImage = NSImage(named: "demo_image")!
		originalImageView.image = inputImage

		guard let sepia = CIFilter(name: "CISepiaTone") else {
			return
		}

		sepia.setValue(inputImage.asCIImage(), forKey: "inputImage")
		sepia.setValue(NSNumber(0.8), forKey: "inputIntensity")
		guard let filtered = sepia.outputImage else {
			return
		}

		self.outputImageView.image = filtered.asNSImage()

		self.imageDifferenceView.leftImage = inputImage.asCGImage()
		self.imageDifferenceView.rightImage = filtered.asCGImage()
		self.imageDifferenceView.animateIn()
	}
}

extension AppDelegate {
	@IBAction func imageDidChange(_: Any) {
		guard let inputImage = originalImageView.image?.asCGImage() else {
			return
		}
		self.imageDifferenceView.leftImage = inputImage
		self.imageDifferenceView.animateIn()
	}

	@IBAction func secondaryImageDidChange(_: Any) {
		guard let outputImage = outputImageView.image?.asCGImage() else {
			return
		}
		self.imageDifferenceView.rightImage = outputImage
		self.imageDifferenceView.animateIn()
	}
}
