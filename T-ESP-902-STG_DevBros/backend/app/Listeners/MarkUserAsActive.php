<?php

namespace App\Listeners;

use Illuminate\Auth\Events\Verified;
use App\Models\User;

class MarkUserAsActive
{
    /**
     * Handle the event.
     *
     * @param  Verified  $event
     * @return void
     */
    public function handle(Verified $event)
    {
        /** @var User $user */
        $user = $event->user;
        $user->isActif = true;
        $user->save();
    }
}
