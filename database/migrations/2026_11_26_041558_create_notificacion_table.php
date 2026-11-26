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
        Schema::create('notificacion', function (Blueprint $table) {
            $table->integer('id_notificacion', true);
            $table->integer('id_usuario')->index('fk_notif_usuario');
            $table->integer('id_solicitud')->nullable()->index('fk_notif_solicitud');
            $table->dateTime('fecha')->useCurrent();
            $table->string('mensaje');
            $table->string('estado', 20)->default('no_leida');
            $table->string('tipo', 30);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notificacion');
    }
};
