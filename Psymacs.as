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
jp/psyark/psycode/core/history/HistoryEntry.as
*/

class HistoryEntry {
    public var index:int;
    public var oldText:String;
    public var newText:String;

    public function HistoryEntry(index:int=0, oldText:String="", newText:String="") {
        this.index   = index;
        this.oldText = oldText;
        this.newText = newText;
    }
}



/*
jp/psyark/utils/StringComparator.as
*/

/**
* 文字列の左右一致を数える
*/
class StringComparator {
    /**
    * @private
    */
    internal static function test():void {
        var sc:StringComparator = new StringComparator();
        var test:Function = function (a:String, b:String, l:int, r:int):void {
            sc.compare(a, b);
            if (sc.commonPrefixLength != l || sc.commonSuffixLength != r) {
                throw new Error();
            }
        };
        test("Hello World", "Hello World", 11, 0);
        test("Hello World", "Hello! World", 5, 6);
        test("Hello World", "HelPIYOrld", 3, 3);
        test("a", "aB", 1, 0);
        test("aBC", "aBCD", 3, 0);
        test("Ba", "a", 0, 1);
        test("aBC", "DaBC", 0, 3);
        test("aXbXc", "aXc", 2, 1);
        test("aaaXccc", "aaaXbbbXccc", 4, 3);
    }

    /**
    * 左側の共通文字列長
    */
    public var commonPrefixLength:int;

    /**
    * 右側の共通文字列長
    */
    public var commonSuffixLength:int;

    /**
    * 2つの文字列を比較し、commonPrefixLengthとcommonSuffixLengthをセットする
    * 
    * @param str1 比較する文字列の一方
    * @param str2 比較する文字列の他方
    */
    public function compare(str1:String, str2:String):void {
        var minLength:int = Math.min(str1.length, str2.length);
        var step:int, l:int, r:int;
        
        step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
        for (l=0; l<minLength; ) {
            if (str1.substr(0, l + step) != str2.substr(0, l + step)) {
                if (step == 1) { break; }
                step >>= 1;
            } else {
                l += step;
            }
        }
        l = Math.min(l, minLength);
        
        minLength -= l;
        
        step = Math.pow(2, Math.floor(Math.log(minLength) / Math.log(2)));
        for (r=0; r<minLength; ) {
            if (str1.substr(-r - step) != str2.substr(-r - step)) {
                if (step == 1) { break; }
                step >>= 1;
            } else {
                r += step;
            }
        }
        r = Math.min(r, minLength);
        
        commonPrefixLength = l;
        commonSuffixLength = r;
    }
}



/*
jp/psyark/psycode/core/psycode_internal.as
*/

namespace psycode_internal = "http://psyark.jp/ns/psycode";



/*
jp/psyark/utils/convertNewlines.as
*/

function convertNewlines(str:String, newline:String="\n"):String {
    return str.replace(/\r\n|\r|\n/g, newline);
}



/*
jp/psyark/psycode/controls/TextScrollBar.as
*/

import flash.events.Event;
import flash.text.TextField;
import jp.psyark.psycode.controls.ScrollBar;

class TextScrollBar extends ScrollBar {
    private var target:TextField;
    
    public function TextScrollBar(target:TextField, direction:String="vertical") {
        this.target = target;
        super(direction);
        
        if (direction == VERTICAL) {
            minValue = 1;
            value = 1;
        }
        
        addEventListener(Event.CHANGE, changeHandler);
        target.addEventListener(Event.CHANGE, targetChangeHandler);
        target.addEventListener(Event.SCROLL, targetScrollHandler);
        
        targetChangeHandler(null);
        targetScrollHandler(null);
    }
    
    private function changeHandler(event:Event):void {
        if (direction == VERTICAL) {
            target.scrollV = Math.round(value);
        } else {
            target.scrollH = Math.round(value);
        }
    }
    
    private function targetChangeHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            maxValue = target.maxScrollV;
            viewSize = target.bottomScrollV - target.scrollV;
        } else {
            maxValue = target.maxScrollH;
            viewSize = target.width;
        }
    }
    
    private function targetScrollHandler(event:Event):void {
        correctTextFieldScrollPosition(target);
        if (direction == VERTICAL) {
            value = target.scrollV;
        } else {
            value = target.scrollH;
        }
    }
    
    protected override function updateSize():void {
        super.updateSize();
        targetChangeHandler(null);
    }
    
    
    /**
    * 時折不正確な値を返すTextField#scrollVが、正しい値を返すようにする
    */
    protected static function correctTextFieldScrollPosition(target:TextField):void {
        // textWidthかtextHeightにアクセスすればOK
        target.textWidth;
        target.textHeight;
    }
}



/*
jp/psyark/psycode/core/TextEditUI.as
*/

import flash.events.Event;
import flash.events.FocusEvent;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import jp.psyark.psycode.core.linenumber.LineNumberView;
import jp.psyark.psycode.controls.UIControl;

/**
* @private
* TextEditAreaクラスは、テキストフィールド・行番号・スクロールバーなど
* テキスト編集UIの基本的な機能を提供し、それらの実装を隠蔽します。
*/
class TextEditUI extends UIControl {
    protected var linumField:LineNumberView;
    protected var scrollBarV:TextScrollBar;
    protected var scrollBarH:TextScrollBar;
    public var textField:TextField;
    
    private var TAB_STOP_RATIO:Number = 2.42;
    private var fileRef:FileReference;
    
    
    /**
    * TextEditUIクラスのインスタンスを初期化します。
    */
    public function TextEditUI() {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(13 * TAB_STOP_RATIO * i);
        }
        var fmt:TextFormat = new TextFormat("Courier New", 13, 0x000000);
        fmt.tabStops = tabStops;
        fmt.leading = 1;
        
        textField = new TextField();
        textField.background = true;
        textField.backgroundColor = 0xFFFFFF;
        textField.multiline = true;
        textField.type = TextFieldType.INPUT;
        textField.defaultTextFormat = fmt;
        textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, function (event:FocusEvent):void {
                event.preventDefault();
            });
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        
        linumField = new LineNumberView(textField);
        linumField.setTextFormat(fmt);
        linumField.addEventListener(Event.RESIZE, linumResizeHandler);
        
        scrollBarV = new TextScrollBar(textField);
        scrollBarH = new TextScrollBar(textField, ScrollBar.HORIZONTAL);
        
        addChild(textField);
        addChild(linumField);
        addChild(scrollBarV);
        addChild(scrollBarH);
        
        updateSize();
        
        textField.addEventListener(Event.SCROLL, textFieldScrollHandler);
    }
    
    public function open():void {
        fileRef = new FileReference();
        fileRef.addEventListener(Event.SELECT, function (event:Event):void {
                fileRef.load();
            });
        fileRef.addEventListener(Event.COMPLETE, function (event:Event):void {
                text = convertNewlines(String(fileRef.data));
            });
        fileRef.browse();
    }
    
    public function save():void {
        var localName:String; // TODO: = CodeUtil.getDefinitionLocalName(text);
        localName ||= "untitled";
        fileRef = new FileReference();
        fileRef.save(text, localName + ".lsr");
    }
    
    public function setFontSize(fontSize:Number):void {
        var tabStops:Array = [];
        for (var i:int=1; i<20; i++) {
            tabStops.push(i * fontSize * 2.42);
        }
        
        var fmt:TextFormat = textField.defaultTextFormat;
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.defaultTextFormat = fmt;
        
        fmt.align = TextFormatAlign.RIGHT;
        fmt.color = 0x666666;
        linumField.setTextFormat(fmt);
        
        fmt = new TextFormat();
        fmt.size = fontSize;
        fmt.tabStops = tabStops;
        textField.setTextFormat(fmt);
        
        dispatchChangeEvent();
    }
    
    
    private function textFieldScrollHandler(event:Event):void {
        dispatchEvent(event);
    }
    
    private function linumResizeHandler(event:Event):void {
        updateSize();
    }
    
    
    /**
    * テキストフィールドへのアクセスを提供します
    */
    public function get text():String {
        return textField.text;
    }
    public function set text(value:String):void {
        textField.text = value;
        dispatchChangeEvent();
    }
    public function get selectionBeginIndex():int {
        return textField.selectionBeginIndex;
    }
    public function get selectionEndIndex():int {
        return textField.selectionEndIndex;
    }
    public function setSelection(beginIndex:int, endIndex:int):void {
        textField.setSelection(beginIndex, endIndex);
    }
    public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
        textField.replaceText(beginIndex, endIndex, convertNewlines(newText));
    }
    public function replaceSelectedText(newText:String):void {
        textField.replaceSelectedText(newText);
    }
    psycode_internal function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void {
        textField.setTextFormat(format, beginIndex, endIndex);
    }
    psycode_internal function resetFocus():void {
        if (stage.focus) {
            throw 1;
        }
        stage.focus = textField;
    }
    
    public function dispatchChangeEvent():void {
        textField.dispatchEvent(new Event(Event.CHANGE, true));
    }
    
    /**
    * エディタのレイアウトを更新します。
    */
    protected override function updateSize():void {
        linumField.height = height;
        textField.x = linumField.width;
        textField.width = width - scrollBarV.width - linumField.width;
        textField.height = height - scrollBarH.height;
        scrollBarV.x = width - scrollBarV.width;
        scrollBarV.height = height - scrollBarH.height;
        scrollBarH.x = linumField.width;
        scrollBarH.y = height - scrollBarH.height;
        scrollBarH.width = width - scrollBarV.width - linumField.width;
        graphics.clear();
        graphics.beginFill(0xEEEEEE);
        graphics.drawRect(0, 0, width, height);
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
jp/psyark/psycode/core/history/HistoryManager.as
*/

import __AS3__.vec.Vector;

class HistoryManager {
    private var currentIndex:int = 0;
    private var entries:Vector.<HistoryEntry>;
    
    public function HistoryManager() {
        entries = new Vector.<HistoryEntry>();
    }
    
    public function appendEntry(entry:HistoryEntry):void {
        entries.length = currentIndex;
        entries.push(entry);
        currentIndex = entries.length;
    }
    
    public function clear():void {
        currentIndex = 0;
        entries.length = 0;
    }
    
    public function get canForward():Boolean {
        return currentIndex < entries.length;
    }
    
    public function get canBack():Boolean {
        return currentIndex > 0;
    }
    
    public function forward():HistoryEntry {
        return entries[currentIndex++];
    }
    
    public function back():HistoryEntry {
        return entries[--currentIndex];
    }
}


/*
jp/psyark/psycode/core/TextEditorBase.as
*/

import flash.events.Event;
import flash.events.TextEvent;
import flash.geom.Rectangle;


/**
* @private
* TextEditorBaseクラスはTextEditUIクラスを継承し、
* キーイベントのキャンセルなどテキストエディタの実装に必要な機能を提供します。
*/
class TextEditorBase extends TextEditUI {
    public var preventFollowingTextInput:Boolean = false;
    public var prevText:String = "";
    public var prevSBI:int;
    public var prevSEI:int;
    
    public var trackChanges:Boolean = true;
    protected var ignoreChange:Boolean = false;
    public var comparator:StringComparator;
    protected var historyManager:HistoryManager;
    
    /**
    * TextEditorBaseクラスのインスタンスを作成します。
    */
    public function TextEditorBase() {
        addEventListener(Event.CHANGE, changeHandler);
        addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
    }
    
    
    /**
    * 次のテキスト入力をキャンセルするように、現在の状態を保存します。
    */
    psycode_internal function preventNextTextInput():void {
        
    }
    
    
    /**
    * テキストが変更された
    */
    private function changeHandler(event:Event):void {
        Psymacs.instance.textChangeHook(this, event);
        //trace("change", "changed=" + (prevText != text), "ignore=" + ignoreChange, "prevent=" + preventFollowingTextInput);
        //trace("{" + escapeText(prevText) + "} => {" + escapeText(text) + "}");
        if (prevText != text) {
            if (preventFollowingTextInput) {
                comparator.compare(prevText, text);
                replaceText(
                    comparator.commonPrefixLength,
                    text.length - comparator.commonSuffixLength,
                    prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength)
                );
                setSelection(prevSBI, prevSEI);
                preventFollowingTextInput = false;
            } else if (trackChanges){
                comparator.compare(prevText, text);
                if (!ignoreChange) {
                    var entry:HistoryEntry = new HistoryEntry(comparator.commonPrefixLength);
                    entry.oldText = prevText.substring(comparator.commonPrefixLength, prevText.length - comparator.commonSuffixLength);
                    entry.newText = text.substring(comparator.commonPrefixLength, text.length - comparator.commonSuffixLength);
                    historyManager.appendEntry(entry);
                }
                //callLater(syntaxHighlighter.update, [comparator.commonPrefixLength, text.length - comparator.commonSuffixLength]);
                prevText = text;
            }
        }
    }
    
    
    /**
    * テキストが入力された
    */
    private function textInputHandler(event:TextEvent):void {
        if (preventFollowingTextInput) {
            event.preventDefault();
        }
    }
    
    
    /**
    * 履歴追加の際、自分が無視できる変更イベントを送信
    */
    protected function dispatchIgnorableChangeEvent():void {
        ignoreChange = true;
        dispatchChangeEvent();
        ignoreChange = false; 
    }
}



/*
jp/psyark/psycode/controls/ScrollBarHandle.as
*/

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import jp.psyark.psycode.controls.ScrollBar;

class ScrollBarHandle extends SimpleButton {
    protected static var handleColors:Array = [0xF7F7F7, 0xECECEC, 0xD8D8D8, 0xCCCCCC, 0xEDEDED];
    protected static var handleAlphas:Array = [1, 1, 1, 1, 1];
    protected static var handleRatios:Array = [0x00, 0x66, 0x80, 0xDD, 0xFF];
    protected static var iconColors:Array = [0x000000, 0xFFFFFF];
    protected static var iconAlphas:Array = [1, 1];
    protected static var iconRatios:Array = [0x00, 0xFF];
    
    private var direction:String;
    private var upFace:Shape;
    private var overFace:Shape;
    
    public function ScrollBarHandle(direction:String="vertical") {
        this.direction = direction;
        cacheAsBitmap = true;
        useHandCursor = false;
        
        upFace = new Shape();
        overFace = new Shape();
        overFace.transform.colorTransform = new ColorTransform(0.95, 1.3, 1.5, 1, 0x00, -0x33, -0x44);
        
        upState = upFace;
        overState = overFace;
        downState = overFace;
        hitTestState = upFace;
    }
    
    public function setSize(w:Number, h:Number):void {
        drawFace(upFace.graphics, w, h);
        drawFace(overFace.graphics, w, h);
    }
    
    protected function drawFace(graphics:Graphics, w:Number, h:Number):void {
        var mtx:Matrix = new Matrix();
        mtx.createGradientBox(w, h, direction == ScrollBar.VERTICAL ? 0 : Math.PI / 2);
        
        graphics.clear();
        graphics.beginFill(0x999999);
        graphics.drawRoundRect(0, 0, w, h, 2);
        graphics.beginGradientFill(GradientType.LINEAR, handleColors, handleAlphas, handleRatios, mtx);
        graphics.drawRect(1, 1, w - 2, h - 2);
        
        graphics.lineStyle(-1, 0xEEEEEE);
        graphics.beginGradientFill(GradientType.LINEAR, iconColors, iconAlphas, iconRatios, mtx);
        for (var i:int=-1; i<2; i++) {
            if (direction == ScrollBar.VERTICAL) {
                graphics.drawRoundRect((w - 8) / 2, (h - 3) / 2 + i * 3, 8, 3, 2);
            } else {
                graphics.drawRoundRect((w - 3) / 2 + i * 3, (h - 8) / 2, 3, 8, 2);
            }
        }
    }
}



/*
jp/psyark/psycode/controls/ListItemRenderer.as
*/

import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import jp.psyark.psycode.controls.UIControl;

class ListItemRenderer extends UIControl {
    private var _data:Object;
    private var _labelField:String;
    private var label:TextField;
    
    public function ListItemRenderer() {
        label = new TextField();
        label.selectable = false;
        label.defaultTextFormat = new TextFormat("Courier New", 13, 0x000000);
        label.backgroundColor = 0xE8F8FF;
        addChild(label);
        updateView();
        
        addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
    
    public function get data():Object {
        return _data;
    }
    
    public function set data(value:Object):void {
        if (_data != value) {
            _data = value;
            updateView();
        }
    }
    
    /**
    * ラベルとして使うプロパティ名を取得または設定します。
    */
    public function get labelField():String {
        return _labelField;
    }
    
    /**
    * @private
    */
    public function set labelField(value:String):void {
        if (_labelField != value) {
            _labelField = value;
            updateView();
        }
    }
    
    protected function updateView():void {
        if (data) {
            try {
                label.text = data[labelField];
            } catch (e:*) {
                label.text = "";
            }
            label.visible = true;
        } else {
            label.visible = false;
        }
    }
    
    protected override function updateSize():void {
        label.width = width;
        label.height = height;
    }
    
    protected function rollOverHandler(event:MouseEvent):void {
        label.background = true;
    }
    
    protected function rollOutHandler(event:MouseEvent):void {
        label.background = false;
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


/*
jp/psyark/psycode/TextEditor.as
*/

import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.FileReference;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
* TextEditorクラス
*/
class TextEditor extends TextEditorBase {
    private var highlightAllTimer:int;
    
    /**
    * コンストラクタ
    */
    public function TextEditor() {
        comparator = new StringComparator();
        historyManager = new HistoryManager();
        
        contextMenu = createDebugMenu();
        
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        addEventListener(Event.CHANGE, function (event:Event):void {
                clearTimeout(highlightAllTimer);
                highlightAllTimer = setTimeout(highlightAll, 1000);
            });
    }
    
    private function highlightAll():void {
        //syntaxHighlighter.update(0, text.length);
    }
    
    
    private function createDebugMenu():ContextMenu {
        var menu:ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        createMenuItem("ファイルを開く(&O)...", open);
        createMenuItem("ファイルを保存(&S)...", save);
        createMenuItem("元に戻す(&Z)", undo, function ():Boolean { return historyManager.canBack; }, true);
        createMenuItem("やり直し(&Y)", redo, function ():Boolean { return historyManager.canForward; });
        createMenuItem("文字サイズ : &64", function ():void { setFontSize(64); }, null, true);
        createMenuItem("文字サイズ : &48", function ():void { setFontSize(48); });
        createMenuItem("文字サイズ : &32", function ():void { setFontSize(32); });
        createMenuItem("文字サイズ : &24", function ():void { setFontSize(24); });
        createMenuItem("文字サイズ : &13", function ():void { setFontSize(13); });
        return menu;
        
        function createMenuItem(caption:String, func:Function, enabler:Function=null, separator:Boolean=false):void {
            var item:ContextMenuItem = new ContextMenuItem(caption, separator);
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function (event:ContextMenuEvent):void {
                    func();
                });
            if (enabler != null) {
                menu.addEventListener(ContextMenuEvent.MENU_SELECT, function (event:ContextMenuEvent):void {
                        item.enabled = enabler();
                    });
            }
            menu.customItems.push(item);
        }
    }
    
    
    /**
    * 履歴を消去
    */
    public function clearHistory():void {
        historyManager.clear();
        prevText = text;
    }
    
    
    /**
    * キー押下イベントハンドラ
    */
    private function keyDownHandler(event:KeyboardEvent):void {
        preventFollowingTextInput = false;

        if (event.keyCode == 90 && event.ctrlKey && !event.altKey) {
            if(event.shiftKey) {
                // Ctrl+Shift+Z : REDO
                redo();
            } else {
                // Ctrl+Z : UNDO
                undo();
            }
            event.preventDefault();
            preventFollowingTextInput = true;
            prevSBI = selectionBeginIndex;
            prevSEI = selectionEndIndex;
            return;
        }

        if(null != Psymacs.instance.keyDownHook) Psymacs.instance.keyDownHook(this, event);
	}


	/**
	* 元に戻す
	*/
	public function undo():void {
		if (historyManager.canBack) {
			var entry:HistoryEntry = historyManager.back();
			replaceText(entry.index, entry.index + entry.newText.length, entry.oldText);
			setSelection(entry.index + entry.oldText.length, entry.index + entry.oldText.length);
			dispatchIgnorableChangeEvent();
		}
	}

	/**
	* やり直し
	*/
	public function redo():void {
		if (historyManager.canForward) {
			var entry:HistoryEntry = historyManager.forward();
			replaceText(entry.index, entry.index + entry.oldText.length, entry.newText);
			setSelection(entry.index + entry.newText.length, entry.index + entry.newText.length);
			dispatchIgnorableChangeEvent();
		}
	}
}

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
