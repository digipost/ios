
var target = UIATarget.localTarget();

//Logs out in case user did not log out before
if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar().leftButton().tap();
    target.delay(2);
}

target.delay(1);
if (target.frontMostApp().navigationBar().leftButton().checkIsValid() ) {
    target.frontMostApp().navigationBar().leftButton().tap();
    target.delay(2);
}

if (target.frontMostApp().navigationBar().leftButton().checkIsValid()) {
    target.frontMostApp().navigationBar().leftButton().tap();
    target.delay(1);
}

if (target.frontMostApp().navigationBar().buttons()["Logg ut"].checkIsValid()) {

target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().collectionViews()[0].cells()["Sign Out"].buttons()["Sign Out"].tap();
    target.delay(4);
}


UIATarget.localTarget().delay(2);
target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
UIATarget.localTarget().delay(6);
UIATarget.localTarget().pushTimeout(1);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("30086835378");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer12345");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
UIATarget.localTarget().pushTimeout(4);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
UIATarget.localTarget().delay(2);