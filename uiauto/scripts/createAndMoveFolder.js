
var target = UIATarget.localTarget();
UIALogger.logDebug("start createAndMoveFolder.js");
// end login
target.delay(1);

// tap user account
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.35, y:0.06}});

// tap edit
target.frontMostApp().navigationBar().rightButton().tap();

target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()["Add folder"].tap();
target.frontMostApp().mainWindow().collectionViews()[0].cells()[1].images()["Letter"].tapWithOptions({tapOffset:{x:0.49, y:0.36}});
target.frontMostApp().mainWindow().textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("test\n");
target.frontMostApp().navigationBar().buttons()["Lagre"].tap();
target.delay(5);
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.07, y:0.88}});

target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()["test"].tapWithOptions({tapOffset:{x:0.97, y:0.52}});

target.delay(2);
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
