<?php

namespace Tests\Feature;

use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Models\Outfit;
use App\Models\OutfitItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OutfitItemTest extends TestCase
{
    use RefreshDatabase;

    public function test_store(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Outfit to Delete',
        ]);

        $clothingModel = ClothingModel::factory()->create();

        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $data = [
            'outfit_id' => $outfit->id,
            'clothing_id' => $clothing->id,
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/outfitItem', $data);

        $response->assertStatus(201);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Outfit to Delete',
        ]);

        $clothingModel = ClothingModel::factory()->create();

        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfitItem = OutfitItem::factory()->create([
            'outfit_id' => $outfit->id,
            'clothing_id' => $clothing->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/outfitItem/$outfitItem->id");

        $response->assertStatus(204);
    }
}
