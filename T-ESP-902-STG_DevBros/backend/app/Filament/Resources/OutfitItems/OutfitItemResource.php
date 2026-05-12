<?php

namespace App\Filament\Resources\OutfitItems;

use App\Filament\Resources\OutfitItems\Pages\CreateOutfitItem;
use App\Filament\Resources\OutfitItems\Pages\EditOutfitItem;
use App\Filament\Resources\OutfitItems\Pages\ListOutfitItems;
use App\Filament\Resources\OutfitItems\Pages\ViewOutfitItem;
use App\Filament\Resources\OutfitItems\Schemas\OutfitItemForm;
use App\Filament\Resources\OutfitItems\Schemas\OutfitItemInfolist;
use App\Filament\Resources\OutfitItems\Tables\OutfitItemsTable;
use App\Models\OutfitItem;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class OutfitItemResource extends Resource
{
    protected static ?string $model = OutfitItem::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static string|UnitEnum|null $navigationGroup = 'Dressing';

    protected static ?int $navigationSort = 4;

    protected static ?string $modelLabel = 'item outfit';

    protected static ?string $pluralModelLabel = 'items outfit';

    public static function form(Schema $schema): Schema
    {
        return OutfitItemForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return OutfitItemInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return OutfitItemsTable::configure($table);
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
            'index' => ListOutfitItems::route('/'),
            'create' => CreateOutfitItem::route('/create'),
            'view' => ViewOutfitItem::route('/{record}'),
            'edit' => EditOutfitItem::route('/{record}/edit'),
        ];
    }
}
