RESPAWN_RATE = 5;
MAX_PARTICLES = 1000;
GRAVITY = 0.005;

explosion = {
    'direction': 0,
    'drift': 5,
    'power': 10,
    'decay': 50,
    'color': [200, 0, 0],
    'gravity': 0.005,
}

fountain = {
    'direction': 0,
    'drift': 0.5,
    'power': 10,
    'decay': 40,
    'color': [0, 190, 225],
    'gravity': 0.5
}

clown_puke = {
    'direction': 30,
    'drift': 0.5,
    'power': 8,
    'decay': 30,
    'gravity': 1
}

function Particle (pos, settings, context) {
    this.context = context;

    this.x = pos[0];
    this.y = pos[1];

    var rads = (settings['direction'] - 90) * (Math.PI / 180.0);

    this.xvel = (Math.cos(rads) + ((Math.random() * settings['drift']) - (settings['drift'] / 2)) * settings['power'] / 10);
    this.yvel = (Math.sin(rads) + ((Math.random() * settings['drift']) - (settings['drift'] / 2)) * settings['power'] / 10);

    this.life = (Math.random() * 500) + 500;
    this.max_life = this.life;

    this.gravity = settings['gravity'];
    this.decay = (Math.random() * settings['decay']) + 5;

    if (settings['color']) {
        this.color = settings['color'];
    } else {
        this.color = [Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), Math.floor(Math.random() * 255)];
    }

    this.alive = function() {
        return this.life > 0;
    }

    this.draw = function() {
        if (!this.alive())
            return;

        context.fillStyle = 'rgba('
                + this.color[0]
                + ', ' + this.color[1]
                + ', ' + this.color[2]
                + ', ' + Math.max(this.life / this.max_life, 0) + ')';
        context.beginPath();
        context.arc(this.x, this.y, 1, 0, Math.PI * 2, true);
        context.closePath();
        context.fill();
    };

    this.update = function() {
        if (!this.alive())
            return;

        this.x += this.xvel;
        this.y += this.yvel;

        this.y += this.gravity;

        this.life -= this.decay;
    };
};

function Emitter (settings, context) {
    this.settings = settings;
    this.context = context;
    this.active = true;
    this.particles = [];
    this.position = [];

    this.reset = function(width, height, x, y) {
        if (!x || !y)
            this.position = [Math.random() * width, Math.random() * height];
        else
            this.position = [x, y];

        this.particles = [];

        // Prime the emitter
        for (var i = 0; i < RESPAWN_RATE; i++) {
            this.particles.push(new Particle(this.position, this.settings, this.context));
        }
    };

    this.update = function() {
        // For the 'dead' particles, we need to build up a secondary
        // list.  Trying to remove particles from a list as we are
        // iterating through it is destined for pain.
        var remove_list = [];

        var em = this;
        $.each(this.particles, function(idx) {
            if (!this.update) {
                console.log('Found a non-particle in the particle list at index: ' + idx);
                return;
            }

            this.update();
            if (!this.alive()) {
                remove_list.push(idx);
            }
        });

        // Remove dead particles from the list
        $.each(remove_list, function(idx) {
            if (!em.particles[this].alive()) {
                em.particles.splice(this, 1);
            }
        });

        if (this.active) {
            var spawn_count = 0;
            if (this.particles.length < MAX_PARTICLES) {
                spawn_count = Math.min(MAX_PARTICLES - this.particles.length, RESPAWN_RATE);
            }

            for (var i = 0; i < spawn_count; i++)
                this.particles.push(new Particle(this.position, this.settings, this.context));
        }
    };

    this.draw = function() {
        $.each(this.particles, function(idx) {
            this.draw();
        });
    };
};

function clear_screen() {
    var can = $('#cv')[0];
    var ctx = can.getContext("2d");
    can.width = can.width;
    ctx.clearRect(0, 0, 500, 300);
}


$(function() {
    var can = $('#cv')[0];
    var ctx = can.getContext('2d');

    em = new Emitter(explosion, ctx);

    $('#cv').mouseup(function(event) {
        var mouseX = event.pageX - $(this).offset().left;
        var mouseY = event.pageY - $(this).offset().top;

        var settings = [explosion, fountain, clown_puke][Math.floor(Math.random() * 3)]

        em = new Emitter(settings, ctx);
        em.reset(can.width, can.height, mouseX, mouseY);
    });

    $('#reset_button').click(function() {
        em.reset(can.width, can.height);
    });

    em.reset(can.width, can.height);

    $.timer(50, function() {
        clear_screen();
        em.draw();
        em.update();
    });
});

