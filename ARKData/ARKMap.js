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
bgImage.src = "http://gilgamech.com/ARKData/Images/TheCenter_Pencil.jpg";

// load clientClint
var clientClintReady = false;
var clientClintImage = new Image();
clientClintImage.onload = function () {
  clientClintReady = true;
};
clientClintImage.src = "http://gilgamech.com/images/clientClint.png";

// packet image
var packetReady = false;
var packetImage = new Image();
packetImage .onload = function () {
  packetReady = true;
};
packetImage .src = "http://gilgamech.com/images/packet.png";

// Game objects
var ARKMapJSON = "";
var TribeJSON = ""
var TribeO2 = "";

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
	loadARKMap();
};

// Load JSON
// https://laracasts.com/discuss/channels/general-discussion/load-json-file-from-javascript
function loadJSON(file, callback) {   

    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', file, true); // Replace 'my_data' with the path to your file
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
            callback(xobj.responseText);
          }
    };
    xobj.send(null);  
 }
 
// Load...stuff?
// https://laracasts.com/discuss/channels/general-discussion/load-json-file-from-javascript
function loadARKMap() {
    
    loadJSON("http://gilgamech.com/ARKData/ARKMap.json", function(response) {
  
        var actual_JSON = JSON.parse(response);
		ARKMapJSON = actual_JSON
    }); // end loadJSON
    
}

//https://stackoverflow.com/questions/14853779/adding-input-elements-dynamically-to-form
function addARKFields(type,id,placeholder,value,maxlength,size,min,max){
	var container = document.getElementById("container");
	// Create an <input> element, set its type and name attributes
	var input = document.createElement("input");
	input.type = type;
	input.id = id;
	input.placeholder = placeholder;
	input.value = value;
	input.maxlength = maxlength;
	input.size = size;
	input.min = min;
	input.max = max;
	container.appendChild(input);
}
	// Number of inputs to create
	// var number = document.getElementById("member").value;
	// Container <div> where dynamic content will be placed
	// Clear previous contents of the container
	//while (container.hasChildNodes()) {
	//	container.removeChild(container.lastChild);
	//}
	// for (i=0;i<number;i++){
		// Append a node with a random text
		// container.appendChild(document.createTextNode("Member " + (i)));
	// }

function loadTribes() {
    
    loadJSON("http://gilgamech.com/ARKData/tribe.json", function(response) {
  
        var actual_JSON = JSON.parse(response);
		TribeJSON = actual_JSON
    }); // end loadJSON
    
}

function updateTribeFields() {
	for (i = 0; i < ARKMapJSON.length; i++) { 
		// Set up X, Y and Tribe name.
		TribeX = (ARKMapJSON[i].Long * Math.round((canvas.width/100))* 10 ) / 10;
		TribeY = (ARKMapJSON[i].Lat * Math.round((canvas.height/100))* 10 ) / 10;
		TribeName = (ARKMapJSON[i].TribeName)
		Type = (ARKMapJSON[i].Type)
		Comments = (ARKMapJSON[i].Comments)

		// document.getElementById('TribeName').value=TribeName ; 
		//addARKFields(type,id,placeholder,value,maxlength,size);
		addARKFields("Text",("TribeName" + i),"Tribe name",ARKMapJSON[i].TribeName,32,24);
		addARKFields("Text",("BaseType" + i),"Base type",ARKMapJSON[i].Type,16,8);
		addARKFields("Number",("Lat" + i),"Lat",ARKMapJSON[i].Lat,4,4,0,100);
		addARKFields("Number",("Long" + i),"Long",ARKMapJSON[i].Long,4,4,0,100);
		addARKFields("Text",("LastSeenDate" + i),"Last Seen Date",ARKMapJSON[i].LastSeenDate,4,8);
		addARKFields("Text",("DestroyByDate" + i),"Destroy By Date",ARKMapJSON[i].DestroyDate,8,16);
		addARKFields("Number",("DestroyBy6Digit" + i),"6Digit","",6,6,999999);
		addARKFields("Text",("Comments" + i),"Comments (140 char limit)",ARKMapJSON[i].Comments,140,40);
		// Append a line break 
		container.appendChild(document.createElement("br"));
	}; 
	  
}

  //draw it all
var render = function () {
  if (bgReady) {
    ctx.drawImage(bgImage, 0, 0);
  }
    
  ctx.textBaseline = "top";
   ctx.font = "10px Helvetica";
	var CursorText = "Mouseover for tribe data."
	var CursorText2 = "Lat: " + (Math.round((mousePos.y*100/canvas.height)*10)/10) + " Long: " + (Math.round((mousePos.x*100/canvas.width)*10)/10);
	var CursorText3 = ""
	var CursorText4 = ""
	var mouseover = 0
	var TextWidthMax = 0
	var TextBoxHeight = 62
	
for (i = 0; i < ARKMapJSON.length; i++) { 
	// Set up X, Y and Tribe name.
	TribeX = (ARKMapJSON[i].Long * Math.round((canvas.width/100))* 10 ) / 10;
	TribeY = (ARKMapJSON[i].Lat * Math.round((canvas.height/100))* 10 ) / 10;
	TribeName = (ARKMapJSON[i].TribeName)
	Type = (ARKMapJSON[i].Type)
	Comments = (ARKMapJSON[i].Comments)
	
	// Draw up box behind name
	ctx.fillStyle="#aabdb7";
    ctx.font = "10px Helvetica";
	
	// Draw text
    ctx.fillStyle = "#000000";
	ctx.fillRect(TribeX,TribeY,5,5); 
	ctx.fillRect(TribeX,TribeY,(ctx.measureText(TribeName).width), (ctx.measureText(TribeName).height)); 
	ctx.textAlign = "left";
	ctx.fillText((ARKMapJSON[i].TribeName), TribeX, TribeY+5);


	//Is the mouse near a base?
	if (
		 TribeX > (mousePos.x  - 16) 
		 && TribeX < (mousePos.x + 6 )
		 && TribeY > (mousePos.y  - 16) 
		 && TribeY < (mousePos.y + 6 )  
	  ) {
		CursorText = TribeName + " - " + Type
		CursorText2 = "Lat: " + ARKMapJSON[i].Lat + " Long: " + ARKMapJSON[i].Long + " Last Seen: " + ARKMapJSON[i].LastSeenDate;
		CursorText3 = "Demolish allowed on: " + ARKMapJSON[i].DestroyDate;
		CursorText4 = Comments;
		mouseover = 1;
		} else {
		
	}
	
}; 
  
  
    ctx.font = "12px Helvetica";
	TextWidthMax = Math.max(ctx.measureText(CursorText2).width, Math.max(ctx.measureText(CursorText3).width, ctx.measureText(CursorText4).width));

	ctx.font = "22px Helvetica";
	ctx.fillStyle="#fcfae5";
	// TextWidthMax = ctx.measureText(CursorText).width
	//TextWidthMax = Math.max(Math.max(ctx.measureText(CursorText).width, ctx.measureText(CursorText2).width),0)
	TextWidthMax = Math.max(ctx.measureText(CursorText).width, TextWidthMax);
	

if ((mousePos.x + TextWidthMax) > canvas.width) {
  ctx.textAlign = "right";
	ctx.fillRect((mousePos.x-9-(TextWidthMax)), (mousePos.y+15), (TextWidthMax + 5),TextBoxHeight)
  } else {
	ctx.textAlign = "left";
	ctx.fillRect((mousePos.x-9), (mousePos.y+15), (TextWidthMax + 5),62)
};

if ((mousePos.y + TextBoxHeight) > canvas.height) {
	// ctx.fillRect((mousePos.x-9-(TextWidthMax)), (mousePos.y-47), (TextWidthMax + 5),62)
  } else {
	// ctx.fillRect((mousePos.x-9), (mousePos.y+15), (TextWidthMax + 5),62)
};
	//Draw mouse ARKMapJSON.
    ctx.fillStyle = "#222200";
    ctx.fillText(CursorText, (mousePos.x-6), (mousePos.y+16));
	
    ctx.font = "12px Helvetica";
    ctx.fillText(CursorText2, (mousePos.x-6), (mousePos.y+38));
    ctx.fillText(CursorText3, (mousePos.x-6), (mousePos.y+50));
    ctx.fillText(CursorText4, (mousePos.x-6), (mousePos.y+62));
  
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