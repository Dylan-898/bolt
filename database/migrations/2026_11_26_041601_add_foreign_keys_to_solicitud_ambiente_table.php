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
        Schema::table('solicitud_ambiente', function (Blueprint $table) {
            $table->foreign(['id_ambiente'], 'fk_sa_ambiente')->references(['id_ambiente'])->on('ambiente')->onUpdate('cascade')->onDelete('restrict');
            $table->foreign(['id_solicitud'], 'fk_sa_solicitud')->references(['id_solicitud'])->on('solicitud')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('solicitud_ambiente', function (Blueprint $table) {
            $table->dropForeign('fk_sa_ambiente');
            $table->dropForeign('fk_sa_solicitud');
        });
    }
};
