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
}