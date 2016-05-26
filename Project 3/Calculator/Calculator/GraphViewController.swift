//
//  GraphViewController.swift
//  Graphic Calculator
//  Assignment - 3 : Graphic Calculator
//  GraphViewController acts as delegate for the GraphView and contains useful methods to graph functionality of the calculator
//  It implements protocol GraphViewDataSource and act as datasource for the GraphView
//  It also contains important methods to save the user default settings for drawing graph using NSUserDefaults

/*
Implemented:
1. Renamed ViewController to CalculatorViewController
2. CalculatorBrain doesn't appear in non-private API
3. GraphView and Calculator spilt view on iphone 6+ and ipad
4.Descripion of graph
5.Used Delegation
6. Generic Graph UIview
7. Graph Discontinuous function
8.GraphView: IBDesignable and scale is IBInspectable
9. a. Pinch : Zoom the entire graph in and out
10.Pan : Moves the entire graph 90% works. Coordinated axes sometime do not cover the entire graph view
11.Double tap
*/


import UIKit


// GraphViewController implements the GraphViewDataSource protocol. I

class GraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var graphView: GraphView! {
        
        didSet {
            graphView.dataSource = self  //declares as delegate to graphView Datasource
           
           //Added Pinch Gesture to support Zooming functionality
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "zoomGraph:"))
           
            // Check if userDeafults setting are stored : GraphOrigin and scale
            if  let userSetorigin = searchForOrigin(userdefaults){
                graphView.userGraphOrigin = userSetorigin
            }
            
            if  let s = userdefaults.objectForKey("\(scale)") {
                graphView.scale = CGFloat(s as! NSNumber)
            }else{
                graphView.scale = 50.0
            }
        }
    }
    
    // DataStructure for storing user defaults setting to draw the graph
    private struct Settings {
        private static let Origin = "originOfGraph"
        private  static let Scale = "scaleOfGraph"
    }
    
    
    // acts as small database for storing user preferences to draw the graph
    let userdefaults = NSUserDefaults.standardUserDefaults()
    
    // setter and Getter: Setter sets the origin as CGPoint in NsUsedefaults dictionaty 
    // getter returns origin
    var origin: CGPoint? {
        
        get {
            var defaultOrigin:CGPoint?
            if let userOrigin =  searchForOrigin(userdefaults) {
                defaultOrigin = userOrigin
                return defaultOrigin
            }
            return nil
        }set {
            userdefaults.setObject(newValue as? AnyObject, forKey: Settings.Origin)
        }
     }
    
    // scale of graph
    var scale: CGFloat {
        get {
            if let scale = userdefaults.objectForKey(Settings.Scale){
                return CGFloat(scale as! NSNumber)
            }
            return 50.0
            
        }set {
            userdefaults.setObject(scale, forKey: Settings.Scale)
        }
    }
    
  
    // Function which search for the default user value of origin
    func searchForOrigin (userSetting: NSUserDefaults)-> CGPoint? {
        var origin  = CGPoint()
        if let o = userSetting.objectForKey(Settings.Origin) as? CGPoint
        {
            origin = o
            return origin
        }
        return nil
    }
    
    // This is pan gesture which moves the entire graph including axes
    // The movement of graph as various state progresses handled graphView.pan() method
    // When pan ends , we store the origin to save user preferences
  @IBAction func moveGraph(gesture: UIPanGestureRecognizer) {
        
        graphView.pan(gesture)
        switch gesture.state {
        case .Ended:
            origin = graphView.userGraphOrigin
        default: break
            
        }
    }
  
    // Handler for pinch Gesture to Zoom in/out the graph
    func zoomGraph(gesture: UIPinchGestureRecognizer) {
    graphView.pinch(gesture)
        if gesture.state == .Ended {
        scale = graphView.scale
        origin = graphView.origin
        }
    }
 
    // Tap Gesture which move the orgin of the graph when user double click at any particular location on graphView
    @IBAction func moveOrigin(sender:UITapGestureRecognizer){
        graphView.moveOrigin(sender)
        switch sender.state {
        case .Ended:
            origin = graphView.userGraphOrigin
        default: break
        }
    }
    
    // We use PropertyList  to blindly pass around the program from CalculatorBrain to GraphViewController
    private var calculatorBrain = CalculatorBrain()
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return calculatorBrain.program
        }
        set {
            calculatorBrain.program = newValue
        }
    }
    
   
    // Here , GraphView Controller implements this method to act as delegate for graphView datasource
    func calculateY(x: CGFloat) -> CGFloat? {
        calculatorBrain.varibleValues["M"] = Double(x)
        let  evaluationResult = calculatorBrain.evaluate()
        if  evaluationResult  != nil {
            return  CGFloat(evaluationResult!)
        }
        return nil
    }
    
}


