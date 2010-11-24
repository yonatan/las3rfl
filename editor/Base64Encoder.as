/////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2007 Advanced Flex Project http://code.google.com/p/advancedflex/.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package {

    import flash.utils.ByteArray;

    /**
         * Base64的编码器
         */
    public final class Base64Encoder {

        /**
         * 用String来编码
         * @param src 原文
         * @param charSet Base64字符集，默认为 Base64CharSet.RFC_3548
         * @return 密文（原文编码后的数据）
         *
         * @see Base64CharSet#RFC_3548
         */
        public static function encode(src:String, charSet:String = ""):String {
            // Convert string to ByteArray
            var bytes:ByteArray = new ByteArray();
            bytes.writeUTFBytes(src);
            // Return encoded ByteArray
            return encodeByteArray(bytes, charSet ? charSet : Base64CharSet.RFC_3548);
        }

        /**
         * 用ByteArray来编码
         * @param src 原文
         * @param charSet Base64字符集，默认为 Base64CharSet.RFC_3548
         * @return 密文（原文编码后的数据）
         *
         * @see Base64CharSet#RFC_3548
         */
        public static function encodeByteArray(data:ByteArray, charSet:String = ""):String {
            charSet = charSet ? charSet : Base64CharSet.RFC_3548;
            // Initialise output
            var output:String = "";
            // Create data and output buffers
            var dataBuffer:Array;
            var outputBuffer:Array = new Array(4);
            // Rewind ByteArray
            data.position = 0;
            // while there are still bytes to be processed
            while (data.bytesAvailable > 0) {
                // Create new data buffer and populate next 3 bytes from data
                dataBuffer = new Array();
                for (var i:uint = 0; i < 3 && data.bytesAvailable > 0; i++) {
                    dataBuffer[i] = data.readUnsignedByte();
                }
                // Convert to data buffer Base64 character positions and
                // store in output buffer
                outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;
                outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);
                outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);
                outputBuffer[3] = dataBuffer[2] & 0x3f;
                // If data buffer was short (i.e not 3 characters) then set
                // end character indexes in data buffer to index of '=' symbol.
                // This is necessary because Base64 data is always a multiple of
                // 4 bytes and is basses with '=' symbols.
                for (var j:uint = dataBuffer.length; j < 3; j++) {
                    outputBuffer[j + 1] = 64;
                }
                // Loop through output buffer and add Base64 characters to
                // encoded data string for each character.
                for (var k:uint = 0; k < outputBuffer.length; k++) {
                    output += charSet.charAt(outputBuffer[k]);
                }
            }
            // Return encoded data
            return output;
        }
    }
}
