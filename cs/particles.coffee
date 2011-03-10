RESPAWN_RATE = 5
MAX_PARTICLES = 1000

explosion =
    direction: 0
    drift: 5
    power: 10
    decay: 50
    color: [200, 0, 0]
    gravity: 0.005

fountain =
    direction: 0
    drift: 0.5
    power: 10
    decay: 40
    color: [0, 190, 225]
    gravity: 0.5

clown_puke =
    direction: 30
    drift: 0.5
    power: 8
    decay: 30
    gravity: 1

class Particle
    constructor: (position, @settings, @context) ->
        @position = position.slice()

        rads = (settings['direction'] - 90) * (Math.PI / 180.0)

        @xvel = (Math.cos(rads) + ((Math.random() * settings['drift']) - (settings['drift'] / 2)) * (settings['power'] / 10))
        @yvel = (Math.sin(rads) + ((Math.random() * settings['drift']) - (settings['drift'] / 2)) * (settings['power'] / 10))

        @life = (Math.random() * 500) + 500
        @max_life = @life

        @gravity = settings['gravity']
        @decay = (Math.random() * settings['decay']) + 5

        if settings['color']?
            @color = settings['color']
        else
            @color = [Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), Math.floor(Math.random() * 255)]

    alive: ->
        @life > 0

    draw: ->
        if not @alive()
            return

        @context.fillStyle = 'rgba(' +
            @color[0] +
            ', ' + @color[1] +
            ', ' + @color[2] +
            ', ' + Math.max(@life / @max_life, 0) + ')'
        @context.beginPath()
        @context.arc @position[0], @position[1], 1, 0, Math.PI * 2, true
        @context.closePath()
        @context.fill()

    update: ->
        if not @alive()
            return

        @position[0] += @xvel
        @position[1] += @yvel

        @position[1] += @gravity

        @life -= @decay


class Emitter
    constructor: (@position, @settings, @context) ->
        if not @position?
            @position = [Math.random() * 500, Math.random() * 300]

        @particles = []
        @active = true

        # Prime the emitter
        (@particles.push(new Particle @position, @settings, @context) for i in [1..RESPAWN_RATE])

    update: ->
        remove_list = []

        for particle, i in @particles
            particle.update()
            if not particle.alive()
                remove_list.push i

        for idx in remove_list
            @particles.splice idx, 1

        if @active
            spawn_count = if @particles.length < MAX_PARTICLES then Math.min(MAX_PARTICLES - @particles.length, RESPAWN_RATE) else 0

            for i in [1..spawn_count]
                @particles.push(new Particle @position, @settings, @context)

    draw: ->
        (p.draw() for p in @particles)

clear_screen = (canvas) ->
    context = canvas.getContext '2d'

    canvas.width = canvas.width
    context.clearRect 0, 0, canvas.width, canvas.height


$ ->
    canvas = $('#cv')[0]
    context = canvas.getContext '2d'

    emitters = []

    $('#cv').mouseup (event) ->
        mouseX = event.pageX - $(this).offset().left
        mouseY = event.pageY - $(this).offset().top

        settings = [explosion, fountain, clown_puke][Math.floor(Math.random() * 3)]

        emitters.push(new Emitter [mouseX, mouseY], settings, context)

    $('#reset_button').click ->
        emitter.reset canvas.width, canvas.height

    $.timer 50, ->
        clear_screen canvas
        (em.draw() for em in emitters)
        (em.update() for em in emitters)

