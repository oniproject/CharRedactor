'use strict'

Vue = require 'vue'

Actor = require './actor'
saveAs = require 'filesaver.js'

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
		currentAnimation: 'vfds'
		newAnimationName: ''

		selectedFrame: -1
		newFrameName: 'suika walk ↘ 0'

		# ↖ ↑ ↗
		# ←   →
		# ↙ ↓ ↘
		animations:
			'vfds':
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

	filters:
		degrees:
			read: (val) ->
				val * (180 / Math.PI)
			write: (val, oldVal) ->
				val * (Math.PI / 180)

	components:
		frame: {}
		addDialog: require './modal.coffee'
	events:
		undo: (count) ->
		redo: (count) ->
		load: (data) ->
			@animations = data
			@$options.actor.data = data
		save: ->
			json = JSON.stringify @$data.animations
			blob = new Blob([json], {type: 'text/json;charset=utf-8'})
			saveAs blob, 'animations.json'
		add: (name) ->
			console.log 'add', name

	methods:
		addAnimation: ->
			@animations.$add @newAnimationName,
				directions:
					'↖':[], '↑':[], '↗':[]
					'←':[],         '→':[]
					'↙':[], '↓':[], '↘':[]
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
		handleFileSelect = (event)=>
			file = event.target.files[0]
			reader = new FileReader()
			reader.onload = (event) =>
				@$emit 'load', JSON.parse(reader.result)
			reader.readAsText file
			event.target.value = ''

		document.getElementById('file').addEventListener('change', handleFileSelect, false)

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

		actor = @$options.actor = new Actor(@$data.animations)
		actor.scale.x = actor.scale.y = 0.5
		container.addChild(actor)
		actor.currentAnimation = @currentAnimation
		actor.currentDirection = @currentDirection
		actor.currentFrame = 0

		@$watch 'currentDirection', ((val, oldVal) -> actor.currentDirection = val), true
		@$watch 'currentAnimation', ((val, oldVal) -> actor.currentAnimation = val), true

		canvas = document.getElementById('canvas')
		renderer = PIXI.autoDetectRenderer getW(canvas), getH(canvas),
			view: canvas
			transparent: true
			antialias: true
			resolution: 1

		animate = ->
			Vue.nextTick animate
			renderer.render(stage)
		Vue.nextTick animate

		resize = ->
			w = getW(canvas)
			h = getH(canvas)
			container.x = (w / 2) | 0
			container.y = (h / 2) | 0
			renderer.resize(w, h)

		window.addEventListener('resize', resize)
		resize()
