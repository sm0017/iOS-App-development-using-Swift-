//
//  GraphView.swift
//  Graphic Calculator
//  Copyright © 2016 USM. All rights reserved.
//  Custom Graph View to draw the coordinate axes and graph 
//  When user hit the 'G' button, it graphs the program in the calculator brain using the 'M' as independent variable 

import UIKit

// declare the protocol to get the data/model for the graphView
protocol GraphViewDataSource:  class {
    func calculateY(x:CGFloat) -> CGFloat?
}

@IBDesignable   // makes custom view visible on storyboard
class GraphView: UIView {
    
    //To communicate with graphViewController:
    weak var dataSource: GraphViewDataSource?
    
    
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        
                return  convertPoint(originOfGraph!, fromView: superview)
    }
    
    var userGraphOrigin: CGPoint? {
        get {
            if originOfGraph != nil {
                return originOfGraph
            }
            return nil
        }set {
            originOfGraph  =  newValue
        }
    }
    
    
    var originOfGraph: CGPoint? { didSet { setNeedsDisplay() } }
    
    var changedOrigin = false
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            
        case .Changed:
            let translation = gesture.translationInView(self)
            
            // normally the translation of a pan gesture is relative to the point at which it was first recognized
            // but we are resetting that point so that we are getting "incremental" pan data
            
            if let view = gesture.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                    y:view.center.y + translation.y)
            }
            gesture.setTranslation(CGPointZero, inView: self)
            
        case .Ended:
            
            if userGraphOrigin == nil  {
                userGraphOrigin = CGPoint(x: origin.x + self.frame.origin.x, y: origin.y + self.frame.origin.y)
            }else {
                userGraphOrigin = CGPoint(x: origin.x + self.frame.origin.x, y: origin.y + self.frame.origin.y)
            }
        
        default: break
            
        }
    }
    
    // redraw when device is rotated
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    //GraphView handler for tap gesture to relocate the  origin of graph 
    func moveOrigin(gesture: UITapGestureRecognizer){
        if gesture.state == .Ended {
            userGraphOrigin = gesture.locationInView(self)
            setNeedsDisplay()
        }
    }
    
    func pinch(gesture: UIPinchGestureRecognizer){
        
        switch gesture.state {
            
        case .Changed :
            if gesture.state == .Changed {
                scale *= gesture.scale
                gesture.scale = 1
            }
        default: break
        }
    }
    
    // This method calls the AxesDrawer to draw the coordinate axes
    // Later we use the datasource to get the y coordinate of point and plot the points
    
    var nothingSet = true
    override func drawRect(rect: CGRect) {
        
        if originOfGraph == nil && nothingSet {
            originOfGraph = center
            nothingSet = false
        }
        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var point = CGPoint()
        var lastPoint = false
        
        // iterate over every pixel across the width of view and draw the line to or moveToPoint if the last datapoint is valid
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            
            point.x = CGFloat(i) / contentScaleFactor
            
            let horizontalDist = origin.x - point.x
            
            if let y = dataSource?.calculateY((horizontalDist) / scale){
                
                if y.isNormal || y.isZero {
                    
                    point.y = origin.y - y * scale
                    
                    if lastPoint {
                        path.addLineToPoint(point)
                    }else {
                        path.moveToPoint(point)
                        lastPoint = true
                    }
                }else {
                    break
                }
            }else {
                lastPoint = false
            }
            path.stroke()
        }
    }
    
}

