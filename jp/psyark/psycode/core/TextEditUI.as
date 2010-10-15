package jp.psyark.psycode.core {

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import jp.psyark.psycode.core.linenumber.LineNumberView;
	import jp.psyark.psycode.controls.UIControl;
	import jp.psyark.psycode.controls.ScrollBar;
	import jp.psyark.psycode.controls.TextScrollBar;
	import jp.psyark.psycode.core.psycode_internal;
	import jp.psyark.utils.convertNewlines;

	/**
	* @private
	* TextEditAreaクラスは、テキストフィールド・行番号・スクロールバーなど
	* テキスト編集UIの基本的な機能を提供し、それらの実装を隠蔽します。
	*/
	public class TextEditUI extends UIControl {
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
}