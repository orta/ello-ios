//
//  StreamTextCellHTMLSpec.swift
//  Ello
//
//  Created by Sean on 2/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Quick
import Nimble
import Moya


class StreamTextCellHTMLSpec: QuickSpec {

    override func spec() {

        describe("+indexFileAsString:") {

            it("returns the stub index html file") {
                let indexFile = StreamTextCellHTML.indexFileAsString()

                expect(indexFile).to(contain("reportContentHeight"))
            }
            
        }

        describe("+postHTML:") {

            it("returns the stub index html file with custom markup added") {
                let postHTML = StreamTextCellHTML.postHTML("<p>Hi mom, I am some HTML!</p>")
                let expectedHTML = "<p>Hi mom, I am some HTML!</p>"

                expect(postHTML).to(contain(expectedHTML))
            }
            
        }
    }

}
