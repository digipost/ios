
var target = UIATarget.localTarget();


target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
UIATarget.localTarget().delay(2)
UIATarget.localTarget().pushTimeout(1);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();target.frontMostApp().keyboard().typeString("30086835378");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer12345");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
UIATarget.localTarget().pushTimeout(4);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
UIATarget.localTarget().delay(1)

/// start move to first letter in list
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
UIATarget.localTarget().pushTimeout(1);
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].visibleCells()[0].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].elements()[0].tap();

// End move to first letter in list
// start Move letter


target.frontMostApp().toolbar().buttons()["Move"].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Betalte fakturaer"].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().navigationBar().leftButton().tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Betalte fakturaer"].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().toolbar().buttons()["Move"].tap();
UIATarget.localTarget().delay(0.5)
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Mailbox"].tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();

// Log out part
target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().buttons()["Sign Out"].tap();
