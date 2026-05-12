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
            $table->string('color')->nullable()->change();
            $table->string('size')->nullable()->change();
            $table->string('style')->nullable()->change();
            $table->string('season')->nullable()->change();
            $table->string('fabric')->nullable()->change();
            $table->string('texture')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('clothing', function (Blueprint $table) {
            $table->string('color')->change();
            $table->string('size')->change();
            $table->string('style')->change();
            $table->string('season')->change();
            $table->string('fabric')->change();
            $table->string('texture')->change();
        });
    }
};
