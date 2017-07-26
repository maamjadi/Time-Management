//
//  CalendarViewController.swift
//  TM
//
//  Created by Amin Amjadi on 7/13/17.
//  Copyright © 2017 MDJD. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: JTAppleCalendarView!
    @IBOutlet weak var monthViewCalendarCollectionView: JTAppleCalendarView!
    @IBOutlet var monthView: UIView!
    
    let formatter = DateFormatter()
    let date = Date()
    var dateOfCell: Date?
    var monthCell: MonthViewCollectionViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        setupCalendar()
        
        let expandCalendarGesture = UIPanGestureRecognizer(target: self, action: #selector(expandCalendar(sender:)))
        calendarCollectionView.addGestureRecognizer(expandCalendarGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calendarCollectionView.scrollToDate(date)
        calendarCollectionView.selectDates(from: date, to: date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func expandCalendar(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended:
            fallthrough
        case .changed:
            let velocity = sender.velocity(in: calendarCollectionView)
            if velocity.y > 500 {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.setupMonthView()
                })
            }
        default:
            break
        }
    }
    
    func setupCalendar() {
        calendarCollectionView.minimumLineSpacing = 0
        calendarCollectionView.minimumInteritemSpacing = 0
        
        calendarCollectionView.visibleDates { (visibleDates) in
            let date = visibleDates.monthDates.first!.date
            
            self.formatter.dateFormat = "yyyy"
            self.yearLabel.text = self.formatter.string(from: date)
            self.formatter.dateFormat = "MMMM"
            self.monthLabel.text = self.formatter.string(from: date)
        }
    }
    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCollectionViewCell else { return }
        if cellState.isSelected {
            validCell.dateOfCell.textColor = UIColor.white
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateOfCell.textColor = UIColor.white.withAlphaComponent(0.9)
            } else {
                validCell.dateOfCell.textColor = UIColor.gray
            }
        }
    }
    
    func handleSelectedDates(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCollectionViewCell else { return }
        validCell.selectedDateView.layer.cornerRadius = validCell.selectedDateView.frame.size.width / 2
        validCell.selectedDateView.backgroundColor = UIColor.orange
        if cellState.isSelected {
            self.formatter.dateFormat = "yyyy MM dd"
            let today = formatter.string(from: date)
            let choosenDate = formatter.string(from: cellState.date)
            if today == choosenDate {
                validCell.selectedDateView.backgroundColor = UIColor.red
            }
            validCell.selectedDateView.isHidden = false
        } else {
            validCell.selectedDateView.isHidden = true
        }
    }
    
    func hidePrePostDates(cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? MonthViewCollectionViewCell else { return }
        if cellState.dateBelongsTo == .thisMonth {
            validCell.isHidden = false
        } else {
            validCell.isHidden = true
        }
    }
    
    func handleCells(cell: JTAppleCell?, cellState: CellState) {
        handleSelectedDates(cell: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    func setupMonthView() {
        monthView.bounds = self.view.bounds
        monthView.center = self.view.center
        self.view.addSubview(monthView)
    }

    @IBAction func DismissToAgenda(_ sender: UIButton) {
        monthView.removeFromSuperview()
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if calendar == calendarCollectionView {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCollectionViewCell
        cell.dateOfCell.text = cellState.text
        handleCells(cell: cell, cellState: cellState)
        return cell
        } else {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! MonthViewCollectionViewCell
            cell.dateOfCell.text = cellState.text
            if cellState.date == monthViewCalendarCollectionView.visibleDates().monthDates.first?.date {
                self.formatter.dateFormat = "MMM"
                cell.monthLabelMonthView.text = self.formatter.string(from: cellState.date)
                cell.monthLabelMonthView.isHidden = false
            }
            monthCell = cell
            handleCells(cell: cell, cellState: cellState)
            hidePrePostDates(cell: cell, cellState: cellState)
            return cell
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCells(cell: cell, cellState: cellState)
        if calendar == monthViewCalendarCollectionView {
        hidePrePostDates(cell: cell, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCells(cell: cell, cellState: cellState)
        if calendar == monthViewCalendarCollectionView {
            hidePrePostDates(cell: cell, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendar()
    }
}
