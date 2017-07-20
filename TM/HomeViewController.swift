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


class HomeViewController: UIViewController, AfterAsynchronous {
    
    var calendars = [EKEvent]() { didSet { setNeedsFocusUpdate() } }
    var reminders = [EKReminder]() { didSet { setNeedsFocusUpdate() }}
    var rowsWhichAreChecked = [NSIndexPath]()
    @IBOutlet var reminderTableView: UITableView!
    @IBOutlet weak var needPermissionView: UIView!
    @IBOutlet var noReminderView: UIVisualEffectView!
    @IBOutlet weak var secStackView: UIStackView!
    @IBOutlet weak var firstStackVIew: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewDetail: UIStackView!
    @IBOutlet weak var dismissTopViewDetail: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topBackgroundImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.reminderTableView.reloadData()
        self.collectionView.reloadData()
        
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
    
    func setBackgroundImage() {
        let now = Date()
        var image: UIImage
        let six = now.dateAt(hours: 6, minutes: 0)
        let noon = now.dateAt(hours: 12, minutes: 0)
        let five = now.dateAt(hours: 17, minutes: 0)
        let eight = now.dateAt(hours: 20, minutes: 0)
        
        if now >= six && now < noon {
            image = UIImage(named: "morning")!
        }
        else if now >= noon && now < five {
            image = UIImage(named: "afternoon")!
        }
        else if now >= five && now < eight {
            image = UIImage(named: "evening")!
        } else {
            image = UIImage(named: "night")!
        }
        self.topBackgroundImage.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        EventStore.eventKit.checkEventKitAuthorizationStatus(afterCheck: self)
        setBackgroundImage()
    }

    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
    }
    
    func checkReminders(nReminders: Int) {
        if nReminders == 0 {
            reminderTableView.separatorStyle = .none
            noReminderView.frame.size = reminderTableView.frame.size
            noReminderView.frame.origin = secStackView.frame.origin
            
            view.addSubview(noReminderView)
            if topViewDetail.alpha == 1 {
                self.view.bringSubview(toFront: topViewDetail)
            }
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
        (self.tabBarController as! CustomTabBarController).changeCenterButtonColor(backgroundColor: #colorLiteral(red: 0.5451, green: 0.5451, blue: 0.5451, alpha: 1), tintColor: #colorLiteral(red: 0.2078, green: 0.2078, blue: 0.2078, alpha: 1))
    }
    
    func topViewDismiss(sender: UIVisualEffect) {
        topViewDetail.fadeOut(0.1, sizeTransformation: false)
        (self.tabBarController as! CustomTabBarController).changeCenterButtonColor(backgroundColor: #colorLiteral(red: 0.5137, green: 0.5137, blue: 0.5137, alpha: 1), tintColor: #colorLiteral(red: 0.349, green: 0.349, blue: 0.349, alpha: 1))
    }
    
    struct Storyboard {
        static let TableViewCellIdentifier = "Reminder"
        static let CollectionViewCellIdentifier = "Event"
    }
    
    func onFinish() {
        let tabBar = self.tabBarController as! CustomTabBarController
        let checkAuthorizationStatus = Error.manageError.giveError(typeOfError: "Permission")
        if checkAuthorizationStatus == true {
            calendars = EventStore.eventKit.giveCalendarsSinceNow()
            reminders = EventStore.eventKit.giveReminders()
            EventStore.eventKit.eraseEventArrays()
            DispatchQueue.main.async {
            self.checkReminders(nReminders: self.reminders.count)
            }
            DispatchQueue.main.async() {
                self.collectionView.reloadData()
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

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CollectionViewCellIdentifier, for: indexPath) as! EventCollectionViewCell
        cell.event = calendars[indexPath.item]
        return cell
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReminderTableViewCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TableViewCellIdentifier, for: indexPath) as! ReminderTableViewCell
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
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        
    }
}

