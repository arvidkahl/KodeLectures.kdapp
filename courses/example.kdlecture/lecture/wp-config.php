<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'arvidkahl_ynx90rcm');

/** MySQL database username */
define('DB_USER', 'arvidkahl_ynx90r');

/** MySQL database password */
define('DB_PASSWORD', 'h5mmg9no');

/** MySQL hostname */
define('DB_HOST', 'mysql0.db.koding.com');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

define('AUTH_KEY',         '.[x|?dy:#C<0S|ByoU7I|AwpF_s-jXTlpK;.7bT]s|_yS{K)Y1A.)`(?M p9AI-4');
define('SECURE_AUTH_KEY',  ')qlzeL8ats+)1Z&%7Q)7D0(LT]!]P}VBkB61w)W*TbI]F,+iF|q-nfuUG)><lw|h');
define('LOGGED_IN_KEY',    'AR$S=Jy]B>JLmK^64e|Z0BA0$5@(9NMFS@1t0mo~=qK}c.;(a(nqpck(~*6w(-ER');
define('NONCE_KEY',        '5=r?!-s|pMfRfsKtE.~/Y};#bjbU(tJ_Sb,C6Bg%r~m:gCDgQP_SqC-aQ6Lpjn,?');
define('AUTH_SALT',        'aR?5Y]!:-aP8pBLw6v+U^?ViR 4C*l-C,oe-fSa#YA({)lpQNtjxc<Y#0,{6D-6t');
define('SECURE_AUTH_SALT', ')Jw;-nvw7 MU>9e+9[S}zkRh.+eE3#lEzp;*b@:4i`G/+(Y<Mq7f//5y.6/5+ 8z');
define('LOGGED_IN_SALT',   'qG)+1T;uM:v=#iJ`g-e-}{x>flp0rlp[<%kGjTfHo}~9])?rOL7*SK$}^+r~^zQ_');
define('NONCE_SALT',       'xuchEN<o9|!.YV36=:I|!5%@cHERfn<mhM2:/lcK &c_r=[KlY+0`$PzjWz;+qg6');
/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
