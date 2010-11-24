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

        /**
         * Base64的字符集(Character Set)
         */
        public final class Base64CharSet {

                /**
                 * 在<strong>RFC-3548</strong>里定义的一般的字符集
                 */
                public static const RFC_3548:String =
                        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

                /**
                 * 在<strong>RFC-3548</strong>里定义的为了URL与文件名(Filename)anquan的字符集(URL and Filename safe)。
                 */
                public static const RFC_3548_URL_AMD_FILENAME_SAFE:String =
                        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=";
        }
}
