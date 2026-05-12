<?php

namespace App\Filament\Widgets;

use App\Models\Clothing;
use App\Models\Favorite;
use App\Models\Outfit;
use App\Models\Suitcase;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AdminOverview extends StatsOverviewWidget
{
    protected ?string $pollingInterval = '30s';

    protected int|string|array $columnSpan = 'full';

    protected function getStats(): array
    {
        $usersCount = User::query()->count();
        $activeUsersCount = User::query()->where('isActif', true)->count();
        $adminUsersCount = User::query()->where('is_admin', true)->count();
        $clothingsCount = Clothing::query()->count();
        $outfitsCount = Outfit::query()->count();
        $suitcasesCount = Suitcase::query()->count();
        $favoritesCount = Favorite::query()->count();

        return [
            Stat::make('Utilisateurs', number_format($usersCount))
                ->description("{$activeUsersCount} actifs")
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('primary'),
            Stat::make('Admins', number_format($adminUsersCount))
                ->description('Comptes autorises au dashboard')
                ->descriptionIcon('heroicon-m-shield-check')
                ->color('success'),
            Stat::make('Vetements', number_format($clothingsCount))
                ->description('Articles dans le dressing')
                ->descriptionIcon('heroicon-m-swatch')
                ->color('warning'),
            Stat::make('Outfits', number_format($outfitsCount))
                ->description('Looks enregistres')
                ->descriptionIcon('heroicon-m-sparkles')
                ->color('info'),
            Stat::make('Valises', number_format($suitcasesCount))
                ->description('Preparations de voyage')
                ->descriptionIcon('heroicon-m-briefcase')
                ->color('gray'),
            Stat::make('Favoris', number_format($favoritesCount))
                ->description('Selections sauvegardees')
                ->descriptionIcon('heroicon-m-heart')
                ->color('danger'),
        ];
    }
}
