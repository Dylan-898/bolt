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
        Schema::table('notificacion', function (Blueprint $table) {
            $table->foreign(['id_solicitud'], 'fk_notif_solicitud')->references(['id_solicitud'])->on('solicitud')->onUpdate('cascade')->onDelete('set null');
            $table->foreign(['id_usuario'], 'fk_notif_usuario')->references(['id_usuario'])->on('usuario')->onUpdate('cascade')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('notificacion', function (Blueprint $table) {
            $table->dropForeign('fk_notif_solicitud');
            $table->dropForeign('fk_notif_usuario');
        });
    }
};
