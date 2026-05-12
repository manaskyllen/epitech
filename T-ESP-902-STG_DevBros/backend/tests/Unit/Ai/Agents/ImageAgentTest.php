<?php

namespace Tests\Unit\Ai\Agents;

use App\Ai\Agents\ImageAgent;
use Illuminate\Contracts\JsonSchema\JsonSchema;
use Mockery;
use Tests\TestCase;

class ImageAgentTest extends TestCase
{
    protected function tearDown(): void
    {
        Mockery::close();

        parent::tearDown();
    }

    public function test_instructions_return_expected_text(): void
    {
        $agent = new ImageAgent();

        $this->assertSame(
            'You are role is to analyze the image provided and return a description of the image.',
            $agent->instructions()
        );
    }

    public function test_messages_and_tools_are_empty(): void
    {
        $agent = new ImageAgent();

        $this->assertSame([], iterator_to_array($agent->messages()));
        $this->assertSame([], iterator_to_array($agent->tools()));
    }

    public function test_schema_defines_success_validation_and_data(): void
    {
        $schema = Mockery::mock(JsonSchema::class);
        $schema->shouldReceive('boolean')->andReturnSelf();
        $schema->shouldReceive('number')->andReturnSelf();
        $schema->shouldReceive('string')->andReturnSelf();
        $schema->shouldReceive('array')->andReturnSelf();
        $schema->shouldReceive('object')->andReturnSelf();
        $schema->shouldReceive('enum')->andReturnSelf();
        $schema->shouldReceive('nullable')->andReturnSelf();
        $schema->shouldReceive('description')->andReturnSelf();

        $agent = new ImageAgent();
        $result = $agent->schema($schema);

        $this->assertIsArray($result);
        $this->assertArrayHasKey('success', $result);
        $this->assertArrayHasKey('validation', $result);
        $this->assertArrayHasKey('data', $result);
    }
}
