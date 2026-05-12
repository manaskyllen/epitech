<?php
// OPcache Preload for Laravel
$dir = __DIR__ . '/vendor';

$rii = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir));

foreach ($rii as $file) {
    if ($file->isDir()) {
        continue;
    }

    if (pathinfo($file->getFilename(), PATHINFO_EXTENSION) === 'php') {
        opcache_compile_file($file->getPathname());
    }
}
