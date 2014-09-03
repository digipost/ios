
var target = UIATarget.localTarget();


target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
UIATarget.localTarget().delay(2);
UIATarget.localTarget().pushTimeout(1);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();target.frontMostApp().keyboard().typeString("30086835378");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer12345");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
UIATarget.localTarget().pushTimeout(4);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
UIATarget.localTarget().delay(2)

/// start move to first letter in list
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
UIATarget.localTarget().pushTimeout(1);
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].visibleCells()[0].tap();

// End move to first letter in list
// Start Edit multiple
target.frontMostApp().navigationBar().rightButton().tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
// end deselect
// start delete topmost cell
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
target.frontMostApp().toolbar().buttons()["Delete"].tap();
UIATarget.localTarget().delay(1)
target.frontMostApp().actionSheet().buttons()["Delete 1 letter"].tap();

// end delete topmost cell
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().buttons()["Sign Out"].tap();


// End Edit multiple
