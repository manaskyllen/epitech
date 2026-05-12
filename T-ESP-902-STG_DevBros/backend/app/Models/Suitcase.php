<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Suitcase extends Model
{
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'name',
        'departure_date',
        'end_date',
        'destination',
        'user_id',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany<\App\Models\Clothing, $this>
     */
    public function clothings(): BelongsToMany
    {
        return $this->belongsToMany(Clothing::class, 'clothing_suitcase')
            ->withTimestamps();
    }

    protected $casts = [
        'name' => 'string',
        'departure_date' => 'date',
        'end_date' => 'date',
        'destination' => 'string',
        'user_id' => 'integer',
    ];
}
