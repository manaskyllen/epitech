<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Nette\Utils\Random;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_index(): void
    {
        $user = User::factory()->create([
            'firstname' => 'John',
            'lastname' => 'Doe',
            'email' => 'john@doe.fr',
            'profilePictureUrl' => 'https://example.com/profile.jpg',
            'sso' => 'some-sso-id',
            'password' => bcrypt('password123'), 
            'isActif' => true,
            'newsletter' => false,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/user');

        $response->assertStatus(200);
    }

    public function test_store(): void
    {
         $user = User::factory()->create([
            'firstname' => 'John',
            'lastname' => 'Doe',
            'email' => 'john@doe.fr',
            'profilePictureUrl' => 'https://example.com/profile.jpg',
            'sso' => 'some-sso-id',
            'password' => bcrypt('password123'), 
            'isActif' => true,
            'newsletter' => false,
        ]);

        $data = [
            'firstname' => 'Jane',
            'lastname' => 'Moe',
            'email' => 'jane@moe.fr',
            'profilePictureUrl' => 'https://example.com/jane.jpg',
            'sso' => 'another-sso-id',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'isActif' => true,
            'newsletter' => false
        ];

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/user', $data);

        $response->assertStatus(201);
    }

    public function test_show(): void
    {
         $user = User::factory()->create([
            'firstname' => 'John',
            'lastname' => 'Doe',
            'email' => 'john@doe.fr',
            'profilePictureUrl' => 'https://example.com/profile.jpg',
            'sso' => 'some-sso-id',
            'password' => bcrypt('password123'), 
            'isActif' => true,
            'newsletter' => false,
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/user/$user->id");

        $response->assertStatus(200);
    }

    public function test_update(): void
    {
         $user = User::factory()->create([
            'firstname' => 'John',
            'lastname' => 'Doe',
            'email' => 'john@doe.fr',
            'profilePictureUrl' => 'https://example.com/profile.jpg',
            'sso' => 'some-sso-id',
            'password' => bcrypt('password123'), 
            'isActif' => true,
            'newsletter' => false,
        ]);

        $data = [
            'firstname' => 'Jane',
            'lastname' => 'Moe',
            'email' => 'jane@moe.fr'
        ];

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/user/$user->id", $data);

        $response->assertStatus(200);
    }

    public function test_destroy(): void
    {
        $user = User::factory()->create([
            'firstname' => 'John',
            'lastname' => 'Doe',
            'email' => 'john@doe.fr',
            'profilePictureUrl' => 'https://example.com/profile.jpg',
            'sso' => 'some-sso-id',
            'password' => bcrypt('password123'), 
            'isActif' => true,
            'newsletter' => false,
        ]);
        
        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/user/$user->id");
        $response->assertStatus(204);
    }
}
