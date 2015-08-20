//
//  OmnibarImageCell.swift
//  Ello
//
//  Created by Colin Gray on 8/18/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

public class OmnibarImageCell: UITableViewCell {
    class func reuseIdentifier() -> String { return "OmnibarImageCell" }

    struct Size {
        static let margins = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
        static let deleteButtonGutter = CGFloat(40)
    }

    public let scrollView = UIScrollView()
    public let flImageView = FLAnimatedImageView()
    public let deleteButton: UIControl

    public var omnibarImage: UIImage? {
        get { return flImageView.image }
        set { flImageView.image = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        deleteButton = ElloPostToolBarOption.Delete.imageLabelControl()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollEnabled = false

        let leftGesture = UISwipeGestureRecognizer()
        leftGesture.direction = .Left
        leftGesture.addTarget(self, action: Selector("startEditing"))
        scrollView.addGestureRecognizer(leftGesture)

        let rightGesture = UISwipeGestureRecognizer()
        rightGesture.direction = .Right
        rightGesture.addTarget(self, action: Selector("slideClosed"))
        scrollView.addGestureRecognizer(rightGesture)

        contentView.addSubview(scrollView)
        scrollView.addSubview(flImageView)
        scrollView.addSubview(deleteButton)
    }

    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = contentView.bounds
        scrollView.contentSize = CGSize(width: contentView.bounds.size.width + Size.deleteButtonGutter, height: contentView.bounds.size.height)
        flImageView.frame = contentView.bounds.inset(Size.margins)
        deleteButton.frame = flImageView.frame.fromRight().growRight(Size.deleteButtonGutter)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        stopEditing()
    }

    public func stopEditing() {
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    public func startEditing() {
        var tableView: UITableView?
        var view: UIView? = self
        while view != nil {
            if let tv = view as? UITableView {
                tableView = tv
                break
            }
            view = view!.superview
        }
        if let tableView = tableView {
            for cell in tableView.visibleCells() {
                if let imageCell = cell as? OmnibarImageCell where imageCell != self {
                    imageCell.slideClosed()
                }
            }
        }
        scrollView.setContentOffset(CGPoint(x: 40, y: 0), animated: true)
    }

    public func slideClosed() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    public class func heightForImage(image: UIImage, tableWidth: CGFloat) -> CGFloat {
        return image.size.height * tableWidth / image.size.width + Size.margins.top + Size.margins.bottom
    }

}
