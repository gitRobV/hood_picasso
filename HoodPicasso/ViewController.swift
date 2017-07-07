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
    

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet var viewBG: UIView!
    @IBOutlet weak var canvas1: UIImageView!
    @IBOutlet weak var canvas2: UIImageView!
    @IBOutlet weak var canvas3: UIImageView!
    var selectedImage = UIImage(named: "alley")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas1.image = UIImage(named: "gallery")
        canvas2.image = UIImage(named: "building")
        canvas3.image = UIImage(named: "subway2")
        
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
                manager.deviceMotionUpdateInterval = 1.0 / 60.0
                manager.startDeviceMotionUpdates(to: cameraQ, withHandler: {
                    (data: CMDeviceMotion?, error: Error?) in
                    if let camdata = data {
                        let attitude: CMAttitude = camdata.attitude
                        self.cameraNode.eulerAngles = SCNVector3Make(
                            Float(attitude.roll - Double.pi/2.0),
                            Float(attitude.yaw), Float(attitude.pitch))
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
    
    func buildSphere() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        let sphere = SCNSphere(radius: 75.0)
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
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

