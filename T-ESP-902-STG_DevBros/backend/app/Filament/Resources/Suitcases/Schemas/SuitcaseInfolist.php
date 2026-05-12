<?php

namespace App\Filament\Resources\Suitcases\Schemas;

use App\Models\Suitcase;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

class SuitcaseInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Valise')
                    ->schema([
                        TextEntry::make('name')
                            ->label('Nom'),
                        TextEntry::make('destination')
                            ->label('Destination'),
                        TextEntry::make('user.full_name')
                            ->label('Utilisateur')
                            ->default('-'),
                        TextEntry::make('user.email')
                            ->label('Email')
                            ->default('-'),
                        TextEntry::make('departure_date')
                            ->label('Date de depart')
                            ->date(),
                        TextEntry::make('end_date')
                            ->label('Date de fin')
                            ->date(),
                        TextEntry::make('clothings_total')
                            ->label('Vetements')
                            ->state(fn (Suitcase $record): int => $record->clothings()->count()),
                        TextEntry::make('created_at')
                            ->label('Cree le')
                            ->dateTime(),
                    ])
                    ->columns(2),
            ]);
    }
}
