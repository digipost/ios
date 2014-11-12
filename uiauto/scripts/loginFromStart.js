
var target = UIATarget.localTarget();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logWarning("Alert with title '" + title + "' encountered!");
    UIATarget.localTarget().captureScreenWithName("alert_" + (new Date()).UTC());
    return false;
}

UIALogger.logDebug("start loginFromStart.js");
//Logs out in case user did not log out before
target.pushTimeout(5);
if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar().leftButton().tap();
}
if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar().leftButton().tap();
}

if (target.frontMostApp().navigationBar().leftButton().checkIsValid()) {
    target.frontMostApp().navigationBar().leftButton().tap();
}
target.popTimeout();
target.pushTimeout(4);
if (target.frontMostApp().navigationBar().buttons()["Logg ut"].checkIsValid()) {
target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().collectionViews()[0].cells()["Sign Out"].buttons()["Sign Out"].tap();
}

target.popTimeout();

target.pushTimeout(10);
target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
target.popTimeout();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("13013500002");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer1234");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
UIATarget.localTarget().pushTimeout(4);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.popTimeout();
UIATarget.localTarget().delay(2);