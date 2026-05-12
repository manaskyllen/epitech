<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;

class WeatherService
{
    private string $apiKey;
    private string $baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

    public function __construct()
    {
        $this->apiKey = config('services.openweather.key');
    }

    public function getWeather(string $destination, string $startDate, string $endDate): array
    {
        try {
            $response = Http::timeout(3)->get($this->baseUrl, [
                'q' => $destination,
                'appid' => $this->apiKey,
                'units' => 'metric',
                'lang' => 'fr'
            ]);

            if ($response->successful()) {
                $data = $response->json();

                // On transforme en collection dès le départ
                $tripData = collect($data['list'] ?? [])->filter(function ($item) use ($startDate, $endDate) {
                    $ts = $item['dt'] ?? null;
                    if (!$ts) return false;

                    $itemDate = date('Y-m-d', $ts);
                    return $itemDate >= $startDate && $itemDate <= $endDate;
                });

                if ($tripData->isNotEmpty()) {
                    return $this->formatRealData($tripData);
                }
            } else {
                Log::warning('Weather API Error: ' . $response->body());
            }

        } catch (\Exception $e) {
            Log::error('Weather Service Exception: ' . $e->getMessage());
        }

        return $this->getSeasonalAverage($startDate);
    }

    /**
     * Formate les données réelles de l'API avec calcul de dominance
     */
    private function formatRealData(Collection $tripData): array
    {
        // Extraction des températures
        $minTemp = round($tripData->min('main.temp_min'));
        $maxTemp = round($tripData->max('main.temp_max'));

        // On mappe pour extraire proprement les infos météo de l'index 0
        $weatherDetails = $tripData->map(function ($item) {
            return [
                'description' => $item['weather'][0]['description'] ?? 'Inconnu',
                'icon' => $item['weather'][0]['icon'] ?? '01d',
            ];
        });

        // Calcul de la description la plus fréquente
        $dominantCondition = $weatherDetails->groupBy('description')
            ->sortByDesc->count()
            ->keys()
            ->first();

        // Calcul de l'icône la plus fréquente (ex: 09d, 10d pour la pluie)
        $dominantIcon = $weatherDetails->groupBy('icon')
            ->sortByDesc->count()
            ->keys()
            ->first();

        return [
            'temp_min' => (int) $minTemp,
            'temp_max' => (int) $maxTemp,
            'condition' => ucfirst($dominantCondition),
            'icon_code' => $dominantIcon
        ];
    }

    /**
     * Génère une météo estimée selon le mois (Fallback)
     */
    private function getSeasonalAverage(string $date): array
    {
        $timestamp = strtotime($date);
        $month = $timestamp ? (int) date('m', $timestamp) : (int) date('m');

        return match (true) {
            in_array($month, [12, 1, 2]) => [
                'temp_min' => 2, 'temp_max' => 8, 'condition' => 'Frais & Nuageux', 'icon_code' => '04d'
            ],
            in_array($month, [3, 4, 5]) => [
                'temp_min' => 10, 'temp_max' => 18, 'condition' => 'Éclaircies', 'icon_code' => '02d'
            ],
            in_array($month, [6, 7, 8]) => [
                'temp_min' => 18, 'temp_max' => 28, 'condition' => 'Ensoleillé', 'icon_code' => '01d'
            ],
            default => [
                'temp_min' => 12, 'temp_max' => 20, 'condition' => 'Nuageux', 'icon_code' => '03d'
            ],
        };
    }
}
