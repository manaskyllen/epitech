<?php

namespace App\Filament\Resources\Clothing;

use App\Filament\Resources\Clothing\Pages\CreateClothing;
use App\Filament\Resources\Clothing\Pages\EditClothing;
use App\Filament\Resources\Clothing\Pages\ListClothing;
use App\Filament\Resources\Clothing\Pages\ViewClothing;
use App\Filament\Resources\Clothing\Schemas\ClothingForm;
use App\Filament\Resources\Clothing\Schemas\ClothingInfolist;
use App\Filament\Resources\Clothing\Tables\ClothingTable;
use App\Models\Clothing;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class ClothingResource extends Resource
{
    protected static ?string $model = Clothing::class;

    protected static ?string $recordTitleAttribute = 'itemSubtype';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSwatch;

    protected static string|UnitEnum|null $navigationGroup = 'Dressing';

    protected static ?int $navigationSort = 1;

    protected static ?string $modelLabel = 'vetement';

    protected static ?string $pluralModelLabel = 'vetements';

    public static function form(Schema $schema): Schema
    {
        return ClothingForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return ClothingInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ClothingTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListClothing::route('/'),
            'create' => CreateClothing::route('/create'),
            'view' => ViewClothing::route('/{record}'),
            'edit' => EditClothing::route('/{record}/edit'),
        ];
    }
}
