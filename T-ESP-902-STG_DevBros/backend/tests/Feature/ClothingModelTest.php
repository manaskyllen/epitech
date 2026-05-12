<?php

namespace Tests\Feature;

use App\DTOs\AssetFileDataDto;
use App\DTOs\PreparedClothingAssetsDto;
use App\Models\ClothingModel;
use App\Models\User;
use App\Services\ClothingAssetService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Mockery;
use Tests\TestCase;

class ClothingModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_index(): void
    {
        $user = User::factory()->create();
        ClothingModel::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothingModel');

        $response->assertStatus(200);
    }

    public function test_index_returns_404_when_no_models(): void
    {
        $response = $this->getJson('/api/clothingModel');

        $response->assertStatus(404)
            ->assertJson(['message' => 'No clothing models found']);
    }

    public function test_get_model_file_returns_minio_file_response(): void
    {
        Storage::fake('minio');

        $clothingModel = ClothingModel::factory()->create([
            'model' => 'minio-model.glb',
            'texture' => 'texture',
            'slots' => 'body',
        ]);

        Storage::disk('minio')->put('minio-model.glb', 'GLB-BINARY');

        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->get('/api/clothingModel/' . $clothingModel->id . '/file');

        $response->assertStatus(200);
        $this->assertEquals('model/gltf-binary', $response->headers->get('Content-Type'));
    }

    public function test_get_model_file_returns_local_storage_file_response(): void
    {
        $localPath = storage_path('app/public/local-model.glb');
        file_put_contents($localPath, 'GLB-BINARY');

        $clothingModel = ClothingModel::factory()->create([
            'model' => 'local-model.glb',
            'texture' => 'texture',
            'slots' => 'body',
        ]);

        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->get('/api/clothingModel/' . $clothingModel->id . '/file');

        @unlink($localPath);
        $response->assertStatus(200);
    }

    public function test_get_model_file_returns_not_configured_when_model_path_empty(): void
    {
        $clothingModel = ClothingModel::factory()->create([
            'model' => '',
            'texture' => 'texture',
            'slots' => 'body',
        ]);

        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->get('/api/clothingModel/' . $clothingModel->id . '/file');

        $response->assertStatus(404)
            ->assertJson(['message' => 'Model file is not configured']);
    }

    public function test_get_model_file_returns_file_not_found_when_resolution_fails(): void
    {
        $clothingModel = ClothingModel::factory()->create([
            'model' => 'https://example.com/missing.glb',
            'texture' => 'texture',
            'slots' => 'body',
        ]);

        Http::fake([
            'https://example.com/*' => Http::response('Not Found', 404),
        ]);

        $mockService = Mockery::mock(ClothingAssetService::class);
        $mockService->shouldReceive('resolveModelAsset')
            ->once()
            ->with($clothingModel->slots, $clothingModel->name)
            ->andReturn((object) [
                'source' => 'public',
                'key' => 'missing-file.glb',
                'filename' => 'missing-file.glb',
            ]);

        $this->app->instance(ClothingAssetService::class, $mockService);

        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->get('/api/clothingModel/' . $clothingModel->id . '/file');

        $response->assertStatus(404)
            ->assertJson(['message' => 'File not found']);
    }

    public function test_show(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/clothingModel/$clothingModel->id");

        $response->assertStatus(200);
    }

    /**
     * Test du store avec un fichier GLB valide
     */
    public function test_store_with_valid_glb_file(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();

        // Créer un fichier GLB mock valide
        $glbContent = $this->createValidGlbContent();
        $file = UploadedFile::fake()->createWithContent('test-model.glb', $glbContent);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'model3d' => $file,
                'slots' => 'body'
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'model_name',
                'default_texture',
                'path'
            ]);

        // Vérifier que le fichier a été sauvegardé
        Storage::disk('public')->assertExists('models/' . $file->hashName());

        // Vérifier que l'enregistrement a été créé en DB
        $this->assertDatabaseHas('clothing_models', [
            'name' => 'test_model_name',
            'texture' => 'test_texture',
            'slots' => 'body'
        ]);
    }

    /**
     * Test sans fichier uploadé
     */
    public function test_store_without_file(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'slots' => 'body'
            ]);

        $response->assertStatus(400)
            ->assertJson([
                'message' => 'No valid file uploaded'
            ]);
    }

    /**
     * Test avec un fichier invalide (pas un GLB)
     */
    public function test_store_with_invalid_file_type(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();

        // Créer un fichier non-GLB
        $file = UploadedFile::fake()->create('document.pdf', 100);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'model3d' => $file,
                'slots' => 'body'
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['model3d']);
    }

    /**
     * Test avec un fichier GLB invalide (mauvais header)
     */
    public function test_store_with_invalid_glb_structure(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();

        // Créer un fichier avec un contenu invalide
        $invalidContent = 'This is not a valid GLB file';
        $file = UploadedFile::fake()->createWithContent('invalid.glb', $invalidContent);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'model3d' => $file,
                'slots' => 'body'
            ]);

        $response->assertStatus(400)
            ->assertJson([
                'message' => 'Invalid GLB file'
            ]);
    }

    /**
     * Test avec un fichier trop volumineux
     */
    public function test_store_with_file_too_large(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();

        // Créer un fichier de plus de 50MB
        $file = UploadedFile::fake()->create('large-model.glb', 51201);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'model3d' => $file,
                'slots' => 'body'
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['model3d']);
    }

    /**
     * Test avec slots par défaut
     */
    public function test_store_with_default_slots(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();

        $glbContent = $this->createValidGlbContent();
        $file = UploadedFile::fake()->createWithContent('test-model.glb', $glbContent);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/clothingModel', [
                'model3d' => $file
                // Pas de slots fourni
            ]);

        $response->assertStatus(201);

        // Vérifier que le slot par défaut a été utilisé
        $this->assertDatabaseHas('clothing_models', [
            'slots' => 'unknown_slots'
        ]);
    }

    /**
     * Test sans authentification
     */
    public function test_store_requires_authentication(): void
    {
        Storage::fake('public');

        $glbContent = $this->createValidGlbContent();
        $file = UploadedFile::fake()->createWithContent('test-model.glb', $glbContent);

        $response = $this->postJson('/api/clothingModel', [
            'model3d' => $file,
            'slots' => 'body'
        ]);

        $response->assertStatus(401);
    }

    /**
     * Crée un contenu GLB valide pour les tests
     */
    private function createValidGlbContent(): string
    {
        // Structure minimale d'un fichier GLB valide
        $gltfData = json_encode([
            'asset' => ['version' => '2.0'],
            'nodes' => [
                ['name' => 'test_model_name']
            ],
            'materials' => [
                ['name' => 'test_texture']
            ]
        ]);

        $jsonLength = strlen($gltfData);

        // Header GLB (12 bytes)
        $header = pack('V', 0x46546C67); // "glTF" magic
        $header .= pack('V', 2); // version
        $header .= pack('V', 12 + 8 + $jsonLength); // length total

        // Chunk JSON (8 bytes header + data)
        $jsonChunk = pack('V', $jsonLength); // chunk length
        $jsonChunk .= pack('V', 0x4E4F534A); // "JSON" type
        $jsonChunk .= $gltfData;

        return $header . $jsonChunk;
    }

    public function test_update(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $data = [
            'name' => 'Updated Name',
            'material' => 'Linen',
        ];

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/clothingModel/$clothingModel->id", $data);

        $response->assertStatus(200);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/clothingModel/$clothingModel->id");

        $response->assertStatus(204);
    }

    public function test_show_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothingModel/999');

        $response->assertStatus(404)->assertJson(['message' => 'Clothing model not found']);
    }

    public function test_update_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->putJson('/api/clothingModel/999', [
            'name' => 'New Name'
        ]);

        $response->assertStatus(404)->assertJson(['message' => 'Clothing model not found']);
    }

    public function test_destroy_returns_404_when_not_found(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->deleteJson('/api/clothingModel/999');

        $response->assertStatus(404)->assertJson(['message' => 'Clothing model not found']);
    }

    public function test_get_model_file_returns_url_file_response(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create([
            'model' => 'https://example.com/test.glb',
            'texture' => 'texture',
            'slots' => 'body',
        ]);

        Http::fake([
            'https://example.com/*' => Http::response('GLB-BINARY', 200, ['Content-Type' => 'model/gltf-binary']),
        ]);

        $response = $this->actingAs($user, 'sanctum')->get('/api/clothingModel/' . $clothingModel->id . '/file');

        $response->assertStatus(200);
        $this->assertEquals('model/gltf-binary', $response->headers->get('Content-Type'));
    }

    public function test_get_assets_returns_200(): void
    {
        $user = User::factory()->create();
        $clothingModel = ClothingModel::factory()->create();

        $mockService = Mockery::mock(ClothingAssetService::class);
        $mockService->shouldReceive('assetsForModel')
            ->once()
            ->with($clothingModel->model, $clothingModel->slots, $clothingModel->name, $clothingModel->texture)
            ->andReturn(new PreparedClothingAssetsDto(
                new AssetFileDataDto('model-key', 'model.glb', 'public', 'http://example.com/model.glb'),
                [new AssetFileDataDto('texture-key', 'texture.png', 'public', 'http://example.com/texture.png')]
            ));

        $this->app->instance(ClothingAssetService::class, $mockService);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothingModel/' . $clothingModel->id . '/assets');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data.textures')
            ->assertJsonPath('data.model.filename', 'model.glb');
    }

    public function test_get_assets_returns_404_when_model_missing(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/clothingModel/999/assets');

        $response->assertStatus(404)->assertJson(['message' => 'Clothing model not found']);
    }
}
