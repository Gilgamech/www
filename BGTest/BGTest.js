//Create the canvas
var canvas = document.createElement("canvas");
var ctx = canvas.getContext("2d");
canvas.width = 600;
canvas.height = 600;
document.body.appendChild(canvas);

// load background
var bgReady = false;
var bgImage = new Image();
bgImage.onload = function () {
  bgReady = true;
};
bgImage.src = "http://gilgamech.com/ark/images/TheCenter_Pencil.jpg";

// load clientClint
var clientClintReady = false;
var clientClintImage = new Image();
clientClintImage.onload = function () {
  clientClintReady = true;
};
clientClintImage.src = "http://gilgamech.com/ark/images/TheCenter_Pencil.jpg";

// packet image
var packetReady = false;
var packetImage = new Image();
packetImage .onload = function () {
  packetReady = true;
};
packetImage .src = "http://gilgamech.com/images/packet.png";

// Game objects

var clientClint = {};
var packet = {};
var packetsCaught = 0;

// keyboard controls
var mousePos = {};

addEventListener('mousemove', function(evt) {
 mousePos = getMousePos(canvas, evt);
}, false);
 
// reset game when player catches packet
var reset = function () {

};
//draw it all
var render = function () {
  if (bgReady) {
    ctx.drawImage(bgImage, 0, 0);
  }
    
  if (clientClintReady) {
    ctx.drawImage(clientClintImage, (mousePos.x-300), (mousePos.y-300));
  }
  if (packetReady) {
    ctx.drawImage(packetImage, packet.x, packet.y);
  }
  
  //score
  ctx.fillStyle = "rgb(250, 250, 250,)";
  ctx.font = "24px Helvetica";
  ctx.textAlign = "left";
  ctx.textBaseline = "top";
  ctx.fillText("Packets caught: " + packetsCaught, 32, 32);
  
};

// Get mouse position
function getMousePos(canvas, evt) {
  var rect = canvas.getBoundingClientRect();
  return {
    x: evt.clientX - rect.left,
    y: evt.clientY - rect.top
  };
}


// Game loop
var main = function () {
  var now = Date.now();
  var delta = now - then;
  
  render();
  
  then = now;
};

//Play!
reset();
var then = Date.now();
setInterval(main, 50); //function, milliseconds between execution - higher number is more responsive and also more CPU use. 