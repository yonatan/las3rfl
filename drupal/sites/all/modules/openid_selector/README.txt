# $Id: README.txt,v 1.6 2010/10/18 13:27:34 agerasika Exp $

REQUIREMENTS
-------------------
This module depends on libraries module which must be downloaded
and installed separately.

To use this module in Drupal, you will need to download the 
Javascript OpenID Selector v1.2 from
http://code.google.com/p/openid-selector/downloads/list

INSTALLATION
-------------------
Note: this instruction assumes that you install this module in
      sites/all/modules directory (recommended).
   1. Unzip the files in the sites/all/modules directory. It should now
      contain a openid_selector directory.
   2. Download Javascript OpenID Selector v1.2 from 
      http://code.google.com/p/openid-selector/downloads/list. Unzip the
      contents of the openid-selector directory in the
      sites/all/libraries/openid-selector directory.
   4. Enable the module as usual from Drupal's admin pages.

UPGRADING
-------------------
Version 1.0 of this module requires Javascript OpenID Selector 1.0
Version 1.2 of this module requires Javascript OpenID Selector 1.1
Version 1.3+ of this module requires Javascript OpenID Selector 1.2
When upgrading this module from previous versions to version 1.3 please also 
upgrade Javascript OpenID Selector 

TROUBLESHOOTING
----------------------------
If your OpenID Selector does not show you must check if all files are
extracted correctly.

The correct directory structure is as follows:
sites
  all
    libraries
      openid-selector
        css
        images
        js
        demo.html
    modules
      openid_selector
        ...
        openid_selector.module
        ...

MAINTAINER
----------------------------
Andriy Gerasika (http://www.gerixsoft.com/)
