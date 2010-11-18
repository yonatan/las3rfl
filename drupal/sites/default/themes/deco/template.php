<?php

/**
 * @file
 * File which contains theme overrides for the Deco theme.
 */


/**
 * Override or insert PHPTemplate variables into the templates.
 */
function phptemplate_preprocess_page(&$vars) {
	$vars['body_classes'] = isset($vars['body_classes']) ? $vars['body_classes'] : '';
	
	// variable to see if we have a triple sidebars and are not on block admin page
	$vars['sidebar_triple'] = FALSE;
	
	// add variable for block admin page
	$vars['block_admin'] = FALSE;
	
	if (arg(2) == 'block' && arg(3) == FALSE) {
		$vars['block_admin'] = TRUE;
		_deco_alert_layout($vars);
		$vars['body_classes'] .= ' block-admin';
	}
	
	else {
		
		// convert secondary right sidebar to right sidebar if there's no right sidebar
		if ($vars['sidebar_right_sec'] && empty($vars['sidebar_right'])) {
			$vars['sidebar_right'] = $vars['sidebar_right_sec'];
			$vars['sidebar_right_sec'] = '';
		}
		
		// set a class on the body to allow easier css themeing based on the layout type
  	if ($vars['sidebar_right'] && $vars['sidebar_right_sec'] && $vars['sidebar_left']) {
    	$vars['body_classes'] .= ' sidebar-triple';
			$vars['sidebar_triple'] = TRUE;
		}
		elseif ($vars['sidebar_left'] && $vars['sidebar_right']) {
  		$vars['body_classes'] .= ' sidebar-double';
		}
		elseif ($vars['sidebar_right'] && $vars['sidebar_right_sec']) {
	  	$vars['body_classes'] .= ' sidebar-right-double';
		}
  	elseif ($vars['sidebar_left']) {
  		$vars['body_classes'] .= ' sidebar-left';
		}
  	elseif ($vars['sidebar_right'] || $vars['sidebar_right_sec']) {
  		$vars['body_classes'] .= ' sidebar-right';
		}

		// add additional rightbar body class to reduce css to refer to right sidebars
		if ($vars['sidebar_right']) {
			$vars['body_classes'] .= ' rightbar';
		}
	}
	
	// set variables for the logo and slogan
	$site_fields = array();
  if ($vars['site_name']) {
    $site_fields[] = check_plain($vars['site_name']);
  }
  if ($vars['site_slogan']) {
    $site_fields[] = '- '.check_plain($vars['site_slogan']);
  }
  
	$vars['site_title'] = implode(' ', $site_fields);

	if (isset($site_fields[0])) {
  	$site_fields[0] = '<span class="site-name">'. $site_fields[0] .'</span>';
	}
	if (isset($site_fields[1])) {
		$site_fields[1] = '<span class="site-slogan">'. $site_fields[1] .'</span>';
	}
	
  $vars['site_title_html'] = implode(' ', $site_fields);

	// convert primary links to lowercase and secondary links to uppercase
	if ($vars['primary_links']) {
		foreach ($vars['primary_links'] as $key => $link) {
			$vars['primary_links'][$key]['title'] = strtolower($link['title']);
		}
	}
	if ($vars['secondary_links']) {
		foreach ($vars['secondary_links'] as $key => $link) {
			$vars['secondary_links'][$key]['title'] = strtoupper($link['title']);
		}
	}
}

/**
 * Alert the user when the layout is changed based on the used regions. 
 *
 * @param $regions
 *   An associative array containing the regions.
 */
function _deco_alert_layout($regions) {
	if (user_access('administer blocks')) {
		// remove the block indicators first
		$sidebars = array(
			'sidebar_right_sec' => $regions['sidebar_right_sec'], 
			'sidebar_right'     => $regions['sidebar_right'], 
			'sidebar_left'      => $regions['sidebar_left']
		);
	
		foreach ($sidebars as $k => $v) {
			$sidebars[$k] = preg_replace('/(\<div class="block-region"\>)(.*)(\<\/div\>)/', '', $v);
		}
	
		// warn the user that the secondary right sidebar will look like a regular right sidebar
		if ($sidebars['sidebar_right_sec'] && empty($sidebars['sidebar_right'])) {
			drupal_set_message(t('Warning: if you add blocks to the <em>secondary right sidebar</em> and leave the <em>right sidebar</em> empty, the <em>secondary right
			sidebar</em> will be rendered as a regular <em>right sidebar</em>.'));
		}
		// warn the user that the three sidebars will look like three equal columns
		elseif ($sidebars['sidebar_right'] && $sidebars['sidebar_right_sec'] && $sidebars['sidebar_left']) {
			drupal_set_message(t('Warning: if you add blocks to all three sidebars they will be rendered as three equal columns above the content.'));
		}
	}
}

/**
 * Generates the html to be rendered in the content area. Prevents duplication in the page template file
 */
function phptemplate_render_content($content, $tabs, $title, $help, $show_messages, $messages, $feed_icons, $body_classes) {
	
	$in_node = (strstr($body_classes, 'page-node') ? TRUE : FALSE);
	
	$output = '';
	$output .= ((!empty($title)) ? '<h2 class="content-title">'.$title.'</h2>' : '');
	$tabs = menu_primary_local_tasks();
	
	$output .= ($tabs ? phptemplate_menu_local_tasks('<ul class="tabs primary">'.$tabs.'</ul>') : '');
	
	$secondary_tabs = menu_secondary_local_tasks();
	
	$output .= ($secondary_tabs ? phptemplate_menu_secondary_local_tasks('<ul class="tabs secondary">'.$secondary_tabs.'</ul>') : '');
	$output .= ($help ? '<div class="help">'.$help.'</div>' : '');
	$output .= (($show_messages && $messages) ? $messages : '');
  $output .= $content;
	$output .= ($feed_icons ? $feed_icons : '');

	return $output;
}

/**
 * Format a group of form items.
 * Add HTML hooks for advanced styling
 *
 * @param $element
 *   An associative array containing the properties of the element.
 *   Properties used: attributes, title, value, description, children, collapsible, collapsed
 * @return
 *   A themed HTML string representing the form item group.
 */
function phptemplate_fieldset($element) {
  if ($element['#collapsible']) {
    drupal_add_js('misc/collapse.js');

    if (!isset($element['#attributes']['class'])) {
      $element['#attributes']['class'] = '';
    }

    $element['#attributes']['class'] .= ' collapsible';
    if ($element['#collapsed']) {
     $element['#attributes']['class'] .= ' collapsed';
    }
  }

  return '<fieldset'. drupal_attributes($element['#attributes']) .'>'. ($element['#title'] ? '<legend>'. $element['#title'] .'</legend>' : '') .'<div class="top"><div class="bottom"><div class="bottom-ornament">'. (isset($element['#description']) && $element['#description'] ? '<div class="description">'. $element['#description'] .'</div>' : '') . (!empty($element['#children']) ? $element['#children'] : '') . $element['#value'] ."</div></div></div></fieldset>\n";
}

/**
 * Returns the rendered local tasks. The default implementation renders
 * them as tabs.
 *
 * @ingroup themeable
 */
function phptemplate_menu_local_tasks($tasks = '') {
	$output = '';
	
  if (!empty($tasks)) {
		$output = "\n<div class=\"content-bar clear-block\"><div class=\"left\">\n". $tasks ."\n</div></div>\n";
	}

  return $output;
}

/**
 * Returns the rendered local tasks. The default implementation renders
 * them as tabs.
 *
 * @ingroup themeable
 */
function phptemplate_menu_secondary_local_tasks($tasks = '') {
	$output = '';
	
  if (!empty($tasks)) {
		$output = "\n<div class=\"content-bar-indented\"><div class=\"content-bar clear-block\"><div class=\"left\">\n". $tasks ."\n</div></div></div>\n";
	}

  return $output;
}

/**
 * Return a themed breadcrumb trail.
 *
 * @param $breadcrumb
 *   An array containing the breadcrumb links.
 * @return a string containing the breadcrumb output.
 */
function phptemplate_breadcrumb($breadcrumb) {
  if (!empty($breadcrumb)) {
    return '<div class="breadcrumb">'. implode(' › ', $breadcrumb) .'</div>';
  }
}

/**
 * 	Format a query pager.
 *
 * Menu callbacks that display paged query results should call theme('pager') to retrieve a pager control so that users can view  
 * other results. Format a list of nearby pages with additional query results.
 * 
 * Adds HTML hooks for making the pager appear in a horizontal bar
 */
function phptemplate_pager($tags = array(), $limit = 10, $element = 0, $parameters = array(), $quantity = 9) {
	$output = theme_pager($tags, $limit, $element, $parameters, $quantity);
	
	if (!empty($output)) {
		$output = '<div class="content-bar"><div class="left">'.$output.'</div></div>';
	}
	return $output;
}


function phptemplate_comment_submitted($comment) {
  return t('!username — !datetime',
    array(
      '!username' => theme('username', $comment),
      '!datetime' => '<span class="date">'.format_date($comment->timestamp).'</span>'
    ));
}

function phptemplate_node_submitted($node) {
  return t('!username — !datetime',
    array(
      '!username' => theme('username', $node),
      '!datetime' => '<span class="date">'.format_date($node->created).'</span>'
    ));
}
?>