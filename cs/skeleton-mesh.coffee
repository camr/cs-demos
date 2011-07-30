class Snake
    constructor: (@canvas) ->
        @points = [
            [100, 0.3], [150, 0.1], [200, 0.0], [250, 0.2], [300, 0.5],
            [350, 0.7], [400, 1.0]
        ]

        @sin = 0

    update: ->
        @sin += 0.1

    draw: ->
        ctx = @canvas.getContext '2d'

        ctx.strokeStyle = '#000'

        ctx.beginPath()
        ctx.lineTo p[0], 150 + (Math.sin(@sin + p[1]) * 20) for p in @points
        ctx.stroke()


# Clear the drawing context
clear_screen = ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    canvas.width = canvas.width
    context.clearRect 0, 0, canvas.width, canvas.height


$ ->
    console.log 'Skeleton Mesh Demo'

    canvas = $('#cv')[0]

    snake = new Snake canvas

    $.timer 50, ->
        snake.update()

        clear_screen()
        snake.draw()
