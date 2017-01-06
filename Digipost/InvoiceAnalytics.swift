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


@objc class InvoiceAnalytics : NSObject{

    static let fakturaOppsettKontekstBasert = "faktura-avtale-oppsett-kontekst-basert"
    
    static func submitEvent(category: String,action: String,label: String){
        let tracker = GAI.sharedInstance().defaultTracker
        let parameters = GAIDictionaryBuilder.createEventWithCategory(category, action:action, label: label, value:nil).build()
        tracker.send(parameters as [NSObject: AnyObject])
    }
    
    static func sendInvoiceCLickedChooseBankDialog(buttonText: String ){
        submitEvent(self.fakturaOppsettKontekstBasert, action: "klikk-start-oppsett", label: buttonText);
    }
    
    static func sendInvoiceOpenBankViewFromListEvent(bankName: String){
        submitEvent(self.fakturaOppsettKontekstBasert, action: "klikk-bank-i-liste", label: bankName);
    }
    
    static func sendInvoiceClickedDigipostOpenPagesLink(bankName: String){
        submitEvent(self.fakturaOppsettKontekstBasert, action: "klikk-digipost-faktura-åpne-sider", label: bankName);
    }
    
    static func sendInvoiceClickedSetup10Link(bankName: String){
        submitEvent(self.fakturaOppsettKontekstBasert, action: "klikk-oppsett-avtale-type-1-link", label: bankName);
    }
    
    static func sendInvoiceClickedSetup20Link(bankName: String){
        submitEvent(self.fakturaOppsettKontekstBasert, action: "klikk-oppsett-avtale-type-2-link", label: bankName);
    }
}
