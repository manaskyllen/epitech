<?php

namespace Tests\Feature;

use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Models\Favorite;
use App\Models\Outfit;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FavoriteTest extends TestCase
{
    use RefreshDatabase;

    public function test_index(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        Favorite::factory()->create([
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/favorite');

        $response->assertStatus(200);
    }

    public function test_show(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $favorite = Favorite::factory()->create([
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/favorite/$favorite->id");

        $response->assertStatus(200);
    }

    public function test_store(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $data = [
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/favorite', $data);

        $response->assertStatus(201);
    }

    public function test_update(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $favorite = Favorite::factory()->create([
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ]);

        $data = [
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ];

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/favorite/$favorite->id", $data);

        $response->assertStatus(200);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        $favorite = Favorite::factory()->create([
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/favorite/$favorite->id");

        $response->assertStatus(204);
    }

    public function test_index_returns_404_when_empty(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/favorite');

        $response->assertStatus(404)->assertJson(['message' => 'No favorites found']);
    }

    public function test_show_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/favorite/999');

        $response->assertStatus(404)->assertJson(['message' => 'Favorite not found']);
    }

    public function test_get_favorites_by_user_id_returns_404_when_user_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/favorite/user/999');

        $response->assertStatus(404)->assertJson(['message' => 'User not found']);
    }

    public function test_get_favorites_by_user_id_returns_404_when_user_has_no_favorites(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/favorite/user/{$user->id}");

        $response->assertStatus(404)->assertJson(['message' => 'No favorites found for this user']);
    }

    public function test_get_favorites_by_user_id_returns_items(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $outfit = Outfit::factory()->create([
            'user_id' => $user->id,
            'name' => 'Casual Outfit',
        ]);

        Favorite::factory()->create([
            'user_id' => $user->id,
            'clothing_id' => $clothing->id,
            'outfit_id' => $outfit->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/favorite/user/{$user->id}");

        $response->assertStatus(200)->assertJsonCount(1);
    }

    public function test_update_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->putJson('/api/favorite/999', [
            'clothing_id' => 1,
        ]);

        $response->assertStatus(404)->assertJson(['message' => 'Favorite not found']);
    }

    public function test_destroy_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->deleteJson('/api/favorite/999');

        $response->assertStatus(404)->assertJson(['message' => 'Favorite not found']);
    }
}
