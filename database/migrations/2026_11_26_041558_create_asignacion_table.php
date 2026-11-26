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
        Schema::create('asignacion', function (Blueprint $table) {
            $table->integer('id_asignacion', true);
            $table->integer('id_solicitud')->index('fk_asig_solicitud');
            $table->integer('id_usuario_asigna')->index('fk_asig_asigna');
            $table->integer('id_usuario_atiende')->index('fk_asig_atiende');
            $table->dateTime('fecha_asignacion')->useCurrent();
            $table->string('estado_asignacion', 20)->default('activa');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('asignacion');
    }
};
