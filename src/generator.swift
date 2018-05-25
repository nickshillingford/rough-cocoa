import Foundation
import UIKit

class Generator {
    let renderer: Renderer
    var defaultOptions: [String : Any]
    let defaultValues: [Any] = [2.0,    // max randomness
                                1.0,    // bowing
                                1.0,    // roughness
                                1.0,    // stroke width
                                -1.0,      // hachure gap
                                0.0,      // hachure angle
                                "hachure",  // fill style
                                UIColor.black.cgColor,  // stroke color
                                UIColor(red:0,green:0,blue:0,alpha:0).cgColor, // fill color
                                -1.0,  // fill weight
                                0.0,   // curve tightness
                                9.0]   // curve step count
    
    init() {
        self.renderer = Renderer()
        self.defaultOptions = [
            "maxRandomnessOffset": defaultValues[0],
            "bowing": defaultValues[1],
            "roughness": defaultValues[2],
            "strokeWidth": defaultValues[3],
            "hachureGap": defaultValues[4],
            "hachureAngle": defaultValues[5],
            "fillStyle": defaultValues[6],
            "stroke": defaultValues[7],
            "fill": defaultValues[8],
            "fillWeight": defaultValues[9],
            "curveTightness": defaultValues[10],
            "curveStepCount": defaultValues[11]
        ]
    }
    
    func line(x1: Int, y1: Int, x2: Int, y2: Int, opt: [String:Any]) -> [CAShapeLayer] {
        let checked = self.checkOptions(input: opt)
        let line = self.renderer.line(x1: x1, y1: y1, x2: x2, y2: y2, opt: checked)
        return sketch(drawings: [line])
    }
    
    func rectangle(x: Int, y: Int, width: Int, height: Int, opt: [String:Any]) -> [CAShapeLayer] {
        let checked = self.checkOptions(input: opt)
        let rect = self.renderer.rectangle(x: x, y: y, width: width, height: height, opt: checked)
        var drawings: [Drawing] = [rect]
        if checked["fillStyle"] as! String == "solid" {
            let yc = [Double(y), Double(y), Double(y + height), Double(y + height)]
            let xc = [Double(x), Double(x + width), Double(x + width), Double(x)]
            let data = self.renderer.solidFill(xCoord: xc, yCoord: yc, opt: checked)
            drawings.append(data)
        }
        else {
            let yc = [Double(y), Double(y), Double(y + height), Double(y + height)]
            let xc = [Double(x), Double(x + width), Double(x + width), Double(x)]
            let data = hachureFill(xCoord: xc, yCoord: yc, opt: checked)
            drawings.append(data)
        }
        return sketch(drawings: drawings)
    }
    
    func circle(x: Int, y: Int, diameter: Int, opt: [String:Any]) -> [CAShapeLayer] {
        let checked = self.checkOptions(input: opt)
        let circ = self.renderer.ellipse(x: x, y: y, width: diameter, height: diameter, opt: checked)
        var drawings: [Drawing] = [circ]
        if checked["fillStyle"] as! String == "hachure" {
            let data = hachureFillEllipse(cx: x, cy: y, width: diameter, height: diameter, opt: checked)
            drawings.append(data)
        }
        return sketch(drawings: drawings)
    }
    
    func ellipse(x: Int, y: Int, width: Int, height: Int, opt: [String:Any]) -> [CAShapeLayer] {
        let checked = self.checkOptions(input: opt)
        let elip = self.renderer.ellipse(x: x, y: y, width: width, height: height, opt: checked)
        var drawings: [Drawing] = [elip]
        if checked["fillStyle"] as! String == "hachure" {
            let data = hachureFillEllipse(cx: x, cy: y, width: width, height: height, opt: checked)
            drawings.append(data)
        }
        return sketch(drawings: drawings)
    }
    
    func polygon(points: [[Any]], opt: [String:Any]) -> [CAShapeLayer] {
        let checked = self.checkOptions(input: opt)
        let poly = self.renderer.linearPath(points: points, close: true, opt: checked)
        var drawings: [Drawing] = [poly]
        var xc: [Double] = []
        var yc: [Double] = []
        for point in points {
            let p1 = point[0] as! Int
            let p2 = point[1] as! Int
            xc.append(Double(p1))
            yc.append(Double(p2))
        }
        if checked["fillStyle"] as! String == "solid" {
            let data = self.renderer.solidFill(xCoord: xc, yCoord: yc, opt: checked)
            drawings.append(data)
        }
        else {
            let data = hachureFill(xCoord: xc, yCoord: yc, opt: checked)
            drawings.append(data)
        }
        return sketch(drawings: drawings)
    }
   
    func sketch(drawings: [Drawing]) -> [CAShapeLayer] {
        var layers: [CAShapeLayer] = []
        for drawing in drawings {
            let sketch = UIBezierPath()
            let layer = CAShapeLayer()
            var index = 0
            while index < drawing.data.count {
                let dict = drawing.data[index] as! [String:[CGFloat]]
                let key = dict.keys[dict.startIndex]
                let val = dict.values[dict.startIndex]
                setCGPoints(sketch: sketch, key: key, val: val)
                index = index + 1
            }
            setLayerProps(drawing: drawing, layer: layer)
            sketch.close()
            layer.path = sketch.cgPath
            layers.append(layer)
        }
        resetDefaultOptions()
        return layers
    }
    
    func checkOptions(input: [String : Any]) -> [String : Any] {
        let r = "roughness", b = "bowing", s = "strokeWidth", a = "hachureAngle", g = "hachureGap", f = "fillWeight"
        for (key, value) in input {
            if (key == r || key == b || key == s || key == a || key == g || key == f) && (!validate(val: value)) {
                if String(describing: type(of: value)) != "Int" {
                    self.defaultOptions.updateValue(1.0, forKey: key)
                }
                else {
                    self.defaultOptions.updateValue(Double(value as! Int), forKey: key)
                }
            }
            else {
                self.defaultOptions.updateValue(value, forKey: key)
            }
        }
        return self.defaultOptions
    }
    
    func setCGPoints(sketch: UIBezierPath, key: String, val: [CGFloat]) {
        if key == "move" {
            sketch.move(to: CGPoint(x: val[0], y: val[1]))
        }
        else if key == "bcurveTo" {
            sketch.addCurve(to: CGPoint(x: val[4], y: val[5]),
                            controlPoint1: CGPoint(x: val[0], y: val[1]),
                            controlPoint2: CGPoint(x: val[2], y: val[3]))
        }
        else if key == "lineTo" {
            sketch.addLine(to: CGPoint(x: val[0], y: val[1]))
        }
    }
    
    func setLayerProps(drawing: Drawing, layer: CAShapeLayer) {
        if drawing.type == "path" {
            layer.lineWidth = CGFloat(self.defaultOptions["strokeWidth"] as! Double)
            layer.strokeColor = (self.defaultOptions["stroke"] as! CGColor)
            layer.fillColor = UIColor(red:0,green:0,blue:0,alpha:0).cgColor
        }
        else if drawing.type == "fillPath" {
            layer.lineWidth = 0.0
            layer.strokeColor = UIColor(red:0,green:0,blue:0,alpha:0).cgColor
            layer.fillColor = (self.defaultOptions["fill"] as! CGColor)
        }
        else if drawing.type == "fillSketch" {
            if (self.defaultOptions["fillWeight"] as! Double) < 0 {
                layer.lineWidth = (CGFloat(self.defaultOptions["strokeWidth"] as! Double) / 2)
            }
            else {
                layer.lineWidth = CGFloat(self.defaultOptions["fillWeight"] as! Double)
            }
            layer.strokeColor = (self.defaultOptions["fill"] as! CGColor)
            layer.fillColor = UIColor(red:0,green:0,blue:0,alpha:0).cgColor
        }
    }
    
    func draw(drawing: [CAShapeLayer], view: UIView) {
        for sketch in drawing.reversed() {
            view.layer.addSublayer(sketch)
        }
    }
    
    func validate(val: Any) -> Bool {
        var isValid = false
        if String(describing: type(of: val)) == "Double" {
            isValid = true
        }
        return isValid
    }
    
    func resetDefaultOptions() {
        self.defaultOptions.updateValue(defaultValues[0], forKey: "maxRandomnessOffset")
        self.defaultOptions.updateValue(defaultValues[1], forKey: "bowing")
        self.defaultOptions.updateValue(defaultValues[2], forKey: "roughness")
        self.defaultOptions.updateValue(defaultValues[3], forKey: "strokeWidth")
        self.defaultOptions.updateValue(defaultValues[4], forKey: "hachureGap")
        self.defaultOptions.updateValue(defaultValues[5], forKey: "hachureAngle")
        self.defaultOptions.updateValue(defaultValues[6], forKey: "fillStyle")
        self.defaultOptions.updateValue(defaultValues[7], forKey: "stroke")
        self.defaultOptions.updateValue(defaultValues[8], forKey: "fill")
        self.defaultOptions.updateValue(defaultValues[9], forKey: "fillWeight")
        self.defaultOptions.updateValue(defaultValues[10], forKey: "curveTightness")
        self.defaultOptions.updateValue(defaultValues[11], forKey: "curveStepCount")
    }
}
