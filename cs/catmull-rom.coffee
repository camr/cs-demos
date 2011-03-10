original_line = [[10, 100], [490, 150]]
smoothed_line = []

mouseX = 0
mouseY = 0
mouseDown = false
mouseDragging = -1

$ ->
    smoothed_line = smooth_line original_line
    draw_scene()

    $('#cv').mousedown (event) ->
        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        mouseDown = true
        mouseDragging = check_drag original_line

    $('#cv').mousemove (event) ->
        if mouseDown
            mouseX = event.pageX - $(this).offset().left
            mouseY = event.pageY - $(this).offset().top

            update_drag original_line

    $('#cv').mouseup (event) ->
        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        if mouseDragging >= 0
            update_drag original_line
        else
            add_point mouseX, mouseY

        mouseDown = false
        mouseDragging = -1

    $('#reset_button').click ->
        original_line = [[10, 100], [490, 150]]
        smoothed_line = smooth_line original_line

        draw_scene()

# Checks to see if the mouse position is close
# to a point in line.  If it is, the function returns
# the index into the line of that point, -1 otherwise
check_drag = (line) ->
    found = -1
    found_distance = 0
    for pt, i in line
        dx = Math.abs mouseX - pt[0]
        dy = Math.abs mouseY - pt[1]

        if (dx < 10 && dy < 10) && (found < 0 || (dx + dy < found_distance))
            found = i
            found_distance = dx + dy

    return found


# Updates the position of the currently dragged point,
#  recalculates the smooth line and redraws the scene.
update_drag = (line) ->
    line[mouseDragging][0] = mouseX
    line[mouseDragging][1] = mouseY

    smoothed_line = smooth_line(original_line)

    draw_scene()


# Similar to check_drag, except this returns the closest point
#  in original_line regardless of distance threshold
find_closest_point = (x, y) ->
    found = 0
    found_distance = Math.abs(x - original_line[0][0]) + Math.abs(y - original_line[0][1])

    for i in [1..original_line.length - 1]
        dx = Math.abs x - original_line[i][0]
        dy = Math.abs y - original_line[i][1]

        if dx + dy < found_distance
            found = i
            found_distance = dx + dy

    return found


# Adds a point to original_line at [x, y]
#  Attempts to find an 'accurate' position for the point
add_point = (x, y) ->
    start = find_closest_point x, y

    new_line = []
    for pt, i in original_line
        new_line.push pt
        if i == start
            new_line.push [x, y]

    original_line = new_line
    smoothed_line = smooth_line original_line

    draw_scene()


# Draw the entire scene
draw_scene = ->
    clear_screen()
    draw_line original_line, [0, 0, 0, 0.3]
    draw_line smoothed_line, [0, 0, 0, 1.0]
    draw_points original_line


# Clear the drawing context
clear_screen = ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    canvas.width = canvas.width
    context.clearRect 0, 0, canvas.width, canvas.height


# Draw a line of 2D points
draw_line = (in_line, color) ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    context.strokeStyle =
        'rgba(' + color[0] +
        ', ' + color[1] +
        ', ' + color[2] +
        ', ' + color[3] + ')'

    context.beginPath()
    context.moveTo in_line[0][0], in_line[0][1]

    context.lineTo l[0], l[1] for l in in_line

    #context.closePath()
    context.stroke()


# Draw the control points
draw_points = (line) ->
    context = $('#cv')[0].getContext '2d'

    context.fillStyle = '#a00'
    context.beginPath()
    context.arc point[0], point[1], 5, 0, Math.PI * 2, true for point in line
    context.closePath()
    context.fill()


# Returns a new line of points smoothed according to
#  the Catmull-Rom algorithm
smooth_line = (in_line) ->
    il = in_line.slice()

    # Duplicate first and last points on the line
    il.unshift(in_line[0])
    il.push(in_line[in_line.length - 1])

    new_points = []

    i = 1
    while i < il.length - 2
        t = 0
        while t < 1.0
            xy = 0
            q = []
            while xy <= 1
                q1 = 2 * il[i][xy]
                q2 = (-il[i-1][xy] + il[i+1][xy]) * (t)
                q3 = ((2 * il[i-1][xy]) - (5 * il[i][xy]) + (4 * il[i+1][xy]) - (il[i+2][xy])) * (t*t)
                q4 = ((-il[i-1][xy]) + (3 * il[i][xy]) - (3 * il[i+1][xy]) + (il[i+2][xy])) * (t*t*t)

                q.push(0.5 * (q1 + q2 + q3 + q4))
                xy++
            new_points.push(q)
            t += 0.1
        i++

    return new_points

