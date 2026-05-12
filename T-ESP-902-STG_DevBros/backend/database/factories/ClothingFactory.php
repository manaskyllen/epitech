<?php

namespace Database\Factories;

use App\Models\ClothingModel;
use App\Models\ClothingTexture;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Clothing>
 */
class ClothingFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'itemType' => $this->faker->randomElement(['top', 'bottom', 'accessories', 'shoes', 'Headwear']),
            'itemSubtype' => $this->faker->randomElement([
                'T-shirt', 'Tank top', 'Blouse', 'Sweatshirt', 'Sweater', 'Cardigan',
                'Jeans', 'Pants', 'Shorts', 'Skirt', 'Leggings', 'Dress', 'Jumpsuit',
                'Jacket', 'Coat', 'Trench coat', 'Puffer jacket', 'Swimsuit',
                'Bra', 'Panties', 'Pajamas', 'Sneakers', 'Boots', 'Sandals',
                'Heels', 'Hat', 'Scarf', 'Belt', 'Bag'
            ]),
            'color' => $this->faker->colorName(),
            'size' => $this->faker->randomElement(['XS', 'S', 'M', 'L', 'XL', 'XXL']),
            'style' => $this->faker->randomElement(['Casual', 'Formal', 'Sporty', 'Vintage', 'Bohemian']),
            'season' => $this->faker->randomElement(['Spring', 'Summer', 'Autumn', 'Winter']),
            'fabric' => $this->faker->randomElement(['Cotton', 'Wool', 'Polyester', 'Silk', 'Linen']),
            'texture' => $this->faker->url(),
            'user_id' => User::factory(),
            'clothingModel_id' => $this->faker->numberBetween(1, ClothingModel::count()),
        ];
    }
}
