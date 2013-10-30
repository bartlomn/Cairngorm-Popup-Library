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
package com.adobe.cairngorm.popup.behavior
{
    import com.adobe.cairngorm.popup.PopUpBase;
    import com.adobe.cairngorm.popup.PopUpEvent;
    import flash.events.Event;

    import mx.core.IFlexDisplayObject;

    public class KeepCenteredBehavior extends PlayEffectsBehavior
    {
        private var popup:IFlexDisplayObject;

        private var base:PopUpBase;

        override public function apply(base:PopUpBase):void
        {
            super.apply(base);
            this.base = base;
            base.addEventListener(PopUpEvent.OPENED, onOpened);
        }

        private function onOpened(event:PopUpEvent):void
        {
            popup = event.popup;
            popup.addEventListener(Event.RESIZE, onResize);
            popup.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
            base.addEventListener(PopUpEvent.CLOSING, onClosing);
        }

        private function onResize(event:Event):void
        {
            popup.x = (popup.stage.width - popup.width) / 2;
            popup.y = (popup.stage.height - popup.height) / 2;
        }

        private function onClosing(event:Event):void
        {
            base.removeEventListener(PopUpEvent.CLOSING, onClosing);
            popup.removeEventListener(Event.RESIZE, onResize);
            if (popup.stage)
            {
                popup.stage.removeEventListener(Event.RESIZE, onResize);
            }
        }
    }
}