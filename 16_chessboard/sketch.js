// let boardSize = 8;
const boardSizeSlider = document.getElementById("boardSizeSlider");
// let tileSize = 600/boardSize;
let weight = 5;

let off = 20*Math.PI/180;
// let r = tileSize/5;
let showTri = true;
let showBranches = true;
let showVertex = true;
let showEnd = false;

let sX = 0;
let sY = 0;
let eX = boardSizeSlider.value-1;
let eY = boardSizeSlider.value-1;

let board = []
let calculated = false
let maxLayer = 1

let cnv = null;

boardSizeSlider.oninput = function() {
	randomize()
}

function isValid(nX,nY,boardSize){
	if (nX < 0 || nX >= boardSize){ return false; }
	if (nY < 0 || nY >= boardSize){ return false; }
	if (board[nX][nY].visited != 0) { return false; }
	return true;
}

function toCoords(x,y){
	return {
		x: x,
		y: y
	}
}

function findNeighbours(x,y,boardSize){
	let list = []
	if (isValid(x+2,y+1,boardSize)) {list.push(toCoords(x+2,y+1))}
	if (isValid(x-2,y+1,boardSize)) {list.push(toCoords(x-2,y+1))}
	if (isValid(x+2,y-1,boardSize)) {list.push(toCoords(x+2,y-1))}
	if (isValid(x-2,y-1,boardSize)) {list.push(toCoords(x-2,y-1))}
	if (isValid(x+1,y+2,boardSize)) {list.push(toCoords(x+1,y+2))}
	if (isValid(x-1,y+2,boardSize)) {list.push(toCoords(x-1,y+2))}
	if (isValid(x+1,y-2,boardSize)) {list.push(toCoords(x+1,y-2))}
	if (isValid(x-1,y-2,boardSize)) {list.push(toCoords(x-1,y-2))}
	return list
}

function setup() {
	// cz.parent('sketch-holder');
	
	let boardSize = boardSizeSlider.value

	let dim = min(windowWidth,windowHeight)
	cnv = createCanvas(dim,dim)
	cnv.parent('sketch-holder')
	cnv.mouseClicked(randomize)
	
	// var x = (windowWidth - width)/2;
	// var y = (windowHeight - height) / 2;
	// cnv.position(x, y);
	

    setFrameRate(30)
	background(0,0,0)
	
	let tileSize = (0.9*dim)/boardSize

    translate(width/2,height/2)
    translate(-(boardSize*tileSize)/2,-(boardSize*tileSize)/2)
	// rect(0,0,tileSize*boardSize,tileSize*boardSize);
	
	for (let i = 0; i < boardSize; i++){
		for (let j = 0; j < boardSize; j++){
			let fillNo = ((i+j) % 2 == 0) ? 50 : 255
			fill(fillNo,fillNo,fillNo)
			rect(j*tileSize,i*tileSize,tileSize,tileSize)
		}
	}

	if (sX == null) {
		return
	}

	if (!calculated){
		board = []
		for (let i = 0; i < boardSize; i++){
			row = []
			for (let j = 0; j < boardSize; j++){
				let cell = {
					seen: false,
					visited: false,
					prev: null,
					layer: 0
				}
				row.push(cell)
			}
			board.push(row)
		}
	// }
	
	// translate(tileSize/2,tileSize/2);

	// if (!calculated){
		let curr = null
		let queue = []
		queue.push(toCoords(sX,sY))
		while(queue.length != 0){
			curr = queue.shift()
			// console.log(curr,board[curr.x][curr.y])
			if (board[curr.x][curr.y].visited) { continue }
			board[curr.x][curr.y].visited = true
			let neighbours = findNeighbours(curr.x,curr.y,boardSize)
			// console.log(curr.x,curr.y,neighbours)
			for (let n of neighbours){
				if (!board[n.x][n.y].prev) { board[n.x][n.y].prev = curr }
				if (!board[n.x][n.y].seen) { queue.push(n) }
				board[n.x][n.y].seen = true
				let newLayer = board[curr.x][curr.y].layer + 1
				board[n.x][n.y].layer = newLayer
				if (newLayer > maxLayer){
					maxLayer = newLayer
				}
			}
		}

		calculated = true
	}

	if (calculated){
		translate(tileSize/2,tileSize/2);
	}

	strokeWeight(weight)
	// stroke(255,0,0)
	// fill(255,0,0)
	for (let i = 0; i < boardSize; i++){
		for (let j = 0; j < boardSize; j++){
			if (showVertex){
				fill(0,(board[i][j].layer-1)*255/maxLayer,255-(board[i][j].layer-1)*255/maxLayer);
				ellipse(i*tileSize,j*tileSize,tileSize/5,tileSize/5);
			}
			if (board[i][j].prev){
				stroke(0,board[i][j].layer*255/maxLayer,255-board[i][j].layer*255/maxLayer);
				line(i*tileSize,j*tileSize,board[i][j].prev.x*tileSize,board[i][j].prev.y*tileSize);
			}
		}
	}

	if (eX != -1 && eY != -1){
		stroke(255,0,0)
		curr = toCoords(eX,eY)
		// console.log(curr.x,curr.y,board[curr.x][curr.y])
		while (board[curr.x][curr.y].prev){
			ellipse(curr.x*tileSize,curr.y*tileSize,tileSize/10,tileSize/10);
			stroke(board[curr.x][curr.y].layer*155/board[eX][eY].layer + 100,0,0);
			x2 = curr.x*tileSize;
			y2 = curr.y*tileSize;
			x1 = board[curr.x][curr.y].prev.x*tileSize;
			y1 = board[curr.x][curr.y].prev.y*tileSize;
			line(x2,y2,x1,y1);

			if (showTri){
				let m = -1.0*((y2-y1)/(x2-x1));
				let a = Math.atan(m);
				//print(" gradient:",m);
				//print(" angle:",degrees(a));
				// print("\n");
				fill(board[curr.x][curr.y].layer*155/board[eX][eY].layer + 100,0,0);
				if (x2 > x1){ a += PI; }
				let r = tileSize/5
				triangle(x2,y2,x2+r*Math.cos(a+off),y2-r*Math.sin(a+off),x2+r*Math.cos(a-off),y2-r*Math.sin(a-off));
			}

			curr = board[curr.x][curr.y].prev
		}

	}

	// for (let i = 0; i < boardSize; i++){
	// 	for (let j = 0; j < boardSize; j++){
	// 		console.log(i,j,board[i][j].prev)
	// 	}
	// }
}


function randomize() {
	// console.log(mouseX,mouseY)
	let boardSize = boardSizeSlider.value
	eX = Math.round(Math.random()*boardSize)
	eY = Math.round(Math.random()*boardSize)
	sX = Math.round(Math.random()*boardSize)
	sY = Math.round(Math.random()*boardSize)
	while (sX == eX && sY == eY){
		eX = Math.round(Math.random()*boardSize)
		eY = Math.round(Math.random()*boardSize)
		sX = Math.round(Math.random()*boardSize)
		sY = Math.round(Math.random()*boardSize)
	}
	if (sX == boardSize) { sX--}
	if (sY == boardSize) { sY--}
	if (eX == boardSize) { eX--}
	if (eY == boardSize) { eY--}
	calculated = false
	setup()
}




function windowResized() {
	setup()
}