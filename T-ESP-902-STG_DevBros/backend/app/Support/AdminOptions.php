<?php

namespace App\Support;

class AdminOptions
{
    public static function clothingItemTypes(): array
    {
        return [
            'top' => 'Top',
            'bottom' => 'Bas',
            'accessories' => 'Accessoires',
            'shoes' => 'Chaussures',
            'Headwear' => 'Couvre-chef',
        ];
    }

    public static function clothingItemSubtypes(): array
    {
        return [
            'T-shirt' => 'T-shirt',
            'Tank top' => 'Débardeur',
            'Blouse' => 'Blouse',
            'Sweatshirt' => 'Sweatshirt',
            'Sweater' => 'Pull',
            'Cardigan' => 'Cardigan',
            'Jeans' => 'Jean',
            'Pants' => 'Pantalon',
            'Shorts' => 'Short',
            'Skirt' => 'Jupe',
            'Leggings' => 'Legging',
            'Dress' => 'Robe',
            'Jumpsuit' => 'Combinaison',
            'Jacket' => 'Veste',
            'Coat' => 'Manteau',
            'Trench coat' => 'Trench',
            'Puffer jacket' => 'Doudoune',
            'Swimsuit' => 'Maillot',
            'Bra' => 'Soutien-gorge',
            'Panties' => 'Culotte',
            'Pajamas' => 'Pyjama',
            'Sneakers' => 'Baskets',
            'Boots' => 'Bottes',
            'Sandals' => 'Sandales',
            'Heels' => 'Talons',
            'Hat' => 'Chapeau',
            'Scarf' => 'Echarpe',
            'Belt' => 'Ceinture',
            'Bag' => 'Sac',
        ];
    }

    public static function seasons(): array
    {
        return [
            'spring' => 'Printemps',
            'summer' => 'Ete',
            'autumn' => 'Automne',
            'winter' => 'Hiver',
            'Spring' => 'Printemps',
            'Summer' => 'Ete',
            'Autumn' => 'Automne',
            'Winter' => 'Hiver',
        ];
    }

    public static function genders(): array
    {
        return [
            'male' => 'Homme',
            'female' => 'Femme',
            'unisex' => 'Unisexe',
        ];
    }

    public static function clothingSlots(): array
    {
        return [
            'body' => 'Corps',
            'legs' => 'Jambes',
            'feet' => 'Pieds',
            'head' => 'Tete',
            'accessories' => 'Accessoires',
            'full_body' => 'Corps complet',
            'unknown_slots' => 'Non defini',
        ];
    }
}
