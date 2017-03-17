//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Digipost

class InvoiceBankAgreementTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        InvoiceBankAgreement.clearBanks()
    }
    
    override func tearDown() {
        super.tearDown()
        InvoiceBankAgreement.clearBanks()
    }
    
    func jsonDictionaryFromFile(_ filename: String) -> Dictionary<String, AnyObject> {
        let testBundle = Bundle(for: OAuthTests.self)
        let path = testBundle.path(forResource: filename, ofType: nil)
        XCTAssertNotNil(path, "wrong filename")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        XCTAssertNotNil(data, "wrong filename")
        do{
            let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,AnyObject>
            return jsonDictionary
        }catch let error{
            XCTAssertNil(error, "could not read json")
            return Dictionary<String, AnyObject>()
        }
    }
    
    func mockInactiveAgreements(){
        let inactiveAgreements = jsonDictionaryFromFile("InactiveBankAgreements.json")
        InvoiceBankAgreement.storeBanks(banksStatus: inactiveAgreements)
    }
    
    func mockActiveType1Agreements() {
        let inactiveAgreements = jsonDictionaryFromFile("ActiveType1BankAgreements.json")
        InvoiceBankAgreement.storeBanks(banksStatus: inactiveAgreements)
    }
    
    func mockActiveType2Agreements() {
        
        let inactiveAgreements = jsonDictionaryFromFile("ActiveType2BankAgreements.json")
        InvoiceBankAgreement.storeBanks(banksStatus: inactiveAgreements)
    }
    
    func testInactiveAgreements() {
        mockInactiveAgreements()
        
        guard let banks = InvoiceBankAgreement.getBanks() else {
            XCTFail("Banks don't exist!")
            return
        }
    
        XCTAssert(banks.count > 0, "Banks array should not be empty")
        for bank in banks {
            XCTAssertFalse(bank.activeType1Agreement, "Should not be active")
            XCTAssertFalse(bank.activeType2Agreement, "Should not be active")
        }
    }
    
    func testActiveType1Agreements() {
        mockActiveType1Agreements()
        
        guard let banks = InvoiceBankAgreement.getBanks() else {
            XCTFail("Banks don't exist!")
            return
        }
        
        var activeType1Agreement = false
        for bank in banks {
            XCTAssertFalse(bank.activeType2Agreement, "Should not be active")
            if bank.activeType1Agreement {
                activeType1Agreement = true
            }
            
        }
        
        XCTAssert(activeType1Agreement, "Should exist active type 1 agreement")
    }
    
    func testActiveType2Agreements() {
        mockActiveType2Agreements()
        
        guard let banks = InvoiceBankAgreement.getBanks() else {
            XCTFail("Banks don't exist!")
            return
        }
        
        var activeType2Agreement = false
        for bank in banks {
            XCTAssertFalse(bank.activeType1Agreement, "Should not be active")
            if bank.activeType2Agreement {
                activeType2Agreement = true
            }
        }
        
        XCTAssert(activeType2Agreement, "Should exist active type 2 agreement")
    }
    
    func testActiveType1AndType2Agreements() {
        let inactiveAgreements = jsonDictionaryFromFile("ActiveType1AndType2Agreements.json")
        InvoiceBankAgreement.storeBanks(banksStatus: inactiveAgreements)
        
        guard let banks = InvoiceBankAgreement.getBanks() else {
            XCTFail("Banks don't exist!")
            return
        }
        
        var activeType1Agreement = false
        var activeType2Agreement = false

        for bank in banks {
            if bank.activeType1Agreement {
                activeType1Agreement = true
            }
            if bank.activeType2Agreement {
                activeType2Agreement = true
            }
        }
        
        XCTAssert(activeType1Agreement, "Should exist active type 1 agreement")
        XCTAssert(activeType2Agreement, "Should exist active type 2 agreement")
        
    }
}
