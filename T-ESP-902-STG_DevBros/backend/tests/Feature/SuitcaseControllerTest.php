<?php

namespace Tests\Feature;

use App\Models\ClothingModel;
use App\Models\User;
use App\Models\Suitcase;
use App\Models\Clothing;
use App\Services\WeatherService;
use App\Services\SuitcaseGenerator;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Mockery;
use Tests\TestCase;

class SuitcaseControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
    }


    public function test_list_user_suitcases()
    {
        $this->actingAs($this->user);

        Suitcase::factory()->count(2)->for($this->user)->create();

        $response = $this->getJson('/api/suitcases');

        $response->assertStatus(200)
            ->assertJsonCount(2);
    }

    public function test_create_a_suitcase_and_calls_weather_and_generator_services()
    {
        $this->actingAs($this->user);

        $weatherService = Mockery::mock(WeatherService::class);
        $weatherService->shouldReceive('getWeather')->once()->andReturn([
            '2025-10-28' => 15,
            '2025-10-29' => 20,
        ]);

        $suitcaseGenerator = Mockery::mock(SuitcaseGenerator::class);
        $suitcaseGenerator->shouldReceive('generate')->once()->andReturn(['id' => 1, 'name' => 'Paris Trip']);

        $this->app->instance(WeatherService::class, $weatherService);
        $this->app->instance(SuitcaseGenerator::class, $suitcaseGenerator);

        $data = [
            'name' => 'Paris Trip',
            'departure_date' => '2025-10-28',
            'end_date' => '2025-10-29',
            'destination' => 'Paris',
        ];

        $response = $this->postJson('/api/suitcase', $data);

        $response->assertStatus(201)
            ->assertJsonFragment(['name' => 'Paris Trip']);
    }

    public function test_show_a_single_suitcase()
    {
        $this->actingAs($this->user);

        $suitcase = Suitcase::factory()->for($this->user)->create();

        $response = $this->getJson("/api/suitcase/{$suitcase->id}");

        $response->assertStatus(200)
            ->assertJsonFragment(['id' => $suitcase->id]);
    }

    public function test_return_404_if_suitcase_not_found()
    {
        $this->actingAs($this->user);

        $response = $this->getJson("/api/suitcase/999");

        $response->assertStatus(404);
    }

    public function test_update_a_suitcase()
    {
        $this->actingAs($this->user);

        $suitcase = Suitcase::factory()->for($this->user)->create();

        $response = $this->putJson("/api/suitcase/{$suitcase->id}", [
            'name' => 'Updated name',
        ]);

        $response->assertStatus(200)
            ->assertJsonFragment(['name' => 'Updated name']);
    }

    public function test_delete_a_suitcase()
    {
        $this->actingAs($this->user);

        $suitcase = Suitcase::factory()->for($this->user)->create();

        $response = $this->deleteJson("/api/suitcase/{$suitcase->id}");

        $response->assertStatus(200)
            ->assertJsonFragment(['message' => 'Valise supprimée avec succès']);
    }

    public function test_add_clothing_to_suitcase(): void
    {
        $this->actingAs($this->user);

        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $this->user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $suitcase = Suitcase::factory()->for($this->user)->create();

        $response = $this->postJson("/api/suitcase/{$suitcase->id}/add-clothing", [
            'clothing_id' => $clothing->id,
        ]);

        $response->assertStatus(200)
            ->assertJsonFragment(['message' => 'Clothe add into suitcase']);
    }

    public function test_remove_clothing_from_suitcase(): void
    {
        $this->actingAs($this->user);

        $clothingModel = ClothingModel::factory()->create();
        $clothing = Clothing::factory()->create([
            'user_id' => $this->user->id,
            'clothingModel_id' => $clothingModel->id,
        ]);

        $suitcase = Suitcase::factory()->for($this->user)->create();
        $suitcase->clothings()->attach($clothing->id);

        $response = $this->postJson("/api/suitcase/{$suitcase->id}/remove-clothing", [
            'clothing_id' => $clothing->id,
        ]);

        $response->assertStatus(200)
            ->assertJsonFragment(['message' => 'Clothe remove from suitcase']);
    }

    public function test_add_clothing_returns_404_when_suitcase_not_found(): void
    {
        $this->actingAs($this->user);

        $response = $this->postJson('/api/suitcase/999/add-clothing', [
            'clothing_id' => 1,
        ]);

        $response->assertStatus(404);
    }

    public function test_remove_clothing_returns_404_when_suitcase_not_found(): void
    {
        $this->actingAs($this->user);

        $response = $this->postJson('/api/suitcase/999/remove-clothing', [
            'clothing_id' => 1,
        ]);

        $response->assertStatus(404);
    }
}
