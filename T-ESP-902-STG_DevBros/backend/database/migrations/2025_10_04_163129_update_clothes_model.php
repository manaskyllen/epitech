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
        Schema::table('clothing_models', function (Blueprint $table) {
            $table->dropColumn('material');
            

            $table->string('texture')->nullable()->after('model');
            $table->string('slots')->nullable()->after('texture');
            
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('clothing_models', function (Blueprint $table) {
            $table->longText('material')->after('name');
            
            $table->dropColumn(['texture', 'slots']);
        });
    }
};