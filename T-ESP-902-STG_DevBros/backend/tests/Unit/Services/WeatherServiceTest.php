<?php

namespace Tests\Unit\Services;

use App\Services\WeatherService;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class WeatherServiceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        config(['services.openweather.key' => 'fake-key']);
    }

    public function test_return_aggregated_weather_data_when_api_success()
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response([
                'list' => [
                    [
                        'dt' => strtotime('2025-10-28 12:00:00'),
                        'main' => ['temp_min' => 14.0, 'temp_max' => 16.0],
                        'weather' => [['description' => 'rain', 'icon' => '10d']]
                    ],
                    [
                        'dt' => strtotime('2025-10-29 12:00:00'),
                        'main' => ['temp_min' => 18.0, 'temp_max' => 22.0],
                        'weather' => [['description' => 'rain', 'icon' => '10d']]
                    ],
                    [
                        'dt' => strtotime('2025-10-29 18:00:00'),
                        'main' => ['temp_min' => 15.0, 'temp_max' => 19.0],
                        'weather' => [['description' => 'sun', 'icon' => '01d']]
                    ],
                ]
            ], 200)
        ]);

        $service = new WeatherService();
        $result = $service->getWeather('Paris', '2025-10-28', '2025-10-29');

        $this->assertSame(14, $result['temp_min']);
        $this->assertSame(22, $result['temp_max']);
        $this->assertSame('Rain', $result['condition']);
        $this->assertSame('10d', $result['icon_code']);
    }

    public function test_return_seasonal_fallback_when_api_fails()
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response('Server Error', 500)
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-10-28', '2025-10-29');

        $this->assertEquals([
            'temp_min' => 12,
            'temp_max' => 20,
            'condition' => 'Nuageux',
            'icon_code' => '03d'
        ], $result);
    }

    public function test_return_winter_seasonal_average_for_january(): void
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response([], 404)
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-01-15', '2025-01-16');

        $this->assertSame([
            'temp_min' => 2,
            'temp_max' => 8,
            'condition' => 'Frais & Nuageux',
            'icon_code' => '04d'
        ], $result);
    }

    public function test_return_spring_seasonal_average_for_april(): void
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response([], 500)
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-04-15', '2025-04-16');

        $this->assertSame([
            'temp_min' => 10,
            'temp_max' => 18,
            'condition' => 'Éclaircies',
            'icon_code' => '02d'
        ], $result);
    }

    public function test_return_summer_seasonal_average_for_july(): void
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response([], 500)
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-07-15', '2025-07-16');

        $this->assertSame([
            'temp_min' => 18,
            'temp_max' => 28,
            'condition' => 'Ensoleillé',
            'icon_code' => '01d'
        ], $result);
    }

    public function test_return_default_seasonal_average_for_autumn(): void
    {
        Http::fake([
            'https://api.openweathermap.org/*' => Http::response([], 500)
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-10-15', '2025-10-16');

        $this->assertSame([
            'temp_min' => 12,
            'temp_max' => 20,
            'condition' => 'Nuageux',
            'icon_code' => '03d'
        ], $result);
    }

    public function test_return_seasonal_fallback_when_http_throws_exception(): void
    {
        Http::fake([
            'https://api.openweathermap.org/*' => function () {
                throw new \Exception('Connection timeout');
            }
        ]);

        $service = new WeatherService();

        $result = $service->getWeather('Paris', '2025-04-01', '2025-04-02');

        $this->assertSame([
            'temp_min' => 10,
            'temp_max' => 18,
            'condition' => 'Éclaircies',
            'icon_code' => '02d'
        ], $result);
    }
}
