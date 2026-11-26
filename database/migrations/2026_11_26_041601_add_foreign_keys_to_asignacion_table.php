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
        Schema::table('asignacion', function (Blueprint $table) {
            $table->foreign(['id_usuario_asigna'], 'fk_asig_asigna')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_usuario_atiende'], 'fk_asig_atiende')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_solicitud'], 'fk_asig_solicitud')->references(['id_solicitud'])->on('solicitud')->onUpdate('cascade')->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('asignacion', function (Blueprint $table) {
            $table->dropForeign('fk_asig_asigna');
            $table->dropForeign('fk_asig_atiende');
            $table->dropForeign('fk_asig_solicitud');
        });
    }
};
