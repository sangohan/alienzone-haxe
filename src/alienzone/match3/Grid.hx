/**
 *--------------------------------------------------------------------+
 * Grid.hx
 *--------------------------------------------------------------------+
 * Copyright DarkOverlordOfData (c) 2014-2015
 *--------------------------------------------------------------------+
 *
 * This file is a part of Alien Zone
 *
 * Alien Zone is free software; you can copy, modify, and distribute
 * it under the terms of the GPLv3 License
 *
 *--------------------------------------------------------------------+
 *
 * 
 * @see https://github.com/hugeen/jmatch3
 */
package alienzone.match3;

class Grid {

    public var width:Int;
    public var height:Int;
    public var gravity:String;
    public var pieces:Array<Array<Piece>>;

    public static var directions = [
        "up"    =>  new Point(0, -1),
        "down"  =>  new Point(0, 1),
        "right" =>  new Point(1, 0),
        "left"  =>  new Point(-1, 0)
    ];
    
    public static var emptyObject:MatchObject = new MatchObject();

    /**
     * options:
     * - width (default 10)
     * - height (default 10)
     * - gravity (default false): "up", "right", "down", "left", or NONE
     */
    public function new(width:Int=10, height:Int=10, gravity:String='NONE') {

        this.gravity = gravity;
        this.height = height;
        this.width = width;
        pieces = [for (x in 0...width) [for (y in 0...height) new Piece(this, x, y)]];

    }

    /**
     *  Get last empty piece from an Array of pieces
     */
    public static function getLastEmptyPiece(pieces:Array<Piece>):Piece {
        var lastEmpty:Piece = null;
        for (piece in pieces) {
            if (piece.object.type == emptyObject.type) {
                lastEmpty = piece;
            }
        }
        return lastEmpty;
    }


    /**
     * Return if given coordinates are in the grid
     */
    public function coordsInWorld(point:Point):Bool {
        return (point.x >= 0 && point.y >= 0 && point.x < width && point.y < height);
    }

    // Return the piece from given coordinates
    public function getPiece(point:Point):Piece {
        if (coordsInWorld(point)) {
            return pieces[point.x][point.y];
        }
        else {
            return null;
        }
    }

    /**
     * Return the piece neighbour of another piece from a given direction
     */
    public function neighbourOf(piece:Piece, direction:Point):Piece {
        return getPiece(piece.relativeCoordinates(direction, 1));
    }

    /**
     * Return a Hash of pieces by direction
     */
    public function neighboursOf(piece:Piece):Map<String,Piece> {
        var result:Map<String,Piece> = new Map();
        
        for (directionName in ['up', 'down', 'right', 'left']) {
            var direction:Point = directions[directionName];
            result.set(directionName, neighbourOf(piece, direction));
        }
        return result;        
    }

    /**
     * Execute a callback for each current match
     */
    public function forEachMatch(callback):Void {
        var matches:Array<Array<Piece>> = getMatches();
        for (match in matches) {
            callback(match, match[0].object.type);
        }
    }

    /**
     * Return an array of matches or false
     */
    public function getMatches():Array<Array<Piece>> {
        var checked:Array<Piece> = [];
        var matches:Array<Array<Piece>> = [];

        for (pieces in this.pieces) {
            for (piece in pieces) {
                if (checked.indexOf(piece) == -1) {
                    var match:Array<Piece> = piece.deepMatchingNeighbours();
                    for (m in match) {
                        checked.push(m);
                    }
                    if (match.length >= 3) {
                        if (piece.object.type != emptyObject.type) {
                            matches.push(match);
                        }
                    }
                }
            }
        }
        return matches;
    }

    /**
     * Return an Array of pieces
     */
    public function getRow(row:Int, reverse:Bool):Array<Piece> {
        var pieces:Array<Piece> = [];
        
        for (piece in this.pieces) {
            pieces.push(piece[row]);
        }
        if (reverse) {
            pieces.reverse();
        }
        return pieces;
    }

    /**
     * Return an Array of pieces
     */
    public function getColumn(column:Int, reverse:Bool):Array<Piece> {
        var pieces:Array<Piece> = [];

        for (i in 0...this.pieces[column].length) {
            pieces.push(this.pieces[column][i]);
        }
        if (reverse) {
            pieces.reverse();
        }
        return pieces;
    }

    /**
     * Destroy all matches and update the grid
     */
    public function clearMatches():Bool {
        var matches:Array<Array<Piece>> = getMatches();
        
        if (matches.length == 0) {
            return false;
        }
        for (pieces in matches) {
            for (p in pieces) {
                p.clear();
            }
        }
        return true;
    }

    /**
     * Swap 2 pieces object
     */
    public function swapPieces(piece1:Piece, piece2:Piece):Void {
        var tmp1 = piece1.object;
        var tmp2 = piece2.object;
        piece1.object = tmp2;
        piece2.object = tmp1;
    }

    /**
     * Return an Array of falling pieces
     */
    public function applyGravity():Array<Piece> {
        var fallingPieces:Array<Piece> = [];
        var fallingPiecesWithoutEmpty:Array<Piece> = [];
        if (gravity == 'up' || gravity == 'down' || gravity == 'left' || gravity == 'right') {

            var direction:Point = directions[gravity];
            var horizontal:Bool = direction.x != 0;
            var reverse:Bool = horizontal ? direction.x == 1 : direction.y == 1;
            var limit:Int = (horizontal) ? height : width;
            var chunk:Array<Piece>;
        
            for (i in 0...limit) {

                chunk = horizontal ? getRow(i, reverse) : getColumn(i, reverse);
                
                function applyGravity(grid:Grid):Void {
                
                    var swaps:Int = 0;
                    for (piece in chunk) {
                    
                        var neighbour:Piece = piece.neighbour(direction);

                        if (neighbour != null) {
                            if (piece.object.type != emptyObject.type && neighbour.object.type == emptyObject.type) {
                                grid.swapPieces(piece, neighbour);
                                if (fallingPieces.indexOf(neighbour) == -1) {
                                    fallingPieces.push(neighbour);
                                }
                                swaps++;
                            }
                        }
                    }
                    if (swaps>0) {
                        applyGravity(grid);
                    }
                }
                applyGravity(this);
            }
            for (piece in fallingPieces) {
                if (piece.object.type != emptyObject.type) {
                    fallingPiecesWithoutEmpty.push(piece);
                }
            }
        
        }
        return fallingPiecesWithoutEmpty;
    }
}