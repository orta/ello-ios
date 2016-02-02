//
//  OmnibarScreenTableViewDelegate.swift
//  Ello
//
//  Created by Colin Gray on 2/2/2016.
//  Copyright (c) 2016 Ello. All rights reserved.
//

extension OmnibarScreen: UITableViewDelegate, UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRegions.count
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath path: NSIndexPath) -> CGFloat {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case let .AttributedText(attrdString):
                return OmnibarTextCell.heightForText(attrdString, tableWidth: regionsTableView.frame.width, editing: reordering)
            case let .Image(image, _, _):
                return OmnibarImageCell.heightForImage(image, tableWidth: regionsTableView.frame.width, editing: reordering)
            case .ImageURL:
                return OmnibarImageDownloadCell.Size.height
            case .Spacer:
                return OmnibarImageCell.Size.bottomMargin
            case .Error:
                return OmnibarErrorCell.Size.height
            }
        }
        return 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(region.reuseIdentifier, forIndexPath: path)
            cell.selectionStyle = .None
            cell.showsReorderControl = true

            switch region {
            case let .AttributedText(attributedText):
                let textCell = cell as! OmnibarTextCell
                textCell.isFirst = path.row == 0
                textCell.attributedText = attributedText
            case let .Image(image, data, _):
                let imageCell = cell as! OmnibarImageCell
                if let data = data {
                    imageCell.omnibarAnimagedImage = FLAnimatedImage(animatedGIFData: data)
                }
                else {
                    imageCell.omnibarImage = image
                }
                imageCell.reordering = reordering
            case let .Error(url):
                let textCell = cell as! OmnibarErrorCell
                textCell.url = url
            default: break
            }
            return cell
        }
        return UITableViewCell()
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .AttributedText(_):
                startEditingAtPath(path)
            default:
                stopEditing()
            }
        }
    }

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath path: NSIndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .Error, .Spacer: return false
            default: return true
            }
        }
        return false
    }

    public func tableView(tableView: UITableView, moveRowAtIndexPath sourcePath: NSIndexPath, toIndexPath destPath: NSIndexPath) {
        if let source = reorderableRegions.safeValue(sourcePath.row) {
            reorderableRegions.removeAtIndex(sourcePath.row)
            reorderableRegions.insert(source, atIndex: destPath.row)
        }
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath path: NSIndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            return region.editable
        }
        return false
    }

    public func tableView(tableView: UITableView, commitEditingStyle style: UITableViewCellEditingStyle, forRowAtIndexPath path: NSIndexPath) {
        if style == .Delete {
            if reordering {
                deleteReorderableAtIndexPath(path)
            }
            else {
                deleteEditableAtIndexPath(path)
            }
        }
    }

    public func deleteReorderableAtIndexPath(path: NSIndexPath) {
        if let (_, region) = reorderableRegions.safeValue(path.row)
            where region.editable
        {
            reorderableRegions.removeAtIndex(path.row)
            regionsTableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Automatic)
            if reorderableRegions.count == 0 {
                reorderingTable(false)
            }
        }
    }

    public func deleteEditableAtIndexPath(path: NSIndexPath) {
        if let (index_, region) = editableRegions.safeValue(path.row),
            index = index_ where region.editable
        {
            if editableRegions.count == 1 {
                submitableRegions = [.Text("")]
                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Top)
            }
            else {
                submitableRegions.removeAtIndex(index)
                var deletePaths = [path]
                var reloadPaths = [NSIndexPath]()
                var insertPaths = [NSIndexPath]()
                regionsTableView.beginUpdates()

                // remove the spacer *after* the deleted row (if it's the first
                // or N-1th row in series of image rows), and *before* the last
                // row (if it's the last row in a series of image rows)
                if let (_, belowTextRegion) = editableRegions.safeValue(path.row + 2),
                    (_, aboveTextRegion) = editableRegions.safeValue(path.row - 2),
                    belowText = belowTextRegion.text, aboveText = aboveTextRegion.text
                {
                    // merge text in submitableRegions
                    let newText = aboveText.joinWithNewlines(belowText)
                    submitableRegions[index - 1] = .AttributedText(newText)
                    submitableRegions.removeAtIndex(index)
                    reloadPaths.append(NSIndexPath(forItem: path.row - 2, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row - 1, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row + 1, inSection: 0))
                    deletePaths.append(NSIndexPath(forItem: path.row + 2, inSection: 0))
                }
                else if let last = submitableRegions.last where !last.isText {
                    insertPaths.append(path)
                    submitableRegions.append(.Text(""))
                }
                else if let (_, region) = editableRegions.safeValue(path.row + 1) where region.isSpacer {
                    deletePaths.append(NSIndexPath(forItem: path.row + 1, inSection: 0))
                }
                else if let (_, region) = editableRegions.safeValue(path.row - 1) where region.isSpacer {
                    deletePaths.append(NSIndexPath(forItem: path.row - 1, inSection: 0))
                }

                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.deleteRowsAtIndexPaths(deletePaths, withRowAnimation: .Automatic)
                regionsTableView.reloadRowsAtIndexPaths(reloadPaths, withRowAnimation: .None)
                regionsTableView.insertRowsAtIndexPaths(insertPaths, withRowAnimation: .Automatic)
                regionsTableView.endUpdates()
            }
        }
        updateButtons()
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == textScrollView {
            synchronizeScrollViews()
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != regionsTableView {
            regionsTableView.contentOffset = scrollView.contentOffset
        }
    }

}
