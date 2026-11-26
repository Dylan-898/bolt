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
        Schema::create('evidencia_novedad', function (Blueprint $table) {
            $table->integer('id_evidencia', true);
            $table->integer('id_novedad')->index('fk_evnov_novedad');
            $table->string('ruta_archivo');
            $table->dateTime('fecha_carga')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('evidencia_novedad');
    }
};
