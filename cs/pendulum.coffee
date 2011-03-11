class Vector
    constructor: (@x, @y) ->

    add: (vec) ->
        @x += vec.x
        @y += vec.y

        this

    cross: (vec) ->
        (@x*vec.y) - (@y - vec.x)

    divideBy: (scalar) ->
        @x /= scalar
        @y /= scalar

        this


class Pendulum
    constructor: (canvas) ->
        @anchor = new Vector(canvas.width / 2, 5)

        @length = 200
        @damping = 0.995
        @angular_velocity = 0

        @active = true

        @theta = Math.PI - (Math.PI / 4)

        @context = canvas.getContext '2d'

    draw: ->
        @weight = new Vector(@length*Math.cos(@theta), @length*Math.sin(@theta))
        @weight.add(@anchor)

        @context.save()
        @context.translate @anchor.x, @anchor.y
        @context.rotate -(Math.PI / 2)
        @context.translate -@anchor.x, -@anchor.y

        @drawLine @anchor, @weight
        @drawCircle @anchor, 3
        @drawCircle @weight, 20

        @context.restore()

    update: ->
        if not @active
            return

        @theta += @angular_velocity
        @angular_velocity += (Math.sin(@theta) / @length)
        @angular_velocity *= @damping


    drawCircle: (circ, radius) ->
        @context.strokeStyle = '#000'
        @context.fillStyle = '#fff'
        @context.beginPath()
        @context.arc circ.x, circ.y, radius, 0, Math.PI * 2, true
        @context.closePath()
        @context.fill()
        @context.stroke()

    drawLine: (p1, p2) ->
        @context.strokeStyle = '#000'
        @context.beginPath()
        @context.moveTo p1.x, p1.y
        @context.lineTo p2.x, p2.y
        @context.closePath()
        @context.stroke()


clear_screen = ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    can.width = can.width
    ctx.clearRect 0, 0, can.width, can.height


reposition_weight = (x, y, p) ->
    x -= p.anchor.x
    y -= p.anchor.y

    p.length = Math.sqrt((x*x) + (y*y))

    p.theta = Math.atan(-x / y) - (Math.PI)


$ ->
    clear_screen()

    can = $('#cv')[0]
    ctx = can.getContext '2d'

    p = new Pendulum can

    mouse_dragging = false

    $('#cv').mousedown (event) ->
        p.active = false

        mouse_dragging = true

        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        reposition_weight mouseX, mouseY, p

    $('#cv').mousemove (event) ->
        if not mouse_dragging
            return

        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        reposition_weight mouseX, mouseY, p

    $('#cv').mouseup (event) ->
        mouse_dragging = false
        p.angular_velocity = 0
        p.active = true

    $.timer 50, ->
        clear_screen()
        p.draw()
        p.update()

