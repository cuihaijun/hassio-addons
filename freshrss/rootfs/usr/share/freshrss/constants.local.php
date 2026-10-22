<?php

//This directory must be writable
defined('DATA_PATH') or define('DATA_PATH', '/data/freshrss');

// Custom extensions directory
defined('THIRDPARTY_EXTENSIONS_PATH') or define('THIRDPARTY_EXTENSIONS_PATH', '/config/extensions');

// Disable copying logs to syslog/stderr to prevent host journald/console flooding
defined('COPY_LOG_TO_SYSLOG') or define('COPY_LOG_TO_SYSLOG', false);
defined('COPY_SYSLOG_TO_STDERR') or define('COPY_SYSLOG_TO_STDERR', false);
