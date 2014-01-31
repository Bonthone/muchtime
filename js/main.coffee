COLORS =
  purple: "#b20038"
  pink: "#fe2468"
  lightTeal: "#00a4a5"
  darkTeal: "#005b63"
  cream: "#fefee2"
  beige: "#dfd3b0"

$ ->
  setupIpad()
  setupMBP()
  $("body").on "click", "button:not(.selected)", ->
    setupIpad($(this).data("timeframe"))
    $(this).addClass("selected").siblings().removeClass("selected")

  $(".window").dragAndDrop
    handle: "h1"
    initialX: 120
    initialY: 40
    xMin: 0
    yMin: 0
    xMax: 1440
    yMax: 900

  $(".corner.tl").dragAndDrop()

  $(".handle").click ->
    $("#mbp-track").animate
      right: if $("#mbp-track").css("right") is "-301px" then "-1px" else "-301px"


setupIpad = (timeframe = 30) ->
  stage = new Kinetic.Stage
    container: "ipad-graph"
    width: 608 
    height: 392 
  layer = new Kinetic.Layer()

  xs = steppedRange(608, timeframe)
  ys = _.map(Array(timeframe+1), -> boundedRandom(100, 200))
  graph = new Kinetic.Line
    points: _.flatten(_.zip(xs, ys))
    stroke: "#00a4a5"
    strokeWidth: 5

  clientRatePerDay = 3.623
  clientsPerTimeframe = Math.floor(clientRatePerDay * timeframe)
  text = new Kinetic.Text
    x: 40
    y: 250
    text: "#{clientsPerTimeframe}\nclients"
    fill: COLORS.darkTeal
    fontSize: 40
    fontFamily: "Helvetica Neue"
    align: "center"

  kmRatePerDay = 13.818
  kmPerTimeframe = Math.floor(kmRatePerDay * timeframe)
  text2 = text.clone
    text: "#{kmPerTimeframe}\nkm"
    fill: COLORS.pink
    x: 250

  minutesPerDay = 436.235
  minutesPerTimeframe = timeframe * minutesPerDay
  hoursPerTimeframe = Math.floor(minutesPerTimeframe / 60)
  minutesPerTimeframe = Math.floor(minutesPerTimeframe % 60)

  text3 = text.clone
    text: "#{hoursPerTimeframe}:#{if minutesPerTimeframe <= 9 then 0 else "" }#{minutesPerTimeframe}\nhours"
    x: 410
    fill: COLORS.lightTeal

  layer.add(graph)
  layer.add(text)
  layer.add(text2)
  layer.add(text3)
  stage.add(layer)

setupMBP = ->
  STAGE_WIDTH = 1200 
  STAGE_HEIGHT = 500

  stage = new Kinetic.Stage
    container: "mbp-graph"
    width: STAGE_WIDTH
    height: STAGE_HEIGHT 
  layer = new Kinetic.Layer()
  
  steps = 30
  xs = steppedRange(STAGE_WIDTH, steps)
  ys = _.map(Array(steps+1), -> boundedRandom(100, 200))
  graph = new Kinetic.Line
    points: _.flatten(_.zip(xs, ys))
    stroke: "#00a4a5"
    strokeWidth: 5

  layer.add(graph)
  stage.add(layer)


steppedRange = (range, steps) ->
  range/steps * step for step in [0..steps]
  
boundedRandom = (min, max) ->
  Math.floor(Math.random() * (max - min) + min)

formatTime = (timeInSeconds, showSeconds = false) ->
  withLeadingZero = (number) ->
    "#{if number <= 9 then 0 else ''}#{number}"

  hours = withLeadingZero timeInSeconds / 3600
  minutes = withLeadingZero (timeInSeconds % 3600) / 60
  seconds = withLeadingZero timeInSeconds % (3600 * 60)

  "#{hours}:#{minutes}:#{seconds}"

$.fn.dragAndDrop = (options = {}) ->
  $el = $(this)
  $handle = if options.handle then $(options.handle)
  dragStart = ($handle or $el).asEventStream("mousedown")
  dragEnd = $("html").asEventStream("mouseup")

  coords = (a) -> { x: a.clientX, y: a.clientY }
  add = (a, b) -> { x: a.x + b.x, y: a.y + b.y }

  getDelta = (t) ->
    [a, b] = [t[1], t[0]]
    { x: a.x - b.x, y: a.y - b.y }

  draggingDeltas = dragStart.flatMap ->
    $("html").asEventStream("mousemove")
      .map(coords)
      .slidingWindow(2, 2)
      .map(getDelta)
      .takeUntil(dragEnd)

  position = draggingDeltas.scan({ x: options.initialX or 0, y: options.initialY or 0 }, add)

  position.onValue (pos) ->
    xMin = if options.xMin? then options.xMin else -$el.offset().left
    yMin = if options.yMin? then options.yMin else -$el.offset().top
    xMax = if options.xMax? then options.xMax - $el.width() else window.innerWidth - $el.offset().left
    yMax = if options.yMax? then options.yMax - $el.height() else window.innerHeight - $el.offset().top
    $el.css
      left: Math.min(Math.max(xMin, pos.x), xMax)
      top: Math.min(Math.max(xMin, pos.y), yMax)
