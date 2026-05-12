<?php

namespace Tests\Feature;

use App\Models\Clothing;
use App\Models\ClothingModel;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ClothingTest extends TestCase
{
    use RefreshDatabase;

    public function test_index(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothing');

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

        $clothingId = $clothing->id;

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/clothing/$clothingId");

        $response->assertStatus(200);
    }

    public function test_update(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $clothingId = $clothing->id;

        $data = [
            'size' => 'L',
            'color' => 'Red',
            'itemType' => 'top',
            'itemSubtype' => 'Sweatshirt',
            'style' => 'Formal',
            'season' => 'Winter',
            'fabric' => 'Denim',
        ];

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/clothing/$clothingId", $data);

        $response->assertStatus(200);
    }

    public function test_show_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothing/999');

        $response->assertStatus(404)->assertJson(['message' => 'Clothing item not found']);
    }

    public function test_index_returns_404_when_empty(): void
    {
        $response = $this->getJson('/api/clothing');

        $response->assertStatus(404)->assertJson(['message' => 'No clothing items found']);
    }

    public function test_get_clothing_by_user_id_returns_404_when_user_does_not_exist(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothing/user/999');

        $response->assertStatus(404)->assertJson(['message' => 'User not found']);
    }

    public function test_get_clothing_by_user_id_returns_404_when_user_has_no_clothing(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/clothing/user/{$user->id}");

        $response->assertStatus(404)->assertJson(['message' => 'No clothing items found for this user']);
    }

    public function test_get_clothing_by_user_id_returns_items(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();
        Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/clothing/user/{$user->id}");

        $response->assertStatus(200)->assertJsonCount(1);
    }

    public function test_ai_result_returns_200_on_success(): void
    {
        $user = User::factory()->create();
        config(['services.clothing.key' => 'http://fake.test']);

        Http::fake([
            '*' => Http::response([
                'data' => [
                    'ItemType' => 'Top',
                    'ItemSubtype' => 'T-shirt',
                    'Size' => 'L',
                    'Color' => 'Blue',
                    'Season' => 'Winter',
                    'Gender' => 'Ladies',
                    'material' => 'leather',
                    'Style' => 'Casual',
                ],
            ], 200),
        ]);

        $file = UploadedFile::fake()->image('clothing.jpg');

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/clothing', [
            'file' => $file,
        ]);

        $response->assertStatus(200)->assertJsonPath('data.itemSubtype', 'T-shirt');
    }

    public function test_ai_result_returns_500_on_failure(): void
    {
        $user = User::factory()->create();
        config(['services.clothing.key' => 'http://fake.test']);

        Http::fake([
            '*' => Http::response([], 500),
        ]);

        $file = UploadedFile::fake()->image('clothing.jpg');

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/clothing', [
            'file' => $file,
        ]);

        $response->assertStatus(500)->assertJson(['message' => 'AI Inspection failed']);
    }

    public function test_store_creates_clothing_and_model(): void
    {
        Storage::fake('minio');

        $user = User::factory()->create();

        $data = [
            'itemType' => 'top',
            'itemSubtype' => 'T-shirt',
            'color' => 'Blue',
            'size' => 'M',
            'style' => 'Casual',
            'season' => 'Summer',
            'gender' => 'female',
            'texture' => 'smooth',
            'file' => UploadedFile::fake()->image('clothing.jpg'),
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/clothing/store', $data);

        $response->assertStatus(201)
            ->assertJsonPath('data.clothing_model.name', 'T-shirt')
            ->assertJsonPath('data.itemSubtype', 'T-shirt');
    }

    public function test_update_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->putJson('/api/clothing/999', [
            'size' => 'XL',
        ]);

        $response->assertStatus(404)->assertJson(['message' => 'Clothing item not found']);
    }

    public function test_destroy_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->deleteJson('/api/clothing/999');

        $response->assertStatus(404)->assertJson(['message' => 'Clothing item not found']);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $clothing = Clothing::factory()->create([
            'user_id' => $user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);
        $clothingId = $clothing->id;

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/clothing/$clothingId");

        $response->assertStatus(204);
    }
}
