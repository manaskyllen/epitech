<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AddressesRelationManager extends RelationManager
{
    protected static string $relationship = 'addresses';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('street1')
                    ->label('Adresse 1')
                    ->required()
                    ->maxLength(255),
                TextInput::make('street2')
                    ->label('Adresse 2')
                    ->maxLength(255),
                TextInput::make('city')
                    ->label('Ville')
                    ->required()
                    ->maxLength(255),
                TextInput::make('zipCode')
                    ->label('Code postal')
                    ->required()
                    ->maxLength(20),
                TextInput::make('country')
                    ->label('Pays')
                    ->required()
                    ->maxLength(100),
            ]);
    }

    public function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('street1')->label('Adresse 1'),
                TextEntry::make('street2')->label('Adresse 2')->default('-'),
                TextEntry::make('city')->label('Ville'),
                TextEntry::make('zipCode')->label('Code postal'),
                TextEntry::make('country')->label('Pays'),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('street1')
            ->columns([
                TextColumn::make('street1')
                    ->label('Adresse 1')
                    ->searchable(),
                TextColumn::make('city')
                    ->label('Ville')
                    ->searchable(),
                TextColumn::make('country')
                    ->label('Pays')
                    ->badge(),
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
