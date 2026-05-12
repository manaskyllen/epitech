<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('clothing', function (Blueprint $table) {
            $table->enum('itemSubtype', ['T-shirt','Tank top','Blouse','Sweatshirt','Sweater','Cardigan','Jeans','Pants','Shorts','Skirt','Leggings','Dress','Jumpsuit','Jacket','Coat','Trench coat','Puffer jacket','Swimsuit','Bra','Panties','Pajamas','Sneakers','Boots','Sandals','Heels','Hat','Scarf','Belt','Bag']);
            $table->string('color')->after('itemSubtype');
            $table->string('size')->after('color');
            $table->string('style')->after('size')->nullable();
            $table->string('season')->after('style')->nullable();
            $table->string('fabric')->after('season')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

    }
};
