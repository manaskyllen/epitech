<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Clothing extends Model
{
    /** @use HasFactory<\Database\Factories\ClothingFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $table = 'clothing';

    protected $fillable = [
        'itemType',
        'itemSubtype',
        'color',
        'size',
        'style',
        'season',
        'gender',
        'fabric',
        'texture',
        'user_id',
        'clothingModel_id',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\ClothingModel, $this>
     */
    public function clothingModel(): BelongsTo
    {
        return $this->belongsTo(ClothingModel::class, 'clothingModel_id');
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Favorite, $this>
     */
    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\OutfitItem, $this>
     */
    public function outfitItems(): HasMany
    {
        return $this->hasMany(OutfitItem::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany<\App\Models\Suitcase, $this>
     */
    public function suitcases(): BelongsToMany
    {
        return $this->belongsToMany(Suitcase::class, 'clothing_suitcase')
            ->withTimestamps();
    }

    protected $casts = [
        'itemType' => 'string',
        'itemSubtype' => 'string',
        'color' => 'string',
        'size' => 'string',
        'style' => 'string',
        'season' => 'string',
        'gender' => 'string',
        'fabric' => 'string',
        'texture' => 'string',
        'user_id' => 'integer',
        'clothingModel_id' => 'integer',
    ];

    public function getDisplayNameAttribute(): string
    {
        return trim(implode(' ', array_filter([
            $this->itemSubtype,
            $this->color ? "({$this->color})" : null,
        ])));
    }
}
