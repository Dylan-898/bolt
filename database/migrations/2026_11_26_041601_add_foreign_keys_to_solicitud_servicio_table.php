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
        Schema::table('solicitud_servicio', function (Blueprint $table) {
            $table->foreign(['id_servicio'], 'fk_ss_servicio')->references(['id_servicio'])->on('servicio')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_solicitud'], 'fk_ss_solicitud')->references(['id_solicitud'])->on('solicitud')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('solicitud_servicio', function (Blueprint $table) {
            $table->dropForeign('fk_ss_servicio');
            $table->dropForeign('fk_ss_solicitud');
        });
    }
};
