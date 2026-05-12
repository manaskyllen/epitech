<?php

namespace Database\Seeders;

use App\Models\ClothingModel;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ClothingModelSeeder extends Seeder
{
    private const MODEL_DEFINITIONS = [
        [
            'name' => 'T-shirt',
            'model' => 'character-assets/clothes/top/tshirt.glb',
            'texture' => null,
            'slots' => 'top',
        ],
        [
            'name' => 'Sweatshirt',
            'model' => 'character-assets/clothes/top/sweatshirt.glb',
            'texture' => null,
            'slots' => 'top',
        ],
        [
            'name' => 'Jeans',
            'model' => 'character-assets/clothes/bottom/jeans.glb',
            'texture' => null,
            'slots' => 'bottom',
        ],
        [
            'name' => 'Shoes',
            'model' => 'character-assets/clothes/shoes/shoes.glb',
            'texture' => null,
            'slots' => 'shoes',
        ],
    ];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        foreach (self::MODEL_DEFINITIONS as $definition) {
            ClothingModel::updateOrCreate(
                [
                    'name' => $definition['name'],
                    'slots' => $definition['slots'],
                ],
                $definition
            );
        }
    }
}
