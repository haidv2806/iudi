//
//  IUDITests.swift
//  IUDITests
//
//  Created by LinhMAC on 22/02/2024.
//

import XCTest
@testable import IUDI

final class IUDITests: XCTestCase {

    func userNameTest(){
        let userName = ""
        let usernameValid = isValidInput(Input: userName)
        XCTAssertTrue(usernameValid)
    }
    func isValidInput(Input:String) -> Bool {
        return Input.range(of: "\\A\\w{7,18}\\z", options: .regularExpression) != nil
    }
}
