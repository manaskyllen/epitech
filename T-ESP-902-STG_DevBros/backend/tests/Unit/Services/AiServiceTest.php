<?php

namespace Tests\Unit\Services;

use App\Ai\Agents\ImageAgent;
use App\Services\AiService;
use Illuminate\Http\UploadedFile;
use Laravel\Ai\Responses\AgentResponse;
use Mockery;
use Tests\TestCase;

class AiServiceTest extends TestCase
{
    protected function tearDown(): void
    {
        Mockery::close();

        parent::tearDown();
    }

    public function test_inspect_clothing_file_forwards_request_to_image_agent(): void
    {
        $expectedResponse = Mockery::mock(AgentResponse::class);

        $file = UploadedFile::fake()->image('clothing.jpg');
        
        $serviceMock = Mockery::mock(ImageAgent::class);
        $serviceMock->shouldReceive('prompt')
            ->once()
            ->with(
                'Analyze the provided image and return a description of the image.',
                [$file],
                \Laravel\Ai\Enums\Lab::Gemini,
                'gemini-3.1-flash-lite-preview'
            )
            ->andReturn($expectedResponse);

        $service = new AiService($serviceMock);
        $response = $service->inspectClothingFile($file);

        $this->assertSame($expectedResponse, $response);
    }
}
