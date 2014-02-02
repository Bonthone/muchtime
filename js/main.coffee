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


  $(".corner.tl").each (i, e) ->
    corner = $(e)
    corner.clone()
    .appendTo(corner.parent())
    .css
      height: '1000px'
      width: '1000px'
      'margin-left': '-770px'
      'margin-top': '-770px'
      'z-index': 1
    .dragAndDrop()
    corner.css
      'pointer-events': 'none'

  $(".handle").click ->
    $("#mbp-track").animate
      right: if $("#mbp-track").css("right") is "-301px" then "-1px" else "-301px"

  timer.resetTo(31337)

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
    stroke: COLORS.lightTeal
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
  STAGE_WIDTH = 1100 
  STAGE_HEIGHT = 300

  stage = new Kinetic.Stage
    container: "mbp-graph"
    width: STAGE_WIDTH
    height: STAGE_HEIGHT

  layer = new Kinetic.Layer()
  
  steps = 100
  xs = steppedRange(STAGE_WIDTH, steps)
  ys = _.map(Array(steps+1), -> boundedRandom(100, 200))
  graph = new Kinetic.Line
    points: _.flatten(_.zip(xs, ys))
    stroke: "#00a4a5"
    strokeWidth: 5


  selection = new Kinetic.Rect
    x: 400
    y: 50
    width: 100
    height: 200
    stroke: "black"
    dash: [5, 5]
    draggable: true
    fill: "rgba(0, 0, 0, 0.2)"
    dragBoundFunc: (pos) ->
      x: pos.x
      y: @getAbsolutePosition().y

  layer.add(graph)
  layer.add(selection)
  stage.add(layer)

  stage2 = new Kinetic.Stage
    container: "mbp-stats"
    width: 650
    height: 145 
  layer2 = new Kinetic.Layer()

  wedge = new Kinetic.Wedge
    x: stage2.width() - 75
    y: stage2.height() / 2
    radius: 70
    angle: 60
    fill: "#00a4a5"
    rotation: -120

  wedge2 = wedge.clone
    rotation: -60
    angle: 129
    fill: COLORS.pink

  wedge3 = wedge.clone
    rotation: 69
    angle: 103 
    fill: COLORS.purple

  wedge4 = wedge.clone
    rotation: 172
    angle: 68
    fill: COLORS.darkTeal

  text = new Kinetic.Text
    x: 0
    y: 15
    text: "306\nhours"
    fill: COLORS.lightTeal
    fontSize: 40
    fontFamily: "Helvetica Neue"
    align: "center"

  text2 = text.clone
    x: 150
    text: "147\nkm"
    fill: COLORS.pink

  text3 = text.clone
    x: 270
    text: "240\nclients"
    fill: COLORS.darkTeal

  layer2.add(wedge)
  layer2.add(wedge2)
  layer2.add(wedge3)
  layer2.add(wedge4)
  layer2.add(text)
  layer2.add(text2)
  layer2.add(text3)
  stage2.add(layer2)


  $("#mbp-list > div").each ->
    length = $(this).data("length")
    $(this).css
      height: length/120 + "px"
    $(this).find(".elapsed").text(formatTime(length))

steppedRange = (range, steps) ->
  range/steps * step for step in [0..steps]
  
boundedRandom = (min, max) ->
  Math.floor(Math.random() * (max - min) + min)

formatTime = (timeInSeconds, showSeconds = false) ->
  withLeadingZero = (number) ->
    "#{if number <= 9 then 0 else ''}#{number}"

  hours = withLeadingZero Math.floor timeInSeconds / 3600
  minutes = withLeadingZero Math.floor (timeInSeconds % 3600) / 60
  seconds = withLeadingZero timeInSeconds % (60)

  "#{hours}:#{minutes}:#{seconds}"

timer =
  currentTime: Bacon.never()
  reset: -> this.resetTo(0)
  resetTo: (initial) ->
    plus = (a,b) -> a + b
    this.currentTime = Bacon.interval(1000, 1).scan(initial, plus)

    this.currentTime.onValue (sec) ->
      console.log sec
      $(".timer").text(formatTime(sec, true))

$.fn.dragAndDrop = (options = {}) ->
  $el = $(this)
  $handle = if options.handle then $(options.handle)
  dragStart = ($handle or $el).asEventStream("mousedown")
  dragEnd = $(window).asEventStream("mouseup")

  coords = (a) -> { x: a.clientX, y: a.clientY }
  add = (a, b) -> { x: a.x + b.x, y: a.y + b.y }

  getDelta = (t) ->
    [a, b] = [t[1], t[0]]
    { x: a.x - b.x, y: a.y - b.y }

  draggingDeltas = dragStart.flatMapLatest ->
    $("html").asEventStream("mousemove")
      .map(coords)
      .slidingWindow(2, 2)
      .map(getDelta)
      .takeUntil(dragEnd)

  position = draggingDeltas.scan({ x: options.initialX or 0, y: options.initialY or 0 }, add)

  position.onValue (pos) ->
    if options.xMin?
      xMax = options.xMax - $el.width()
      yMax = options.yMax - $el.height()
      $el.css
        left: Math.min(Math.max(options.xMin, pos.x), xMax)
        top: Math.min(Math.max(options.yMin, pos.y), yMax)
    else
      $el.css
        left: pos.x
        top: pos.y
