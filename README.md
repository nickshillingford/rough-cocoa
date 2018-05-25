# Rough-Cocoa
An iOS graphics library for rendering UI Bezier Paths in hand drawn sketch styles.

## Install

Download the src folder from this repository and include the files in your Xcode project. If you'd like it to be available on CocoaPods, let me know.

## Usage

![Rough Cocoa shapes](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/rough.png?alt=media&token=29998706-f4c0-4cf8-bc06-61c290965e45)

```swift
let gen = Generator()

let yellow = UIColor(red: 1.00, green: 0.81, blue: 0.28, alpha: 1.0).cgColor
let blue = UIColor(red: 0.17, green: 0.42, blue: 0.77, alpha: 1.0).cgColor
let red = UIColor(red: 0.99, green: 0.16, blue: 0.28, alpha: 1.0).cgColor

let rect1 = gen.rectangle(x: 150, y: 80, width: 200, height: 100, opt: [:]) // uses the default options

let rect2 = gen.rectangle(x: 28, y: 80, width: 100, height: 100, opt: ["fill": blue,
                                                                       "fillStyle": "solid",
                                                                       "roughness": 1.5])
                                                                       
let circ1 = gen.circle(x: 80, y: 320, diameter: 120, opt: ["fill": red,
                                                           "hachureAngle": 45,
                                                           "fillWeight": 2.5])
                                                           
let elip1 = gen.ellipse(x: 252, y: 320, width: 200, height: 120, opt: [:])

let poly1 = gen.polygon(points: [[82, 450], [21, 570], [143, 570]], opt: ["bowing": 1.5,
                                                                          "roughness": 2.5,
                                                                          "strokeWidth": 5,
                                                                          "stroke": yellow])
                                                                          
let poly2 = gen.polygon(points: [[187, 450], [187, 570], [337, 570]], opt: ["bowing": 2])

gen.draw(drawing: rect1, view: self.view) // draw path on the UIViewController's main view
.
.
gen.draw(drawing: poly2, view: self.view)                                                                      
```

## Notes

Support for arcs and custom paths coming soon.

## Credits

This library was inspired by Preet Shihn's Rough JS.
The core algorithms were also borrowed from Rough JS.
