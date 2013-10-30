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
package com.adobe.cairngorm.popup
{
    import flash.events.Event;

    import mx.core.IFlexDisplayObject;

    public class PopUpEvent extends Event
    {
        //------------------------------------------------------------------------
        //
        //  Constants
        //
        //------------------------------------------------------------------------

        public static const OPENING:String = "opening";

        public static const OPENED:String = "opened";

        public static const CLOSING:String = "closing";

        public static const CLOSED:String = "closed";

        //------------------------------------------------------------------------
        //
        //  Private Variables
        //
        //------------------------------------------------------------------------

        private var suspendCallback:Function;

        private var resumeCallback:Function;

        //------------------------------------------------------------------------
        //
        //  Constructor
        //
        //------------------------------------------------------------------------

        public function PopUpEvent(
            type:String,
            popup:IFlexDisplayObject,
            suspendCallback:Function,
            resumeCallback:Function)
        {
            super(type);

            _popup = popup;
            this.suspendCallback = suspendCallback;
            this.resumeCallback = resumeCallback;
        }

        //------------------------------------------------------------------------
        //
        //  Properties
        //
        //------------------------------------------------------------------------

        //-------------------------------
        //  popup
        //-------------------------------

        private var _popup:IFlexDisplayObject;

        public function get popup():IFlexDisplayObject
        {
            return _popup;
        }

        //------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //------------------------------------------------------------------------

        public function suspendClosure():void
        {
            if (suspendCallback != null)
            {
                suspendCallback();
            }
        }

        public function resumeClosure():void
        {
            if (resumeCallback != null)
            {
                resumeCallback();
            }
        }

        //------------------------------------------------------------------------
        //
        //  Overrides : Event
        //
        //------------------------------------------------------------------------

        override public function clone():Event
        {
            return new PopUpEvent(type, _popup, suspendCallback, resumeCallback);
        }
    }
}