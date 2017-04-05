
config = require '../src/Config'

filename = "ViewShowTableEditor.coffee"
list = [ "./Web/views/", "../Web/views", "../../Web/views", "../CoffeeNinjaCommon/ninja/views",
"../../CoffeeNinjaCommon/ninja/views", "../../../CoffeeNinjaCommon/ninja/views", "./Web/Admin/views/",
"../Web/Admin/views/", "../../Web/Admin/views/", "/Users/bpollack/Projects/Edge/EdgeServerAdmin/node_modules/NinjaCommon/ninja/views",
"/Users/bpollack/Projects/Edge/node_modules/NinjaCommon/ninja/views",
"/Users/bpollack/Projects/node_modules/NinjaCommon/ninja/views",
"/Users/bpollack/node_modules/NinjaCommon/ninja/views","/Users/node_modules/NinjaCommon/ninja/views",
"/node_modules/NinjaCommon/ninja/views" ]

result = config.FindFileInPath filename, list, false
console.log "Result without path:", result

result = config.FindFileInPath filename, list, true
console.log "Result with path:", result

