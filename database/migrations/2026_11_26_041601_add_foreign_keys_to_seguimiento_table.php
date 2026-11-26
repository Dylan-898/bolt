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
        Schema::table('seguimiento', function (Blueprint $table) {
            $table->foreign(['id_asignacion'], 'fk_seg_asignacion')->references(['id_asignacion'])->on('asignacion')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_usuario'], 'fk_seg_usuario')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('seguimiento', function (Blueprint $table) {
            $table->dropForeign('fk_seg_asignacion');
            $table->dropForeign('fk_seg_usuario');
        });
    }
};
