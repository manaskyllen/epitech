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
        Schema::create('suitcases', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->date('departure_date');
            $table->date('end_date');
            $table->unsignedBigInteger('user_id');
            $table->string('destination');
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });

        Schema::create('clothing_suitcase', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('suitcase_id');
            $table->unsignedBigInteger('clothing_id');
            $table->timestamps();

            $table->foreign('suitcase_id')->references('id')->on('suitcases')->onDelete('cascade');
            $table->foreign('clothing_id')->references('id')->on('clothing')->onDelete('cascade');
            $table->unique(['suitcase_id', 'clothing_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('clothing_suitcase');
        Schema::dropIfExists('suitcases');
    }
};
