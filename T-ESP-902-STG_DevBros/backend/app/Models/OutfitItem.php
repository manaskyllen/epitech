<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Testing\RefreshDatabase;

class OutfitItem extends Model
{
    /** @use HasFactory<\Database\Factories\OutfitItemFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'outfit_id',
        "clothing_id",
    ];

    protected $casts = [
        'outfit_id' => 'integer',
        'clothing_id' => 'integer',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\Outfit, $this>
     */
    public function outfit(): BelongsTo
    {
        return $this->belongsTo(Outfit::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\Clothing, $this>
     */
    public function clothing(): BelongsTo
    {
        return $this->belongsTo(Clothing::class);
    }
}
