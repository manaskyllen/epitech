<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SuitcasesRelationManager extends RelationManager
{
    protected static string $relationship = 'suitcases';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('Nom')
                    ->required()
                    ->maxLength(255),
                TextInput::make('destination')
                    ->label('Destination')
                    ->required()
                    ->maxLength(255),
                DatePicker::make('departure_date')
                    ->label('Date de depart')
                    ->required(),
                DatePicker::make('end_date')
                    ->label('Date de fin')
                    ->required(),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('name')->label('Nom'),
                TextEntry::make('destination')->label('Destination'),
                TextEntry::make('departure_date')->label('Date de depart')->date(),
                TextEntry::make('end_date')->label('Date de fin')->date(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->searchable(),
                TextColumn::make('destination')
                    ->label('Destination')
                    ->searchable(),
                TextColumn::make('departure_date')
                    ->label('Depart')
                    ->date(),
                TextColumn::make('end_date')
                    ->label('Retour')
                    ->date(),
                TextColumn::make('clothings_count')
                    ->label('Vetements')
                    ->counts('clothings'),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                CreateAction::make(),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
