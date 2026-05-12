<?php

namespace Database\Factories;

use App\Models\Clothing;
use App\Models\Outfit;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\OutfitItem>
 */
class OutfitItemFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'outfit_id' => $this->faker->numberBetween(1, Outfit::count()), 
            'clothing_id' => $this->faker->numberBetween(1, Clothing::count()), 
        ];
    }
}
