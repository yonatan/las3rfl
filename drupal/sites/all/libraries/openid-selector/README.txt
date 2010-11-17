OVERVIEW
-------------------
This is a simple Javascript OpenID selector. It has been designed so 
that users do not even need to know what OpenID is to use it, they 
simply select their account by a recognisable logo.

USAGE
-------------------
See demo.html source

TROUBLESHOOTING
----------------------------
Please remember after you change list of providers, you must run 
generate-sprite.js <lang> to refresh sprite image

generate-sprite.js requires ImageMagick to be installed and works
only in Windows (Linux and Apple users can run in VM)

Before running generate-sprite.js for the first time, check its
source code and correct line 16 (var imagemagick = '<...>';) to 
point to ImageMagick install dir.

LICENSE
-------------------
This code is licenced under the New BSD License.

