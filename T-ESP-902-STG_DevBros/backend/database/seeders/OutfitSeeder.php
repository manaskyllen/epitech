<?php

namespace Database\Seeders;

use App\Models\Outfit;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class OutfitSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Outfit::factory(10)->create();
    }
}
