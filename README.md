# macOS image differencing view

A NSView class to interactively display the differences between two images

## Features

* Single import file.  Swift and Objective-C support.
* Usable from Interface Builder or programmatically
* Display a combined image with an interactive slider to show/hide.
* (Optional) animation support

## Usage

### Direct
Add `DSFImageDifferenceView.swift` to your project

### Cocoapods
Add

`pod 'DSFImageDifferenceView', :git => 'https://github.com/dagronf/DSFImageDifferenceView'` 
  
to your Podfile


## Example usage

```swift
   @IBOutlet var imageDifferenceView: DSFImageDifferenceView!
   
   ...
   
   let imageleft: CGImage = ...
   let imageright: CGImage = ...
   self.imageDifferenceView.leftImage = imageleft
   self.imageDifferenceView.rightImage = imageright
   
   ...
   
   /// Swap the left and right images and animate in the change
   self.imageDifferenceView.swap()
   self.animateIn()
```

## Demo screenshot

![](https://github.com/dagronf/dagronf.github.io/blob/master/art/projects/DSFImageDifferenceView/demo.gif?raw=true)

## License

```
MIT License

Copyright (c) 2019 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
