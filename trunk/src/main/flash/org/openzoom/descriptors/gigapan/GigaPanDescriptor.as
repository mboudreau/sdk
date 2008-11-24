////////////////////////////////////////////////////////////////////////////////
//
//  OpenZoom
//  Copyright (c) 2008, Daniel Gasienica <daniel@gasienica.ch>
//
//  OpenZoom is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  OpenZoom is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with OpenZoom. If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
package org.openzoom.descriptors.gigapan
{

import flash.utils.Dictionary;

import org.openzoom.descriptors.IMultiScaleImageDescriptor;
import org.openzoom.descriptors.IMultiScaleImageLevel;
import org.openzoom.descriptors.MultiScaleImageDescriptorBase;
import org.openzoom.descriptors.MultiScaleImageLevel;
import org.openzoom.utils.math.clamp;

/**
 * Descriptor for the GigaPan.org project panoramas.
 * <http://gigapan.org/>
 */
public class GigaPanDescriptor extends MultiScaleImageDescriptorBase
                               implements IMultiScaleImageDescriptor
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static const DEFAULT_BASE_LEVEL : uint = 8
    private static const DEFAULT_TILE_SIZE : uint = 256
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor.
     */
    public function GigaPanDescriptor( url : String = "http://share.gigapan.org/gigapans0/9539/tiles/",
                                       extension : String = ".jpg",
                                       width : uint = 125412,
                                       height : uint = 14148,
                                       numLevels : uint = 10 )
    {
        this.source = url
        this.extension = extension

        // needed for checking if a tile exists
        aspectRatio = width / height
        originalWidth = width
        originalHeight = height

        _numLevels = numLevels
        _width = _height = 1 << (DEFAULT_BASE_LEVEL + (numLevels - 1))
        
        _tileWidth = DEFAULT_TILE_SIZE
        _tileHeight = DEFAULT_TILE_SIZE
        
        _type = "image/jpeg"

        levels = computeLevels( DEFAULT_TILE_SIZE, this.numLevels )
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var aspectRatio : Number
    private var originalWidth : Number
    private var originalHeight : Number
    
    private var extension : String
    private var levels : Dictionary 

    //--------------------------------------------------------------------------
    //
    //  Methods: IMultiScaleImageDescriptor
    //
    //--------------------------------------------------------------------------
    
    override public function existsTile( level : int, column : uint, row : uint ) : Boolean
    {
    	var l : IMultiScaleImageLevel = getLevelAt( level )
    	if( aspectRatio > 1 )
    	{
            // all columns exist
            return (( row / l.numRows ) < ( 1 / aspectRatio ))	
    	}
    	else
    	{
    		// all rows exist
            return (( column / l.numColumns ) < ( aspectRatio ))	
    	}
    }

    public function getTileURL( level : int, column : uint, row : uint ) : String
    {
    	//http://www.gigapan.org/viewer/PanoramaViewer.swd?url=http://share.gigapan.org/gigapans0/9490/tiles/
    	//&suffix=.jpg&startHideControls=0&width=43000&height=11522&nlevels=9&cleft=0&ctop=0&cright=43000.0&cbottom=11522.0&startEnabled=1&notifyWhenLoaded=1
    	
    	var url : String = source
    	var name : String = "r"
    	var z : int = level
    	var bit : int = (1 << z) >> 1
    	var x : int = column
    	var y : int = row
    	
    	while( bit > 0 )
    	{
    		name += String(( x & bit ? 1 : 0 ) + ( y & bit ? 2 : 0 ))
    		bit = bit >> 1
    	}
    	
    	var i : int = 0
    	while( i < name.length - 3 )
    	{
    		url = url + ("/" + name.substr( i, 3 ))
    		i = i + 3
    	} 
    	
    	var tileURL : String = url + "/" + name + extension
        return tileURL
    }
    
    public function getLevelAt( index : int ) : IMultiScaleImageLevel
    {
        return IMultiScaleImageLevel( levels[ index ] )
    }
    
    
    public function getMinimumLevelForSize( width : Number,
                                            height : Number ) : IMultiScaleImageLevel
    {
        var index : int =
            clamp( Math.ceil( Math.log( Math.max( width, height )) / Math.LN2
                              - DEFAULT_BASE_LEVEL - 1 ), 0, numLevels - 1 )
        return IMultiScaleImageLevel( getLevelAt( index ) ).clone()
    }
    
    public function clone() : IMultiScaleImageDescriptor
    {
        return new GigaPanDescriptor( source, extension, originalWidth, originalHeight, numLevels )
    }

    //--------------------------------------------------------------------------
    //
    //  Methods: Debug
    //
    //--------------------------------------------------------------------------
    
    override public function toString() : String
    {
        return "[GigaPanDescriptor]" + "\n" + super.toString()
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Internal
    //
    //--------------------------------------------------------------------------
    
    private function computeLevels( tileSize : uint, numLevels : int ) : Dictionary
    {
        var levels : Dictionary = new Dictionary()

        var width : uint
        var height : uint

        for( var i : int = 0; i < numLevels; i++ )
        {
            width = 1 << ( DEFAULT_BASE_LEVEL + i )
            height = 1 << ( DEFAULT_BASE_LEVEL + i )
            levels[ i ] = new MultiScaleImageLevel( this, i, width, height,
                                                    Math.ceil( width / tileSize ),
                                                    Math.ceil( height / tileSize ))
        }
        
        return levels
    }
}

}