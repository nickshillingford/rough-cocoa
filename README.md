# Rough-Cocoa
An iOS/tvOS/watchOS graphics library for rendering UI Bezier Paths in hand drawn sketch styles.

## Install

Download the src folder from this repository and include the files in your XCode project.

## Usage

<b>rectangles</b>

```swift
let gen = Generator()

let blue = UIColor(red: 0.17, green: 0.42, blue: 0.77, alpha: 1.0).cgColor
let pink = UIColor(red: 1.00, green: 0.67, blue: 0.80, alpha: 1.0).cgColor

let rect1 = gen.rectangle(x: 60, y: 156, width: 250, height: 136, opt: [:]) // uses the default options

let rect2 = gen.rectangle(x: 50, y: 356, width: 125, height: 125, opt: ["fillStyle": "solid",
                                                                        "roughness": 1.5,
                                                                        "fill": blue])

let rect3 = gen.rectangle(x: 190, y: 356, width: 125, height: 125, opt: ["hachureAngle": 45,
                                                                         "fillWeight": 2.5,
                                                                         "roughness": 2.5,
                                                                         "fill": pink])

gen.draw(drawing: rect1, view: self.view) // draw an object on the ViewController's main view
.
.
```

![Rough Cocoa rectangle](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3156.png?alt=media&token=cb5e24ab-db2c-43eb-818c-72acece789f9)

<b>circles<b/>

```swift
let purple = UIColor(red: 0.62, green: 0.51, blue: 0.73, alpha: 1.0).cgColor
let yellow = UIColor(red: 0.99, green: 0.86, blue: 0.43, alpha: 1.0).cgColor

let circ1 = gen.circle(x: 125, y: 218, diameter: 200, opt: ["hachureAngle": 130,
                                                            "hachureGap": 3,
                                                            "fillWeight": 2,
                                                            "fill": purple])

let circ2 = gen.circle(x: 270, y: 362, diameter: 120, opt: ["roughness": 1.2,
                                                            "hachureAngle": 12,
                                                            "hachureGap": 3.5,
                                                            "fillWeight": 2.5,
                                                            "fill": yellow])

let circ3 = gen.circle(x: 125, y: 472, diameter: 75, opt: [:])

gen.draw(drawing: circ1, view: self.view)
.
.
```

![Rough Cocoa circle](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3157.png?alt=media&token=0598c134-c4ce-4571-b9c8-8601ee3c799f)

<b>polygons</b>

```swift
let green = UIColor(red: 0.11, green: 0.67, blue: 0.47, alpha: 1.0).cgColor
let orange = UIColor(red: 1.00, green: 0.46, blue: 0.22, alpha: 1.0).cgColor

let poly1 = gen.polygon(points: [[225, 100], [175, 200], [275, 200]], opt: [:])

let poly2 = gen.polygon(points: [[100, 245], [100, 377], [250, 377]], opt: ["roughness": 1.7,
                                                                            "bowing": 2,
                                                                            "fillStyle": "solid",
                                                                            "fill": green])

let poly3 = gen.polygon(points: [[100, 500], [214, 440], [214, 560]], opt: ["fill": orange,
                                                                            "fillWeight": 2.5])
gen.draw(drawing: poly1, view: self.view)
.
.
```

![Rough Cocoa polygon](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3158.png?alt=media&token=ca25187f-d275-4c4d-9c25-d10e96124b91)

<b>lines</b>

```swift
let red = UIColor(red: 0.99, green: 0.16, blue: 0.28, alpha: 1.0).cgColor

let line1 = gen.line(x1: 40, y1: 150, x2: 330, y2: 475, opt: ["roughness": 1.8,
                                                              "strokeWidth": 0.8,
                                                              "stroke": red])

let line2 = gen.line(x1: 40, y1: 475, x2: 330, y2: 150, opt: ["roughness": 1.8,
                                                              "stroke": red])

gen.draw(drawing: line1, view: self.view)
.
.
```

![Rough Cocoa line](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3160.png?alt=media&token=eb4ba495-a469-4366-9dc1-0de358cf637c)

## Notes

Support for complex and custom paths will eventually be added.

## Credits

This library was inspired by Preet Shihn's Rough JS.
The core algorithms were also borrowed from Rough JS.
