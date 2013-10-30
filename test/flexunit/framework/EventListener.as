/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package flexunit.framework
{
   import flash.events.Event;
   
   import mx.collections.ArrayCollection;
   import mx.collections.ListCollectionView;
   
   /**
    * Listens for expected events, keeping track of the expected events that
    * actually occur. A helper class designed specifically for the 
    * <code>EventfulTestCase</code>.
    */ 
   internal class EventListener
   {
      //-------------------------------
      //
      // properties
      //
      //-------------------------------

      private var _expectedEventTypes : ListCollectionView = new ArrayCollection();
      
      private var _actualEvents : ListCollectionView = new ArrayCollection();
      
      /**
       * Gets a comma-separated string listing the types of events that were
       * expected.
       */ 
      public function get expectedEventTypes() : String
      {
         var eventTypes : String = "";

         for ( var i: uint; i < _expectedEventTypes.length; i++ )
         {
            eventTypes += _expectedEventTypes[ i ] as String; 

            if ( i < _expectedEventTypes.length - 1 )
            {
               eventTypes += ',';
            } 
         }
         
         return eventTypes;
      }

      /**
       * Gets a comma-separated string listing the types of events that have 
       * been heard.
       */ 
      public function get actualEventTypes() : String
      {
         var eventTypes : String = "";

         for ( var i: uint; i < _actualEvents.length; i++ )
         {
            var event : Event = _actualEvents[ i ] as Event;
            
            eventTypes += event.type;
            
            if ( i < _actualEvents.length - 1 )
            {
               eventTypes += ',';
            } 
         }
         
         return eventTypes;
      }
      
      /**
       * Gets an array of all the events that have been heard.
       */ 
      public function get actualEvents() : Array
      {
         return _actualEvents.toArray();
      }
      
      /**
       * Gets the last event to have been heard.
       */ 
      public function get lastActualEvent() : Event
      {
         if ( _actualEvents.length == 0 )
         {
            return null;
         }
         
         return Event( _actualEvents.getItemAt( _actualEvents.length - 1 ) );
      }
      
      //-------------------------------
      //
      // constructor
      //
      //-------------------------------

      public function EventListener()
      {
         _actualEvents = new ArrayCollection();
         _expectedEventTypes = new ArrayCollection();   
      }
      
      //-------------------------------
      //
      // functions
      //
      //-------------------------------

      /**
       * Records an expected event. 
       * 
       * @param type 
       *    the type of event expected
       */ 
      public function expectEvent( type : String ) : void
      {
         _expectedEventTypes.addItem( type );
      }
      
      /**
       * Verifies that the expected events were heard, returning 
       * <code>true</code> if so or <code>false</code> otherwise.
       */ 
      public function verifyExpectedEventsOccurred() : Boolean
      {
         if ( _expectedEventTypes.length != _actualEvents.length )
         {
            return false;
         } 
         
         for ( var i : uint = 0; i < _actualEvents.length; i++ )
         {
            if ( _expectedEventTypes[ i ] != Event( _actualEvents[ i ] ).type )
            {
               return false;
            }
         }
         
         return true;
      }

      /**
       * Handles an event by recording that it actually occurred.
       */ 
      public function handleEvent( event : Event ) : void
      {
         _actualEvents.addItem( event );
      }
   }
}