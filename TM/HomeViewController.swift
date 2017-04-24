//
//  HomeViewController.swift
//  Time Management
//
//  Created by Amin Amjadi on 10/12/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class HomeViewController: UIViewController, iCarouselDataSource, iCarouselDelegate  {
    var items: [Int] = []
    @IBOutlet var carousel: iCarousel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0 ... 99 {
            items.append(i)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        carousel.type = .linear
        carousel .reloadData()
        
        navigationController?.isNavigationBarHidden = true
//        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
//            
//        if user != nil {
//
//        try! FIRAuth.auth()!.signOut()
//        
//        FBSDKAccessToken.setCurrent(nil)
//        
//            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.login()
//            }
//        }

    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            itemView.image = UIImage(named: "page.png")
            itemView.contentMode = .center
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = label.font.withSize(50)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(items[index])"
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.01
        }
        return value
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

