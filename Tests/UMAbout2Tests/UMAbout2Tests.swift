//
// UMAbout2Tests.swift
// UMAbout2Tests
//
// Created by Alex Raccuglia on 8 Sep 2026.
//

import XCTest
@testable import UMAbout2

final class UMAbout2Tests : XCTestCase {
	func testExample () throws {
		let instance = UMAbout2 ()
		XCTAssertEqual ( instance.greeting (), "Hello from UMAbout2!" )
	}

	func testFormatVersionTag () {
		XCTAssertEqual (Ab2AboutViewModel.formatVersionTag (version: "1.2.3", build: "45"), "v1.2.3 (45)")
		XCTAssertEqual (Ab2AboutViewModel.formatVersionTag (version: "v2.0", build: "100"), "v2.0 (100)")
		XCTAssertEqual (Ab2AboutViewModel.formatVersionTag (version: "1.0.0", build: nil), "v1.0.0")
		XCTAssertEqual (Ab2AboutViewModel.formatVersionTag (version: nil, build: "42"), "build 42")
		XCTAssertNil (Ab2AboutViewModel.formatVersionTag (version: nil, build: nil))
		XCTAssertNil (Ab2AboutViewModel.formatVersionTag (version: "  ", build: ""))
	}
}