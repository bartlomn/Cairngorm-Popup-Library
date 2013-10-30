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
    import mx.core.IDeferredInstance;
    import mx.core.IFlexDisplayObject;
    import mx.core.ITransientDeferredInstance;

  /**
     * A component for opening and closing popups that uses an ITransientDeferredInstance
     * to create the popup child view. The popup child view can be declared in
     * MXML within a PopUpWrapper. It must implement IFlexDisplayObject.
     *
     * <br>The popup child view is instantiated and created only when the open
     * property is set to true for the first time. The popup instance will then
     * be kept and reused during the life time of the application if the reuse property is set to true.
     * When reuse is set to false, the popup instance will be destroyed each time the popup is closed and
     * therefore will create a new instance each time it opens.
     * By default the reuse property is set to false.
     *
     * When using Flex SDK 3, the PopUpWrapper uses an IDeferredInstance to create the popup child view.
     * The popup instance is created  only once and kept in memory during the life time of the application and will
     * reuse the same instance each time the popup is re-opened.
     * If you want to destroy the popup instance each time the popup is closed while using SDK 3.x
     * we recommend to use PopUpFactory
     */
    [DefaultProperty("popup")]
    public class PopUpWrapper extends PopUpBase
    {
        /**
         * Whether or not an instance of the popup child view should be reused
         * each time the popup is opened.
         */
		[Bindable]
        public var reuse:Boolean = false;

        //------------------------------------------------------------------------
        //
        //  Constructor
        //
        //------------------------------------------------------------------------

        public function PopUpWrapper()
        {
        }

        //------------------------------------------------------------------------
        //
        //  Properties
        //
        //------------------------------------------------------------------------

        /**
         * Class of object that is to be created for the popup. This is an
         * ITransientDeferredInstance therefore the object will be created on demand as
         * soon as the open propety become true.<br>
         *
         * The class must implement IFlexDisplayObject.
         *
         * @see ITransientDeferredInstance
         * @see #show
         */
        [InstanceType("mx.core.IFlexDisplayObject")]
        public var popup:ITransientDeferredInstance;

        //------------------------------------------------------------------------
        //
        //  Overrides : PopUpBase
        //
        //------------------------------------------------------------------------

        override protected function getPopUp():IFlexDisplayObject
        {
            if (!popup)
            {
                throw new Error("The popup property must be set.", -50);
            }

            return popup.getInstance() as IFlexDisplayObject;
        }

        override protected function popUpClosed():void
        {
            if (!reuse)
            {
                popup.reset();
            }
        }
    }
}