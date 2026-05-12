<?php

namespace App\Filament\Widgets;

use App\Models\Clothing;
use App\Support\AdminOptions;
use Filament\Widgets\ChartWidget;

class ClothingByTypeChart extends ChartWidget
{
    protected ?string $heading = 'Repartition des vetements par type';

    protected ?string $pollingInterval = '60s';

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $counts = Clothing::query()
            ->select('itemType')
            ->selectRaw('COUNT(*) as aggregate')
            ->groupBy('itemType')
            ->pluck('aggregate', 'itemType');

        $labels = [];
        $data = [];

        foreach (AdminOptions::clothingItemTypes() as $value => $label) {
            $labels[] = $label;
            $data[] = (int) ($counts[$value] ?? 0);
        }

        return [
            'datasets' => [
                [
                    'label' => 'Vetements',
                    'data' => $data,
                    'backgroundColor' => [
                        '#F59E0B',
                        '#3B82F6',
                        '#10B981',
                        '#8B5CF6',
                        '#EF4444',
                    ],
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}
