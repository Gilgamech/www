//Create the canvas
var canvas = document.createElement("myCanvas");
var context = canvas.getContext('2d');
canvas.width = 512;
canvas.height = 480;
document.body.appendChild(myCanvas);

// load background
var clockImageLoaded = false;
var clockImage = new Image();
clockImage.onload = function(){
   clockImageLoaded = true;
}
clockImage.src = 'http://i.imgur.com/mLtBiJb.png';

//Get the current time
var d = new Date();
var nowhour = d.getHours();
var nowmin = d.getMinutes();

//draw it all
var render = function () {
  if (clockImageLoaded) {
    context.drawImage(clockImageLoaded, 0, 0);
  }

  //Time Display (Need to change out later)
  context.fillStyle = "rgb(250, 250, 250,)";
  context.font = "24px Helvetica";
  context.textAlign = "left";
  context.textBaseline = "top";
  context.fillText("The time is: " + nowhour + ":" + nowmin, 32, 32);
};


// Clock loop
var main = function () {
  var now = Date.now();
  var delta = now - then;
  
  update(delta/1000);
  render();
  
  then = now;
};

//Play!
reset();
var then = Date.now();
setInterval(main, 1); //run at top speed