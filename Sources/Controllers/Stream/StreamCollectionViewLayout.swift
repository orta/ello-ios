//
//  StreamCollectionViewLayout.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//  Big thanks to https://github.com/chiahsien
//  Swiftified and modified https://github.com/chiahsien/CHTCollectionViewWaterfallLayout

@objc
public protocol StreamCollectionViewLayoutDelegate: UICollectionViewDelegate {

    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize

    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath, numberOfColumns: NSInteger) -> CGFloat

    optional func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: NSIndexPath) -> String

    optional func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets

    optional func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat

    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: NSIndexPath) -> Bool
}

public class StreamCollectionViewLayout : UICollectionViewLayout {

    enum Direction {
        case ShortestFirst
        case LeftToRight
        case RightToLeft
    }

    var columnCount : Int {
        didSet { invalidateLayout() }
    }

    var minimumColumnSpacing : CGFloat {
        didSet { invalidateLayout() }
    }

    var minimumInteritemSpacing : CGFloat {
        didSet { invalidateLayout() }
    }

    var sectionInset : UIEdgeInsets {
        didSet { invalidateLayout() }
    }

    var itemRenderDirection : Direction {
        didSet { invalidateLayout() }
    }

    weak var delegate : StreamCollectionViewLayoutDelegate? {
        get {
            return collectionView!.delegate as? StreamCollectionViewLayoutDelegate
        }
    }
    var columnHeights = [Double]()
    var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    var allItemAttributes = [UICollectionViewLayoutAttributes]()
    var unionRects = [CGRect]()
    let unionSize = 20

    override init(){
        columnCount = 2
        minimumInteritemSpacing = 10
        minimumColumnSpacing = 10
        sectionInset = UIEdgeInsetsZero
        itemRenderDirection = .ShortestFirst
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        columnCount = 2
        minimumInteritemSpacing = 10
        minimumColumnSpacing = 10
        sectionInset = UIEdgeInsetsZero
        itemRenderDirection = .ShortestFirst
        super.init(coder: aDecoder)
    }

    override public func prepareLayout(){
        super.prepareLayout()

        guard let numberOfSections = self.collectionView?.numberOfSections() else {
            return
        }

        unionRects.removeAll()
        columnHeights.removeAll()
        allItemAttributes.removeAll()
        sectionItemAttributes.removeAll()

        for _ in 0..<columnCount {
            self.columnHeights.append(0)
        }

        for section in 0..<numberOfSections {
            addAttributesForSection(section)
        }

        let itemCounts = allItemAttributes.count
        var index = 0
        while(index < itemCounts){
            let rect1 = allItemAttributes[index].frame
            index = min(index + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[index].frame
            unionRects.append(CGRectUnion(rect1, rect2))
            index++
        }
    }

    private func addAttributesForSection(section: Int) {

        var attributes = UICollectionViewLayoutAttributes()

        let width = collectionView!.frame.size.width - sectionInset.left - sectionInset.right

        let spaceColumCount = CGFloat(columnCount-1)

        let itemWidth = floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))

        let itemCount = collectionView!.numberOfItemsInSection(section)
        var itemAttributes = [UICollectionViewLayoutAttributes]()

        // Item will be put into shortest column.
        var groupIndex = ""
        var currentColumIndex = 0
        for index in 0..<itemCount {
            let indexPath = NSIndexPath(forItem: index, inSection: section)
            let itemGroup: String? = self.delegate?.collectionView?(self.collectionView!, layout: self, groupForItemAtIndexPath: indexPath)
            let isFullWidth = self.delegate?.collectionView?(self.collectionView!, layout: self, isFullWidthAtIndexPath: indexPath) ?? false
            if let itemGroup = itemGroup {
                if itemGroup != groupIndex {
                    groupIndex = itemGroup
                    currentColumIndex = nextColumnIndexForItem(index)
                }
            }
            else {
                currentColumIndex = nextColumnIndexForItem(index)
            }

            var calculatedColumnCount = columnCount
            var calculatedItemWidth = itemWidth
            if isFullWidth {
                calculatedItemWidth = floor(width)
                calculatedColumnCount = 1
                currentColumIndex = 0
            }

            let xOffset = sectionInset.left + (calculatedItemWidth + minimumColumnSpacing) * CGFloat(currentColumIndex)
            let yOffset = columnHeights[currentColumIndex]

            var itemHeight : CGFloat = 0.0

            if let height = delegate?.collectionView(self.collectionView!, layout: self, heightForItemAtIndexPath: indexPath, numberOfColumns: calculatedColumnCount) {
                itemHeight = height
            }

            attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = CGRectMake(xOffset, CGFloat(yOffset), calculatedItemWidth, itemHeight)
            itemAttributes.append(attributes)

            allItemAttributes.append(attributes)
            if isFullWidth && columnCount > 1 {
                columnHeights[0] = Double(CGRectGetMaxY(attributes.frame))
                columnHeights[1] = Double(CGRectGetMaxY(attributes.frame))
            }
            else {
                columnHeights[currentColumIndex] = Double(CGRectGetMaxY(attributes.frame))
            }
        }

        sectionItemAttributes.append(itemAttributes)
    }

    override public func collectionViewContentSize() -> CGSize {
        let numberOfSections = collectionView!.numberOfSections()
        if numberOfSections == 0 {
            return CGSizeZero
        }

        let contentWidth = self.collectionView!.bounds.size.width
        return CGSize(width: contentWidth, height: CGFloat(columnHeights.first!))
    }

    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionItemAttributes[indexPath.section][indexPath.item]
    }

    override public func layoutAttributesForElementsInRect (rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0
        var end = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()

        for var i = 0; i < end; i++ {
            if CGRectIntersectsRect(rect, unionRects[i]) {
                begin = i * unionSize;
                break
            }
        }
        for var i = self.unionRects.count - 1; i>=0; i-- {
            if CGRectIntersectsRect(rect, unionRects[i]) {
                end = min((i+1) * unionSize, allItemAttributes.count)
                break
            }
        }

        for var i = begin; i < end; i++ {
            let attr = allItemAttributes[i]
            if CGRectIntersectsRect(rect, attr.frame) {
                attrs.append(attr)
            }
        }

        return attrs
    }

    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "profileHeader", withIndexPath: indexPath)
    }

    override public func shouldInvalidateLayoutForBoundsChange (newBounds : CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        return CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)
    }

    private func shortestColumnIndex() -> Int {
        return columnHeights.indexOf(columnHeights.minElement()!) ?? 0
    }

    private func longestColumnIndex () -> NSInteger {
        return columnHeights.indexOf(columnHeights.maxElement()!) ?? 0
    }

    private func nextColumnIndexForItem (item : NSInteger) -> Int {
        switch (itemRenderDirection) {
        case .ShortestFirst: return shortestColumnIndex()
        case .LeftToRight: return (item % columnCount)
        case .RightToLeft: return (columnCount - 1) - (item % columnCount);
        }
    }
}
