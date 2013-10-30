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
    import com.adobe.cairngorm.popup.IPopUpBehavior;
    import com.adobe.cairngorm.popup.PopUpBase;
    import com.adobe.cairngorm.popup.PopUpEvent;

    import mx.core.UIComponent;
    import mx.effects.Effect;
    import mx.events.EffectEvent;
    import mx.events.FlexEvent;

    /**
     * Plays effects when a popup opens and closes. The effects need to be
     * specified with the <code>openEffect</code> and <code>closeEffect</code>
     * properties.
     */
    public class PlayEffectsBehavior implements IPopUpBehavior
    {
        //------------------------------------------------------------------------
        //
        //  Private Variables
        //
        //------------------------------------------------------------------------

        private var closingEvent:PopUpEvent;

        //------------------------------------------------------------------------
        //
        //  Public Properties
        //
        //------------------------------------------------------------------------

        /** The effect to play as the popup opens. */
        public var openEffect:Effect;

        /** The effect to play as the popup closes. */
        public var closeEffect:Effect;

        private var popup:PopUpBase;

        //------------------------------------------------------------------------
        //
        //  Implementation : IPopUpBehavior
        //
        //------------------------------------------------------------------------

        public function apply(base:PopUpBase):void
        {
            this.popup = base;

            base.addEventListener(PopUpEvent.OPENING, onOpening);
            base.addEventListener(PopUpEvent.CLOSING, onClosing);
        }

        //------------------------------------------------------------------------
        //
        //  Event Listeners
        //
        //------------------------------------------------------------------------

        private function onOpening(event:PopUpEvent):void
        {
            UIComponent(event.popup).callLater(handleStart, [ event ]);
        }

        private function handleStart(event:PopUpEvent):void
        {
            popup.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
            if (openEffect)
            {
                openEffect.play([ event.popup ]);
            }
        }

        private function onClosing(event:PopUpEvent):void
        {
            if (closeEffect)
            {
                closingEvent = event;
                closingEvent.suspendClosure();

                closeEffect.startDelay = 100;
                closeEffect.play([ event.popup ]);
                closeEffect.addEventListener(
                    EffectEvent.EFFECT_END,
                    onCloseEffectEnd);
            }
        }

        private function onCloseEffectEnd(event:EffectEvent):void
        {
            popup.dispatchEvent(new FlexEvent(FlexEvent.HIDE));

            closeEffect.removeEventListener(
                EffectEvent.EFFECT_END,
                onCloseEffectEnd);

            closingEvent.resumeClosure();
            closingEvent = null;
        }
    }
}