
var target = UIATarget.localTarget();

UIATarget.localTarget().delay(1);
target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
UIATarget.localTarget().delay(2);
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

// end login

target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[0].tap();
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["Add folder"].tap();
target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.40, y:0.32}});
target.frontMostApp().mainWindow().textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("test");
UIATarget.localTarget().pushTimeout(1);
target.frontMostApp().navigationBar().buttons()["Lagre"].tap();
UIATarget.localTarget().delay(5);
target.frontMostApp().mainWindow().tableViews()["Empty list"].tapWithOptions({tapOffset:{x:0.08, y:0.65}});
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()["test"].buttons()["Delete"].tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].tapWithOptions({tapOffset:{x:0.92, y:0.56}});
target.frontMostApp().mainWindow().tableViews()["Empty list"].dragInsideWithOptions({startOffset:{x:0.93, y:0.54}, endOffset:{x:0.94, y:0.34}, duration:1.5});
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().mainWindow().tableViews()["Empty list"].cells()[2].staticTexts()[0].scrollToVisible();

target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.12, y:0.65}});
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.80, y:0.09}});
target.frontMostApp().actionSheet().buttons()["Sign Out"].tap();
