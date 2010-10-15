// forked from psyark's F-siteで紹介したエディタを無理やりWonderflに突っ込んでみた
package {
    import flash.display.*;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.*;
    import flash.system.*;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    import flash.utils.*;
    import net.hires.debug.Stats;
	import com.las3r.io.OutputStream;
	import com.las3r.runtime.RT;
	import jp.psyark.psycode.controls.ScrollBar;
	import jp.psyark.psycode.TextEditor;

    [SWF(width=800,height=600,backgroundColor=0xFFFFFF,frameRate=30)]
    public class Psymacs extends Sprite {
        [Embed(source="psymacs.lsr", mimeType="application/octet-stream")]
        protected const PsymacsLsr:Class;
        protected var las3rCode:String

        public static var instance:Psymacs;

		private function nop(..._):void {};
        public var keyDownHook:Function = nop;
		public var tabChangedHook:Function = nop;
		public var tabAddedHook:Function = nop;
		public var removeTabHook:Function = nop;
		public var textChangeHook:Function = nop;

        public var tabView:TabView;
        public var miniBuffer:MiniBuffer;
        public var stats:Stats = new Stats;
        public var rt:*;
        
        public function Psymacs() {
            instance = this;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            tabView = new TabView();
            addChild(tabView);
            
            //tabView.addItem(new TextEditor(), "無題");
            tabView.addEventListener(Event.OPEN, function (event:Event):void {
                    tabView.addItem(new TextEditor(), "無題");
                });

            miniBuffer = new MiniBuffer();
            addChild(miniBuffer);
            
            stage.addEventListener(Event.RESIZE, updateLayout);
            addChild(stats);
            stats.visible = false;
            updateLayout();

            las3rCode = ByteArray(new PsymacsLsr).toString();
            initRuntime();
        }

        private function initRuntime():void {
            var stdout:OutputStream = new OutputStream(function(str:String):void {
					miniBuffer.textField.appendText(str);
					callLater(updateLayout);
				});
            
            rt = new RT(stage, stdout, stdout);

            try {
                rt.loadStdLib(
                    function(val:*):void { 
                        miniBuffer.text = "Las3r runtime loaded.\n"; 
                        rt.evalStr(las3rCode, null, null, miniBuffer.textField.appendText);
                    },
                    function(i:int, total:int):void{ miniBuffer.text += "."; },
                    function(error:*):void{ miniBuffer.text = error; },
                    false/*true=from-source*/
                );
                rt.evalStr("(in-ns 'las3r.core)");
            }
            catch(e:*){
                miniBuffer.text = e;
            }
        }

        public function updateLayout(event:Event=null):void {
            tabView.width = miniBuffer.width = stage.stageWidth;
            miniBuffer.height = Math.min(
                miniBuffer.textField.textHeight + ScrollBar.BAR_THICKNESS * 3, 
                stage.stageHeight / 4);
            miniBuffer.y = tabView.height = stage.stageHeight - miniBuffer.height;
            stats.x = stage.stageWidth - stats.width;
        }

    }
}










/*
jp/psyark/utils/callLater.as
*/

function callLater(func:Function, args:Array=null, frame:int=1):void {
    Helper.callLater(func, args, frame);
}

import flash.display.MovieClip;
import flash.events.Event;

class Helper {
    private static var engine:MovieClip = new MovieClip();
    
    public static function callLater(func:Function, args:Array=null, frame:int=1):void {
        engine.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
                if (--frame <= 0) {
                    engine.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                    func.apply(null, args);
                }
            });
    }
}



/*
jp/psyark/psycode/controls/TabView.as
*/

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.utils.Dictionary;
import jp.psyark.psycode.controls.UIControl;
import jp.psyark.psycode.TextEditor;

class TabView extends UIControl {
    private var contentItemTable:Dictionary;
    public var items:Array;
    private var addButton:SimpleButton;
    
    private var _currentItem:TabViewItem;
    private function get currentItem():TabViewItem {
        return _currentItem;
    }
    private function set currentItem(value:TabViewItem):void {
        if (_currentItem != value) {
            if (_currentItem) {
                removeChild(_currentItem.content);
            }
            _currentItem = value;
            if (_currentItem) {
                addChild(_currentItem.content);
                updateView();
            }
            Psymacs.instance.tabChangedHook(_currentItem);
        }
    }
    
    public function get selectedIndex():int {
        return items.indexOf(currentItem);
    }
    
    public function TabView() {
        contentItemTable = new Dictionary();
        items = new Array();
        addButton = createAddButton();
        addButton.addEventListener(MouseEvent.CLICK, addButtonClickHandler);
        addChild(addButton);
    }
    
    private function createAddButton():SimpleButton {
        var u:Shape = new Shape();
        var o:Shape = new Shape();
        
        o.graphics.beginFill(0x666666);
        o.graphics.drawRoundRect(0, 0, 18, 18, 8);
        o.graphics.beginFill(0xFFFFFF);
        o.graphics.drawRoundRect(1, 1, 16, 16, 6);
        for each (var shape:Shape in [u, o]) {
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(7, 4, 4, 10);
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(4, 7, 10, 4);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(8, 5, 2, 8);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(5, 8, 8, 2);
        }
        
        var btn:SimpleButton = new SimpleButton();
        btn.upState = u;
        btn.overState = o;
        btn.downState = o;
        btn.hitTestState = o;
        return btn;
    }
    
    public function addItem(content:DisplayObject, title:String):void {
        var item:TabViewItem = new TabViewItem(content, title);
        item.addEventListener(Event.CLOSE, itemCloseHandler);
        item.addEventListener(MouseEvent.CLICK, itemClickHandler);
        items.push(item);
        addChild(item);
        contentItemTable[content] = item;
        currentItem = item;
        updateView();
		Psymacs.instance.tabAddedHook(item);
    }
    
    public function addItemWithText(content:String, title:String):void {
        var editor:TextEditor = new TextEditor;

        editor.trackChanges = false;
        editor.textField.text = content;
        editor.prevText = content;
        editor.trackChanges = true;
        addItem(editor, title);
    }

    public function setTitle(content:DisplayObject, title:String):void {
        TabViewItem(contentItemTable[content]).title = title;
        updateView();
    }
    
    public function removeItem(content:DisplayObject):void {
        var item:TabViewItem = contentItemTable[content];
        items.splice(items.indexOf(item), 1);
        removeChild(item);
		Psymacs.instance.removeTabHook(item);
        delete contentItemTable[content];
        if (currentItem == item) {
            currentItem = items[0];
        }
        updateView();
    }
    
    public function get count():int {
        return items.length;
    }
    
    public function getItemAt(index:int):DisplayObject {
        return TabViewItem(items[index]).content;
    }
    
    private function itemClickHandler(event:MouseEvent):void {
        currentItem = TabViewItem(event.currentTarget);
    }
    
    private function itemCloseHandler(event:Event):void {
        removeItem(TabViewItem(event.currentTarget).content);
    }
    
    private function addButtonClickHandler(event:MouseEvent):void {
        dispatchEvent(new Event(Event.OPEN));
    }
    
    public function updateView():void {
        graphics.clear();
        graphics.beginFill(0x999999);
        graphics.drawRoundRect(0, 0, width, height, 8);
        graphics.beginFill(0xEEEEEE);
        graphics.drawRoundRect(1, 1, width - 2, height - 2, 6);
        graphics.beginFill(0x999999);
        graphics.drawRect(0, 22, width, height - 22);
        graphics.beginFill(0xC1CFDD);
        graphics.drawRect(1, 23, width - 2, height - 24);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(4, 26, width - 8, height - 30);
        
        var left:Number = 1;
        for each (var item:TabViewItem in items) {
            item.x = left;
            item.y = 1;
            left += item.width;
        }
        addButton.x = left + 3;
        addButton.y = 2;
        
        if (currentItem) {
            var mtx:Matrix = new Matrix();
            mtx.createGradientBox(10, 20, Math.PI / 2);
            graphics.beginGradientFill(GradientType.LINEAR, [0xD3DFEE, 0xC1CFDD], [1, 1], [0x00, 0xFF], mtx);
            graphics.drawRect(currentItem.x, currentItem.y, currentItem.width, currentItem.height);
            
            currentItem.content.x = 4;
            currentItem.content.y = 26;
            if (currentItem.content is UIControl) {
                UIControl(currentItem.content).setSize(width - 8, height - 30);
            }
        }
    }
    
    protected override function updateSize():void {
        super.updateSize();
        updateView();
    }
}

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.events.Event;  
import flash.text.TextFieldType;

class TabViewItem extends Sprite {
    private var label:TextField;
    private var closeButton:SimpleButton;
    public var content:DisplayObject;
    
    public function get title():String {
        return label.text;
    }
    public function set title(value:String):void {
        label.text = value;
        updateView();
    }
    
    public function TabViewItem(content:DisplayObject, title:String):void {
        var fmt:TextFormat = new TextFormat("_sans");
        fmt.leftMargin = 4;
        fmt.rightMargin = 4;
        
        label = new TextField();
        label.selectable = true;
        label.type = TextFieldType.INPUT;
        label.defaultTextFormat = fmt;
        label.addEventListener(Event.CHANGE, 
            function(e:Event):void { 
                updateView();
                Psymacs.instance.tabView.updateView();
            });
        addChild(label);
        
        closeButton = createCloseButton();
        closeButton.doubleClickEnabled = true;
        closeButton.addEventListener(MouseEvent.DOUBLE_CLICK, closeButtonClickHandler);
        addChild(closeButton);
        
        this.title = title;
        this.content = content;
    }
    
    private function updateView():void {
        label.width = Math.max(60, Math.min(140, label.textWidth + 30));
        label.height = label.textHeight + 4;
        label.y = (20 - label.height) / 2;
        graphics.clear();
        graphics.lineStyle(-1, 0x999999);
        graphics.moveTo(label.width, 0);
        graphics.lineTo(label.width, 22);
        
        closeButton.rotation = 45;
        closeButton.x = label.width - 11;
        closeButton.y = 11;
    }
    
    private function createCloseButton():SimpleButton {
        var u:Shape = new Shape();
        var o:Shape = new Shape();
        
        //o.graphics.beginFill(0xEEEEEE);
        o.graphics.drawCircle(0, 0, 10);
        for each (var shape:Shape in [u, o]) {
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(-2, -6, 4, 12);
            shape.graphics.beginFill(0x666666);
            shape.graphics.drawRect(-6, -2, 12, 4);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(-1, -5, 2, 10);
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(-5, -1, 10, 2);
        }
        
        var btn:SimpleButton = new SimpleButton();
        btn.upState = u;
        btn.overState = o;
        btn.downState = u;
        btn.hitTestState = o;
        return btn;
    }
    
    private function closeButtonClickHandler(event:MouseEvent):void {
        dispatchEvent(new Event(Event.CLOSE));
        event.stopPropagation();
    }
}

import jp.psyark.psycode.core.TextEditUI;

class MiniBuffer extends TextEditUI {
    public function MiniBuffer() {
        linumField.visible = false;
        textField.type = "dynamic";
        textField.wordWrap = true;
    }

    protected override function updateSize():void {
        textField.y = linumField.y = scrollBarV.y = scrollBarH.height;
        linumField.height = height - scrollBarH.height;
        textField.x = scrollBarV.width;
        textField.width = width - scrollBarV.width * 2;
        textField.height = height - scrollBarH.height * 2;
        scrollBarV.x = width - scrollBarV.width;
        scrollBarV.height = height - scrollBarH.height * 2;
        scrollBarH.x = scrollBarV.width;
        scrollBarH.y = height - scrollBarH.height;
        scrollBarH.width = width - scrollBarV.width * 2;
        graphics.clear();
        graphics.beginFill(0xEEEEEE);
        graphics.drawRect(0, 0, width, height);
    }
}
