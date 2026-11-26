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
        Schema::create('usuario', function (Blueprint $table) {
            $table->integer('id_usuario', true);
            $table->string('nombre', 80);
            $table->string('apellido', 80);
            $table->string('documento', 20)->unique('documento');
            $table->string('correo', 120)->unique('correo');
            $table->string('telefono', 20)->nullable();
            $table->string('contrasena');
            $table->string('estado', 20)->default('activo');
            $table->string('turno', 30)->nullable();
            $table->boolean('es_tecnica')->nullable();
            $table->string('ficha', 20)->nullable();
            $table->string('jornada', 30)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('usuario');
    }
};
