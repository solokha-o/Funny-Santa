//
//  GameViewController.swift
//  Funny Santa
//
//  Created by Oleksandr Solokha on 07.08.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MainGameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'MainGameScene.sks'
            if let scene = SKScene(fileNamed: "MainGameScene.sks") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                //scene fill all present
                let width = view.bounds.width
                let height  = view.bounds.height
                scene.size = CGSize(width: width, height: height)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            createLocalNotifications()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //configure local notifications
    private func createLocalNotifications() {
        //Configuring the notification content
        let messages = ["🎅🏻 Santa want running! 🎄".localized, "🎅🏻 Santa is missing you! 🎄".localized, "🎅🏻 Let's play Fanny Santa! 🎄".localized, "🎅🏻 Let's play before Santa will go to sleep! 🎄".localized]
        let title = "Open Funny Santa 🎄".localized
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = title
        var hour = 8
        for message in messages {
            content.body = message
            // Configure the recurring date
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.hour = hour
            // Create the trigger as a repeating event
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content, trigger: trigger)
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Error with creating notifications: \(error!)")
                }
            }
            hour += 4
        }
    }
}
