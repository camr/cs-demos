var obstacles = [
    // [x, y, radius]
];

var map = [
    // [x, y, radius, [obstacle_list]]
];

var bot = {
    destination: 0,
    position: [],
    node: 0,
    path: [],

    build_path: function() {
        var p = [bot.node];
        var current_node = bot.node;

        var potentials = []; // list of indices into map
        $.each(map, function(idx) {
            if (this[3].length === 0 && idx !== bot.node) {
                potentials.push(idx);
            }
        });

        while (current_node !== bot.destination && potentials.length > 0) {
            var neighbors = nearest_neighbors(current_node, potentials, 5);

            for (var i = 0; i < neighbors.length; i++) {
                var np = neighbors[i][0];
                if (is_path_clear(map[current_node], map[np])) {
                    p.push(np);
                    current_node = potentials[np];
                    potentials.splice(np, 1);
                    break;
                }
            }
        }

        this.path = [];
        $.each(p, function() {
            bot.path.push([map[this][0], map[this][1]]);
        });


        return;


        // A* (not working)
        this.path = [this.position];
        var dir = [
            //this.destination[0] - this.position[0],
            //this.destination[1] - this.position[1]
        ];

        var potentials = [];
        $.each(map, function(idx) {
            if (this[3].length == 0) {
                potentials.push(idx);
            }
        });

        var open_set = [[this.node, 0, -1]]; // [node index, G score, prev node]
        var closed_set = [];

        var done = false;
        while (!done) {
            var G = open_set[0][1];
            //var H = distance(bot.destination, map[open_set[0][0]]);

            var prev_node = open_set[0];
            var prev_node_index = 0;

            // find the minimum distance in the open set
            $.each(open_set, function(idx) {
                var this_G = this[1];
                //var this_H = distance(bot.destination, map[this[0]]);

                if (this_G + this_H < G + H) {
                    G = this_G;
                    H = this_H;
                    prev_node = this;
                    prev_node_index = idx;
                }
            });

            // find the 5 nearest points to next_node
            var neighbors = []; // [map index, distance to next_node]
            $.each(potentials, function() {
                var pot = this;
                var dist_to_point = distance(map[prev_node[0]], map[pot]);

                if (neighbors.length < 5) {
                    neighbors.push([pot, dist_to_point]);
                    return;
                }

                $.each(neighbors, function() {
                    if (dist_to_point < this[1]) {
                        this[0] = pot;
                        this[1] = dist_to_point;
                    }
                });
            });

            // filter out neighbors that are already in the closed set
            var good_neighbors = [];
            $.each(neighbors, function() {
                var good = true;
                var n = this;
                $.each(closed_set, function() {
                    if (this[0] === n[0]) {
                        good = false;
                        return;
                    }
                });

                if (good) {
                    good_neighbors.push(this);
                }
            });
            neighbors = good_neighbors;

            $.each(neighbors, function() {
                var n = this;
                var in_open_set = false;
                var open_set_index = -1;
                $.each(open_set, function(idx) {
                    if (this[0] === n[0]) {
                        in_open_set = true;
                        open_set_index = idx;
                    }
                });

                var new_G = prev_node[1] + this[1];

                if (!in_open_set) {
                    open_set.push([this, new_G, prev_node]);
                } else {
                    if (open_set[open_set_index][1] > new_G) {
                        open_set[open_set_index][1] = new_G;
                        open_set[open_set_index][2] = prev_node;
                    }
                }

                //if (map[n[0]][0] == bot.destination[0] && map[n[0]][1] == bot.destination[1]) {
                    //done = true;
                //}
            });

            closed_set.push(prev_node);
            open_set.splice(prev_node_index, 1);
        }

        console.log('open_set: ' + open_set);
        console.log('closed_set: ' + closed_set);
    },

    // update
    update: function() {
    },

    // draw
    draw: function(ctx) {
        // bot
        ctx.fillStyle = '#F00';
        ctx.beginPath();
        ctx.moveTo(this.position[0] + 10, this.position[1] - 10);
        ctx.lineTo(this.position[0] - 10, this.position[1] - 10);
        ctx.lineTo(this.position[0], this.position[1] + 10);
        ctx.lineTo(this.position[0] + 10, this.position[1] - 10);
        ctx.closePath();
        ctx.fill();

        // destination
        ctx.fillStyle = '#F00';
        ctx.beginPath();
        ctx.arc(map[this.destination][0],
                map[this.destination][1],
                map[this.destination][2], 0, Math.PI*2, true);
        ctx.closePath();
        ctx.fill();

        // path
        ctx.strokeStyle = '#0F0';
        ctx.beginPath();
        ctx.moveTo(this.position[0], this.position[1]);
        $.each(this.path, function() {
            ctx.lineTo(this[0], this[1]);
        });
        ctx.stroke();
    },

    check_path_collision: function(path) {
    },

    check_collision: function() {
        $.each(obstacles, function() {
            var dx = Math.abs(this[0] - bot.position[0]);
            var dy = Math.abs(this[1] - bot.position[1]);

            if ((dx*dx) + (dy*dy) <= (this[2]*this[2])) {
                console.log('Collision!');
            }
        });
    },
}


function distance(a, b) {
    return Math.abs(a[0] - b[0]) + Math.abs(a[1] - b[1]);
}


function dot_product(a, b) {
    return (a[0]*b[0]) + (a[1]*b[1]);
}


function nearest_neighbors(node, potentials, k) {
    var neighbors = []; // [potentials index, distance to next_node]

    $.each(potentials, function(pot_index) {
        var map_index = this;

        if (map[map_index][3].length !== 0) {
            // node contains obstacles
            return;
        }

        var dist_to_point = distance(map[node], map[map_index]);

        // prime our list with the first five nodes we find
        if (neighbors.length < k) {
            neighbors.push([pot_index, dist_to_point]);
            return;
        }

        // check to see if the current node is closer than
        // any we've found before.  If it is, find the largest
        // distance in our neighbor set.
        var max = 0;
        var replace = -1;
        $.each(neighbors, function(i) {
            if (dist_to_point < this[1] && this[1] > max && map_index !== node) {
                max = this[1];
                replace = i
            }
        });

        // if we found a closer node, update the neighbor list
        if (replace >= 0) {
            neighbors[replace][0] = pot_index;
            neighbors[replace][1] = dist_to_point;
        }
    });

    return neighbors;
}


function circle_collision(c1, c2) {
    var dx = Math.abs(c1[0] - c2[0]);
    var dy = Math.abs(c1[1] - c2[1]);

    if ((dx*dx) + (dy*dy) < (c1[2]+c2[2])*(c1[2]+c2[2])) {
        return true;
    }

    return false;
}


function is_path_clear(p1, p2) {
    // direction vector of ray
    var dx = p2[0] - p1[0];
    var dy = p2[1] - p1[1];

    for (var i = 0; i < obstacles.length; i++) {
        // vector from sphere center to ray start
        var fx = p1[0] - obstacles[i][0];
        var fy = p1[1] - obstacles[i][1];

        // convenient vars
        var a = dot_product([dx, dy], [dx, dy]);
        var b = 2 * dot_product([fx, fy], [dx, dy]);
        var c = dot_product([fx, fy], [fx, fy]) - (obstacles[i][2]*obstacles[i][2]);

        var disc = (b*b) - (4 * a * c);
        if (disc < 0) {
            // no intersection, path is good for this obstacle
            continue;
        } else {
            disc = Math.sqrt(disc);
            var t = (-b + disc) / (2 * a);

            if (t >= 0 && t <= 1) {
                // solution is on the ray
                return false;
            } else {
                // solution is out-of-range
                continue;
            }
        }
    }

    return true;
}


function clear_screen() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");
    can.width = can.width;
    ctx.clearRect(0, 0, can.width, can.height);
};


function draw_scene() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");

    $.each(obstacles, function(idx) {
        ctx.fillStyle = '#000';
        ctx.beginPath();
        ctx.arc(this[0], this[1], this[2], 0, Math.PI * 2, true);
        ctx.closePath();
        ctx.fill();
    });
};


function draw_map() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");

    $.each(map, function(idx) {
        ctx.strokeStyle = '#05F';
        ctx.beginPath();
        ctx.arc(this[0], this[1], this[2], 0, Math.PI * 2, true);
        ctx.closePath();
        ctx.stroke();
    });
};


function build_obstacle_course(canvas) {
    obstacles = [];
    var length = Math.floor(Math.random() * 10) + 20;

    for (var i = 0; i < length; i++) {
        var good = false;
        var tries = 0;
        while (!good && tries < 20) {
            var x = Math.floor(Math.random() * canvas.width);
            var y = Math.floor(Math.random() * canvas.height);
            var r = Math.floor(Math.random() * 30) + 5;

            good = true;
            $.each(obstacles, function() {
                dx = Math.abs(this[0] - x);
                dy = Math.abs(this[1] - y);

                if ((dx*dx) + (dy*dy) < ((r+this[2]) * (r+this[2]))) {
                    good = false;
                }
            });

            tries++;
        }

        if (good)
            obstacles.push([x, y, r]);
    }
};


function build_map(canvas) {
    map = [];

    var failures = 0;
    var good = false;
    while (failures < 500) {
        var x = Math.floor(Math.random() * canvas.width);
        var y = Math.floor(Math.random() * canvas.height);
        var r = 10; //Math.floor(Math.random() * 20) + 5;

        good = true;
        $.each(map, function() {
            if (circle_collision(this, [x, y, r])) {
                good = false;
            }
        });

        if (good) {
            failures = 0;
            var ob_list = [];
            $.each(obstacles, function(idx) {
                if (circle_collision(this, [x, y, r])) {
                    ob_list.push(idx);
                }
            });

            map.push([x, y, r, ob_list]);
        } else {
            failures++;
        }
    }
};


function place_bot() {
    for (var i = 0; i < map.length; i++) {
        var x = Math.floor(Math.random() * map.length);
        if (map[x][3].length == 0) {
            bot.position = [map[x][0], map[x][1]];
            bot.node = x;
            return;
        }
    }
    console.log('Unable to find an open area!');
};


function place_destination() {
    for (var i = 0; i < map.length; i++) {
        var x = Math.floor(Math.random() * map.length);
        if (map[x][3].length == 0) {
            bot.destination = x;
            return;
        }
    }
    console.log('Didn\'t find an open area!');
};


$(function() {
    var can = $('#cv')[0];
    var ctx = can.getContext('2d');

    $('#reset_button').click(function() {
        build_obstacle_course(can);
        build_map(can);
        place_bot();
        place_destination();

        bot.build_path();

        clear_screen();
        draw_scene();
        draw_map();
        bot.draw(ctx);
    });

    build_obstacle_course(can);
    build_map(can);
    place_bot();
    place_destination();

    bot.build_path();

    clear_screen();
    draw_scene();
    draw_map();
    bot.draw(ctx);
});

