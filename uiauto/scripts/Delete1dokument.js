
var target = UIATarget.localTarget();
UIALogger.logDebug("start Delete1dokument.js");
/// start move to first letter in list
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
UIATarget.localTarget().delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();


// End move to first letter in list
// Start Edit multiple
target.pushTimeout(3);
target.frontMostApp().navigationBar().rightButton().tap();
target.popTimeout();
UIATarget.localTarget().delay(1);
target.pushTimeout(3);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();
// end deselect
// start delete topmost cell
target.pushTimeout(2);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();

target.pushTimeout(2);
target.frontMostApp().toolbar().buttons()[2].tap();
target.popTimeout();
UIATarget.localTarget().delay(2);
target.frontMostApp().actionSheet().collectionViews()[0].cells()[0].buttons()[0].tap();

UIATarget.localTarget().delay(1);
// end delete topmost cell
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();

