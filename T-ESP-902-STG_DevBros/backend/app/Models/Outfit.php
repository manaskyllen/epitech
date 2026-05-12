<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Outfit extends Model
{
    /** @use HasFactory<\Database\Factories\OutfitFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'user_id',
        'name',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'name' => 'string',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\OutfitItem, $this>
     */
    public function outfitItems(): HasMany
    {
        return $this->hasMany(OutfitItem::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Favorite, $this>
     */
    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }
}
