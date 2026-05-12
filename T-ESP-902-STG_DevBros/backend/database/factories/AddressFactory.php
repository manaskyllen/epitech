<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Address>
 */
class AddressFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'street1' => fake()->streetAddress(),
            'street2' => fake()->streetAddress(),
            'city' => fake()->city(),
            'zipCode' => fake()->postcode(),
            'country' => fake()->country(),
            'user_id' => fake()->numberBetween(1, User::count()),
        ];
    }
}
