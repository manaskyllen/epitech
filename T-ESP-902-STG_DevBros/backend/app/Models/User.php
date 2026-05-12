<?php

namespace App\Models;

use Filament\Models\Contracts\HasName;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser, HasName
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'firstname',
        'lastname',
        'email',
        'sso',
        'profilePictureUrl',
        'password',
        'isActif',
        'newsletter',
        'is_admin',
        'otp',
        'otpGeneratedAt',
        'email_verified_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'otp',
        'remember_token',
        'otpGeneratedAt'
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Address, $this>
     */
    public function addresses(): HasMany
    {
        return $this->hasMany(Address::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Favorite, $this>
     */
    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Outfit, $this>
     */
    public function outfits(): HasMany
    {
        return $this->hasMany(Outfit::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Clothing, $this>
     */
    public function clothings(): HasMany
    {
        return $this->hasMany(Clothing::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Suitcase, $this>
     */
    public function suitcases(): HasMany
    {
        return $this->hasMany(Suitcase::class);
    }

    protected  $casts =
    [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'firstname' => 'string',
        'sso' => 'string',
        'lastname' => 'string',
        'email' => 'string',
        'profilePictureUrl' => 'string',
        'isActif' => 'boolean',
        'newsletter' => 'boolean',
        'is_admin' => 'boolean',
        'otp' => 'string',
        'otpGeneratedAt' => 'datetime',
    ];

    public function canAccessPanel(Panel $panel): bool
    {
        return $panel->getId() === 'admin' && $this->is_admin === true;
    }

    public function getFullNameAttribute(): string
    {
        return trim(implode(' ', array_filter([
            $this->firstname,
            $this->lastname,
        ]))) ?: $this->email;
    }

    public function getFilamentName(): string
    {
        return $this->full_name;
    }
}
