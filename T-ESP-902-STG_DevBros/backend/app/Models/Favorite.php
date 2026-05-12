<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Favorite extends Model
{
    /** @use HasFactory<\Database\Factories\FavoriteFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'user_id',
        'clothing_id',
        'outfit_id',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'clothing_id' => 'integer',
        'outfit_id' => 'integer',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\Clothing, $this>
     */
    public function clothing(): BelongsTo
    {
        return $this->belongsTo(Clothing::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\Outfit, $this>
     */
    public function outfit(): BelongsTo
    {
        return $this->belongsTo(Outfit::class);
    }
}
