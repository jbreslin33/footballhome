'use strict';

class Player
{
        constructor(id,pitch,x,y,color)
        {
		this.mContext = pitch.mScreen.mContext;
		console.log("new player");
		this.x = x;
		this.y = y;
		this.mColor = color;

		this.mId = id;

		//need to scale this... 
		/*
		screenWidth/105 gives pixels per meter 
			
			
			
		*/
		this.mSize = 1;

	}

	update()
	{
		this.mContext.beginPath();
  		this.mContext.fillStyle = this.mColor;
  		this.mContext.arc(this.x, this.y, 1.3, 0, Math.PI * 360);
  		this.mContext.fill();
	}
}

