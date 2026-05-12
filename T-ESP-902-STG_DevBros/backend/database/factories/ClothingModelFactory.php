<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\ClothingModel>
 */
class ClothingModelFactory extends Factory
{
    private const MODEL_DEFINITIONS = [
        [
            'name' => 'T-shirt',
            'model' => 'character-assets/clothes/top/tshirt.glb',
            'slots' => 'top',
        ],
        [
            'name' => 'Sweatshirt',
            'model' => 'character-assets/clothes/top/sweatshirt.glb',
            'slots' => 'top',
        ],
        [
            'name' => 'Jeans',
            'model' => 'character-assets/clothes/bottom/jeans.glb',
            'slots' => 'bottom',
        ],
        [
            'name' => 'Shoes',
            'model' => 'character-assets/clothes/shoes/shoes.glb',
            'slots' => 'shoes',
        ],
    ];

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $definition = $this->faker->randomElement(self::MODEL_DEFINITIONS);

        return [
            'name' => $definition['name'],
            'model' => $definition['model'],
            'texture' => null,
            'slots' => $definition['slots'],
        ];
    }
}
