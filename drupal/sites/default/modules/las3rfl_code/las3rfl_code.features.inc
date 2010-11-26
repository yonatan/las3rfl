<?php

/**
 * Implementation of hook_flag_default_flags().
 */
function las3rfl_code_flag_default_flags() {
$flags = array();
// Exported flag: "Bookmarks".
$flags[] = array (
  'content_type' => 'node',
  'name' => 'bookmarks',
  'title' => 'Bookmarks',
  'global' => '0',
  'types' => 
  array (
    0 => 'code',
  ),
  'flag_short' => 'Bookmark this',
  'flag_long' => 'Add this post to your bookmarks',
  'flag_message' => 'This post has been added to your bookmarks',
  'unflag_short' => 'Unbookmark this',
  'unflag_long' => 'Remove this post from your bookmarks',
  'unflag_message' => 'This post has been removed from your bookmarks',
  'unflag_denied_text' => '',
  'link_type' => 'toggle',
  'roles' => 
  array (
    'flag' => 
    array (
      0 => 2,
    ),
    'unflag' => 
    array (
      0 => 2,
    ),
  ),
  'show_on_page' => 1,
  'show_on_teaser' => 0,
  'show_on_form' => 0,
  'access_author' => 'others',
  'i18n' => 0,
  'api_version' => 2,
  'module' => 'las3rfl_code',
  'locked' => 
  array (
    0 => 'name',
  ),
);
return $flags;
}

/**
 * Implementation of hook_imagecache_default_presets().
 */
function las3rfl_code_imagecache_default_presets() {
  $items = array(
    '200x100' => array(
      'presetname' => '200x100',
      'actions' => array(
        '0' => array(
          'weight' => '0',
          'module' => 'imagecache',
          'action' => 'imagecache_scale_and_crop',
          'data' => array(
            'width' => '200',
            'height' => '100',
          ),
        ),
      ),
    ),
  );
  return $items;
}

/**
 * Implementation of hook_node_info().
 */
function las3rfl_code_node_info() {
  $items = array(
    'code' => array(
      'name' => t('Code'),
      'module' => 'features',
      'description' => '',
      'has_title' => '1',
      'title_label' => t('Title'),
      'has_body' => '1',
      'body_label' => t('Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
  );
  return $items;
}

/**
 * Implementation of hook_views_api().
 */
function las3rfl_code_views_api() {
  return array(
    'api' => '2',
  );
}
