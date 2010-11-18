<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="<?php print $language->language ?>" xml:lang="<?php print $language->language ?>">

<head>
  <title><?php print $head_title; ?></title>
  <?php print $head; ?>
  <?php print $styles; ?>
  <?php print $scripts; ?>
	<!--[if lt IE 7]>
  <style type="text/css" media="all">@import "<?php print base_path() . path_to_theme() ?>/fix-ie6.css";</style>
  <![endif]-->
	<!--[if gt IE 5]>
  <style type="text/css" media="all">@import "<?php print base_path() . path_to_theme() ?>/fix-ie.css";</style>
  <![endif]-->
</head>

<body class="<?php print $body_classes; ?>">
  
<?php if (!empty($header)): ?>
	<div id="header-region" class="clear-block"><?php print $header; ?></div>
<?php endif; ?>

	<div id="container" class="clear-block">
		
		<div id="header">
			<div id="top-bar">
			<?php if (isset($secondary_links)) : ?>
				<div class="region-content">
        <?php print theme('links', $secondary_links, array('class' => 'links secondary-links')) ?>
				</div>
      <?php endif; ?>
			</div>
			
			<div class="region-content">
				<?php
				if ($logo || $site_title) {
        	print '<h1><a href="'. check_url($base_path) .'" title="'. $site_title .'">';
        	if ($logo) {
          	print '<img src="'. check_url($logo) .'" alt="'. $site_title .'" id="logo" />';
        	}
        	print ($logo ? '' : $site_title_html) .'</a></h1>';
      	}
				?>
			
				<?php if (isset($primary_links)) : ?>
        	<?php print theme('links', $primary_links, array('class' => 'links primary-links')) ?>
      	<?php endif; ?>
			</div>
		</div> <!-- /header -->
		
		<div id="center">
			<div id="featured">
				<?php if ($mission || $featured): ?>
				<div class="region-content">
				<?php if ($mission): print '<div id="mission">'. $mission .'</div>'; endif; ?>
				<?php if ($featured): print $featured; endif; ?>
				</div>
				<?php endif; ?>
			</div>
			
			<div id="breadcrumb"><div class="region-content">
				<?php if ($breadcrumb): print $breadcrumb; endif; ?>
			</div></div>
			
			<div id="main">
				<div id="sidebar-wrapper">
					<?php if (!$sidebar_triple): ?><div class="top-corners"><div class="bottom-corners"><?php endif; ?>
					<?php if ($sidebar_left): ?>
	        <div id="sidebar-left" class="sidebar">
	         	<?php print $sidebar_left ?>
	       	</div> <!-- /sidebar-left -->
	      	<?php endif; ?>
	
					<?php if (!$sidebar_triple): ?>
					<div id="content">
						<div id="squeeze">
						<?php if ($pre_content) { print $pre_content; } ?>
						<?php print phptemplate_render_content($content, $tabs, $title, $help, $show_messages, $messages, $feed_icons, $body_classes) ?>
						</div>
					</div> <!-- /content -->
					<?php endif; ?>
	
					<?php if ($sidebar_right_sec): ?>
	        <div id="sidebar-right-sec" class="sidebar">
	          <?php print $sidebar_right_sec ?>
	        </div> <!-- /sidebar-right-sec -->
	      	<?php endif; ?>
	
					<?php if ($sidebar_right): ?>
	        <div id="sidebar-right" class="sidebar">
	          <?php print $sidebar_right ?>
	        </div> <!-- /sidebar-right -->
	      	<?php endif; ?>
	
					<?php if ($sidebar_triple): ?>
					<div id="content">
						<?php print phptemplate_render_content($content, $tabs, $title, $help, $show_messages, $messages, $feed_icons, $body_classes) ?>
					</div>
					<?php endif; ?>
					
					<span class="clear"></span>
				</div><?php if (!$sidebar_triple): ?></div></div><?php endif; ?> <!-- /sidebar_wrapper -->
			</div> <!-- /main -->
			
			<div id="content-bottom">
				<?php if ($content_bottom): print '<div class="region-content clear-block">'.$content_bottom.'</div>'; endif; ?>
			</div>
			
		</div> <!-- /center -->
	
		<div id="footer"><div class="top-border"><div class="bottom-border">
			<div class="region-content">
			<?php if (isset($footer_region)) { print $footer_region; } ?>
			<?php if (isset($primary_links)) : ?>
      	<?php print theme('links', $primary_links, array('class' => 'links primary-links')) ?>
    	<?php endif; ?>
			<?php if (isset($footer_message)) { print '<p id="footer-message">'.$footer_message.'</p>'; } ?>
			<span class="clear"></span>
			</div>
		</div></div></div> <!-- /footer -->
	</div> <!-- /container -->
	<?php print $closure ?>
</body>
</html>