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
        Schema::table('evidencia_solicitud', function (Blueprint $table) {
            $table->foreign(['id_solicitud'], 'fk_evsol_solicitud')->references(['id_solicitud'])->on('solicitud')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('evidencia_solicitud', function (Blueprint $table) {
            $table->dropForeign('fk_evsol_solicitud');
        });
    }
};
