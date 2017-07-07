//
//  ViewController.swift
//  HoodPicasso
//
//  Created by Robert on 7/6/17.
//  Copyright © 2017 The Hackathon Winners. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController {
    
    
    let cameraNode = SCNNode()
    let motionManager = CMMotionManager()
    

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet var viewBG: UIView!
    @IBOutlet weak var canvas1: UIImageView!
    @IBOutlet weak var canvas2: UIImageView!
    @IBOutlet weak var canvas3: UIImageView!
    @IBOutlet weak var permView: UIImageView!
    
    @IBAction func paint(_ sender: UIButton) {
        let motionManager: CMMotionManager?
        motionManager = self.motionManager
        if let manager = motionManager {
            print("We have a motion manager")
            if manager.isDeviceMotionAvailable {
                print("We can detect device motion!")
                let myQ = OperationQueue()
                manager.deviceMotionUpdateInterval = 0.01
                manager.startDeviceMotionUpdates(to: myQ, withHandler: {
                    (data: CMDeviceMotion?, error: Error?) in
                    if let mydata = data {
                        print("My pitch ", mydata.attitude.pitch)
                        print("My roll ", mydata.attitude.roll)
                        let thisPitch = self.degrees(radians: mydata.attitude.pitch * 5) + 300
                        let thisRoll = self.degrees(radians: mydata.attitude.roll * 2.5) + 200
                        let currentPoint = CGPoint(x: thisRoll, y: thisPitch)
                        print(currentPoint)
                        self.lastPoint = currentPoint
                        self.drawLines(fromPoint: self.lastPoint, toPoint: currentPoint)
                    }
                    if let myerror = error {
                        print("myError", myerror)
                        manager.stopDeviceMotionUpdates()
                    }
                })
            } else {
                print("We can not detect device motion!")
            }
        } else {
            print("We do not have a motion manager")
        }
        
        
        
    }
    
    var selectedImage = UIImage(named: "fields")
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas1.image = UIImage(named: "pier")
        canvas2.image = UIImage(named: "bridge")
        canvas3.image = UIImage(named: "fields")
        
        let canvas1Tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        canvas1.isUserInteractionEnabled = true
        canvas1.addGestureRecognizer(canvas1Tap)
        
        let canvas2Tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        canvas2.isUserInteractionEnabled = true
        canvas2.addGestureRecognizer(canvas2Tap)
        
        let canvas3Tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        canvas3.isUserInteractionEnabled = true
        canvas3.addGestureRecognizer(canvas3Tap)
        
        buildSphere()
        
        // Do any additional setup after loading the view, typically from a nib.
        let motionManager: CMMotionManager?
        motionManager = CMMotionManager()
        if let manager = motionManager {
            print("We have a motion manager")
            if manager.isDeviceMotionAvailable {
                print("We can detect device motion!")
                let cameraQ = OperationQueue()
                manager.deviceMotionUpdateInterval = 1.0 / 30.0
                manager.startDeviceMotionUpdates(to: cameraQ, withHandler: {
                    (data: CMDeviceMotion?, error: Error?) in
                    if let camdata = data {
                        let attitude: CMAttitude = camdata.attitude
                        self.cameraNode.eulerAngles = SCNVector3Make(
                            Float(attitude.pitch - Double.pi/2.0),
                            Float(0.0), Float(attitude.roll))
                    }
                    if let camerror = error {
                        print("myError", camerror)
                        manager.stopDeviceMotionUpdates()
                    }
                })
                
            } else {
                print("We can not detect device motion!")
            }
        } else {
            print("We do not have a motion manager")
        }
    }
    
    func update() {
        buildSphere()
    }
    
    func degrees(radians:Double) -> Double {
        return (180/Double.pi) * radians
    }
    
    func drawLines(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        permView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        print (fromPoint, " and ", toPoint)
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(4)
        context?.setStrokeColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor)
        
        context?.strokePath()
        permView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func buildSphere() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        let sphere = SCNSphere(radius: 95.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = selectedImage
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        selectedImage = tappedImage.image!
        permView.image = tappedImage.image
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

