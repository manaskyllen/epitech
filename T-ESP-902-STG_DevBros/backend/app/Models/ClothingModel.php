<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ClothingModel extends Model
{
    /** @use HasFactory<\Database\Factories\ClothingModelFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'name',
        'model',
        'texture',
        'slots',
    ];

    protected $casts = [
        'name' => 'string',
        'model' => 'string',
        'texture' => 'string',
        'slots' => 'string',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany<\App\Models\Clothing, $this>
     */
    public function clothings(): HasMany
    {
        return $this->hasMany(Clothing::class, 'clothingModel_id');
    }
}
