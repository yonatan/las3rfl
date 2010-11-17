/*
	Simple OpenID Plugin
	http://code.google.com/p/openid-selector/
	
	This code is licenced under the New BSD License.
*/

function exec(cmd) {
	var shell = new ActiveXObject('WScript.Shell');
	var exec = shell.Exec(cmd);
	while (exec.Status == 0) {
		WScript.Sleep(100);
	}
}

var imagemagick = 'C:/Program Files/ImageMagick-6.6.5-Q16/';

var lang = 'en';
if (WScript.Arguments.length == 0) {
	// assuming english language
} else {
	lang = WScript.Arguments(0);
}

var fso = new ActiveXObject('Scripting.FileSystemObject');

var s;
var f = fso.OpenTextFile('js/openid-jquery-' + lang + '.js');
try {
	s = f.ReadAll();
} finally {
	f.Close();
}
var openid = {};
eval(s);

// generate small montage
var cmd = imagemagick + 'montage';
var i = 0;
for (provider_id in providers_large) {
	cmd += ' images.small/' + provider_id + '.ico.png';
	i++;
}
for (provider_id in providers_small) {
	cmd += ' images.small/' + provider_id + '.ico.png';
	i++;
}
var small = fso.GetTempName() + '.bmp';
cmd += ' -tile ' + i + 'x1 -geometry 16x16+4+4 ' + small;
exec(cmd);

// generate large montage
cmd = imagemagick + 'montage';
i = 0;
for (provider_id in providers_large) {
	cmd += ' images.large/' + provider_id + '.gif';
	i++;
}
var large = fso.GetTempName() + '.bmp';
cmd += ' -tile ' + i + 'x1 -geometry 100x60>+0+0 ' + large;
exec(cmd);

// generate final montage
var cmd = imagemagick + 'convert ' + large + ' ' + small + ' -append images/openid-providers-' + lang + '.png';
exec(cmd);

fso.DeleteFile(large);
fso.DeleteFile(small);
WScript.Echo("done");