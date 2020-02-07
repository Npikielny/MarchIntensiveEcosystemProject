//
//  GraphController.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 2/6/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class GraphController: ResizeableController {
    

    let bg: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        return view
    }()
    
    let maxY: NSTextView = {
        let tv = NSTextView()
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.alignment = .center
        tv.textColor = NSColor.white
        return tv
    }()
    
    let minY: NSTextView = {
        let tv = NSTextView()
        tv.string = "0"
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.alignment = .center
        tv.textColor = NSColor.white
        return tv
    }()
    
    let maxX: NSTextView = {
        let tv = NSTextView()
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.alignment = .center
        tv.textColor = NSColor.white
        return tv
    }()
    
    let minX: NSTextView = {
        let tv = NSTextView()
        tv.string = "0"
        tv.backgroundColor = NSColor.clear
        tv.isEditable = false
        tv.isSelectable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.alignment = .center
        tv.textColor = NSColor.white
        return tv
    }()
    
    
    let margin: CGFloat = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        [bg,minX,minY,maxX,maxY].forEach({view.addSubview($0)})
        
        bg.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        bg.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bg.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1*margin).isActive = true
        
        [minY,maxY].forEach({
            $0.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: bg.leftAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        })
        minY.centerYAnchor.constraint(equalTo: bg.bottomAnchor).isActive = true
        maxY.topAnchor.constraint(equalTo: bg.topAnchor).isActive = true
        
        [minX,maxX].forEach({
            $0.topAnchor.constraint(equalTo: bg.bottomAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
        })
        minX.centerXAnchor.constraint(equalTo: bg.leftAnchor).isActive = true
        maxX.rightAnchor.constraint(equalTo: bg.rightAnchor).isActive = true
    }
    
    
    override func resizeWindow(to Frame: NSSize) {
        createGraph()
    }
    
    var dataPoints: [DataPoint]?
    
    func setData(_ Data: [DataPoint] ) {
        dataPoints = Data
        createGraph()
    }
    
    var graphs: [(CAShapeLayer,CAShapeLayer)]?
    
    var colorDicionary: [Int:NSColor] = [0:#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),1:#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1),2:#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),3:#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),4:#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),5:#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),6:#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]
    
    func createGraph() {
        if let Graphs = graphs {
            for i in Graphs {
                i.0.removeFromSuperlayer()
                i.1.removeFromSuperlayer()
            }
        }
        graphs = [(CAShapeLayer,CAShapeLayer)]()
        if let dt = dataPoints {
            dataHandling(dt: dt, Types: [{return $0.FoodCount},{return $0.AnimalCount}])
        }
    }
    
    func dataHandling(dt: [DataPoint], Types: [(DataPoint) -> (Int)]) {
        var max: Int = 0
        let Size = self.bg.frame.size
        for i in Types {
            for point in dt {
                if i(point) > max {
                    max = i(point)
                }
            }
        }
        let yCoef: CGFloat = {
            if max == 0 {
                return 0
            }else {
              return CGFloat(0.9 * Size.height / CGFloat(max))
            }
        }()
        self.maxY.string = String(Int(Float(max) / 0.8))
        self.maxX.string = String(dt.last!.FrameNumber)
        let xCoef = CGFloat((Size.width - 1) / CGFloat(dt.count-1))
        for (index,i) in Types.enumerated() {
            makeGraph(dt: dt, Type: i, Color: (colorDicionary[index % colorDicionary.count]!), xCoef: xCoef, yCoef: yCoef)
        }
    }
    
    func makeGraph(dt: [DataPoint], Type: (DataPoint) -> (Int), Color: NSColor, xCoef: CGFloat, yCoef: CGFloat) {
        let shapeLayer = CAShapeLayer()
        let path = CGMutablePath()
        
        let antLayer = CAShapeLayer()
        antLayer.strokeColor = NSColor.white.cgColor
        antLayer.lineWidth = 1
        antLayer.lineDashPattern = [10,5,5,5]
        antLayer.fillColor = NSColor.clear.cgColor
        let antPath = CGMutablePath()
        
        path.move(to: CGPoint(x: 0, y: 0))
        antPath.move(to: CGPoint(x: 0, y: 0))
        
        let points = individualGraph(dt: dt, Type)
        
        for i in 0..<points.count {
            path.addLine(to: CGPoint(x: points[i].x*xCoef, y: points[i].y*yCoef))
            antPath.addLine(to: CGPoint(x: points[points.count - 1 - i].x*xCoef, y: points[points.count - 1 - i].y*yCoef))
        }
    
        shapeLayer.path = path
        let fillColor = NSColor(red: Color.redComponent, green: Color.greenComponent, blue: Color.blueComponent, alpha: 0.5)
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.butt
        shapeLayer.lineDashPattern = nil
        shapeLayer.lineDashPhase = 0.0
        shapeLayer.lineJoin = CAShapeLayerLineJoin.miter
        shapeLayer.lineWidth = 3.0
        shapeLayer.miterLimit = 10.0
        shapeLayer.strokeColor = Color.cgColor
        
        antLayer.path = antPath
        
        let lineDashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        lineDashAnimation.fromValue = 0
        lineDashAnimation.toValue = antLayer.lineDashPattern?.reduce(0) { $0 + $1.intValue }
        lineDashAnimation.duration = 1.25
        lineDashAnimation.repeatCount = Float.greatestFiniteMagnitude
        
        antLayer.add(lineDashAnimation, forKey: nil)
        graphs?.append((shapeLayer,antLayer))
       bg.layer?.addSublayer(shapeLayer)
       bg.layer?.addSublayer(antLayer)
    }
    
    func individualGraph(dt: [DataPoint], _ Type: (DataPoint) -> (Int)) -> [CGPoint]{
        
        var points = [CGPoint]()
        
        for i in 0..<dt.count {
            points.append(CGPoint(x: Double(i), y: Double(Type(dt[i]))))
            if i == dt.count - 1{
                points.append(CGPoint(x: Double(i+1), y: 0))
            }
        }
        return points
    }
}
