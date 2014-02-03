COLORS =
  purple: "#b20038"
  pink: "#fe2468"
  lightTeal: "#00a4a5"
  darkTeal: "#005b63"
  cream: "#fefee2"
  beige: "#dfd3b0"


class ActivitiesListModel
  mapActivities: (f) ->
    (activities) -> _.map(activities, f)

  modifyActivity: (updatedActivity) ->
    mapActivities (activity) ->
      if activity.id == updatedActivity.id then updatedActivity else activity

  addActivity: (newActivity) ->
    (activities) -> activities.concat [newActivity]

  constructor: ->
    @activityAdded = new Bacon.Bus()
    @activityModified = new Bacon.Bus()

    modifications =
      @activityAdded.map(@addActivity)
      .merge(@activityModified.map(@modifyActivity))

    @activityProperty = modifications.scan(
      [],
      (activities, modification) -> modification(activities)
    )

class Timer
  constructor: ->
    @currentTime = new Bacon.Bus()
    @unplugPrevious = ->
  reset: -> @resetTo(0)
  resetTo: (initial) ->
    plus = (a,b) -> a + b
    @unplugPrevious()
    @unplugPrevious = @currentTime.plug(
      Bacon.interval(1000, 1).scan(initial, plus)
    )

User =
  activitiesList: new ActivitiesListModel
  timer: new Timer

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

  User.timer.currentTime.onValue (sec) ->
    $(".timer").text(formatTime(sec, true))

  $(".corner.tl").each (i, e) ->
    corner = $(e)
    $corner = corner.clone()

    $corner
      .appendTo(corner.parent())
      .css
        height: '1000px'
        width: '1000px'
        'margin-left': '-770px'
        'margin-top': '-770px'
        'z-index': 1

    corner.css
      'pointer-events': 'none'

    movement = new Bacon.Bus()
    movement.plug($corner.draggingDeltas())

    completedDrags = $corner.dragStart().flatMapLatest (a) ->
      dragEnd.map (b) ->
        [coords(a),coords(b)]

    completedDrags.onValues (start, finish) ->
      delta = getDelta([start, finish])
      threshold = 70
      if delta.x > 0 and delta.y > 0 and (delta.x > threshold or delta.y > threshold)
        movement.push getDelta([$corner.currentPosition(), {x: 300, y: 300}])
        User.timer.reset()
      else
        movement.push getDelta([$corner.currentPosition(), {x: 0, y: 0}])

    position = movement.scan({ x: 0, y: 0 }, add)
    position.onValue (pos) ->
      $corner.css
        left: pos.x
        top: pos.y


  $(".handle").click ->
    $("#mbp-track").animate
      right: if $("#mbp-track").css("right") is "-301px" then "-1px" else "-301px"

  User.timer.resetTo(31337)

  activityTemplate = Handlebars.compile($("#activity-template").html());

  User.activitiesList.activityProperty.onValue (activities) ->
    $list = $("#mbp-list").empty()
    activities.map (activity) ->
      $el = $(activityTemplate(activity))
      $el.css
        height: activity.length / 120 + "px"
      $el
    .map (el) -> $list.prepend(el)


  initial = [
    type: 'leisure'
    length: 1548
    elapsed: formatTime(1548)
  ,
    type: 'clinic'
    length: 7200
    elapsed: formatTime(7200)
  ,
    type: 'housecall'
    length: 1800
    elapsed: formatTime(1800)
  ,
    type: 'office'
    length: 300
    elapsed: formatTime(300)
  ]

  _.each(initial, (activity) -> User.activitiesList.activityAdded.push(activity))

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

coords = (a) -> { x: a.clientX, y: a.clientY }
add = (a, b) -> { x: a.x + b.x, y: a.y + b.y }

getDelta = (t) ->
  [a, b] = [t[1], t[0]]
  { x: a.x - b.x, y: a.y - b.y }

dragEnd = $(window).asEventStream("mouseup")

$.fn.currentPosition = ->
  x: _.parseInt($(this).css('left'))
  y: _.parseInt($(this).css('top'))

$.fn.dragStart = (options = {}) ->
  $handle = if options.handle then $(options.handle)
  ($handle or $(this)).asEventStream("mousedown")

$.fn.draggingDeltas = (options = {}) ->
  $(this).dragStart(options).flatMapLatest ->
    $("html").asEventStream("mousemove")
      .map(coords)
      .slidingWindow(2, 2)
      .map(getDelta)
      .takeUntil(dragEnd)


$.fn.dragAndDrop = (options = {}) ->
  $el = $(this)
  draggingDeltas = $el.draggingDeltas(options)

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
