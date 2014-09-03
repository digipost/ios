
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
UIATarget.localTarget().delay(2)
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();target.frontMostApp().keyboard().typeString("30086835378");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer12345");
UIATarget.localTarget().delay(1)
UIATarget.localTarget().pushTimeout(4);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();


// Log out part


target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().buttons()["Sign Out"].tap();
