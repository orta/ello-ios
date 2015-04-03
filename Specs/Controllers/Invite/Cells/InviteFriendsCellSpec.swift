import Ello
import Quick
import Nimble


class InviteFriendsCellSpec: QuickSpec {
    override func spec() {
        var subject = InviteFriendsCell()
        
        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }
        
        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
        
        describe("initialization") {
            
            beforeEach {
                subject = InviteFriendsCell.loadFromNib()
            }
            
            describe("nib") {

                it("IBOutlets are not nil") {
                    expect(subject.inviteButton).notTo(beNil())
                    expect(subject.nameLabel).notTo(beNil())
                }
                
                it("IBActions are wired up") {
                    
                }
            }
        }
    }
}
