import Ello
import Quick
import Nimble


class FindFriendsCellSpec: QuickSpec {
    override func spec() {
        var subject = FindFriendsCell()
        
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }
        
        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        describe("initialization", {
            
            beforeEach({
                subject = FindFriendsCell.loadFromNib()
            })
            
            describe("nib", {
                
                beforeEach({
                    
                })
                
                it("IBOutlets are  not nil") {
                    expect(subject.profileImageView).notTo(beNil())
                    expect(subject.nameLabel).notTo(beNil())
                    expect(subject.relationshipView).notTo(beNil())
                }
                
                it("IBActions are wired up") {
                    
                }
            })
        })
    }
}
