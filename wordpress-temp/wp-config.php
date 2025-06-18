<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'admin' );

/** Database password */
define( 'DB_PASSWORD', 'securepassword' );

/** Database hostname */
define( 'DB_HOST', 'cnt-db' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'jmT3mq[%?AKpzl?L=58fVn&g!i:4x~YO0Gqf?@SNpQ8<$@ghqkg62FB_oW,F;^6b' );
define( 'SECURE_AUTH_KEY',  '*&[<o|20z2$K#UQ0*`VL~HwuKU8K1S6Dee!;,5>lW,y%Rx;0XcOk?S%R0&^kDP^9' );
define( 'LOGGED_IN_KEY',    'KXhp(<<G*IygY#$fN3mJCTD{l)Uo5+=-/Bt}ysi?4+wQ;4-(~94m{+p#sUD*7zs:' );
define( 'NONCE_KEY',        '2^2| 9EC:&IfW:Sb[x$W+LW9+/b1 1Xa)J [pKF`T6I%u :(?JmFi3>LoCh-F=dS' );
define( 'AUTH_SALT',        'r2z_Sz4kNDMq]I-D`.Z*8cwCE=Q6*H~#!FD>+9+#[tyVc!F.U5VuW9Wk((Uyfhey' );
define( 'SECURE_AUTH_SALT', 'dKOZ]^7D[2X]rabSg$g&tHt._(iW5{_q`@6<y#!5@b#s|FgwS8|_f.m%.E~K8EaN' );
define( 'LOGGED_IN_SALT',   'V<ua5^Li&2K`kJ6NWD$=T@SL`dO;yjuA#V,xHh8f0jBf/l!mt)/?VO|m;T?gh04B' );
define( 'NONCE_SALT',       'P>/{9pgmyg<Mqz~Uy0**tLF]Vq|I.,!>,+ndnFU_|kGEJ^%Q_cYmcBSTO:U0r[_p' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define('FS_METHOD', 'direct');
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);


/* Add any custom values between this line and the "stop editing" line. */

define('WP_MEMORY_LIMIT', '1024M');
define('WP_MAX_MEMORY_LIMIT', '2048M');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
