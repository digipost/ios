
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
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.07, y:0.88}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().collectionViews()[0].cells()["Sign Out"].buttons()["Sign Out"].tap();
target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("13013500002");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer1234");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["Reiseforsikring gjensidige  Received Oct 2, 2014 From Uploaded"].tap();
target.frontMostApp().toolbar().buttons()["Move"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.46}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.37}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["Reiseforsikring gjensidige  Received Oct 2, 2014 From Uploaded"].tap();
target.frontMostApp().toolbar().buttons()["Move"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.46}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["Reiseforsikring gjensidige  Received Oct 2, 2014 From Uploaded"].tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Lønn july 2014  Received Sep 19, 2014 From Uploaded"].tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Bestilling strøm  Received Sep 1, 2014 From Hafslund"].tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().buttons()["Logg ut"].tap();
target.frontMostApp().actionSheet().collectionViews()[0].cells()["Sign Out"].buttons()["Sign Out"].tap();
target.frontMostApp().mainWindow().buttons()["Sign In"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("13013500002");
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("Qwer1234");
target.frontMostApp().windows()[1].toolbar().buttons()["Done"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].links()["Logg inn i Digipost"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["Reiseforsikring gjensidige  Received Oct 2, 2014 From Uploaded"].tap();
target.frontMostApp().toolbar().buttons()["Move"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.46}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.37}});
target.frontMostApp().mainWindow().tableViews()[0].cells()["Reiseforsikring gjensidige  Received Oct 2, 2014 From Uploaded"].tap();
target.frontMostApp().toolbar().buttons()["Move"].tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.46}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.04}});

target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()["test"].tapWithOptions({tapOffset:{x:0.97, y:0.52}});

target.delay(2);
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
