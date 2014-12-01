
var target = UIATarget.localTarget();

if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar()￼￼
}
if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar().leftButton().tap();
}

if (target.frontMostApp().navigationBar().leftButton().checkIsValid()) {
    target.frontMostApp().navigationBar().leftButton().tap();
}


UIALogger.logDebug("start bankid.js");
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.24, y:0.06}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["ikke flytt"].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Konfidensielt brev  Received Nov 18, 2014 From "].tap();
target.frontMostApp().mainWindow().buttons()["Lås opp"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn med ID-porten ID-porten er en felles innloggingsløsning til offentlige tjenester."].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["BankID BankID Med kodebrikke fra banken din"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()["Fødselsnummer"].tap();
target.frontMostApp().keyboard().typeString("01043100358");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].buttons()["Neste"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()["Engangskode"].tap();
target.frontMostApp().keyboard().typeString("otp");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].buttons()["Neste"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()["Personlig passord"].tap();
target.frontMostApp().keyboard().typeString("qwer1234");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].buttons()["Neste"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].buttons()["Neste"].tap();
UIATarget.localTarget().delay(5);
if (target.frontMostApp().mainWindow().buttons()["Lås opp"].checkIsValid()) {
    UIALogger.logFail("Could not login with bankid");
}

