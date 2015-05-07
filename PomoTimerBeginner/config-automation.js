#import "capture.js"

var target = UIATarget.localTarget();
captureLocalizedScreenshot("startup")

var app = target.frontMostApp();
var window = app.mainWindow();


window.buttons()["ui_start_button"].tap()
target.delay(10)
captureLocalizedScreenshot("task_view")
window.buttons()["ui_start_button"].tap()

window.buttons()["ui_history_button"].tap()
target.delay(2)
captureLocalizedScreenshot("history_view")