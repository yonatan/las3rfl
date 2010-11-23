package {
    import flash.display.*;

    public class Spinner extends Sprite {
		private var divisions:Number;
		private var innerRadius:Number;
		private var outerRadius:Number;
		private var cnt:int = 0;

        public function Spinner(divisions:Number = 24, innerRadius:Number = 25, outerRadius:Number = 40) {
			this.divisions = divisions;
			this.innerRadius = innerRadius;
			this.outerRadius = outerRadius;
        }

		public function spin(e:* = null):void {
			cnt++;
			graphics.clear();

			for(var i:uint = 0; i < divisions; i++) {
				var z:Number = (i + cnt) / divisions * (Math.PI * 2);
				var sz:Number = Math.sin(z);
				var cz:Number = Math.cos(z);
				var c:uint = i / divisions * 0xff;
				c = 0xff ^ c;
				c = c << 16 | c << 8 | c;
				graphics.lineStyle(3, c);
				graphics.moveTo(-sz * innerRadius, cz * innerRadius);
				graphics.lineTo(-sz * outerRadius, cz * outerRadius);
			}
		}
    }
}