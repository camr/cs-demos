perlin = (x) ->
    p = 0.4 # persistence
    n = 8 # number of octaves

    total = 0
    for i in [1..n]
        frequency = Math.pow 2, i
        amplitude = Math.pow p, i

        total += interpolated_noise(x * frequency) * amplitude

    return total


noise = (x) ->
    x = (x << 13) ^ x
    (1.0 - ((x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0)


interpolated_noise = (x) ->
    xi = Math.floor x
    xf = x - xi

    v1 = smoothed_noise x
    v2 = smoothed_noise x + 1

    interpolate v1, v2, xf


smoothed_noise = (x) ->
    (noise(x) / 2) + (noise(x-1) / 4) + (noise(x+1) / 4)


interpolate = (v1, v2, i) ->
    ft = i * Math.PI
    f = (1 - Math.cos(ft)) * 0.5

    (v1 * (1 - f)) + (v2 * f)


draw = (x, i) ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    y = ((-(perlin i) + 1) / 2) * can.height

    ctx.fillStyle = '#fff'
    ctx.fillRect x, 0, 3, can.height

    ctx.fillStyle = '#000'
    ctx.fillRect x, y, 3, 30

    ctx.fill()


clear_screen = ->
    can = $('#cv')[0]
    ctx = can.getContext '2d'

    can.width = can.width
    ctx.clearRect 0, 0, can.width, can.height


$ ->
    can = $('#cv')[0]

    i = rate_of_change = 0.1
    x = 1

    $.timer 100, ->
        draw x, i

        if x >= can.width
            x = 1
            i = rate_of_change *= 1.5
            #i = rate_of_change
        else
            x += 5
            i += rate_of_change


    $('#reset_button').click ->
        i = rate_of_change = 0.1
        x = 1
        clear_screen()

