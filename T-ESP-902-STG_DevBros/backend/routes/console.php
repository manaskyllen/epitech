<?php

use App\Models\User;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schedule;
use Symfony\Component\Console\Command\Command;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('admin:grant {email : Email du compte a promouvoir}', function (string $email) {
    $user = User::query()->where('email', $email)->first();

    if (! $user) {
        $this->error("Aucun utilisateur trouve pour {$email}.");

        return Command::FAILURE;
    }

    $user->forceFill(['is_admin' => true])->save();

    $this->info("Acces admin active pour {$user->email}.");

    return Command::SUCCESS;
})->purpose("Promouvoir un utilisateur existant pour l'acces Filament");

Schedule::call(function () {
    DB::table('users')->where('otpGeneratedAt', '<', now()->subMinutes(5))->delete();
})->daily();
