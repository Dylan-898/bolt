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
        Schema::table('novedad_ambiente', function (Blueprint $table) {
            $table->foreign(['id_ambiente'], 'fk_novedad_ambiente')->references(['id_ambiente'])->on('ambiente')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_usuario'], 'fk_novedad_usuario')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('novedad_ambiente', function (Blueprint $table) {
            $table->dropForeign('fk_novedad_ambiente');
            $table->dropForeign('fk_novedad_usuario');
        });
    }
};
