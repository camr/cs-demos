class Pendulum
    constructor: (canvas) ->
        @a = [canvas.width / 2, 50]
        @b = [(canvas.width / 2) + 200, 250]
        @context = canvas.getContext '2d'

    draw: ->
        @drawCircle @a
        @drawCircle @b
        @drawLine @a, @b

    update: ->
        @b[1] += 1

    drawCircle: (circ) ->
        @context.fillStyle = '#000'
        @context.beginPath()
        @context.arc circ[0], circ[1], 10, 0, Math.PI * 2, true
        @context.closePath()
        @context.fill()

    drawLine: (p1, p2) ->
        @context.strokeStyle = '#000'
        @context.beginPath()
        @context.moveTo p1[0], p1[1]
        @context.lineTo p2[0], p2[1]
        @context.closePath()
        @context.stroke()


clear_screen = ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    can.width = can.width
    ctx.clearRect 0, 0, can.width, can.height


$ ->
    clear_screen()

    can = $('#cv')[0]
    ctx = can.getContext '2d'

    p = new Pendulum can

    $.timer 50, ->
        clear_screen()
        p.draw()
        p.update()

