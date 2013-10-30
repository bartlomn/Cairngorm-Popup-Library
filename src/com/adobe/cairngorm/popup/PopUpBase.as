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
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.core.Application;
    import mx.core.EventPriority;
    import mx.core.FlexGlobals;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModule;
    import mx.core.IFlexModuleFactory;
    import mx.core.IMXMLObject;
    import mx.events.CloseEvent;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.PopUpManager;

    //----------------------------------
    //  Events
    //----------------------------------

    /**
     * Dispatched after the popup has been created but just before it is added to
     * the display list by the <code>PopUpManager</code>.
     */
    [Event(name="opening", type="com.adobe.cairngorm.popup.PopUpEvent")]

    /**
     * Dispatched just after the popup has added to the display list by the
     * <code>PopUpManager</code>.
     */
    [Event(name="opened", type="com.adobe.cairngorm.popup.PopUpEvent")]

    /**
     * Dispatched just before the popup is removed from the display list by the
     * <code>PopUpManager</code>.
     */
    [Event(name="closing", type="com.adobe.cairngorm.popup.PopUpEvent")]

    /**
     * Dispatched just after the popup is removed from the display list by the
     * <code>PopUpManager</code>.
     */
    [Event(name="closed", type="com.adobe.cairngorm.popup.PopUpEvent")]

    /**
     * Base class for declarative popup management components. Concrete classes
     * must implement the <code>getPopUp()</code> method and may override the
     * <code>popUpClosed()</code> method.
     */
    public class PopUpBase extends EventDispatcher implements IMXMLObject
    {
        //------------------------------------------------------------------------
        //
        //  Private Variables 
        //
        //------------------------------------------------------------------------

        /** This display object child that is used for the actual popup view. */
        private var child:IFlexDisplayObject;

        /** Tracks the first time a popup is shown. */
        private var firstTime:Boolean = true;

        /** The number of behaviors that have currently suspended closure. */
        private var suspendedBehaviors:int = 0;

        //------------------------------------------------------------------------
        //
        //  Properties
        //
        //------------------------------------------------------------------------

        //-------------------------------
        //  parent
        //-------------------------------

        /**
         * DisplayObject to be used for determining which SystemManager's layers
         * to use and optionally the reference point for centering the new top
         * level window. It may not be the actual parent of the popup as all
         * popups are parented by the SystemManager.
         */

        [Bindable]
        public var parent:DisplayObject;

        //-------------------------------
        //  modal
        //-------------------------------

        /**
         * Define if the Popup contained in the PopUpWrapper is modal.
         * If <code>true</code>, the window is modal which means that
         * the user will not be able to interact with other popups until the
         * window is removed.
         */

        [Bindable]
        public var modal:Boolean;

        //-------------------------------
        //  childList
        //-------------------------------

        /**
         * The child list in which to add the popup contained in the PopUpWrapper.
         * One of <code>PopUpManagerChildList.APPLICATION</code>,
         * <code>PopUpManagerChildList.POPUP</code>,
         * or <code>PopUpManagerChildList.PARENT</code> (default).
         *
         * @see PopUpManagerChildList
         */

        [Bindable]
        public var childList:String;

        //-------------------------------
        //  center
        //-------------------------------

        /**
         * Determines whether or not the popup should be centered relative to its
         * <code>parent</code> when it is opened.
         */

        [Bindable]
        public var center:Boolean = true;

        //-------------------------------
        //  open
        //-------------------------------

        private var _open:Boolean = false;

        /**
         * Whether or not the popup is open. Setting this property to true
         * triggers the opening of the popup. Setting it to false will close the
         * popup. If the popup child view dispatches an CloseEvent.CLOSE event, the
         * popup will also be closed and this property set back to false.
         */
        public function set open(value:Boolean):void
        {
            if (_open == value)
                return;

            _open = value;

            if (suspendedBehaviors > 0)
            {
                suspendedBehaviors = 0;
                removePopUp();
            }

            if (_open)
            {
                openPopUp();
            }
            else
            {
                closePopUp();
            }

			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
        }

		[Bindable("propertyChange")]
        public function get open():Boolean
        {
            return _open;
        }

        //-------------------------------
        //  behaviors
        //-------------------------------

        /**
         * An array of IPopUpBehaviors to apply to the popup created by this
         * component.
         */

        [ArrayElementType("com.adobe.cairngorm.popup.IPopUpBehavior")]
        private var _behaviors:Array = [];

        public function set behaviors(value:Array):void
        {
            if (_behaviors == value)
                return;

            _behaviors = value;

            for each (var behavior:IPopUpBehavior in _behaviors)
            {
                behavior.apply(this);
            }
			
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE));
        }
		
		[Bindable("propertyChange")]
		public function get behaviors():Array
		{
			return _behaviors;
		}

        //-------------------------------		
        //  moduleFactory		
        //-------------------------------		
        /**
         * IFlexModuleFactory to apply style from.
         */
        [Bindable]

        public var moduleFactory:IFlexModuleFactory;

        //------------------------------------------------------------------------
        //
        //  Implementation : IMXMLObject
        //
        //------------------------------------------------------------------------

        /**
         * @private
         */
        public function initialized(document:Object, id:String):void
        {
            //nothing
        }

        //------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //------------------------------------------------------------------------

        /**
         * Get the IFlexDisplayObject that will be used as the popup child view.
         * This is called whenever the popup is opened, before any of the
         * PopUpEvent events are dispatched.
         */
        protected function getPopUp():IFlexDisplayObject
        {
            throw new Error("Abstract method call");
        }

        /**
         * Perform any logic that should take place just after the popup has been
         * closed and removed from the display list by the PopUpManager.
         */
        protected function popUpClosed():void
        {
        }

        //------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //------------------------------------------------------------------------

        private function openPopUp():void
        {
            if (!parent)
            {
                parent = getParent();
            }

            child = getPopUp();
			child.addEventListener(CloseEvent.CLOSE, onClose, false, EventPriority.DEFAULT_HANDLER, true);

            dispatchPopUpEvent(PopUpEvent.OPENING);

            addPopUp();

            if (center)
            {
                PopUpManager.centerPopUp(child);
            }

            dispatchPopUpEvent(PopUpEvent.OPENED);
        }

         private function addPopUp():void
        {
            if (moduleFactory == null)
            {
                if (parent && parent is IFlexModule)
                {
                    moduleFactory = IFlexModule(parent).moduleFactory;
                }
            }

            PopUpManager.addPopUp(child, parent, modal, childList, moduleFactory);
        }

        private function getParent():DisplayObject
        {
            return DisplayObject(FlexGlobals.topLevelApplication);
        }

        //-------------------------------
        //  Close Methods
        //-------------------------------
		
		private function onClose(event:Event):void
		{
			if (event.isDefaultPrevented()) return;
			
			if (child)
			{
				child.removeEventListener(CloseEvent.CLOSE, onClose);
			}
			open = false; 
		}		

        private function closePopUp():void
        {
            if (!child)
                return;

            dispatchPopUpEvent(PopUpEvent.CLOSING);

            if (suspendedBehaviors == 0)
            {
                removePopUp();
            }
        }

        private function removePopUp():void
        {
            if (!child)
                return;

            PopUpManager.removePopUp(child);
            dispatchPopUpEvent(PopUpEvent.CLOSED);
            popUpClosed();
            child.removeEventListener(CloseEvent.CLOSE, onClose);
            child = null;
        }

        private function suspendCallback():void
        {
            suspendedBehaviors++;
        }

        private function resumeCallback():void
        {
            if (suspendedBehaviors > 0)
            {
                suspendedBehaviors--;
            }

            if (suspendedBehaviors == 0)
            {
                removePopUp();
            }
        }

        //-------------------------------
        //  Dispatch Event Methods
        //-------------------------------

        private function dispatchPopUpEvent(type:String):void
        {
            dispatchEvent(new PopUpEvent(type, child, suspendCallback, resumeCallback));
        }
    }
}