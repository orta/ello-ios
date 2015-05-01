import Ello
import Quick
import Nimble


class StreamFooterCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {

            context("single column view") {

                it("configures a stream footer cell") {
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.isOpen).to(beFalse())
                    expect(cell.commentsControl.selected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.scrollView.scrollEnabled).to(beTrue())
                    expect(cell.chevronButton.hidden).to(beFalse())
                    expect(cell.footerConfig.streamKind?.name) == "Friends"
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"
                }
            }

            context("grid layout") {

                it("configures a stream footer cell") {
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Noise, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.isOpen).to(beFalse())
                    expect(cell.commentsControl.selected).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.scrollView.scrollEnabled).to(beFalse())
                    expect(cell.chevronButton.hidden).to(beTrue())
                    expect(cell.footerConfig.streamKind?.name) == "Noise"
                    expect(cell.views) == ""
                    expect(cell.reposts) == ""
                    expect(cell.comments) == "6"
                }
            }

            context("detail streamkind") {

                it("configures a stream footer cell") {
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .PostDetail(postParam: "768"), indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.isOpen).to(beFalse())
                    expect(cell.commentsControl.selected).to(beFalse())
                    expect(cell.scrollView.scrollEnabled).to(beTrue())
                    expect(cell.chevronButton.hidden).to(beFalse())
                    expect(cell.footerConfig.streamKind?.name) == "Post Detail"
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"

                    // details should have open comments
                    expect(cell.commentsOpened).to(beTrue())
                }
            }

            context("repost button") {
                it("usually enabled and visible") {
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.repostControl.enabled).to(beTrue())
                    expect(cell.repostControl.hidden).to(beFalse())
                }
                it("shown if author allows it") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6, "author" : author])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.repostControl.hidden).to(beFalse())
                }
                it("disabled if author doesn't allow it") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6, "author" : author])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.repostControl.hidden).to(beTrue())
                }
                it("disabled if author is current user") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : true])
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6, "author" : author])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: author)

                    expect(cell.repostControl.enabled).to(beFalse())
                }
                it("hidden if author is current user, and reposting isn't allowed") {
                    let author: User = stub(["id" : "1", "hasRepostingEnabled" : false])
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6, "author" : author])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: author)

                    expect(cell.repostControl.hidden).to(beTrue())
                }
            }

            context("loading") {

                it("configures a stream footer cell") {
                    let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                    var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                    var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    // set the state to loading
                    item.state = .Loading

                    StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.isOpen).to(beFalse())
                    expect(cell.commentsOpened).to(beFalse())
                    expect(cell.scrollView.scrollEnabled).to(beTrue())
                    expect(cell.chevronButton.hidden).to(beFalse())
                    expect(cell.footerConfig.streamKind?.name) == "Friends"
                    expect(cell.views) == "9"
                    expect(cell.reposts) == "4"
                    expect(cell.comments) == "6"

                    // commentsButton should be selected when the state is loading
                    expect(cell.commentsControl.selected).to(beTrue())
                }
            }

            context("not loading") {

                context("expanded") {

                    it("configures a stream footer cell") {
                        let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                        var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                        var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                        // set the state to expanded
                        item.state = .Expanded

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isOpen).to(beFalse())
                        expect(cell.commentsOpened).to(beTrue())
                        expect(cell.scrollView.scrollEnabled).to(beTrue())
                        expect(cell.chevronButton.hidden).to(beFalse())
                        expect(cell.footerConfig.streamKind?.name) == "Friends"
                        expect(cell.views) == "9"
                        expect(cell.reposts) == "4"
                        expect(cell.comments) == "6"

                        // commentsButton should be selected when expanded
                        expect(cell.commentsControl.selected).to(beTrue())
                    }

                }

                context("not expanded") {

                    it("configures a stream footer cell") {
                        let post: Post = stub(["id" : "768", "viewsCount" : 9, "repostsCount" : 4, "commentsCount" : 6])
                        var cell: StreamFooterCell = StreamFooterCell.loadFromNib()
                        var item: StreamCellItem = StreamCellItem(jsonable: post, type: .Footer, data: nil, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                        // set the state to none
                        item.state = .None

                        StreamFooterCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                        expect(cell.isOpen).to(beFalse())
                        expect(cell.commentsOpened).to(beFalse())
                        expect(item.state) == StreamCellState.Collapsed
                        expect(cell.scrollView.scrollEnabled).to(beTrue())
                        expect(cell.chevronButton.hidden).to(beFalse())
                        expect(cell.footerConfig.streamKind?.name) == "Friends"
                        expect(cell.views) == "9"
                        expect(cell.reposts) == "4"
                        expect(cell.comments) == "6"
                        expect(cell.commentsControl.selected).to(beFalse())
                    }
                }
            }
        }
    }
}
