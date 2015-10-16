@testable import Ello
import Quick
import Nimble


class StreamRepostHeaderCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            context("has a via") {
                it("configures a stream repost header cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostPath"  : "/666/post/1234",
                        "repostId" : "888",
                        "repostViaId" : "999",
                        "repostViaPath" : "/999/post/1234",
                    ])

                    let cell: StreamRepostHeaderCell = StreamRepostHeaderCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .RepostHeader(height: 20.0))

                    StreamRepostHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.sourceTextView.text) == "Source: @666"
                    expect(cell.viaTextView.text) == "Via: @999"
                    expect(cell.viaTextViewHeight.constant) == 15
                }
            }
            context("does not have a via") {
                it("configures a stream repost header cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14,
                        "repostPath"  : "/666/post/1234",
                        "repostId" : "888"
                    ])

                    let cell: StreamRepostHeaderCell = StreamRepostHeaderCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .RepostHeader(height: 20.0))

                    StreamRepostHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .Following, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.sourceTextView.text) == "Source: @666"
                    expect(cell.viaTextView.text) == ""
                    expect(cell.viaTextViewHeight.constant) == 0
                }
            }
        }
    }
}

