sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.hotload(true)
sbar.end_config()

sbar.event_loop()
