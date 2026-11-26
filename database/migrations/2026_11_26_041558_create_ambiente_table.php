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
        Schema::create('ambiente', function (Blueprint $table) {
            $table->integer('id_ambiente', true);
            $table->string('numero', 20);
            $table->string('nombre', 100);
            $table->string('ubicacion', 150);
            $table->integer('capacidad');
            $table->string('descripcion')->nullable();
            $table->string('estado', 20)->default('disponible');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ambiente');
    }
};
