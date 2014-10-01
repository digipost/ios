
var target = UIATarget.localTarget();

target.delay(1);
UIATarget.localTarget().pushTimeout(2);
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT);
target.pushTimeout(10);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.12, y:0.35}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.13, y:0.45}});

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.04, y:0.97}});

// shoul be back to start of navigation
target.pushTimeout(2);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();
target.delay(1);
target.pushTimeout(2);
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.popTimeout();
target.pushTimeout(5);
target.delay(3);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();
target.delay(1);
target.pushTimeout(5);
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.popTimeout();

target.pushTimeout(5);
target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].tapWithOptions({tapOffset:{x:0.13,y:0.23}});
target.popTimeout();

target.delay(1);          
target.frontMostApp().mainWindow().scrollViews()[0].tapWithOptions({tapOffset:{x:0.40, y:0.37}});
target.delay(1);

target.pushTimeout(5);
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().leftButton().tap();
target.popTimeout();

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
