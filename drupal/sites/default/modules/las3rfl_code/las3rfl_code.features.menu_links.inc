<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function las3rfl_code_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: navigation:<front>
  $menu_links['navigation:<front>'] = array(
    'menu_name' => 'navigation',
    'link_path' => '<front>',
    'router_path' => '',
    'link_title' => 'Code ranking',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '1',
    'has_children' => '1',
    'expanded' => '0',
    'weight' => '-48',
  );
  // Exported menu link: navigation:libraries
  $menu_links['navigation:libraries'] = array(
    'menu_name' => 'navigation',
    'link_path' => 'libraries',
    'router_path' => 'libraries',
    'link_title' => '',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-50',
  );
  // Exported menu link: navigation:ranking/bookmarks/all-time
  $menu_links['navigation:ranking/bookmarks/all-time'] = array(
    'menu_name' => 'navigation',
    'link_path' => 'ranking/bookmarks/all-time',
    'router_path' => 'ranking/bookmarks/all-time',
    'link_title' => 'All time',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-48',
    'parent_path' => '<front>',
  );
  // Exported menu link: navigation:ranking/bookmarks/daily
  $menu_links['navigation:ranking/bookmarks/daily'] = array(
    'menu_name' => 'navigation',
    'link_path' => 'ranking/bookmarks/daily',
    'router_path' => 'ranking/bookmarks/daily',
    'link_title' => 'Today',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-50',
    'parent_path' => '<front>',
  );
  // Exported menu link: navigation:ranking/bookmarks/weekly
  $menu_links['navigation:ranking/bookmarks/weekly'] = array(
    'menu_name' => 'navigation',
    'link_path' => 'ranking/bookmarks/weekly',
    'router_path' => 'ranking/bookmarks/weekly',
    'link_title' => 'This week',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-49',
    'parent_path' => '<front>',
  );
  // Exported menu link: navigation:user/%
  $menu_links['navigation:user/%'] = array(
    'menu_name' => 'navigation',
    'link_path' => 'user/%',
    'router_path' => 'user/%',
    'link_title' => 'My account',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-49',
  );
  // Exported menu link: primary-links:logout
  $menu_links['primary-links:logout'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'logout',
    'router_path' => 'logout',
    'link_title' => 'Log out',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '50',
  );
  // Exported menu link: primary-links:node/61
  $menu_links['primary-links:node/61'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'node/61',
    'router_path' => 'node/%',
    'link_title' => 'Search',
    'options' => array(
      'attributes' => array(
        'title' => 'Search',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '0',
  );
  // Exported menu link: primary-links:node/62
  $menu_links['primary-links:node/62'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'node/62',
    'router_path' => 'node/%',
    'link_title' => 'Las3rfl?',
    'options' => array(
      'attributes' => array(
        'title' => 'About',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '0',
  );
  // Exported menu link: primary-links:node/add/code
  $menu_links['primary-links:node/add/code'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'node/add/code',
    'router_path' => 'node/add/code',
    'link_title' => 'Write new code',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '0',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('All time');
  t('Code ranking');
  t('Las3rfl?');
  t('Log out');
  t('My account');
  t('Search');
  t('This week');
  t('Today');
  t('Write new code');


  return $menu_links;
}
