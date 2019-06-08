//
//  DSFImageDifferenceView.swift
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

@objc class DSFImageDifferenceView: NSView {
	// MARK: Public accessors

	/// The image being displayed on the left
	@objc var leftImage: CGImage? {
		didSet {
			self.leftLayer.image.contents = self.leftImage
			self.leftLayer.image.contentsGravity = .resizeAspect
			self.leftImageSize = self.leftImage?.size ?? .zero
			self.reposition()
		}
	}

	/// The image being displayed on the right
	@objc var rightImage: CGImage? {
		didSet {
			self.rightLayer.image.contents = self.rightImage
			self.rightLayer.image.contentsGravity = .resizeAspect
			self.rightImageSize = self.rightImage?.size ?? .zero
			self.reposition()
		}
	}

	/// The position of the separator within the view (0.0 -> 1.0)
	@objc dynamic var separatorPos: CGFloat = 0.5 {
		didSet {
			self.reposition()
		}
	}

	/// The actual size of the left image, or .zero if nil
	@objc private(set) var leftImageSize: CGSize = .zero

	/// The visible rect for the left image
	@objc private(set) var leftVisibleRect: CGRect = .zero

	/// The actual size of the right image, or .zero if nil
	@objc private(set) var rightImageSize: CGSize = .zero

	/// The visible rect for the right image
	@objc private(set) var rightVisibleRect: CGRect = .zero

	/// The position within the frame for the combined images
	@objc private(set) var imagesExtentRect: CGRect = .zero

	// MARK: Private accessors

	private var animLayer: SeparatorAnimationLayer?

	private let leftLayer = LayerMaskCombo()
	private let rightLayer = LayerMaskCombo()
	private let separatorLayer = CAShapeLayer()

	private let checkerboardLayer = LayerMaskCombo()
	private var lastCheckerBoardSize: CGSize = .zero

	// MARK: Initialization and Setup

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	private func setup() {
		self.focusRingType = .exterior
		self.wantsLayer = true
		self.leftLayer.image.frame = self.bounds
		self.rightLayer.image.frame = self.bounds
		self.checkerboardLayer.image.frame = self.bounds

		guard let primaryLayer = self.layer else {
			return
		}

		primaryLayer.addSublayer(self.leftLayer.image)
		primaryLayer.addSublayer(self.rightLayer.image)
		primaryLayer.addSublayer(self.separatorLayer)
		primaryLayer.addSublayer(self.checkerboardLayer.image)

		self.separatorLayer.zPosition = 20
		self.leftLayer.image.zPosition = 10
		self.rightLayer.image.zPosition = 5
		self.checkerboardLayer.image.zPosition = 0

		self.separatorLayer.backgroundColor = NSColor.selectedControlTextColor.cgColor
		self.separatorLayer.shadowRadius = 3
		self.separatorLayer.shadowColor = CGColor.black
		self.separatorLayer.shadowOpacity = 0.7
		self.separatorLayer.shadowOffset = .zero
		self.separatorLayer.magnificationFilter = CALayerContentsFilter.nearest
		self.separatorLayer.allowsEdgeAntialiasing = false

		DistributedNotificationCenter.default.addObserver(
			self,
			selector: #selector(self.interfaceModeChanged(sender:)),
			name: Notification.Name("AppleInterfaceThemeChangedNotification"),
			object: nil
		)
	}

	@objc func interfaceModeChanged(sender _: NSNotification) {
		let sepColor = NSColor.selectedControlTextColor.cgColor
		self.separatorLayer.backgroundColor = sepColor
		self.separatorLayer.needsDisplay()
	}
}

// MARK: - Convenience methods

extension DSFImageDifferenceView {
	/// Swap the left and right images
	func swap() {
		Swift.swap(&self.leftImage, &self.rightImage)
	}
}

// MARK: - Update and layout

extension DSFImageDifferenceView {
	override func layout() {
		super.layout()

		CATransaction.withDisabledActions {
			self.checkerboardLayer.image.frame = self.bounds
			if self.bounds.size.isInSomeWayLargerThan(lastCheckerBoardSize) {
				let newSize = CGSize(width: self.bounds.width + 50, height: self.bounds.height + 50)
				self.checkerboardLayer.image.contentsGravity = .center
				self.checkerboardLayer.image.contents =
					NSImage.checkerboardImage(
						ofSize: newSize,
						color1: NSColor.quaternaryLabelColor,
						color2: NSColor.tertiaryLabelColor
					)
				lastCheckerBoardSize = newSize
			}
			self.leftLayer.image.frame = self.bounds
			self.rightLayer.image.frame = self.bounds
			self.reposition()
		}
	}

	private func updateMaskFrames(dividerPos: CGFloat) {
		let divided = self.bounds.divided(atDistance: dividerPos, from: .minXEdge)
		self.leftVisibleRect = divided.slice
		self.rightVisibleRect = divided.remainder
	}

	private func reposition() {
		CATransaction.withDisabledActions {
			var leftImageRect: CGRect = .zero
			if leftImageSize != .zero {
				leftImageRect = CGRect(origin: .zero, size: leftImageSize)
				leftImageRect = leftImageRect.scaleAspectFit(maxRect: self.bounds)
			}
			var rightImageRect: CGRect = .zero
			if rightImageSize != .zero {
				rightImageRect = CGRect(origin: .zero, size: rightImageSize)
				rightImageRect = rightImageRect.scaleAspectFit(maxRect: self.bounds)
			}
			else {
				rightImageRect = leftImageRect
			}
			let extent = leftImageRect.union(rightImageRect)
			self.imagesExtentRect = extent

			self.checkerboardLayer.mask.frame = self.imagesExtentRect

			var dividerPos = extent.width * separatorPos
			if extent.width < self.bounds.width {
				dividerPos += extent.origin.x
			}

			let divided = self.bounds.divided(atDistance: dividerPos, from: .minXEdge)
			self.leftVisibleRect = divided.slice
			self.rightVisibleRect = divided.remainder

			self.leftLayer.mask.frame = self.leftVisibleRect
			self.rightLayer.mask.frame = self.rightVisibleRect

			let sepRect = CGRect(x: dividerPos - 1.5, y: self.imagesExtentRect.minY, width: 3, height: self.imagesExtentRect.height)
			separatorLayer.frame = sepRect

			let pathRect = CGRect(x: 1, y: 4, width: 1, height: sepRect.height - 8)
			let sepPath = CGPath(rect: pathRect, transform: nil)
			separatorLayer.path = sepPath
			separatorLayer.fillColor = NSColor.systemGray.cgColor
		}
	}
}

// MARK: - Mouse handling

extension DSFImageDifferenceView {
	override func mouseDown(with theEvent: NSEvent) {
		if let anim = self.animLayer {
			anim.removeAllAnimations()
			self.animLayer = nil
		}
		self.updateSlider(event: theEvent)
	}

	override func mouseDragged(with event: NSEvent) {
		self.updateSlider(event: event)
	}

	private func updateSlider(event: NSEvent) {
		let loc = event.locationInWindow
		let point = self.convert(loc, from: nil)
		if self.imagesExtentRect.contains(point) {
			let startXDiff = self.imagesExtentRect.minX - self.bounds.minX
			let newPos = (point.x - startXDiff) / self.imagesExtentRect.width
			self.separatorPos = newPos
		}
	}
}

// MARK: - Key handling

extension DSFImageDifferenceView {
	override var acceptsFirstResponder: Bool {
		return true
	}

	override func drawFocusRingMask() {
		self.bounds.fill()
	}

	override var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	override func keyDown(with event: NSEvent) {
		if event.modifierFlags.contains(.numericPad) {
			self.interpretKeyEvents([event])
		}
		super.keyDown(with: event)
	}

	private func stepSize() -> CGFloat {
		if let ev = NSApp.currentEvent,
			ev.modifierFlags.contains(.shift) {
			return 0.05
		}
		return 0.01
	}

	override func moveLeft(_: Any?) {
		self.separatorPos = max(0, self.separatorPos - stepSize())
	}

	override func moveRight(_: Any?) {
		self.separatorPos = min(1, self.separatorPos + stepSize())
	}
}

// MARK: - Animation

/// A simple layer class to expose an animation progress for a CAAnimation.
private class SeparatorAnimationLayer: CALayer {
	override init() {
		super.init()
	}

	var progressCallback: ((CGFloat) -> Void)?

	override init(layer: Any) {
		super.init(layer: layer)
		let newL = layer as! SeparatorAnimationLayer
		self.progress = newL.progress
		self.progressCallback = newL.progressCallback
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc dynamic var progress: CGFloat = 0 {
		didSet {
			progressCallback?(progress)
		}
	}

	override static func needsDisplay(forKey key: String) -> Bool {
		if key == "progress" {
			return true
		}
		return super.needsDisplay(forKey: key)
	}
}

extension DSFImageDifferenceView {
	@objc func animateIn() {
		if let alayer = self.animLayer {
			alayer.removeFromSuperlayer()
			self.animLayer = nil
		}

		let alayer = SeparatorAnimationLayer()
		self.animLayer = alayer
		self.layer?.addSublayer(alayer)

		alayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		let keyframes = CAKeyframeAnimation(keyPath: "progress")
		keyframes.values = [0, 1, 0, 0.5]
		keyframes.keyTimes = [0, 0.33, 0.66, 1]
		keyframes.duration = 1.8
		keyframes.timingFunctions = [
			CAMediaTimingFunction(name: .easeInEaseOut),
			CAMediaTimingFunction(name: .easeInEaseOut),
			CAMediaTimingFunction(name: .easeInEaseOut),
		]
		alayer.progressCallback = { [weak self] progress in
			self?.separatorPos = progress
		}
		alayer.add(keyframes, forKey: "SlideIn")
	}
}

private extension DSFImageDifferenceView {
	class LayerMaskCombo {
		let image = CALayer()
		let mask = CALayer()
		init() {
			self.image.mask = self.mask
			self.mask.backgroundColor = CGColor.black
		}
	}
}

// MARK: - Extensions

private extension CGImage {
	/// The size of the CGImage
	var size: CGSize {
		return CGSize(width: self.width, height: self.height)
	}
}

private extension CATransaction {
	/// Perform 'body' without implicit animations
	///
	/// - Parameters:
	///   - body: The block to execute without implicit animations
	class func withDisabledActions<T>(_ body: () throws -> T) rethrows -> T {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		defer {
			CATransaction.commit()
		}
		return try body()
	}
}

private extension NSImage {
	/// Generate an NSImage containing a checkerboard pattern for a specific size
	///
	/// - Parameters:
	///   - ofSize: The size of the image to create
	///   - color1: First color
	///   - color2: Second color
	///   - checkSize: The size of the check
	/// - Returns: An image containing the checkerboard pattern, or nil
	static func checkerboardImage(ofSize: CGSize, color1: NSColor, color2: NSColor, checkSize: CGFloat = 8) -> NSImage? {
		let width = NSNumber(value: Float(checkSize))
		let center = CIVector(cgPoint: CGPoint(x: 0, y: 0))
		let darkColor = CIColor(cgColor: color1.cgColor)
		let lightColor = CIColor(cgColor: color2.cgColor)
		let sharpness = NSNumber(value: 1.0)

		guard let filter = CIFilter(name: "CICheckerboardGenerator") else {
			return nil
		}

		filter.setDefaults()
		filter.setValue(width, forKey: "inputWidth")
		filter.setValue(center, forKey: "inputCenter")
		filter.setValue(darkColor, forKey: "inputColor0")
		filter.setValue(lightColor, forKey: "inputColor1")
		filter.setValue(sharpness, forKey: "inputSharpness")

		let context = CIContext(options: nil)
		guard let cgImage = context.createCGImage(filter.outputImage!, from: CGRect(origin: .zero, size: ofSize)) else {
			return nil
		}
		return NSImage(cgImage: cgImage, size: ofSize)
	}
}

private extension CGSize {
	func isInSomeWayLargerThan(_ size: CGSize) -> Bool {
		return self.height > size.height || self.width > size.width
	}
}

private extension CGRect {
	/// Aspect scale this rect to fit the specified 'maximum' rectangle
	///
	/// - Parameter maxRect: Maximum rectangle to fit
	/// - Returns: The frame of this rectangle, scaled to fit maxRect
	func scaleAspectFit(maxRect: CGRect) -> CGRect {
		let originalAspectRatio = self.width / self.height
		let maxAspectRatio = maxRect.width / maxRect.height

		var newRect = maxRect
		if originalAspectRatio > maxAspectRatio {
			newRect.size.height = maxRect.width * self.height / self.width
			newRect.origin.y += (maxRect.height - newRect.height) / 2.0
		}
		else {
			newRect.size.width = maxRect.height * self.width / self.height
			newRect.origin.x += (maxRect.width - newRect.width) / 2.0
		}
		return newRect
	}
}
