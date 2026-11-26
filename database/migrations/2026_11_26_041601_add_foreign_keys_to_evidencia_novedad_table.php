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
        Schema::table('evidencia_novedad', function (Blueprint $table) {
            $table->foreign(['id_novedad'], 'fk_evnov_novedad')->references(['id_novedad'])->on('novedad_ambiente')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('evidencia_novedad', function (Blueprint $table) {
            $table->dropForeign('fk_evnov_novedad');
        });
    }
};
