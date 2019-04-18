//
//  ARCTrackViewController.swift
//  SpeechToTextDemo
//
//  Created by Subhra Roy on 27/02/19.
//  Copyright © 2019  Subhra Roy All rights reserved.
//

import UIKit

class ARCTrackViewController: UIViewController {

    @IBOutlet weak var lblTrackOrder: UILabel!
    
    let viewPageActivity: NSUserActivity = {
        
        let userActivity = NSUserActivity(activityType: "com.ARC.PrintApp")
        userActivity.title = "View Page"
        if #available(iOS 12.0, *) {
            userActivity.suggestedInvocationPhrase = "View Page"
        } else {
            // Fallback on earlier versions
        }
        userActivity.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = true
        } else {
            // Fallback on earlier versions
        }
        return userActivity
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userActivity = viewPageActivity
        // Do any additional setup after loading the view.
    }
    
    func setTrackDetails( track : String) -> Void{
        
        self.lblTrackOrder.text = track
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
