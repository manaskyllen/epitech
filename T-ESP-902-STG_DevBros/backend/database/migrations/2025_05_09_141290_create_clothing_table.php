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
        Schema::create('clothing', function (Blueprint $table) {
            $table->id();
            $table->enum('itemType', ['top', 'bottom', 'accessories', 'shoes', 'Headwear']);
            $table->string('texture');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('clothingModel_id')->constrained('clothing_models')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('clothing');
    }
};
