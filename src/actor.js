'use strict';

var Actor = function(data) {
	PIXI.DisplayObjectContainer.call(this);

	this.data = data;
	//this.textures = textures;

	this._currentAnimation = 'idle';
	this._currentDirection = 'n';
	this._currentFrame = 0;

	this.lastTime = window.performance.now();
	this.playing = true;

	this._currentDelta = 100;
}

Actor.prototype = Object.create(PIXI.DisplayObjectContainer.prototype);
Actor.prototype.constructor = Actor;

Object.defineProperty(Actor.prototype, 'currentFrame', {
	get: function() {
		return this._currentFrame;
	},
	set: function(val) {
		if (this.data[this._currentAnimation].directions[this._currentDirection].length > val) {
			this._currentFrame = val;
		} else {
			console.error("Bad currentFrame", val);
		}
	},
});

Object.defineProperty(Actor.prototype, 'currentAnimation', {
	get: function() {
		return this._currentAnimation;
	},
	set: function(val) {
		if (this.data.hasOwnProperty(val)) {
			this._currentAnimation = val;
		} else {
			console.error("Bad action", val, this.data);
		}
	},
});

Object.defineProperty(Actor.prototype, 'currentDirection', {
	get: function() {
		return this._currentDirection;
	},
	set: function(val) {
		switch (val) {
			case '↑':
			case '↗':
			case '→':
			case '↘':
			case '↓':
			case '↙':
			case '←':
			case '↖':
				this._currentDirection = val;
				break;
			default:
				console.error("Bad direction", val);
		}
	},
});

Actor.prototype.stop = function() {
	this.playing = false;
}
Actor.prototype.play = function() {
	this.playing = true;
}
Actor.prototype.gotoAndStop = function(frameNumber) {
	this.playing = false;
	this.currentFrame = frameNumber;
}
Actor.prototype.gotoAndPlay = function(frameNumber) {
	this.currentFrame = frameNumber;
	this.playing = true;
}

Actor.prototype.getFrames = function() {
	var animation = this.data[this._currentAnimation];
	return animation.directions[this._currentDirection];
}

Actor.prototype.updateTransform = function() {
	var time = window.performance.now();

	if (!this.playing) {
		this.lastTime = time;
	} else {
		var delta = time - this.lastTime;

		if (delta >= this._currentDelta) {
			this.lastTime = time;

			var frames = this.getFrames();
			if (!frames && this._sprite) {
				this._sprite.visible = false;
				return
			}

			this._currentFrame++;

			if (this._currentFrame >= frames.length) {
				this._currentFrame = 0;
			}
			//this._upd = true;
			var frame = frames[this._currentFrame];
			var texture = PIXI.TextureCache[frame.name];
			if (!texture) {
				if (this._sprite) {
					this._sprite.visible = false;
				}
				return;
			}
			if (!this._sprite) {
				this._sprite = new PIXI.Sprite(texture);
				this.addChild(this._sprite);
			}
			this._currentDelta = frame.t;
			this._sprite.visible = true;
			var sprite = this._sprite;
			sprite.position.x = frame.x;
			sprite.position.y = frame.y;
			sprite.scale.x = frame.sx;
			sprite.scale.y = frame.sy;
			sprite.rotation = frame.rot;
			sprite.setTexture(texture);
		}
	}

	PIXI.DisplayObjectContainer.prototype.updateTransform.call(this);
}

module.exports = Actor;
