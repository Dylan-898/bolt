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
        Schema::table('usuario_rol', function (Blueprint $table) {
            $table->foreign(['id_rol'], 'fk_ur_rol')->references(['id_rol'])->on('rol')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_usuario'], 'fk_ur_usuario')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('usuario_rol', function (Blueprint $table) {
            $table->dropForeign('fk_ur_rol');
            $table->dropForeign('fk_ur_usuario');
        });
    }
};
