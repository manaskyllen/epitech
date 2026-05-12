<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Address extends Model
{
    /** @use HasFactory<\Database\Factories\AddressFactory> */
    use HasFactory;
    use RefreshDatabase;

    protected $fillable = [
        'street1',
        'street2',
        'city',
        'zipCode',
        'country',
        'user_id',
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo<\App\Models\User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    protected $casts = [
        'street1' => 'string',
        'street2' => 'string',
        'city' => 'string',
        'zipCode' => 'string',
        'country' => 'string',
        'user_id' => 'integer',
    ];
}
