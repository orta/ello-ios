import Ello
import Quick
import Nimble


class StreamEmbedCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("configure") {
            context("is a repost") {
                it("configures a stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14
                    ])

                    let embedRegion: EmbedRegion = stub([
                        "isRepost" : true
                    ])

                    let cell: StreamEmbedCell = StreamEmbedCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Embed, data: embedRegion, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamEmbedCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.leadingConstraint.constant) == 30
                    expect(cell.leftBorder.superlayer).notTo(beNil())
                }
            }

            context("is not a repost") {
                it("configures a stream footer cell") {
                    let post: Post = stub([
                        "id" : "768",
                        "viewsCount" : 9,
                        "repostsCount" : 4,
                        "commentsCount" : 6,
                        "lovesCount" : 14
                    ])

                    let embedRegion: EmbedRegion = stub([
                        "url" : NSURL(string: "http://www.example.com/image.jpg")!
                    ])

                    let cell: StreamEmbedCell = StreamEmbedCell.loadFromNib()
                    let item: StreamCellItem = StreamCellItem(jsonable: post, type: .Embed, data: embedRegion, oneColumnCellHeight: 20, multiColumnCellHeight: 20, isFullWidth: false)

                    StreamEmbedCellPresenter.configure(cell, streamCellItem: item, streamKind: .Friend, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expect(cell.leadingConstraint.constant) == 0
                    expect(cell.leftBorder.superlayer).to(beNil())
                }
            }
        }
    }
}
