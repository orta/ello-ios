//
//  NewElloTabBar.swift
//  Ello
//
//  Created by Colin Gray on 10/30/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit


class NewElloTabBar: UIView {
    enum Alignment {
        case Left
        case Right
    }

    enum Display {
        case Title(String)
        case SVG(String)
    }

    struct Item {
        let alignment: Alignment
        let display: Display
        let redDotHidden: Bool

        var title: String? {
            switch display {
            case let .Title(title): return title
            default: return nil
            }
        }

        var svg: String? {
            switch display {
            case let .SVG(svg): return svg
            default: return nil
            }
        }
    }

    class ItemView: UIView {
        struct Size {
            static let redDotRadius: CGFloat = 2
        }

        let item: Item
        var selected: Bool = false {
            didSet { updateContentView() }
        }

        private let contentView: UIView
        private let underlineView: UIView?
        private let redDot: UIView = {
            let v = UIView()
            v.backgroundColor = .redColor()
            return v
        }()

        init(item: Item) {
            self.item = item

            switch item.display {
            case .Title:
                let label = ElloSizeableLabel()
                label.font = UIFont.regularFont(14.0)
                self.contentView = label
                let underlineView = UIView()
                underlineView.backgroundColor = UIColor.blackColor()
                self.underlineView = underlineView
            case .SVG:
                self.contentView = UIImageView()
                self.underlineView = nil
            }

            super.init(frame: CGRectZero)

            if !item.redDotHidden {
                addSubview(redDot)
            }
            addSubview(contentView)
            if let underlineView = underlineView {
                addSubview(underlineView)
            }

            updateContentView()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func updateContentView() {
            switch item.display {
            case let .Title(title):
                let titleView = self.contentView as! ElloSizeableLabel
                let color = selected ? UIColor.blackColor() : UIColor.greyA()
                titleView.setLabelText(title, color: color)
                titleView.clipsToBounds = false
            case let .SVG(svgName):
                let svgView = self.contentView as! UIImageView
                let actualName = selected ? "\(svgName)_selected" : "\(svgName)_normal"
                svgView.image = SVGKImage(named: actualName).UIImage
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            let contentSize = contentView.intrinsicContentSize()
            let actualSize = CGSize(width: contentSize.width + 2, height: contentSize.height + 2)
            contentView.frame = CGRect(
                x: (bounds.width - actualSize.width) / 2,
                y: (bounds.height - actualSize.height) / 2,
                width: actualSize.width,
                height: actualSize.height
                )
            let radius = Size.redDotRadius
            let offset: CGPoint
            switch item.display {
            case .Title:
                offset = CGPoint(x: 0, y: 12.5)
            case .SVG:
                offset = CGPoint(x: -3.5, y: 12.5)
            }
            redDot.frame = CGRect(
                x: contentView.frame.maxX + offset.x,
                y: offset.y,
                width: radius * 2,
                height: radius * 2
                )
            redDot.layer.cornerRadius = radius

            if let underlineView = underlineView {
                underlineView.hidden = !selected
                underlineView.frame = CGRect(
                    x: (bounds.width - contentSize.width) / 2,
                    y: bounds.height - 14,
                    width: contentSize.width,
                    height: 2.5
                    )
            }
        }

        override func intrinsicContentSize() -> CGSize {
            var contentSize = self.contentView.intrinsicContentSize()
            switch item.display {
            case .Title:
                contentSize.width += 11  // margins for the red dot
            case .SVG:
                contentSize.width = 24  // icon + red dot size
            }
            contentSize.height = 50  // tab bar height
            return contentSize
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .whiteColor()
    }

    var itemViews: [ItemView] = []
    var items: [Item] {
        get { return itemViews.map { $0.item } }
        set {
            for view in itemViews {
                view.removeFromSuperview()
            }
            itemViews = generateItemViews(newValue)
            for view in itemViews {
                addSubview(view)
            }
        }
    }
    var selectedIndex: Int? {
        didSet {
            for view in itemViews {
                view.selected = false
            }
            if let index = selectedIndex, view = itemViews.safeValue(index) {
                view.selected = true
            }
        }
    }

    private func generateItemViews(items: [Item]) -> [ItemView] {
        return items.map { item in
            return ItemView(item: item)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let tweenMargin: CGFloat = 10

        var left: CGFloat = 15
        let leftViews = itemViews.filter { view in
            return view.item.alignment == .Left
        }
        for view in leftViews {
            let size = view.intrinsicContentSize()
            view.frame.origin = CGPoint(x: left, y: 0)
            view.frame.size = size
            left += size.width + tweenMargin
        }

        var right: CGFloat = bounds.width - 15
        let rightViews = itemViews.filter { view in
            return view.item.alignment == .Right
        }
        for view in rightViews.reverse() {
            let size = view.intrinsicContentSize()
            right -= size.width
            view.frame.origin = CGPoint(x: right, y: 0)
            view.frame.size = size
            right -= tweenMargin
        }
    }

}
