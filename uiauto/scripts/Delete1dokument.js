
var target = UIATarget.localTarget();
UIALogger.logDebug("start Delete1dokument.js");
/// start move to first letter in list
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.28, y:0.06}});
UIATarget.localTarget().delay(1);
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.28, y:0.06}});


// End move to first letter in list
// Start Edit multiple
UIATarget.localTarget().delay(1);
target.frontMostApp().navigationBar().rightButton().tap();
UIATarget.localTarget().delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
// end deselect
// start delete topmost cell
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().toolbar().buttons()[2].tap();
UIATarget.localTarget().delay(2);
target.frontMostApp().actionSheet().collectionViews()[0].cells()[0].buttons()[0].tap();

UIATarget.localTarget().delay(1);
// end delete topmost cell
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();

