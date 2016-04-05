//
//  FAMCalendarViewController.swift
//  FAMCalendarView
//
//  Created by Kazuya Ueoka on 2016/03/26.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

let FAMCalendarYearViewSize :CGSize = CGSize(width: 100.0, height: 44.0)

public typealias FAMCalendarViewBlocks = (() -> Void)
public typealias FAMCalendarViewCompletionBlocks = ((completion: FAMCalendarViewBlocks) -> Void)

public protocol FAMCalendarViewDataSource : class
{
    func imageForCalendarView(calendarView :FAMCalendarView, atDate date :NSDate) -> UIImage?
    func calendarViewMinDate() -> NSDate?
    func calendarViewMaxDate() -> NSDate?
}

public protocol FAMCalendarViewDelegate : class
{
    func calendarView(calendarView :FAMCalendarView, didSelectedDate date :NSDate) -> Void
}

//MARK: FAMCalendarHeaderView

public class FAMCalendarHeaderView :UICollectionReusableView
{
    public static let headerIdentifier :String = "headerIdentifier"
    lazy var yearLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = NSTextAlignment.Center
        result.font = UIFont(name: "Avenir-Medium", size: 12.0)
        result.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        result.numberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.ByWordWrapping
        return result
    }()
    lazy var monthLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = NSTextAlignment.Center
        result.font = UIFont(name: "Avenir-Medium", size: 40.0)
        result.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        result.numberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.ByWordWrapping
        return result
    }()
    lazy var prevButton :UIButton = {
        let button :UIButton = UIButton(type: .Custom)
        button.setImage(UIImage(named: "bt_prev"), forState: .Normal)
        button.imageView?.contentMode = .Center
        return button
    }()
    lazy var forwardButton :UIButton = {
        let button :UIButton = UIButton(type: .Custom)
        button.setImage(UIImage(named: "bt_forward"), forState: .Normal)
        button.imageView?.contentMode = .Center
        return button
    }()
    var didSet :Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._commonInit()
    }
    
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.addSubview(self.yearLabel)
        self.addSubview(self.monthLabel)
        self.addSubview(self.prevButton)
        self.addSubview(self.forwardButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalMargin :CGFloat = 16.0
        let verticalMergin :CGFloat = 4.0
        let yearSize :CGSize = self.yearLabel.sizeThatFits(CGSize(width: (self.frame.size.width - horizontalMargin) / 2.0, height: 20.0))
        let monthSize :CGSize = self.monthLabel.sizeThatFits(CGSize(width: (self.frame.size.width - horizontalMargin) / 2.0, height: 40.0))
        let totalHeight :CGFloat = yearSize.height + verticalMergin + monthSize.height
        self.yearLabel.frame = CGRect(x: horizontalMargin, y: (self.frame.size.height - totalHeight) / 2.0, width: self.frame.size.width - horizontalMargin * 2.0, height: yearSize.height)
        self.monthLabel.frame = CGRect(x: horizontalMargin, y: self.yearLabel.frame.maxY + verticalMergin, width: self.frame.size.width - horizontalMargin * 2.0, height: monthSize.height)

        let buttonSize :CGSize = CGSize(width: 40.0, height: 40.0)
        self.prevButton.frame = CGRect(x: horizontalMargin, y: (self.frame.size.height - buttonSize.height) / 2.0, width: buttonSize.width, height: buttonSize.height)
        self.forwardButton.frame = CGRect(x: self.frame.size.width - horizontalMargin - buttonSize.width, y: (self.frame.size.height - buttonSize.height) / 2.0, width: buttonSize.width, height: buttonSize.height)
    }
    
    deinit
    {
        self.yearLabel.removeFromSuperview()
        self.monthLabel.removeFromSuperview()
        self.prevButton.removeFromSuperview()
        self.forwardButton.removeFromSuperview()
    }
}

//MARK: FAMCalendarViewCell

private class FAMCalendarWeekdayCell :UICollectionViewCell
{
    static let cellIdentifier :String = "calendarViewWeekdayCellIdentifier"

    lazy var dateLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = NSTextAlignment.Center
        result.font = UIFont(name: "Avenir-Heavy", size: 9.0)
        result.backgroundColor = UIColor.clearColor()
        result.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        return result
    }()

    private var didSet :Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self._commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self._commonInit()
    }

    private func _commonInit()
    {
        if didSet
        {
            return
        }
        didSet = true

        self.backgroundColor = UIColor.clearColor()
        self.addSubview(self.dateLabel)
    }

    private override func layoutSubviews() {
        super.layoutSubviews()

        self.dateLabel.frame = self.bounds
    }
}

public class FAMCalendarViewCell :UICollectionViewCell
{
    static let cellIdentifier :String = "calendarViewCellIdentifier"
    lazy var dateLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = .Center
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    lazy var imageView :UIImageView = {
        let result :UIImageView = UIImageView()
        result.contentMode = .ScaleAspectFill
        result.clipsToBounds = true
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    var active :Bool = false {
        didSet
        {
            if active
            {
                self.dateLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.03)
            } else
            {
                self.dateLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.08)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    private var didSet :Bool = false
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.dateLabel)
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
        self.dateLabel.frame = self.bounds
    }
    
    deinit
    {
        self.imageView.removeFromSuperview()
        self.dateLabel.removeFromSuperview()
    }
}

//MARK: FAMCalendarViewLayout

public class FAMCalendarViewLayout :UICollectionViewFlowLayout
{
    private let margin :CGFloat = 2.0
    public static let numberOfWeekDays :CGFloat = 7.0
    lazy private var calendarItemSize :CGSize = {
        let size :CGFloat = ((UIScreen.mainScreen().bounds.size.width - numberOfWeekDays) / numberOfWeekDays)
        return CGSize(width: size - self.margin, height:size - self.margin)
    }()
    
    override init() {
        super.init()
        
        self.itemSize = self.calendarItemSize
        self.minimumLineSpacing = self.margin
        self.minimumInteritemSpacing = self.margin
        self.sectionInset = UIEdgeInsets(top: self.margin, left: 0.0, bottom: 0.0, right: 0.0)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: FAMCalendarView

public class FAMCalendarView :UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private var didSet :Bool = false
    public var numberOfWeeks :Int = 0
    public var numberOfDays :Int = 0
    
    public var year :Int = 0
    public var month :Int = 0
    public var date :NSDate? {
        didSet
        {
            guard let currentDate = date else
            {
                return
            }
            
            let calendar :NSCalendar = NSCalendar.currentCalendar()
            calendar.locale = NSLocale.systemLocale()
            calendar.timeZone = NSTimeZone.systemTimeZone()
            let comp1 :NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: currentDate)
            comp1.month += 1
            comp1.day = 0
            
            guard let _date = calendar.dateFromComponents(comp1) else
            {
                return
            }
            let comp2 :NSDateComponents = calendar.components([.Day, .WeekOfMonth, .Year, .Month], fromDate: _date)
            self.numberOfWeeks = comp2.weekOfMonth
            self.numberOfDays = comp2.day
            self.year = comp2.year
            self.month = comp2.month
        }
    }
    public weak var calendarDataSource :FAMCalendarViewDataSource?
    public weak var calendarDelegate :FAMCalendarViewDelegate?
    
    public var prev :FAMCalendarViewBlocks?
    public var forward :FAMCalendarViewBlocks?
    public var didSelect :FAMCalendarViewCompletionBlocks?
    
    lazy var calendarHeaderView :FAMCalendarHeaderView = {
        let result :FAMCalendarHeaderView = FAMCalendarHeaderView()
        
        return result
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self._commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._commonInit()
    }
    
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.backgroundColor = UIColor.whiteColor()
        self.delegate = self
        self.dataSource = self
        self.registerClass(FAMCalendarViewCell.self, forCellWithReuseIdentifier: FAMCalendarViewCell.cellIdentifier)
        self.registerClass(FAMCalendarWeekdayCell.self, forCellWithReuseIdentifier: FAMCalendarWeekdayCell.cellIdentifier)
        self.registerClass(FAMCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FAMCalendarHeaderView.headerIdentifier)
    }
    
    //MARK: UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.numberOfWeeks + 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(FAMCalendarViewLayout.numberOfWeekDays)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if 0 == indexPath.section
        {
            let cell :FAMCalendarWeekdayCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMCalendarWeekdayCell.cellIdentifier, forIndexPath: indexPath) as! FAMCalendarWeekdayCell
            cell.dateLabel.text = FAMCalendarWeekDay.toString(indexPath.row)
            return cell
        } else
        {
            let cell :FAMCalendarViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMCalendarViewCell.cellIdentifier, forIndexPath: indexPath) as! FAMCalendarViewCell
            if let currentDate = self.date?.dateFromIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1))
            {
                cell.dateLabel.text = "\(currentDate.day())"
                cell.active = currentDate.isEqual(toYear: self.year, month: self.month)

                cell.imageView.image = cell.active ? self.calendarDataSource?.imageForCalendarView(self, atDate: currentDate) : nil
            }
            return cell
        }
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view :FAMCalendarHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FAMCalendarHeaderView.headerIdentifier, forIndexPath: indexPath) as! FAMCalendarHeaderView
        view.yearLabel.text = "\(self.year)"
        view.monthLabel.text = "\(self.month)"
        view.prevButton.addTarget(self, action: #selector(FAMCalendarView.onPrevButtonDidTapped(_:)), forControlEvents: .TouchUpInside)
        view.forwardButton.addTarget(self, action: #selector(FAMCalendarView.onForwardButtonDidTapped(_:)), forControlEvents: .TouchUpInside)
        return view
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let layout :FAMCalendarViewLayout = collectionViewLayout as! FAMCalendarViewLayout
        let size :CGSize = layout.itemSize

        if 0 == indexPath.section
        {
            return CGSize(width: size.width, height: 20.0)
        } else
        {
            return size
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section
        {
            return CGSize(width: self.frame.size.width, height: 120.0)
        } else
        {
            return CGSize.zero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.didSelect?(completion: {
            if let currentDate = self.date?.dateFromIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1))
            {
                self.calendarDelegate?.calendarView(self, didSelectedDate: currentDate)
            }
        })
    }

    //MARK: events
    func onPrevButtonDidTapped(button :UIButton)
    {
        self.prev?()
    }
    
    func onForwardButtonDidTapped(button :UIButton)
    {
        self.forward?()
    }
    
    deinit
    {
        self.calendarDataSource = nil
        self.calendarDelegate = nil
        self.delegate = nil
        self.dataSource = nil
    }
}

//MARK: FAMCalendarViewCollectionViewCell

public class FAMCalendarViewCollectionViewCell :UICollectionViewCell
{
    public static let cellIdentifier = "calendarViewCollectionViewCellIdentifier"
    public var date :NSDate = NSDate() {
        didSet
        {
            self.calendarView.date = self.date
            self.calendarView.reloadData()
        }
    }
    public weak var dataSource :FAMCalendarViewDataSource? {
        didSet
        {
            self.calendarView.calendarDataSource = self.dataSource
            self.calendarView.reloadData()
        }
    }
    public weak var delegate :FAMCalendarViewDelegate? {
        didSet
        {
            self.calendarView.calendarDelegate = self.delegate
        }
    }
    public lazy var calendarView :FAMCalendarView = {
        let result :FAMCalendarView = FAMCalendarView(frame: CGRect.zero, collectionViewLayout: FAMCalendarViewLayout())
        result.date = self.date
        result.calendarDelegate = self.delegate
        result.calendarDataSource = self.dataSource
        return result
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    private var didSet :Bool = false
    private func _commonInit()
    {
        if self.didSet
        {
            return
        }
        self.didSet = true
        self.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.calendarView)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.calendarView.frame = self.bounds
    }
}

//MARK: FAMCalendarYearsCollectionViewlayout

public class FAMCalendarYearsCollectionViewlayout : UICollectionViewFlowLayout
{
    private static let margin :CGFloat = 2.0
    override init() {
        super.init()
        self._commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }

    var _didSet :Bool = false
    private func _commonInit()
    {
        if _didSet
        {
            return
        }
        _didSet = true

        self.itemSize = FAMCalendarYearViewSize
        self.minimumLineSpacing = self.dynamicType.margin
        self.minimumInteritemSpacing = self.dynamicType.margin
        self.scrollDirection = .Horizontal
    }

    //参考：http://dev.classmethod.jp/smartphone/iphone/collection-view-layout-cell-snap/
    public override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let width :CGFloat = (FAMCalendarYearViewSize.width + self.dynamicType.margin)
        let offset :CGPoint = CGPoint(x: (self.collectionView?.contentOffset.x ?? 0.0) + (self.collectionView?.contentInset.left ?? 0.0), y: self.collectionView?.contentOffset.y ?? 0.0)
        let currentPage :CGFloat = offset.x / width
        let maxPage :CGFloat = (self.collectionView?.contentSize.width ?? 0.0) / width
        let nextPage :CGFloat = (velocity.x > 0.0 && maxPage > ceil(currentPage)) ? ceil(currentPage) : floor(currentPage)
        return CGPoint(x: nextPage * width - (self.collectionView?.contentInset.left ?? 0.0), y: proposedContentOffset.y)
    }
}

//MARK: FAMCalendarYearsCollectionViewCell

public class FAMCalendarYearsCollectionViewCell : UICollectionViewCell
{
    static public let cellIdentifier :String = "calendarYearsCollectionViewCellIdentifier"

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.textLabel.frame = self.bounds
    }

    private var _didSet :Bool = false
    private func _commonInit()
    {
        if _didSet
        {
            return
        }

        _didSet = true
        self.contentView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(self.textLabel)
    }

    public lazy var textLabel :UILabel = {
        let result :UILabel = UILabel()
        result.numberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.ByCharWrapping
        result.font = UIFont(name: "Avenir-Heavy", size: 12.0)
        result.textColor = UIColor.blackColor()
        result.textAlignment = .Center
        return result
    }()
}

protocol FAMCalendarYearsCollectionViewDelegate : class
{
    func calendarYearsView(calendarYearsView view :FAMCalendarYearsCollectionView, didChangedYear year:Int) -> Void
}

//MARK: FAMCalendarYearsCollectionView

public class FAMCalendarYearsCollectionView : UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource
{
    public var years :[Int] = [] {
        didSet
        {
            self.reloadData()
        }
    }

    public var year :Int = NSDate().year() {
        didSet
        {
            self._selectYear(self.year)
        }
    }

    weak var yearsDelegate :FAMCalendarYearsCollectionViewDelegate?

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self._commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }

    var _didSet :Bool = false
    private func _commonInit()
    {
        if _didSet
        {
            return
        }

        _didSet = true
        self.backgroundColor = UIColor.whiteColor()
        self.registerClass(FAMCalendarYearsCollectionViewCell.self, forCellWithReuseIdentifier: FAMCalendarYearsCollectionViewCell.cellIdentifier)
        self.delegate = self
        self.dataSource = self
        self.contentInset = UIEdgeInsets(top: 0.0, left: (self.frame.size.width - FAMCalendarYearViewSize.width) / 2.0, bottom: 0.0, right: (self.frame.size.width - FAMCalendarYearViewSize.width) / 2.0)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    private func _selectYear(year :Int)
    {
        if let index :Int = self.years.indexOf(year)
        {
            guard let collectionViewLayout :FAMCalendarYearsCollectionViewlayout = self.collectionViewLayout as? FAMCalendarYearsCollectionViewlayout else
            {
                return
            }

            let contentOffset :CGPoint = CGPoint(x: (CGFloat(index) * (collectionViewLayout.itemSize.width + collectionViewLayout.minimumInteritemSpacing)), y: self.contentOffset.y)
            self.scrollRectToVisible(CGRect(x: contentOffset.x, y: contentOffset.y, width: collectionViewLayout.itemSize.width, height: collectionViewLayout.itemSize.height), animated: true)
        }
    }

    //MARK: UICollectionViewDataSource nad UICollectionViewDelegate
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.years.count
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :FAMCalendarYearsCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMCalendarYearsCollectionViewCell.cellIdentifier, forIndexPath: indexPath) as! FAMCalendarYearsCollectionViewCell
        cell.textLabel.text = "\(self.years[indexPath.row])"
        return cell
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.years.count > indexPath.row
        {
            self.year = self.years[indexPath.row]
        }
    }

    //MARK: UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self._checkScrollViewScrolling(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self._checkScrollViewScrolling(scrollView)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self._checkScrollViewScrolling(scrollView)
    }

    private func _checkScrollViewScrolling(scrollView :UIScrollView)
    {
        if scrollView.dragging || scrollView.decelerating || scrollView.tracking
        {
            return
        }

        guard let indexPath :NSIndexPath = self.indexPathForItemAtPoint(CGPoint(x: scrollView.contentOffset.x + scrollView.contentInset.left, y: scrollView.contentOffset.y)) else
        {
            return
        }

        if self.years.count > indexPath.row
        {
            self.yearsDelegate?.calendarYearsView(calendarYearsView: self, didChangedYear: self.years[indexPath.row])
        }
    }

    //MARK: deinit
    deinit
    {
        self.delegate = nil
        self.dataSource = nil
    }
}

//MARK: FAMCalendarViewController

public class FAMCalendarViewController :UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FAMCalendarYearsCollectionViewDelegate
{
    public var date :NSDate
    
    lazy private var closeButton :UIBarButtonItem = { [weak self] in
        let result :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(FAMCalendarViewController.onCloseButtonDidTapped(_:)))
        return result
    }()

    public weak var dataSource :FAMCalendarViewDataSource? {
        didSet
        {
            guard let minDate :NSDate = self.dataSource?.calendarViewMinDate(), let maxDate :NSDate = self.dataSource?.calendarViewMaxDate() else
            {
                return
            }

            self.yearsCollectionView.years = NSDate.yearsFromDates(minDate, endDate: maxDate)
        }
    }
    public weak var delegate :FAMCalendarViewDelegate?

    lazy private var _contentInset :UIEdgeInsets = { [weak self] in
        return UIEdgeInsets(top: UIApplication.sharedApplication().statusBarFrame.height + (self?.navigationController?.navigationBar.frame.height ?? 0.0), left: 0.0, bottom: 0.0, right: 0.0)
    }()
    lazy public var layout :UICollectionViewFlowLayout = {
        let layout :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = UIScreen.mainScreen().bounds.size
        return layout
    }()
    lazy public var collectionView :UICollectionView = {
        let result :UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        result.backgroundColor = UIColor.whiteColor()
        result.registerClass(FAMCalendarViewCollectionViewCell.self, forCellWithReuseIdentifier: FAMCalendarViewCollectionViewCell.cellIdentifier)
        result.delegate = self
        result.dataSource = self
        result.pagingEnabled = true
        result.showsVerticalScrollIndicator = false
        result.showsHorizontalScrollIndicator = false
        return result
    }()
    public lazy var yearsLayout :FAMCalendarYearsCollectionViewlayout = {
        return FAMCalendarYearsCollectionViewlayout()
    }()
    public lazy var yearsCollectionView :FAMCalendarYearsCollectionView = {
        let result :FAMCalendarYearsCollectionView = FAMCalendarYearsCollectionView(frame: CGRect(x: 0.0, y: self.view.frame.size.height - FAMCalendarYearViewSize.height, width: self.view.frame.size.width, height: FAMCalendarYearViewSize.height), collectionViewLayout: self.yearsLayout)
        result.yearsDelegate = self
        return result
    }()
    
    init(withDate date :NSDate, dataSource :FAMCalendarViewDataSource?, delegate :FAMCalendarViewDelegate?)
    {
        self.date = date
        self.dataSource = dataSource
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = [self.closeButton]
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.yearsCollectionView)

        if let minDate :NSDate = self.dataSource?.calendarViewMinDate(), let maxDate :NSDate = self.dataSource?.calendarViewMaxDate()
        {
            self.yearsCollectionView.years = NSDate.yearsFromDates(minDate, endDate: maxDate)
        }
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.yearsCollectionView.year = self.date.year()
    }

    private var _didSetContentOffset :Bool = false
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.frame = self.view.bounds
        self.yearsCollectionView.frame = CGRect(x: 0.0, y: self.view.frame.size.height - FAMCalendarYearViewSize.height, width: self.view.frame.size.width, height: FAMCalendarYearViewSize.height)

        if let indexPath :NSIndexPath = self._indexPathFromDate(self.date) where !_didSetContentOffset
        {
            _didSetContentOffset = true
            self._moveToIndexPath(indexPath, animated: false)
        }
    }

    public func close(completion: (() -> Void)?)
    {
        self.dismissViewControllerAnimated(true, completion: {
            self.dataSource = nil
            self.delegate = nil
            completion?()
        })
    }
    
    //MARK: events
    public func onCloseButtonDidTapped(button :UIBarButtonItem?)
    {
        self.close(nil)
    }

    private func _totalMonths() -> Int
    {
        guard let minDate :NSDate = self.dataSource?.calendarViewMinDate() else
        {
            return 0
        }

        guard let maxDate :NSDate = self.dataSource?.calendarViewMaxDate() else
        {
            return 0
        }

        return NSDate.totalMonths(minDate, maxDate: maxDate)
    }

    private func _dateFromIndexPath(indexPath :NSIndexPath) -> NSDate?
    {
        guard let minDate :NSDate = self.dataSource?.calendarViewMinDate() else
        {
            return nil
        }

        let components :NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: minDate)
        components.day = 1
        components.month += indexPath.row
        return NSCalendar.currentCalendar().dateFromComponents(components)
    }

    private func _indexPathFromDate(date :NSDate?) -> NSIndexPath?
    {
        if nil == date
        {
            return nil
        }

        guard let minDate :NSDate = self.dataSource?.calendarViewMinDate(), let maxDate :NSDate = self.dataSource?.calendarViewMaxDate() else
        {
            return nil
        }

        let compareMin :NSComparisonResult = minDate.compare(date!)
        let compareMax :NSComparisonResult = maxDate.compare(date!)
        if compareMin == .OrderedAscending && compareMax == .OrderedDescending
        {
            return NSIndexPath(forRow: NSDate.totalMonths(minDate, maxDate: date!) - 1, inSection: 0)
        } else if (compareMin == .OrderedDescending)
        {
            return NSIndexPath(forRow: 0, inSection: 0)
        } else
        {
            return NSIndexPath(forRow: self._totalMonths() - 1, inSection: 0)
        }
    }

    private func _moveToIndexPath(indexPath :NSIndexPath, animated: Bool) -> Void
    {
        if 0 > indexPath.row || indexPath.row >= self.collectionView.numberOfItemsInSection(indexPath.section)
        {
            return
        }

        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
    }

    //MARK: UICollectionViewDelegate UIColelctionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._totalMonths()
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :FAMCalendarViewCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMCalendarViewCollectionViewCell.cellIdentifier, forIndexPath: indexPath) as! FAMCalendarViewCollectionViewCell
        cell.calendarView.contentInset = self._contentInset
        cell.calendarView.prev = {
            self._moveToIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section), animated: true)
        }
        cell.calendarView.forward = {
            self._moveToIndexPath(NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section), animated: true)
        }
        cell.calendarView.didSelect = { (completion :FAMCalendarViewBlocks) in
            self.close(completion)
        }
        cell.calendarView.date = self._dateFromIndexPath(indexPath)
        cell.delegate = self.delegate
        cell.dataSource = self.dataSource
        return cell
    }

    //MARK: FAMCalendarYearsCollectionViewDelegate
    func calendarYearsView(calendarYearsView view: FAMCalendarYearsCollectionView, didChangedYear year: Int) {
        let date :NSDate = NSDate.date(fromYear: year, month: self.date.month(), day: self.date.day())
        if let indexPath :NSIndexPath = self._indexPathFromDate(date)
        {
            self._moveToIndexPath(indexPath, animated: true)
        }
    }

    //MARK: UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self._scrollViewDidEndScrolling(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self._scrollViewDidEndScrolling(scrollView)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self._scrollViewDidEndScrolling(scrollView)
    }

    private func _scrollViewDidEndScrolling(scrollView :UIScrollView)
    {
        if scrollView.decelerating || scrollView.dragging || scrollView.tracking
        {
            return
        }

        guard let indexPath :NSIndexPath = self.collectionView.indexPathForItemAtPoint(scrollView.contentOffset) else
        {
            return
        }
        guard let date :NSDate = self._dateFromIndexPath(indexPath) else
        {
            return
        }

        let lastYear :Int = self.date.year()
        self.date = date
        let currentYear :Int = self.date.year()
        if lastYear != currentYear
        {
            self.yearsCollectionView.year = currentYear
        }
    }

    //MARK: deinit
    deinit
    {
        self.navigationItem.leftBarButtonItems = nil
        self.dataSource = nil
        self.delegate = nil
    }
}

//MARK: navigationController

public class FAMCalendarNavigationController :UINavigationController
{
    public override func loadView() {
        super.loadView()
        self.modalTransitionStyle = .CrossDissolve
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBar.backgroundColor = UIColor.clearColor()
    }
}