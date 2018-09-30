## Rectangles

![Rough Cocoa rectangle](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3171.png?alt=media&token=39e47742-86c4-4c2c-960d-2ec524054df2)

```swift

let gen = Generator()
let rect = gen.rectangle(x: 64, y: 250, width: 250, height: 120, opt: [:]) // uses the default options
gen.draw(drawing: rect, view: self.view) // draw the shape on the UIViewController's main view                                                           
```

## Lines and Ellipses

![Rough Cocoa lines-ellipse](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3165.png?alt=media&token=485f9f81-0601-4142-b6d0-7c809eac14da)

```swift

let circ = gen.circle(x: 150, y: 150, diameter: 50, opt: [:])
let elip = gen.ellipse(x: 220, y: 450, width: 150, height: 80, opt: [:])
let line = gen.line(x1: 150, y1: 150, x2: 220, y2: 450, opt: [:])   

```

## Filling

![Rough Cocoa filling](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3164.png?alt=media&token=b255feb3-c6e2-4e63-a99d-24724a5db94b)

```swift

let yellow = UIColor(red: 0.99, green: 0.86, blue: 0.43, alpha: 1.0).cgColor
let red = UIColor(red: 0.99, green: 0.16, blue: 0.28, alpha: 1.0).cgColor
let blue = UIColor(red: 0.11, green: 0.67, blue: 0.84, alpha: 1.0).cgColor
let purple = UIColor(red: 0.62, green: 0.51, blue: 0.73, alpha: 1.0).cgColor

let rect = gen.rectangle(x: 60, y: 175, width: 100, height: 100, opt: ["fill": red,
                                                                       "hachureAngle": 45])
let circ = gen.circle(x: 260, y: 225, diameter: 100, opt: ["fill": blue,
                                                           "hachureAngle": 100,
                                                           "hachureGap": 10])
        
let circ2 = gen.circle(x: 100, y: 375, diameter: 100, opt: ["fill": yellow,
                                                            "fillWeight": 2.5,
                                                            "hachureAngle": 12])
        
let rect2 = gen.rectangle(x: 208, y: 325, width: 100, height: 100, opt: ["fillStyle": "solid",
                                                                         "fill": purple])
                                                                         
```

## Sketching

![Rough Cocoa sketch](https://firebasestorage.googleapis.com/v0/b/web-demo-2188e.appspot.com/o/IMG_3163.png?alt=media&token=99778141-a7e3-4ae2-a852-43ce72a92844)

```swift

let orange = UIColor(red: 1.00, green: 0.46, blue: 0.22, alpha: 1.0).cgColor
let pink = UIColor(red: 0.96, green: 0.39, blue: 0.69, alpha: 1.0).cgColor
let green = UIColor(red: 0.11, green: 0.67, blue: 0.47, alpha: 1.0).cgColor

let rect = gen.rectangle(x: 50, y: 220, width: 100, height: 100, opt: ["roughness": 0.5, "fill": orange])
let rect2 = gen.rectangle(x: 210, y: 220, width: 100, height: 100, opt: ["roughness": 3, "fill": pink])
let rect3 = gen.rectangle(x: 130, y: 375, width: 100, height: 100, opt: ["bowing": 6.5,
                                                                         "stroke": green,
                                                                         "strokeWidth": 3])
                                                                         
```

## Credits

This library was inspired by Preet Shihn's Rough JS.
The core algorithms were also borrowed from Rough JS.
