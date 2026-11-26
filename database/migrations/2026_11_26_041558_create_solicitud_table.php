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
        Schema::create('solicitud', function (Blueprint $table) {
            $table->integer('id_solicitud', true);
            $table->integer('id_usuario')->index('fk_solicitud_usuario');
            $table->dateTime('fecha')->useCurrent();
            $table->text('descripcion');
            $table->string('prioridad', 20)->default('media');
            $table->string('estado', 20)->default('pendiente');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('solicitud');
    }
};
