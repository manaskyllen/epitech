<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Home', [
        'appName' => config('app.name'),
    ]);
});

Route::get('/character', function () {
    return Inertia::render('Character');
});

Route::get('/__debug-env', function () {
    return response()->json([
        'app_env' => config('app.env'),
        'app_url' => config('app.url'),
        'hostname' => gethostname(),
        'db' => DB::select('select inet_server_addr(), inet_server_port(), current_database()'),
    ]);
});
