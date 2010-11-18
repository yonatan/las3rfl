
OVERVIEW

Deco is a Drupal 6 core theme developed for the Google Summer of Code 2007. The 
original project proposal is available on the Google Code website:
http://code.google.com/soc/drupal/appinfo.html?csaid=AA41B8D436D691BB

Deco offers the following features:
- Full theming for Drupal and its core modules
- Additional regions
- Multiple layouts
- Logo customisation (see included logo.psd file)


INSTALLATION

Copy the whole deco directory to your Drupal themes directory. To enable and use 
the theme go to the theme administration page of your Drupal installation and 
enable and set deco as the default theme.

Please note that Drupal 5 is not yet supported.


REGIONS AND BLOCKS

Deco offers the following regions:

- Right sidebar: 
Default region, a large sidebar on the right side.
- Left sidebar: 
Left sidebar with blocks rendered as separate boxes.
- Secondary right sidebar:
Small sidebar on the right side. Please note that when used without the right 
sidebar it will be rendered as a large right sidebar.
- Featured: 
Region between the header and the content. Blocks in this region take up 75% of 
the site's width and have large white type.
- Before content:
Just above the regular content.
- Content:
Under the regular content.
- Bottom content:
Region between the content and the footer. Blocks here will be shown in two 
columns.
- Header:
Preceeds the actual site, before the header.
- Footer:
Region inside the footer, before the primary footer navigation and footer 
message.

WARNING:
Using the three sidebars together is not possible. In stead they will be rendered 
as three equal columns with the page content beneath it.


MULTIPLE LAYOUTS

By using the various regions Deco offers you can create different layouts:

- Single sidebar:
Use either the left or right sidebar.
- Double sidebar:
Use both the left and right sidebar regions.
- Double right sidebar:
Use both the right and secondary right sidebar regions.
- Triple equal column:
Use the left, right and secondary right sidebars.


CUSTOMIZING

Own logo:
If you want your own logo or slogan in stead of the default one you can change 
this in the theme's configuration page. Please see the theme admin page for 
this.

Logo based on default logo:
If you want to use the brown background of the default logo you can use the PSD 
file in designs/logo.psd. Open this file in photoshop, remove/add/edit the 
necessary layers and use the "save for web" feature to save the logo.png slice 
as an 8-bit transparent PNG with #1D1D1D as matte color.

Editing images:
In the designs directory you will find a slices.psd file and a psd direcory. The 
slices.psd file is used to generate all the deco images from. Each image slice 
is an actual image used in the theme.
The psd directory contains the actual designs from which the slices.psd file is 
made. Please note that not all designs were included because of size 
constraints.

Recoloring:
Right now Deco has no recoloring support. This will be supported in the near 
future.