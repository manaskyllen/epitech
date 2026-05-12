<?php

namespace App\Listeners;

use App\Notifications\SendOtpNotification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;

class SendOtpVerification
{
    /**
     * Create the event listener.
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     */
    public function handle($event)
    {
        $user = $event->user;

        $otp = rand(100000, 999999);

        $user->update([
            'otp' => $otp,
            'otpGeneratedAt' => now(),
        ]);

        $user->notify(new SendOtpNotification($otp));
    }
}
