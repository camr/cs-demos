canvas_width = 100
canvas_height = 100

font_red = 128
font_green = 128
font_blue = 128

font_size = 64

clear_screen = ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    can.width = can.width
    ctx.clearRect 0, 0, can.width, can.height

draw_text = (ctx) ->
    ctx.font = 'bold ' + font_size + 'px serif'
    ctx.fillStyle = 'rgba(' + font_red + ', ' + font_green + ', ' + font_blue + ', 1)'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText "text", canvas_width/2, canvas_height/2

$ ->
    clear_screen()

    can = $('#cv')[0]
    ctx = can.getContext '2d'

    canvas_width = can.width
    canvas_height = can.height

    $('#cv').mousemove (event) ->
        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        horizontal_percentage = mouseX / canvas_width
        vertical_percentage = mouseY / canvas_height

        font_red = Math.round(horizontal_percentage * 255)
        font_green = Math.round(vertical_percentage * 255)

    $('#cv').mouseup (event) ->
        font_choices = [28, 42, 64, 86, 112, 142, 164]
        font_size = font_choices[Math.round(1 + (Math.random() * (font_choices.length - 1))) - 1]

    $.timer 50, ->
        clear_screen()
        draw_text ctx

