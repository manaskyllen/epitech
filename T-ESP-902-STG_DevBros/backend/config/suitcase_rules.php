<?php

return [
    'base' => [
        't-shirt' => ['per_day' => 1],
        'sous-vêtement' => ['per_day' => 1],
        'chaussettes' => ['per_day' => 1],
        'pantalon' => ['per_days' => 3],
        'pyjama' => ['min' => 1],
        'chaussures' => ['min' => 1],
    ],

    'temperature' => [
        'cold' => [ // < 15°C
            'pull' => ['min' => 1],
            'manteau' => ['min' => 1],
            'écharpe' => ['min' => 1],
            'gants' => ['min' => 1],
            'bonnet' => ['min' => 1],
        ],
        'mild' => [ // 15°C - 25°C
            'veste légère' => ['min' => 1],
        ],
        'hot' => [ // > 25°C
            'short' => ['per_days' => 2],
            'maillot de bain' => ['min' => 1],
            'sandales' => ['min' => 1],
        ],
    ],

    'conditions' => [
        'rain' => [
            'k-way' => ['min' => 1],
            'parapluie' => ['min' => 1],
        ],
        'snow' => [
            'après-ski' => ['min' => 1],
            'gants' => ['min' => 1],
            'bonnet' => ['min' => 1],
        ],
    ],
];
