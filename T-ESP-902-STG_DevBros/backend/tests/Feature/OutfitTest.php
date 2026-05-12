<?php

namespace Tests\Feature;

use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Models\Outfit;
use App\Models\OutfitItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OutfitTest extends TestCase
{
    use RefreshDatabase;

    public function test_index(): void
    {
        $user = User::factory()->create();
        Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/outfit');

        $response->assertStatus(200);
    }

    public function test_show(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/outfit/$outfit->id");

        $response->assertStatus(200);
    }

    public function test_store(): void
    {
        $user = User::factory()->create();
        $data = [
            'user_id' => $user->id,
            'name' => 'New Outfit',
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/outfit', $data);

        $response->assertStatus(201);
    }

    public function test_update(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Old Outfit',
        ]);

        $data = [
            'name' => 'Updated Outfit',
        ];

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/outfit/$outfit->id", $data);

        $response->assertStatus(200);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Outfit to Delete',
        ]);

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/outfit/$outfit->id");

        $response->assertStatus(204);
    }

    public function test_index_returns_404_when_empty(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/outfit');

        $response->assertStatus(404)->assertJson(['message' => 'No outfits found']);
    }

    public function test_show_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/outfit/999');

        $response->assertStatus(404)->assertJson(['message' => 'Outfit not found']);
    }

    public function test_get_outfits_by_user_id_returns_404_when_user_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/outfit/user/999');

        $response->assertStatus(404)->assertJson(['message' => 'User not found']);
    }

    public function test_get_outfits_by_user_id_returns_items(): void
    {
        $user = User::factory()->create();
        Outfit::factory()->create(['user_id' => $user->id, 'name' => 'Casual Outfit']);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/outfit/user/{$user->id}");

        $response->assertStatus(200)->assertJsonCount(1);
    }

    public function test_get_clothing_by_outfit_id_returns_404_when_no_items(): void
    {
        $user = User::factory()->create();
        $outfit = Outfit::factory()->create(['user_id' => $user->id, 'name' => 'Casual Outfit']);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/outfit/{$outfit->id}/clothing");

        $response->assertStatus(404)->assertJson(['message' => 'No clothing items found for this outfit']);
    }

    public function test_get_clothing_by_outfit_id_returns_items(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);
        $outfit = Outfit::factory()->create(['user_id' => $user->id, 'name' => 'Casual Outfit']);

        OutfitItem::factory()->create([
            'outfit_id' => $outfit->id,
            'clothing_id' => $clothing->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/outfit/{$outfit->id}/clothing");

        $response->assertStatus(200)->assertJsonCount(1);
    }
}
