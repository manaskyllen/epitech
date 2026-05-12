<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AddressTest extends TestCase
{
    use RefreshDatabase;

    public function test_index(): void
    {
        $user = User::factory()->create();
        Address::factory()->create([
            'user_id' => $user->id,
        ]);
        $response = $this->actingAs($user, 'sanctum')->getJson('/api/address');

        $response->assertStatus(200);
    }

    public function test_show(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create([
            'user_id' => $user->id,
        ]);

        $addressId = $address->id;

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/address/$addressId");

        $response->assertStatus(200);
    }

    public function test_getAddressByUserId(): void
    {
        $user = User::factory()->create();
        Address::factory()->create([
            'user_id' => $user->id,
        ]);
        $userId = $user->id;

        $response = $this->actingAs($user, 'sanctum')->getJson("api/address/user/$userId");

        $response->assertStatus(200);
    }

    public function test_store(): void
    {
        $user = User::factory()->create();

        $data = [
            'street1' => '123 Main St',
            'city' => 'Anytown',
            'zipCode' => '12345',
            'country' => 'USA',
            'user_id' => $user->id,
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/address', $data);

        $response->assertStatus(201);
    }

    public function test_update(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create([
            'user_id' => $user->id,
        ]);
        $addressId = $address->id;
        $data = [
            'street1' => '456 Elm St',
            'city' => 'Othertown',
            'zipCode' => '67890',
            'country' => 'USA',
        ];
        $response = $this->actingAs($user, 'sanctum')->putJson("/api/address/$addressId", $data);

        $response->assertStatus(200);
    }

    public function test_delete(): void
    {
        $user = User::factory()->create();
        $address = Address::factory()->create([
            'user_id' => $user->id,
        ]);
        $addressId = $address->id;

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/address/$addressId");

        $response->assertStatus(204);
    }
}
