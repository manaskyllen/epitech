<?php

namespace App\Services;

use App\Models\Suitcase;
use App\Models\Clothing;

class SuitcaseGenerator
{
    public function generate(Suitcase $suitcase, array $forecast, int $userId): array
    {
        $days = $suitcase->departure_date->diffInDays($suitcase->end_date) + 1;
        $rules = config('suitcase_rules');
        $required = [];

        foreach ($rules['base'] as $type => $rule) {
            if (isset($rule['per_day'])) {
                $required[$type] = $days * $rule['per_day'];
            } elseif (isset($rule['per_days'])) {
                $required[$type] = ceil($days / $rule['per_days']);
            } elseif (isset($rule['min'])) {
                $required[$type] = $rule['min'];
            }
        }

        $minTemp = $forecast['temp_min'] ?? 15;
        $maxTemp = $forecast['temp_max'] ?? 20;

        if ($minTemp < 15) {
            foreach ($rules['temperature']['cold'] ?? [] as $type => $rule) {
                $required[$type] = max($required[$type] ?? 0, $rule['min'] ?? 0);
            }
        }
        if ($maxTemp >= 25) {
            foreach ($rules['temperature']['hot'] ?? [] as $type => $rule) {
                if (isset($rule['per_days'])) {
                    $required[$type] = max($required[$type] ?? 0, ceil($days / $rule['per_days']));
                } elseif (isset($rule['min'])) {
                    $required[$type] = max($required[$type] ?? 0, $rule['min']);
                }
            }
        }
        if ($maxTemp >= 15 && $minTemp < 25) {
            foreach ($rules['temperature']['mild'] ?? [] as $type => $rule) {
                $required[$type] = max($required[$type] ?? 0, $rule['min'] ?? 0);
            }
        }

        $dbMapping = [
            't-shirt'       => 'T-shirt',
            'pantalon'      => 'Pants',
            'pull'          => 'Sweater',
            'chaussettes'   => 'Socks', // (Assurez-vous d'avoir 'Socks' dans itemSubtype ou itemType)
            'sous-vêtement' => 'Underwear', // ou 'Panties'/'Bra' selon votre logique
            'manteau'       => 'Coat',
            'chaussures'    => 'Sneakers', // ou une recherche plus large sur itemType='shoes'
            'pyjama'        => 'Pajamas',
            'veste légère'  => 'Jacket',
            'short'         => 'Shorts',
            // Ajoutez les autres ici...
        ];

        $warnings = [];
        $selected = collect();

        foreach ($required as $ruleKey => $quantity) {
            $dbSearchTerm = $dbMapping[$ruleKey] ?? ucfirst($ruleKey);

            $available = Clothing::where('user_id', $userId)
                ->where(function($query) use ($dbSearchTerm) {
                    $query->where('itemSubtype', $dbSearchTerm)
                        ->orWhere('itemType', $dbSearchTerm);
                })
                ->take($quantity)
                ->get();

            if ($available->count() < $quantity) {
                $warnings[$ruleKey] = $quantity - $available->count();
            }
            $selected = $selected->merge($available);
        }

        $selectedIds = $selected->pluck('id')->unique();

        $suitcase->clothings()->sync($selectedIds);

        return [
            'suitcase' => $suitcase->load('clothings'),
            'warnings' => $warnings,
        ];
    }
}
