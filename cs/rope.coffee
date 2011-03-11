class Point
    constructor: (@x, @y) ->
        @vx = @vy = @nx = @ny = 0


class Rope
    constructor: (@context) ->
        @standing_length = 10
        @gravity = 8
        @damping = 0.93

        @points = [
            new Point 250, 10
            new Point 250, 30
            new Point 250, 50
            new Point 250, 70
            new Point 250, 90
            new Point 250, 110
            new Point 250, 130
        ]

        for pt in @points
            pt.nx = pt.x
            pt.ny = pt.y

    pick_point: (x, y) ->
        sp = -1
        cd = 5000
        for pt, i in @points
            dx = Math.abs x - pt.x
            dy = Math.abs y - pt.y

            if dx+dy < 10 and dx+dy < cd
                sp = i
                cd = dx+dy
        sp

    update: ->
        for i in [1..@points.length - 1]
            xv1 = @points[i-1].x - @points[i].x
            yv1 = @points[i-1].y - @points[i].y
            m1 = Math.sqrt((xv1*xv1) + (yv1*yv1))
            e1 = m1 - @standing_length

            try
                xv2 = @points[i+1].x - @points[i].x
                yv2 = @points[i+1].y - @points[i].y
                m2 = Math.sqrt((xv2*xv2) + (yv2*yv2))
                e2 = m2 - @standing_length

                xv = (xv1 / m1 * e1) + (xv2 / m2 * e2)
                yv = (yv1 / m1 * e1) + (yv2 / m2 * e2) + @gravity
            catch error # Last point doesn't have a second connection
                xv = (xv1 / m1 * e1)
                yv = (yv1 / m1 * e1) + @gravity


            @points[i].vx = @points[i].vx * @damping + (xv * 0.03)
            @points[i].vy = @points[i].vy * @damping + (yv * 0.03)
            @points[i].nx = @points[i].x + @points[i].vx
            @points[i].ny = @points[i].y + @points[i].vy

        for pt in @points
            pt.x = pt.nx
            pt.y = pt.ny

    draw: ->
        @context.strokeStyle = '#000'
        @context.fillStyle = '#fff'
        @context.beginPath()
        @context.moveTo @points[0].x, @points[0].y
        @context.lineTo pt.x, pt.y for pt in @points
        @context.stroke()

        for pt in @points
            @context.beginPath()
            @context.arc pt.x, pt.y, 5, 0, Math.PI * 2, true
            @context.closePath()
            @context.fill()
            @context.stroke()


clear_screen = ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    can.width = can.width
    ctx.clearRect 0, 0, can.width, can.height


$ ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    selected_point = -1

    r = new Rope context

    $('#reset_button').click ->
        r = new Rope context

    $('#cv').mousedown (event) ->
        cx = event.pageX - $(this).offset().left
        cy = event.pageY - $(this).offset().top

        selected_point = r.pick_point cx, cy

    $('#cv').mousemove (event) ->
        if selected_point < 0
            return

        px = event.pageX - $(this).offset().left
        py = event.pageY - $(this).offset().top

        r.points[selected_point].x = px
        r.points[selected_point].y = py
        r.points[selected_point].vx = r.points[selected_point].vy = 0

    $('#cv').mouseup ->
        selected_point = -1

    $.timer 50, ->
        clear_screen()
        r.update()
        r.draw()

