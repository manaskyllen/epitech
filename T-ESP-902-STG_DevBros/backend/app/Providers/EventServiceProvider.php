<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Auth\Events\Verified;
use App\Listeners\MarkUserAsActive;
use App\Listeners\SendOtpVerification;
use Illuminate\Auth\Events\Registered;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        Verified::class => [
            MarkUserAsActive::class,
        ],
        Registered::class => [
        SendOtpVerification::class,
    ],
    ];

    public function boot()
    {
        //
    }
}
