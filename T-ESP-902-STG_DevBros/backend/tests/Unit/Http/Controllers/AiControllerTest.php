<?php

namespace Tests\Unit\Http\Controllers;

use App\Http\Controllers\AiController;
use App\Services\AiService;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Mockery;
use Tests\TestCase;
use Illuminate\Validation\ValidationException;

class AiControllerTest extends TestCase
{
    protected function tearDown(): void
    {
        Mockery::close();

        parent::tearDown();
    }

    public function test_analyze_clothing_image_returns_service_response_json(): void
    {
        $file = UploadedFile::fake()->image('clothing.jpg');
        $request = Request::create('/api/ai/inspect/clothing', 'POST', [], [], ['file' => $file]);

        $expectedResponse = ['success' => true, 'validation' => ['clothing_detected' => true]];

        $serviceMock = Mockery::mock(AiService::class);
        $serviceMock->shouldReceive('inspectClothingFile')
            ->once()
            ->with($file)
            ->andReturn($expectedResponse);

        $this->app->instance(AiService::class, $serviceMock);
        $controller = new AiController($serviceMock);
        $response = $controller->analyzeClothingImage($request);

        $this->assertSame(200, $response->getStatusCode());
        $this->assertSame($expectedResponse, $response->getData(true));
    }

    public function test_analyze_clothing_image_validates_file_input(): void
    {
        $this->expectException(ValidationException::class);

        $request = Request::create('/api/ai/inspect/clothing', 'POST');

        $serviceMock = Mockery::mock(AiService::class);
        $controller = new AiController($serviceMock);

        $controller->analyzeClothingImage($request);
    }
}
