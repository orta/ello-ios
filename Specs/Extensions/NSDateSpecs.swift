//
//  NSDateSpecs.swift
//  Ello
//
//  Created by Sean on 8/6/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

import Ello
import Quick
import Moya
import Nimble


class NSDateSpecs: QuickSpec {
    override func spec() {

        describe("NSDate") {

            let sep_30_1978 = NSDate(timeIntervalSince1970: 275961600)
            let sep_30_1978_again = NSDate(timeIntervalSince1970: 275961600)
            let now = NSDate()

            describe("toServerDateString()") {
                // tested in DateFormatterSpec
            }

            describe("toHTTPDateString()") {
                // tested in DateFormatterSpec
            }

            describe("isInPast") {

                context("date is now") {
                    // not able to test due to limitation of creating the test date prior to the calculation
                    // trust me, this works!
                }

                context("date is in the past") {
                    it("returns true") {
                        expect(sep_30_1978.isInPast) == true
                    }
                }

                context("date is in the future") {
                    it("returns false") {
                        expect(NSDate.distantFuture().isInPast) == false
                    }
                }

            }

            describe("==") {

                context("dates are equal") {

                    it("returns true") {
                        expect(sep_30_1978 == sep_30_1978_again) == true
                    }
                }

                context("dates are not equal") {

                    it("returns false") {
                        expect(sep_30_1978 == now) == false
                    }
                }
            }

            describe("!=") {

                context("dates are equal") {

                    it("returns false") {
                        expect(sep_30_1978 != sep_30_1978_again) == false
                    }
                }

                context("dates are not equal") {

                    it("returns true") {
                        expect(sep_30_1978 != now) == true
                    }
                }
            }

            describe(">") {

                context("dates are equal") {
                    it("returns false") {
                        expect(sep_30_1978 > sep_30_1978_again) == false
                        expect(now > now) == false
                    }
                }

                context("first date is not more recent than the second date") {
                    it("returns false") {
                        expect(sep_30_1978 > now) == false
                    }
                }

                context("first date is more recent than the second date") {
                    it("returns true") {
                        expect(now > sep_30_1978) == true
                    }
                }
            }

            describe("<") {

                context("dates are equal") {
                    it("returns false") {
                        expect(sep_30_1978 < sep_30_1978_again) == false
                        expect(now < now) == false
                    }
                }

                context("first date is not more recent than the second date") {
                    it("returns true") {
                        expect(sep_30_1978 < now) == true
                    }
                }

                context("first date is more recent than the second date") {
                    it("returns false") {
                        expect(now < sep_30_1978) == false
                    }
                }
            }

            describe("<=") {

                context("dates are equal") {
                    it("returns true") {
                        expect(sep_30_1978 <= sep_30_1978_again) == true
                        expect(now <= now) == true
                    }
                }

                context("first date is not more recent than the second date") {
                    it("returns true") {
                        expect(sep_30_1978 <= now) == true
                    }
                }

                context("first date is more recent than the second date") {
                    it("returns false") {
                        expect(now <= sep_30_1978) == false
                    }
                }
            }

            describe(">=") {

                context("dates are equal") {
                    it("returns true") {
                        expect(sep_30_1978 >= sep_30_1978_again) == true
                        expect(now >= now) == true
                    }
                }

                context("first date is not more recent than the second date") {
                    it("returns false") {
                        expect(sep_30_1978 >= now) == false
                    }
                }

                context("first date is more recent than the second date") {
                    it("returns true") {
                        expect(now >= sep_30_1978) == true
                    }
                }
            }

        }
    }
}

