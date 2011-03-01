$(function() {
    original_line = [[10, 100], [490, 150]];
    smoothed_line = smooth_line(original_line);

    mouseX = 0;
    mouseY = 0;
    mouseDown = false;
    mouseDragging = -1;

    draw_line(smoothed_line);

    $("#cv").mousedown(function(event) {
        mouseX = event.pageX - $(this).offset().left;
        mouseY = event.pageY - $(this).offset().top;
        mouseDown = true;
        check_drag();
    });

    $("#cv").mousemove(function(event) {
        if (mouseDown) {
            mouseX = event.pageX - $(this).offset().left;
            mouseY = event.pageY - $(this).offset().top;
            update_drag();
        }
    });

    $("#cv").mouseup(function(event) {
        mouseX = event.pageX - $(this).offset().left;
        mouseY = event.pageY - $(this).offset().top;

        if (mouseDragging >= 0) {
            update_drag();
        } else {
            add_point(mouseX, mouseY);
        }

        mouseDown = false;
        mouseDragging = -1;
    });

    $("#reset_button").click(function() {
        original_line = [[10, 100], [490, 150]];
        smoothed_line = smooth_line(original_line);
        clear_screen();
        draw_line(smoothed_line);
    });
});

function check_drag() {
    var found = -1;
    var found_distance = 0;
    for (var i = 0; i < original_line.length; i++) {
        var dx = Math.abs(mouseX - original_line[i][0]);
        var dy = Math.abs(mouseY - original_line[i][1]);
        if ((dx < 10 && dy < 10) && (found < 0 || (dx + dy < found_distance))) {
            found = i;
            found_distance = dx + dy;
        }
    }

    mouseDragging = found;
}

function update_drag() {
    original_line[mouseDragging][0] = mouseX;
    original_line[mouseDragging][1] = mouseY;

    smoothed_line = smooth_line(original_line);
    check_drag();

    clear_screen();
    draw_line();
}

function add_point(x, y) {
    var x = x || Math.floor(Math.random() * 500);
    var y = y || Math.floor(Math.random() * 300);

    var start = 0;
    for (var i = 1; i < original_line.length; i++) {
        if (original_line[i][0] < x) {
            start = i;
        } else {
            break;
        }
    }

    new_line = [];    
    original_line.forEach(function(pt, index) {
        new_line.push(pt);
        if (index == start) {
            new_line.push([x, y]);
        }
    });
    original_line = new_line;

    smoothed_line = smooth_line(original_line);

    clear_screen()
    draw_line();
}

function clear_screen() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");
    can.width = can.width;
    ctx.clearRect(0, 0, 500, 300);
}

function draw_line() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");

    ctx.strokeStyle = "rgba(0, 0, 0, 1.0)";
    ctx.moveTo(smoothed_line[0][0], smoothed_line[0][1]);
    for (var i = 1; i < smoothed_line.length; i++) {
        ctx.lineTo(smoothed_line[i][0], smoothed_line[i][1]);
    }
    ctx.stroke();

    ctx.strokeStyle = "rgba(0, 0, 0, 0.3)";
    ctx.moveTo(original_line[0][0], original_line[0][1]);
    $.each(original_line, function(idx, p) {
        ctx.lineTo(p[0], p[1]);
    });
    ctx.stroke();

    draw_points();
}

function draw_points() {
    var ctx = $('#cv')[0].getContext('2d');

    for (var i = 0; i < original_line.length; i++) {
        ctx.fillStyle = '#a00';
        ctx.beginPath();
        ctx.arc(original_line[i][0], original_line[i][1], 5, 0, Math.PI * 2, true);
        ctx.closePath();
        ctx.fill();
    }
}

function smooth_line(in_line) {
    var il = in_line.slice();
    il.unshift(in_line[0]);
    il.push(in_line[in_line.length-1]);

    var new_points = [];

    var i = 1;
    while (i < il.length - 2) {
        var t = 0;
        while (t < 1.0) {
            var xy = 0;
            var q = [];
            while (xy <= 1) {
                var q1 = 2 * il[i][xy];
                var q2 = (-il[i-1][xy] + il[i+1][xy]) * (t);
                var q3 = ((2 * il[i-1][xy]) - (5 * il[i][xy]) + (4 * il[i+1][xy]) - (il[i+2][xy])) * (t*t);
                var q4 = ((-il[i-1][xy]) + (3 * il[i][xy]) - (3 * il[i+1][xy]) + (il[i+2][xy])) * (t*t*t);

                q.push(0.5 * (q1 + q2 + q3 + q4));
                xy++;
            }
            new_points.push(q);
            t += 0.1;
        }
        i++;
    }

    return new_points;
}
