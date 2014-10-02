
var target = UIATarget.localTarget();

UIALogger.logDebug("start Movedocument.js");
/// start move to first letter in list
target.pushTimeout(30);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1);
var firstFolder = target.frontMostApp().mainWindow().tableViews()[0].cells()[0].name();
target.frontMostApp().mainWindow().tableViews()[0].cells()[firstFolder].tap();
target.delay(1);
var documentName = target.frontMostApp().mainWindow().tableViews()[0].cells()[0].name();
target.frontMostApp().mainWindow().tableViews()[0].cells()[documentName].tap();
target.popTimeout();

// End move to first letter in list
// start Move letter

target.delay(4);
if (target.frontMostApp().toolbar().buttons()[0].checkIsValid()) {
    target.frontMostApp().toolbar().buttons()[0].tap();
} else {
    if (target.frontMostApp().toolbar().buttons()["Move"].checkIsValid()){
        target.frontMostApp().toolbar().buttons()["Move"].tap();
    }
}
UIATarget.localTarget().delay(2);
var name = target.frontMostApp().mainWindow().tableViews()[0].cells()[0].name();
target.frontMostApp().mainWindow().tableViews()[0].cells()[name].tap();


UIATarget.localTarget().delay(1);
target.pushTimeout(3);
target.frontMostApp().navigationBar().leftButton().tap();
UIATarget.localTarget().delay(1);

target.frontMostApp().mainWindow().tableViews()[0].cells()[name].tap();
UIATarget.localTarget().delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[documentName].tap();
target.frontMostApp().toolbar().buttons()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[firstFolder].tap();
target.popTimeout();



target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();

