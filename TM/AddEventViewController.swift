//
//  AddEventViewController.swift
//  TM
//
//  Created by Amin Amjadi on 7/15/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailMenuBtnView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet var timeView: UIView!
    @IBOutlet weak var hourSelector: UIImageView!
    @IBOutlet weak var hourSelector2: UIImageView!
    @IBOutlet weak var hourSelectorView: UIView!
    @IBOutlet weak var hourSelectorView2: UIView!
    @IBOutlet weak var minuteSelector: UIImageView!
    @IBOutlet weak var minuteSelector2: UIImageView!
    @IBOutlet weak var minuteSelectorView: UIView!
    @IBOutlet weak var minuteSelectorView2: UIView!
    @IBOutlet weak var centertimeSelector: UIView!
    @IBOutlet weak var centertimeSelector2: UIView!
    @IBOutlet weak var expandChooseDateTimeBtn: UIButton!
    @IBOutlet weak var expandChooseDateTimeBtn2: UIButton!
    @IBOutlet weak var chooseDateTimeCalendar: JTAppleCalendarView!
    @IBOutlet weak var chooseDateTimeCalendar2: JTAppleCalendarView!
    @IBOutlet weak var hourTimeViewLabel: UILabel!
    @IBOutlet weak var hourTimeViewLabel2: UILabel!
    @IBOutlet weak var minuteTimeViewLabel: UILabel!
    @IBOutlet weak var minuteTimeViewLabel2: UILabel!
    @IBOutlet weak var amPMTimeViewLabel: UILabel!
    @IBOutlet weak var amPMTimeViewLabel2: UILabel!
    @IBOutlet weak var monthTimeViewLabel: UILabel!
    @IBOutlet weak var monthTimeViewLabel2: UILabel!
    @IBOutlet weak var monthCalendarTimeViewLabel: UILabel!
    @IBOutlet weak var monthCalendarTimeViewLabel2: UILabel!
    @IBOutlet weak var dateTimeViewLabel: UILabel!
    @IBOutlet weak var dateTimeViewLabel2: UILabel!
    @IBOutlet weak var dayTimeViewLabel: UILabel!
    @IBOutlet weak var dayTimeViewLabel2: UILabel!
    @IBOutlet weak var chooseDatePanelTimeView: UIStackView!
    @IBOutlet weak var chooseDatePanelTimeView2: UIStackView!
    @IBOutlet weak var startViewTabTimeView: UIView!
    @IBOutlet weak var endViewTabTimeView: UIView!
    @IBOutlet weak var moreViewTabTimeView: UIView!
    
    var items = ["Calendar", "Time", "List", "Invite", "Location", "Alert", "Tag", "Notes", "Starts", "Ends"]
    var getInitialScrollViewContent = true
    var initialContentSize: CGFloat?
    var tempItems = [String]()
    let formatter = DateFormatter()
    let date = Date()
    var currentOpenView: UIView?
    var currentOpenViewCell: CGPoint?
    
    
    var collectionViewLayout: SpringyFlowLayout? {
        return collectionView.collectionViewLayout as? SpringyFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
        tempItems = items
        
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialScrollToDateTimeViewCalendar(calendar: chooseDateTimeCalendar)
        initialScrollToDateTimeViewCalendar(calendar: chooseDateTimeCalendar2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        //timeView-----------------------------------------------------------
        chooseDatePanelTimeView.transform = CGAffineTransform(translationX: chooseDatePanelTimeView.frame.size.width + 20, y: 0)
        chooseDatePanelTimeView2.transform = CGAffineTransform(translationX: chooseDatePanelTimeView.frame.size.width + 20, y: 0)
        chooseDatePanelTimeView.isHidden = true
        chooseDatePanelTimeView2.isHidden = true
        
        collectionViewLayout?.setupLayout()
        detailMenuBtnView.layer.cornerRadius = detailMenuBtnView.frame.size.width / 2
        detailMenuBtnView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        buttonReleased()
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissSubviews(sender:)))
        dimView.addGestureRecognizer(dismissTap)
        hourSelectorView.layer.cornerRadius = hourSelectorView.frame.size.width / 2
        minuteSelectorView.layer.cornerRadius = minuteSelectorView.frame.size.width / 2
        centertimeSelector.layer.cornerRadius = centertimeSelector.frame.size.width / 2
        hourSelectorView2.layer.cornerRadius = hourSelector2.frame.size.width / 2
        minuteSelectorView2.layer.cornerRadius = minuteSelector2.frame.size.width / 2
        centertimeSelector2.layer.cornerRadius = centertimeSelector2.frame.size.width / 2
        
        let width = self.view.frame.size.width
        endViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
        moreViewTabTimeView.transform = CGAffineTransform(translationX: 2*width, y: 0)
        
        setupChooseDateCalendarView()
        //-----------------------------------------------------------
    }
    
    func initialScrollToDateTimeViewCalendar(calendar: JTAppleCalendarView) {
        calendar.scrollToDate(date, animateScroll: false)
        calendar.selectDates(from: date, to: date)
    }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        if detailMenuBtnView.transform != .identity {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailMenuBtnView.transform = .identity
                self.menuButton.setImage(UIImage(named: "addEventMainButtonDetail"), for: .normal)
            })
        }
    }
    
    @IBAction func menuButtonRelease(_ sender: UIButton, forEvent event: UIEvent) {
        menuAction(event: event)
    }
    
    @IBAction func menuButtonReleaseOutside(_ sender: UIButton, forEvent event: UIEvent) {
        menuAction(event: event)
    }
    
    func buttonReleased() {
        if detailMenuBtnView.transform == .identity {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailMenuBtnView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.menuButton.setImage(UIImage(named: "addEventMainButton"), for: .normal)
            })
        }
    }
    
    func dismissSubviews(sender: UITapGestureRecognizer) {
        if let activeView = currentOpenView {
            activeView.center = currentOpenViewCell!
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.alpha = 0
            activeView.transform = CGAffineTransform(scaleX: 0.01, y: 0.005)
        }, completion: {(success) in
            activeView.removeFromSuperview()
            self.currentOpenView = nil
            self.currentOpenViewCell = nil
        })
        }
    }
    
    func showSubviewForCollectionView(cell: UICollectionViewCell) {
        guard let validCell = cell as? AddEventCollectionViewCell else { return }
        if validCell.title.text == "Time" {
            currentOpenView = timeView
            currentOpenViewCell = validCell.center
        }
        if let activeView = currentOpenView {
        dimView.isUserInteractionEnabled = true
        activeView.center = self.view.center
        activeView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        activeView.layer.cornerRadius = 10
        self.view.addSubview(activeView)
        activeView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.alpha = 0.7
            activeView.transform = .identity
        })
        }
    }
    
    func menuAction(event: UIEvent) {
        if let touch = event.allTouches?.first {
            let pointOfTouch = touch.location(in: self.view)
            let menuFrame = menuButton.frame
            let width = menuFrame.size.width
            let origin = menuFrame.origin
            //let detailViewOrigin = detailMenuBtnView.frame.origin
            if (pointOfTouch.y < origin.y-width && pointOfTouch.y >= 0 && pointOfTouch.x >= origin.x && pointOfTouch.x <= origin.x+width*2) {
                saveEvent()
            }
            else if (pointOfTouch.x < origin.x-width && pointOfTouch.x >= 0 && pointOfTouch.y >= origin.y && pointOfTouch.y <= origin.y+width*2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        buttonReleased()
    }
    
    func saveEvent() {
        print("Save Funtion")
    }
    
    @IBAction func timeSegmentValueChanged(_ sender: CustomSegmentControl) {
        let width = self.view.frame.size.width
        switch sender.selectedButtonIndex {
        case 0:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: 2*width, y: 0)
            })
            break
        case 1:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: -width, y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: width, y: 0)
            })
            break
        case 2:
            UIView.animate(withDuration: 0.3, animations: {
                self.startViewTabTimeView.transform = CGAffineTransform(translationX: -(2*width), y: 0)
                self.endViewTabTimeView.transform = CGAffineTransform(translationX: -width, y: 0)
                self.moreViewTabTimeView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
            break
        default:
            break
        }
    }
    
    @IBAction func expandChooseDateTime(_ sender: UIButton) {
        expandChooseDateTimeBtn.isHidden = true
        chooseDatePanelTimeView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.chooseDatePanelTimeView.transform = CGAffineTransform.identity
        }
        monthTimeViewLabel.alpha = 0.7
        dayTimeViewLabel.alpha = 0.7
        dateTimeViewLabel.alpha = 0.7
    }
    
    @IBAction func expandChooseDateTime2(_ sender: UIButton) {
        expandChooseDateTimeBtn2.isHidden = true
        chooseDatePanelTimeView2.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.chooseDatePanelTimeView2.transform = CGAffineTransform.identity
        }
        monthTimeViewLabel2.alpha = 0.7
        dayTimeViewLabel2.alpha = 0.7
        dateTimeViewLabel2.alpha = 0.7
    }
    
    
    func dismissChooseDatePanelTimeView() {
        if expandChooseDateTimeBtn.isHidden == true {
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.chooseDatePanelTimeView.transform = CGAffineTransform(translationX: self.chooseDatePanelTimeView.frame.size.width + 20, y: 0)
            }) { (sucess) in
                self.expandChooseDateTimeBtn.isHidden = false
                self.chooseDatePanelTimeView.isHidden = true
                self.monthTimeViewLabel.alpha = 1
                self.dayTimeViewLabel.alpha = 1
                self.dateTimeViewLabel.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.chooseDatePanelTimeView2.transform = CGAffineTransform(translationX: self.chooseDatePanelTimeView2.frame.size.width + 20, y: 0)
            }) { (sucess) in
                self.expandChooseDateTimeBtn2.isHidden = false
                self.chooseDatePanelTimeView2.isHidden = true
                self.chooseDatePanelTimeView.isHidden = true
                self.monthTimeViewLabel2.alpha = 1
                self.dayTimeViewLabel2.alpha = 1
                self.dateTimeViewLabel2.alpha = 1
            }
        }
    }
    
    func calculateMonth(startDate: Date, nextMonth: Bool) -> DateComponents {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        
        // Change int value which you want to minus from current Date.
        components.day = 1
        if nextMonth == true {
            components.month = components.month!+1
        } else {
            components.month = components.month!-1
        }
        return components
    }
    
    @IBAction func nextMonthTimeView() {
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                let components = self.calculateMonth(startDate: startDate, nextMonth: true)
                let nextMonth = Calendar.current.date(from: components)
                self.chooseDateTimeCalendar.scrollToDate(nextMonth!)
            }
        }
    }
    
    @IBAction func previousMonthTimeView() {
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                let components = self.calculateMonth(startDate: startDate, nextMonth: false)
                let nextMonth = Calendar.current.date(from: components)
                self.chooseDateTimeCalendar.scrollToDate(nextMonth!)
            }
        }
    }
    
    func handleChooseDateCellTimeView(calendar: JTAppleCalendarView, cell: JTAppleCell?, cellState: CellState) {
        handleChooseDateSelectedViewTimeView(calendar: calendar,cell: cell, cellState: cellState)
    }
    
    func handleChooseDateSelectedViewTimeView(calendar: JTAppleCalendarView ,cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? ChooseDateTimeCollectionViewCell else { return }
        validCell.selectedDateView.layer.cornerRadius = 2
        validCell.selectedDateView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        if cellState.isSelected {
            validCell.selectedDateView.isHidden = false
            if calendar == chooseDateTimeCalendar {
            formatter.dateFormat = "MMM"
            monthTimeViewLabel.text = " " + formatter.string(from: cellState.date)
            formatter.dateFormat = "dd"
            dateTimeViewLabel.text = formatter.string(from: cellState.date)
            } else {
                formatter.dateFormat = "MMM"
                monthTimeViewLabel2.text = " " + formatter.string(from: cellState.date)
                formatter.dateFormat = "dd"
                dateTimeViewLabel2.text = formatter.string(from: cellState.date)
            }
        } else {
            validCell.selectedDateView.isHidden = true
        }
    }
    
    func setupChooseDateCalendarView() {
        chooseDateTimeCalendar.minimumLineSpacing = 0
        chooseDateTimeCalendar.minimumInteritemSpacing = 0
        
        chooseDateTimeCalendar.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                
                self.formatter.dateFormat = "MMMM"
                self.monthCalendarTimeViewLabel.text = self.formatter.string(from: startDate)
            }
        }
        chooseDateTimeCalendar2.visibleDates { (visibleDates) in
            if let startDate = visibleDates.monthDates.first?.date {
                
                self.formatter.dateFormat = "MMMM"
                self.monthCalendarTimeViewLabel2.text = self.formatter.string(from: startDate)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSubviewForCollectionView(cell: collectionView.cellForItem(at: indexPath)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConstants.collectionViewCellId, for: indexPath) as! AddEventCollectionViewCell
        cell.title.text = items[indexPath.row]
        return cell
    }
    
}

extension AddEventViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let offestY = scrollView.contentOffset.y
            let contentSize = scrollView.contentSize.height
            let frameSize = scrollView.frame.size.height
            if getInitialScrollViewContent == true {
                self.initialContentSize = contentSize
            }
            if offestY > contentSize - frameSize {
                self.items.append(contentsOf: tempItems)
                collectionViewLayout?.setupLayout()
            }
            else if offestY < 0 {
                self.items.insert(contentsOf: tempItems, at: 0)
                let bottom = CGPoint(x: 0, y: contentSize + offestY)
                scrollView.setContentOffset(bottom, animated: false)
                collectionViewLayout?.setupLayout()
            }
            self.collectionView.reloadData()
        }
    }
}

extension AddEventViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, generateInDates: .off, generateOutDates: .off, firstDayOfWeek: .monday, hasStrictBoundaries: true)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "ChooseDateTimeCell", for: indexPath) as! ChooseDateTimeCollectionViewCell
        cell.dateOfCell.text = cellState.text
        handleChooseDateCellTimeView(calendar: calendar, cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if calendar == chooseDateTimeCalendar {
            chooseDateTimeCalendar2.selectDates([date])
        }
        handleChooseDateCellTimeView(calendar: calendar, cell: cell, cellState: cellState)
        dismissChooseDatePanelTimeView()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleChooseDateCellTimeView(calendar: calendar, cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupChooseDateCalendarView()
    }
    
}
