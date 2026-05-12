<?php

namespace App\Filament\Resources\Suitcases;

use App\Filament\Resources\Suitcases\Pages\CreateSuitcase;
use App\Filament\Resources\Suitcases\Pages\EditSuitcase;
use App\Filament\Resources\Suitcases\Pages\ListSuitcases;
use App\Filament\Resources\Suitcases\Pages\ViewSuitcase;
use App\Filament\Resources\Suitcases\RelationManagers\ClothingsRelationManager;
use App\Filament\Resources\Suitcases\Schemas\SuitcaseForm;
use App\Filament\Resources\Suitcases\Schemas\SuitcaseInfolist;
use App\Filament\Resources\Suitcases\Tables\SuitcasesTable;
use App\Models\Suitcase;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class SuitcaseResource extends Resource
{
    protected static ?string $model = Suitcase::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBriefcase;

    protected static string|UnitEnum|null $navigationGroup = 'Voyages';

    protected static ?int $navigationSort = 1;

    protected static ?string $modelLabel = 'valise';

    protected static ?string $pluralModelLabel = 'valises';

    public static function form(Schema $schema): Schema
    {
        return SuitcaseForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return SuitcaseInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return SuitcasesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            ClothingsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListSuitcases::route('/'),
            'create' => CreateSuitcase::route('/create'),
            'view' => ViewSuitcase::route('/{record}'),
            'edit' => EditSuitcase::route('/{record}/edit'),
        ];
    }
}
