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
import EventKit


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, iCarouselDataSource, iCarouselDelegate, AfterAsynchronous  {
    var calendars = [EKEvent]()
    var reminders = [EKReminder]()
    var rowsWhichAreChecked = [NSIndexPath]()
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var reminderTableView: UITableView!
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet var noReminderView: UIVisualEffectView!
    @IBOutlet weak var secStackView: UIStackView!
    @IBOutlet weak var firstStackVIew: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewDetail: UIStackView!
    @IBOutlet weak var dismissTopViewDetail: UIVisualEffectView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        carousel.type = .linear
        carousel .reloadData()
        
        
        self.reminderTableView.dataSource = self
        self.reminderTableView.delegate = self
        
        navigationController?.isNavigationBarHidden = true
        
        let tapTopView = UITapGestureRecognizer(target: self, action: #selector(topViewTapped(sender:)))
        tapTopView.delegate = self as? UIGestureRecognizerDelegate
        topView.addGestureRecognizer(tapTopView)
        
        let tapTopViewDismiss = UITapGestureRecognizer(target: self, action: #selector(topViewDismiss(sender:)))
            tapTopViewDismiss.delegate = self as? UIGestureRecognizerDelegate
        dismissTopViewDetail.addGestureRecognizer(tapTopViewDismiss)
        
        
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
        UserService.userService.createDirectory()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        EventStore.eventKit.checkEventKitAuthorizationStatus(afterCheck: self)
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return calendars.count
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
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 310, height: 200))
            itemView.image = UIImage(named: "page.png")
            itemView.contentMode = .center
            
            label = UILabel(frame: itemView.bounds)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = label.font.withSize(20)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(calendars[index].title)"
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.01
        }
        return value
    }

    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReminderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Reminders", for: indexPath) as! ReminderTableViewCell
        let reminder:EKReminder! = self.reminders[indexPath.row]
        cell.reminderLabel?.text = reminder.title
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = reminder.dueDateComponents?.date {
            cell.scheduleLabel?.text = formatter.string(from: dueDate)
        } else {
            cell.scheduleLabel?.text = "N/A"
        }
        
        let isRowChecked = rowsWhichAreChecked.contains(indexPath as NSIndexPath)
        
        if(isRowChecked == true)
        {
            cell.checkbox.isChecked = true
            cell.checkbox.buttonClicked(sender: cell.checkbox)
        }else{
            cell.checkbox.isChecked = false
            cell.checkbox.buttonClicked(sender: cell.checkbox)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: ReminderTableViewCell = tableView.cellForRow(at: indexPath) as! ReminderTableViewCell
        // cross checking for checked rows
        if(rowsWhichAreChecked.contains(indexPath as NSIndexPath) == false) {
            cell.checkbox.isChecked = true
            cell.checkbox.buttonClicked(sender: cell.checkbox)
            rowsWhichAreChecked.append(indexPath as NSIndexPath)
        } else {
            cell.checkbox.isChecked = false
            cell.checkbox.buttonClicked(sender: cell.checkbox)
            // remove the indexPath from rowsWhichAreCheckedArray
            if let checkedItemIndex = rowsWhichAreChecked.index(of: indexPath as NSIndexPath){
                rowsWhichAreChecked.remove(at: checkedItemIndex)
            }
        }
    }
    
    func checkReminders(nReminders: Int) {
        if nReminders == 0 {
            reminderTableView.separatorStyle = .none
            noReminderView.frame.size = reminderTableView.frame.size
            noReminderView.frame.origin.y = secStackView.frame.origin.y
            
            self.view.addSubview(noReminderView)
        }
        else if nReminders > 0 {
            reminderTableView.separatorStyle = .singleLine
            noReminderView.removeFromSuperview()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func topViewTapped(sender: UIView) {
        self.view.bringSubview(toFront: topViewDetail)
        
        topViewDetail.fadeIn(0.2, sizeTransformation: false)
    }
    
    func topViewDismiss(sender: UIVisualEffect) {
        topViewDetail.fadeOut(0.1, sizeTransformation: false)
    }
    
    func onFinish() {
        let tabBar = self.tabBarController as! CustomTabBarController
        let checkAuthorizationStatus = Error.manageError.giveError(typeOfError: "Permission")
        if checkAuthorizationStatus == true {
            calendars = EventStore.eventKit.giveCalendarsSinceNow()
            reminders = EventStore.eventKit.giveReminders()
            checkReminders(nReminders: reminders.count)
            DispatchQueue.main.async() {
                self.carousel.reloadData()
                self.reminderTableView.reloadData()
            }
            tabBar.showTabBar()
            needPermissionView.fadeOut()
        } else {
            tabBar.hideTabBar()
            self.view.bringSubview(toFront: needPermissionView)
            needPermissionView.fadeIn()
        }
    }


}

