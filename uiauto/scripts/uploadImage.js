
var target = UIATarget.localTarget();
target.pushTimeout(10);

target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.delay(1);
target.frontMostApp().actionSheet().collectionViews()[0].visibleCells()[1].tap();
// Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.
target.delay(1);
target.frontMostApp().mainWindow().collectionViews()[0].cells()[0].tap();
target.delay(1);
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.popTimeout();