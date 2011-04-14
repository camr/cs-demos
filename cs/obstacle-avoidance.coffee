class Bot
    constructor: (@canvas) ->
        @dx = @x = @dy = @y = 0
        @radius = 15
        @speed = 5

        @red = @green = 0

        @x = Math.floor(Math.random() * @canvas.width)
        @y = Math.floor(Math.random() * @canvas.height)
        @set_destination @x, @y

    place: (@course) ->
        good = false
        while not good
            @x = Math.floor(Math.random() * @canvas.width)
            @y = Math.floor(Math.random() * @canvas.height)
            good = true

            for ob in @course.obstacles
                if circle_collision ob, [@x, @y, @radius]
                    good = false
                    break

    set_destination: (@dx, @dy) ->
        if not @course?
            return

    update: ->
        if circle_collision [@x, @y, 3], [@dx, @dy, 3]
            return

        rads = Math.atan2 @dx - @x, @dy - @y
        @direction = ((rads * 180.0) / Math.PI) + 90

        @x += @speed * Math.sin rads
        @y += @speed * Math.cos rads

        xf = 0
        yf = 0
        for ob in @course.obstacles
            local_force = (ob[2] * 200) / Math.pow(Math.sqrt(distance2(ob, [@x, @y])), 2)
            angle = Math.PI / 2 - Math.atan2(@y - ob[1], @x - ob[0])
            xf += local_force * Math.sin angle
            yf += local_force * Math.cos angle

        @x += xf
        @y += yf

    draw: ->
        ctx = @canvas.getContext '2d'

        # Draw destination
        ctx.save()
        ctx.translate @dx, @dy

        ctx.fillStyle = '#38F2BC'
        ctx.beginPath()
        ctx.arc 0, 0, 10, 0, Math.PI * 2, true
        ctx.closePath()
        ctx.fill()

        ctx.restore()

        # Draw bot
        ctx.save()
        ctx.translate @x, @y

        ctx.fillStyle = '#3C41D2'
        ctx.beginPath()
        ctx.arc 0, 0, @radius, 0, Math.PI * 2, true
        ctx.closePath()
        ctx.fill()

        rads = ((@direction - 90) * Math.PI) / 180.0
        lx = 30 * Math.sin rads
        ly = 30 * Math.cos rads

        # Draw direction pointer
        ctx.strokeStyle = '#000'
        ctx.beginPath()
        ctx.moveTo 0, 0
        ctx.lineTo lx, ly
        ctx.closePath()
        ctx.stroke()

        ctx.restore()



class ObstacleCourse
    constructor: (@canvas) ->
        @obstacles = []

    build: (obstacle_count) ->
        @obstacles = []

        if not obstacle_count?
            obstacle_count = Math.floor(Math.random() * 10) + 10

        while obstacle_count--
            good = false
            tries = 0

            while !good and tries < 20
                x = Math.floor(Math.random() * @canvas.width)
                y = Math.floor(Math.random() * @canvas.height)
                r = Math.floor(Math.random() * 20) + 5

                good = true
                for ob in @obstacles
                    dist = distance2 [ob[0], ob[1]], [x, y]

                    if dist < ((r + ob[2]) * (r + ob[2]))
                        good = false
                        break

                ++tries

            if good
                @obstacles.push [x, y, r]

    draw: ->
        ctx = @canvas.getContext '2d'

        ctx.save()

        for ob in @obstacles
            ctx.fillStyle = '#000'
            ctx.beginPath()
            ctx.arc ob[0], ob[1], ob[2], 0, Math.PI * 2, true
            ctx.closePath()
            ctx.fill()

        ctx.restore()


# Returns the distance squared between p1 and p2
distance2 = (p1, p2) ->
    dx = Math.abs(p1[0] - p2[0])
    dy = Math.abs(p1[1] - p2[1])

    ((dx*dx) + (dy*dy))


# Checks for a collision between two circles
#  defined as [x, y, radius]
circle_collision = (c1, c2) ->
    d1 = distance2 c1, c2
    d2 = c1[2] + c2[2]

    (d1 < (d2*d2))


# Clear the drawing context
clear_screen = ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    canvas.width = canvas.width
    context.clearRect 0, 0, canvas.width, canvas.height


$ ->
    console.log 'Obstacle Avoidance Demo'

    canvas = $('#cv')[0]

    course = new ObstacleCourse canvas
    course.build()

    bot = new Bot canvas
    bot.place course

    $('#reset_button').click ->
        course.build()

    $('#cv').click (event) ->
        x = event.pageX - $(this).offset().left
        y = event.pageY - $(this).offset().top

        bot.set_destination x, y


    $.timer 50, ->
        bot.update()

        clear_screen()
        course.draw()
        bot.draw()

