'use strict'

Vue = require 'vue'

module.exports =
	events:
		getRect: (event) ->
			texture = @$options.texture.baseTexture
			frames = @$options.json.frames

			x = event.offsetX
			y = event.offsetY

			return unless texture or frames

			for name, frame of frames
				do (name, frame) =>
					rect = frame.frame
					if rect
						isX = rect.x > x - rect.w and rect.x < x
						isY = rect.y > y - rect.h and rect.y < y
						if  isX and isY
							console.log name
							@$dispatch 'add', name
						#else
							#console.log name, x, y, isX, isY, rect



		clearAll: ->
			console.log 'clearAll'
			delete @$options['json']
			delete @$options['texture']
			@$options.icontainer.removeChildren()
			@$options.jcontainer.removeChildren()
			@$options.imageEl.value = ''
			@$options.jsonEl.value = ''
		checkLoaded: ->
			texture = @$options.texture.baseTexture
			frames = @$options.json.frames

			return unless texture or frames

			form = document.getElementById 'modal-form'
			form.style.display = 'none'

			console.log 'checkLoaded', texture, frames
			for name, frame of frames
				do (name, frame) =>
					rect = frame.frame
					if rect
						size = new PIXI.Rectangle rect.x, rect.y, rect.w, rect.h
						crop = size.clone()
						trim = null
						if frame.trimmed
							actualSize = frame.sourceSize
							realSize = frame.spriteSourceSize
							trim = new PIXI.Rectangle(
								realSize.x, realSize.y, actualSize.w, actualSize.h)
						PIXI.TextureCache[name] = new PIXI.Texture(texture, size, crop, trim)

	attached: ->
		json = @$options.jsonEl = document.getElementById 'framesJson'
		image = @$options.imageEl = document.getElementById 'framesImage'

		json.addEventListener 'change', (event)=>
			file = event.target.files[0]
			reader = new FileReader()
			reader.onload = (event) =>
				json = @$options.json = JSON.parse(reader.result)
				frames = json.frames

				graphics = new PIXI.Graphics()
				@$options.jcontainer.addChild graphics
				graphics.lineStyle 1, 0xCC0000, 1
				for name, frame of frames
					do (name, frame) =>
						rect = frame.frame
						if rect
							graphics.drawRect rect.x, rect.y, rect.w, rect.h
							text = new PIXI.Text name,
								font: 'bold 12px Arial'
								fill: '#CC0000'
								stroke: 'black'
								strokeThickness: 2
							text.x = rect.x
							text.y = rect.y
							@$options.jcontainer.addChild text
			reader.readAsText file
	
		image.addEventListener 'change', (event)=>
			file = event.target.files[0]
			reader = new FileReader()
			reader.onload = (event) =>
				texture = @$options.texture = PIXI.Texture.fromImage(reader.result)
				onload = =>
					sprite = @$options.sprite = new PIXI.Sprite(texture)
					console.log 'onload', texture.width, texture.height
					@$options.icontainer.addChild sprite
					@$options.canvas.style.width = sprite.width + 'px'
					@$options.canvas.style.height = sprite.height + 'px'
					@$options.renderer.resize sprite.width, sprite.height
				if texture.baseTexture.hasLoaded
					onload()
				else
					texture.baseTexture.on 'loaded', onload
			reader.readAsDataURL file

		stage = @$options.stage = new PIXI.Stage()

		icontainer = @$options.icontainer = new PIXI.DisplayObjectContainer()
		stage.addChild icontainer

		jcontainer = @$options.jcontainer = new PIXI.DisplayObjectContainer()
		stage.addChild jcontainer

		canvas = @$options.canvas = document.getElementById('add-canvas')
		renderer = @$options.renderer = PIXI.autoDetectRenderer 100, 100,
			view: canvas
			transparent: true
			antialias: false
			resolution: 1

		animate = ->
			Vue.nextTick animate
			renderer.render(stage)
		Vue.nextTick animate

