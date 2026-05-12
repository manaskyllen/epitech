<?php

namespace Database\Seeders;

use App\Models\OutfitItem;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class OutfitItemSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        OutfitItem::factory(10)->create();
    }
}
