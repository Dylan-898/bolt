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
        Schema::create('novedad_ambiente', function (Blueprint $table) {
            $table->integer('id_novedad', true);
            $table->integer('id_ambiente')->index('fk_novedad_ambiente');
            $table->integer('id_usuario')->index('fk_novedad_usuario');
            $table->dateTime('fecha')->useCurrent();
            $table->text('descripcion');
            $table->string('estado', 20)->default('abierta');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('novedad_ambiente');
    }
};
