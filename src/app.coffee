'use strict'

Actor = require './actor'

getH = (el) ->
	style = window.getComputedStyle(el, null)
	parseFloat(style.getPropertyValue('height'))

getW = (el) ->
	style = window.getComputedStyle(el, null)
	parseFloat(style.getPropertyValue('width'))


module.exports =
	template: require('./app.jade')()
	data:
		currentDirection: '↓'
		currentAnimation: 'idle'
		newAnimationName: ''

		selectedFrame: -1
		newFrameName: 'suika walk ↘ 0'

		#// ↖ ↑ ↗
		#// ←   →
		#// ↙ ↓ ↘
		animations:
			'idle':
				directions:
					'↓': [
						{
							name: 'suika walk ↓ 0'
							t: 100
							x: -38, y: -88
							sx: 1.0, sy: 1.0
							rot: 0
						},
						{
							name: 'suika walk ↓ 1'
							t: 100
							x: -38, y: -90
							sx: 1.0, sy: 1.0
							rot: 0
						},
						{
							name: 'suika walk ↓ 2'
							t: 100
							x: -38, y: -88
							sx: 1.0, sy: 1.0
							rot: 0
						},
						{
							name: 'suika walk ↓ 1'
							t: 100
							x: -38, y: -90
							sx: 1.0, sy: 1.0
							rot: 0
						},
					]
			'move':
				directions: {}

	filters:
		degrees:
			read: (val) ->
				val * (180 / Math.PI);
			write: (val, oldVal) ->
				val * (Math.PI / 180);

	components:
		frame: {}

	events:
		undo: (count) ->
		redo: (count) ->
		load: (data) ->

	methods:
		addAnimation: ->
			@animations.$add(@newAnimationName, {})
			@newAnimationName = ''
		rmAnimation: ->
			@animations.$delete(@currentAnimation)
			@currentAnimation = ''
		addFrame: ->
			anim = @animations[@currentAnimation]
			frames = anim.directions[@currentDirection]
			frames.push
				name: @newFrameName,
				t: 0,
				x: 0,
				y: 0,
				sx: 1.0,
				sy: 1.0,
				rot: 0,
		rmFrame: ->
			anim = @animations[@currentAnimation]
			frames = anim.directions[@currentDirection]
			if @selectedFrame != -1 and @selectedFrame < frames.length
				frames.splice(@selectedFrame, 1)
				console.info('rm', @selectedFrame)
			else
				console.warn('rm FAIL', @selectedFrame, frames.length)

	ready: ->
		stage = new PIXI.Stage()

		container = new PIXI.DisplayObjectContainer()
		stage.addChild(container)

		graphics = new PIXI.Graphics()
		container.addChild(graphics)

		graphics.lineStyle(1, 0xCC0000, 1)
		graphics.moveTo(-10000, 0)
		graphics.lineTo(10000, 0)
		graphics.moveTo(0, -10000)
		graphics.lineTo(0, 10000)

		loader = new PIXI.AssetLoader(['suika.json'])
		loader.onComplete = =>
			actor = new Actor(@$data.animations)
			actor.scale.x = actor.scale.y = 0.5
			container.addChild(actor)
			actor.currentAnimation = @currentAnimation
			actor.currentDirection = @currentDirection
			actor.currentFrame = 0
		loader.load()

		canvas = @$el.getElementsByTagName('canvas')[0]
		renderer = PIXI.autoDetectRenderer getW(canvas), getH(canvas),
			view: canvas
			transparent: true
			antialias: true
			resolution: 2

		animate = ->
			requestAnimFrame(animate)
			renderer.render(stage)
		requestAnimFrame(animate)

		resize = ->
			w = getW(canvas)
			h = getH(canvas)
			container.x = (w / 2) | 0
			container.y = (h / 2) | 0
			renderer.resize(w, h)

		window.addEventListener('resize', resize)
		resize()
